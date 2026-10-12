using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;

namespace MeowletEducation
{
    // Saves one finished AR activity (POST from assets/js/ar/ar-lesson.js):
    //   { lessonId, mode: "ar"|"card"|"3d", score: 0-100|null, summary, result: "<json>", seconds }
    // Stores it in ARActivityResults, marks the lesson done in LessonProgress and,
    // when it was the last lesson, completes the enrollment.
    // Answers { ok: true, courseFinished: bool } or { ok: false, error }.
    public class ArResult : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        private class Payload
        {
            public int lessonId { get; set; }
            public string mode { get; set; }
            public int? score { get; set; }
            public string summary { get; set; }
            public string result { get; set; }
            public int? seconds { get; set; }
        }

        public void ProcessRequest(HttpContext context)
        {
            var request = context.Request;

            if (request.HttpMethod != "POST")
            {
                Answer(context, 405, false, "Use POST.");
                return;
            }

            // A custom header can't be sent cross-site without a CORS preflight,
            // so this stops other websites from posting results for a signed-in learner.
            if (request.Headers["X-Requested-With"] != "MeowletAR")
            {
                Answer(context, 400, false, "Missing request header.");
                return;
            }

            if (context.Session == null || context.Session["UserId"] == null)
            {
                Answer(context, 401, false, "Your session has ended. Sign in again.");
                return;
            }
            int userId = Convert.ToInt32(context.Session["UserId"]);

            Payload p;
            try
            {
                string body;
                using (var reader = new StreamReader(request.InputStream))
                    body = reader.ReadToEnd();
                if (body.Length > 60000) throw new ArgumentException("too large");
                p = new JavaScriptSerializer().Deserialize<Payload>(body);
            }
            catch (Exception)
            {
                Answer(context, 400, false, "The result could not be read.");
                return;
            }

            if (p == null || p.lessonId <= 0 || (p.mode != "ar" && p.mode != "card" && p.mode != "camera" && p.mode != "3d") ||
                (p.score.HasValue && (p.score < 0 || p.score > 100)))
            {
                Answer(context, 400, false, "The result is incomplete.");
                return;
            }

            string summary = (p.summary ?? "").Trim();
            if (summary.Length > 400) summary = summary.Substring(0, 400);
            string json = p.result ?? "";
            if (json.Length > 40000) json = json.Substring(0, 40000);
            int? seconds = p.seconds.HasValue ? Math.Max(0, Math.Min(86400, p.seconds.Value)) : (int?)null;

            DbSchema.EnsureUpToDate();

            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;
                using (var conn = new SqlConnection(connStr))
                using (var cmd = new SqlCommand(@"
DECLARE @Course INT, @Scene NVARCHAR(50);

-- Only an AR lesson in a course this learner is enrolled in.
SELECT @Course = l.CourseId, @Scene = ISNULL(l.ARSceneKey, N'unknown')
FROM dbo.CourseLessons l
JOIN dbo.Enrollments e ON e.CourseId = l.CourseId AND e.UserId = @Me
WHERE l.LessonId = @Lesson AND l.ContentType = 'AR';

IF @Course IS NULL BEGIN SELECT -1; RETURN; END;

SET XACT_ABORT ON;
BEGIN TRANSACTION;

INSERT INTO dbo.ARActivityResults (UserId, LessonId, SceneKey, Mode, Score, Summary, ResultJson, Seconds)
VALUES (@Me, @Lesson, @Scene, @Mode, @Score, @Summary, @Json, @Seconds);

INSERT INTO dbo.LessonProgress (UserId, LessonId)
SELECT @Me, @Lesson
WHERE NOT EXISTS (SELECT 1 FROM dbo.LessonProgress WHERE UserId = @Me AND LessonId = @Lesson);

UPDATE dbo.Enrollments SET CompletedAt = SYSUTCDATETIME()
WHERE UserId = @Me AND CourseId = @Course AND CompletedAt IS NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.CourseLessons l
                  WHERE l.CourseId = @Course
                    AND NOT EXISTS (SELECT 1 FROM dbo.LessonProgress x WHERE x.UserId = @Me AND x.LessonId = l.LessonId));

COMMIT TRANSACTION;

SELECT CASE WHEN EXISTS (SELECT 1 FROM dbo.Enrollments
                         WHERE UserId = @Me AND CourseId = @Course AND CompletedAt IS NOT NULL) THEN 1 ELSE 0 END;", conn))
                {
                    cmd.Parameters.AddWithValue("@Me", userId);
                    cmd.Parameters.AddWithValue("@Lesson", p.lessonId);
                    cmd.Parameters.AddWithValue("@Mode", p.mode);
                    cmd.Parameters.Add(new SqlParameter("@Score", SqlDbType.TinyInt) { Value = p.score.HasValue ? (object)(byte)p.score.Value : DBNull.Value });
                    cmd.Parameters.Add(new SqlParameter("@Summary", SqlDbType.NVarChar, 400) { Value = summary.Length == 0 ? (object)DBNull.Value : summary });
                    cmd.Parameters.Add(new SqlParameter("@Json", SqlDbType.NVarChar, -1) { Value = json.Length == 0 ? (object)DBNull.Value : json });
                    cmd.Parameters.Add(new SqlParameter("@Seconds", SqlDbType.Int) { Value = seconds.HasValue ? (object)seconds.Value : DBNull.Value });
                    conn.Open();

                    int outcome = Convert.ToInt32(cmd.ExecuteScalar());
                    if (outcome < 0)
                    {
                        Answer(context, 403, false, "You need to be enrolled in this course to save a result.");
                        return;
                    }

                    context.Response.ContentType = "application/json";
                    context.Response.Write(new JavaScriptSerializer().Serialize(new { ok = true, courseFinished = outcome == 1 }));
                }
            }
            catch (SqlException ex)
            {
                Answer(context, 500, false, "Database error: " + ex.Message);
            }
        }

        private static void Answer(HttpContext context, int status, bool ok, string error)
        {
            context.Response.StatusCode = status;
            context.Response.ContentType = "application/json";
            context.Response.TrySkipIisCustomErrors = true;
            context.Response.Write(new JavaScriptSerializer().Serialize(new { ok, error }));
        }
    }
}
