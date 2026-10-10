using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;

namespace MeowletEducation
{
    // JSON API behind the course builder (AdminCourse.aspx). A course's
    // chapters are its CourseLessons rows; what is inside a chapter are its
    // LessonBlocks rows.
    //   GET  ?courseId=N                     the course with its chapters and blocks
    //   POST action=addChapter               courseId, title
    //        action=updateChapter            courseId, id, title, minutes
    //        action=deleteChapter            courseId, id
    //        action=addBlock                 courseId, chapterId, type (Text|Media|Quiz)
    //        action=updateBlock              courseId, id, body, mediaKind, mediaUrl
    //        action=deleteBlock              courseId, id
    //        action=reorder                  courseId, layout = {"chapters":[id,...],"blocks":{"chapterId":[id,...]}}
    //        action=upload                   courseId, kind (Image|Video), file
    // Admins only. POSTs must carry X-Requested-With, which a plain cross-site
    // form can't send.
    public class AdminCourseApi : IHttpHandler, IRequiresSessionState
    {
        private static readonly string[] BlockTypes = { "Text", "Media", "Quiz" };

        public bool IsReusable { get { return false; } }

        private static string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString; }
        }

        // An error the admin should see, sent back as { error } with a status.
        private class ApiError : Exception
        {
            public readonly int Status;
            public ApiError(int status, string message) : base(message) { Status = status; }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            try
            {
                if (!IsAdmin(context)) throw new ApiError(401, "Log in as an admin.");

                var req = context.Request;
                int courseId = Int(req.HttpMethod == "GET" ? req.QueryString["courseId"] : req.Form["courseId"], "course");

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    EnsureCourse(conn, courseId);

                    if (req.HttpMethod == "GET")
                    {
                        Write(context, Load(conn, courseId));
                        return;
                    }

                    if (req.HttpMethod != "POST" || req.Headers["X-Requested-With"] != "fetch")
                        throw new ApiError(400, "Unsupported request.");

                    object result;
                    switch (req.Form["action"])
                    {
                        case "addChapter": result = AddChapter(conn, courseId, req.Form["title"]); break;
                        case "updateChapter": result = UpdateChapter(conn, courseId, req.Form); break;
                        case "deleteChapter": result = DeleteChapter(conn, courseId, Int(req.Form["id"], "chapter")); break;
                        case "addBlock": result = AddBlock(conn, courseId, Int(req.Form["chapterId"], "chapter"), req.Form["type"]); break;
                        case "updateBlock": result = UpdateBlock(conn, courseId, req.Form); break;
                        case "deleteBlock": result = DeleteBlock(conn, courseId, Int(req.Form["id"], "block")); break;
                        case "reorder": result = Reorder(conn, courseId, req.Form["layout"]); break;
                        case "upload": result = Upload(req); break;
                        default: throw new ApiError(400, "Unknown action.");
                    }

                    Write(context, result);
                }
            }
            catch (ApiError ex)
            {
                Fail(context, ex.Status, ex.Message);
            }
            catch (SqlException)
            {
                Fail(context, 503, "The database could not be reached. Your last change wasn't saved.");
            }
        }

        private static bool IsAdmin(HttpContext context)
        {
            if (AdminDashboard.DevBypassAuth) return true;
            return context.Session["UserId"] != null &&
                string.Equals(Convert.ToString(context.Session["Role"]), "Admin", StringComparison.OrdinalIgnoreCase);
        }

        // ---------- Reading ----------

        private static object Load(SqlConnection conn, int courseId)
        {
            object course = null;
            using (var cmd = new SqlCommand(
                "SELECT CourseId, CourseCode, Title, IsPublished, ImageUrl FROM dbo.Courses WHERE CourseId = @Id", conn))
            {
                cmd.Parameters.AddWithValue("@Id", courseId);
                using (var r = cmd.ExecuteReader())
                {
                    r.Read();
                    course = new
                    {
                        id = r.GetInt32(0),
                        code = r.GetString(1),
                        title = r.GetString(2),
                        published = r.GetBoolean(3),
                        image = r.IsDBNull(4) ? null : r.GetString(4)
                    };
                }
            }

            var chapters = new List<Dictionary<string, object>>();
            var byId = new Dictionary<int, List<object>>();

            using (var cmd = new SqlCommand(
                "SELECT LessonId, Title, DurationMinutes FROM dbo.CourseLessons WHERE CourseId = @Id ORDER BY Position", conn))
            {
                cmd.Parameters.AddWithValue("@Id", courseId);
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        var blocks = new List<object>();
                        byId[r.GetInt32(0)] = blocks;
                        chapters.Add(new Dictionary<string, object>
                        {
                            { "id", r.GetInt32(0) },
                            { "title", r.GetString(1) },
                            { "minutes", r.GetInt32(2) },
                            { "blocks", blocks }
                        });
                    }
                }
            }

            using (var cmd = new SqlCommand(@"
SELECT b.BlockId, b.LessonId, b.BlockType, b.MediaKind, b.MediaUrl, b.Body
FROM dbo.LessonBlocks b
JOIN dbo.CourseLessons l ON l.LessonId = b.LessonId
WHERE l.CourseId = @Id
ORDER BY b.LessonId, b.Position, b.BlockId", conn))
            {
                cmd.Parameters.AddWithValue("@Id", courseId);
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read()) byId[r.GetInt32(1)].Add(BlockJson(r));
                }
            }

            return new { course = course, chapters = chapters };
        }

        private static object BlockJson(SqlDataReader r)
        {
            return new
            {
                id = r.GetInt32(0),
                type = r.GetString(2),
                mediaKind = r.IsDBNull(3) ? null : r.GetString(3),
                mediaUrl = r.IsDBNull(4) ? null : r.GetString(4),
                body = r.IsDBNull(5) ? null : r.GetString(5)
            };
        }

        // ---------- Chapters ----------

        private static object AddChapter(SqlConnection conn, int courseId, string title)
        {
            title = Clean(title, 200);
            if (title.Length == 0) title = "Untitled chapter";

            using (var cmd = new SqlCommand(@"
INSERT INTO dbo.CourseLessons (CourseId, Position, Title, ContentType, DurationMinutes)
OUTPUT INSERTED.LessonId, INSERTED.Title, INSERTED.DurationMinutes
VALUES (@Course, (SELECT ISNULL(MAX(Position), 0) + 1 FROM dbo.CourseLessons WHERE CourseId = @Course),
        @Title, 'Article', 10);", conn))
            {
                cmd.Parameters.AddWithValue("@Course", courseId);
                cmd.Parameters.AddWithValue("@Title", title);

                object chapter;
                using (var r = cmd.ExecuteReader())
                {
                    r.Read();
                    chapter = new { id = r.GetInt32(0), title = r.GetString(1), minutes = r.GetInt32(2), blocks = new object[0] };
                }

                SyncLessonCount(conn, courseId);
                return chapter;
            }
        }

        private static object UpdateChapter(SqlConnection conn, int courseId, System.Collections.Specialized.NameValueCollection form)
        {
            int id = Int(form["id"], "chapter");
            string title = Clean(form["title"], 200);
            int minutes;

            if (title.Length == 0) throw new ApiError(400, "A chapter needs a title.");
            if (!int.TryParse(form["minutes"], out minutes) || minutes < 1 || minutes > 600)
                throw new ApiError(400, "Minutes must be a whole number from 1 to 600.");

            using (var cmd = new SqlCommand(
                "UPDATE dbo.CourseLessons SET Title = @Title, DurationMinutes = @Minutes WHERE LessonId = @Id AND CourseId = @Course", conn))
            {
                cmd.Parameters.AddWithValue("@Title", title);
                cmd.Parameters.AddWithValue("@Minutes", minutes);
                cmd.Parameters.AddWithValue("@Id", id);
                cmd.Parameters.AddWithValue("@Course", courseId);
                if (cmd.ExecuteNonQuery() == 0) throw new ApiError(404, "That chapter no longer exists.");
            }

            return new { ok = true };
        }

        private static object DeleteChapter(SqlConnection conn, int courseId, int id)
        {
            var files = new List<string>();
            using (var cmd = new SqlCommand(@"
SELECT b.MediaUrl FROM dbo.LessonBlocks b
JOIN dbo.CourseLessons l ON l.LessonId = b.LessonId
WHERE b.LessonId = @Id AND l.CourseId = @Course AND b.MediaUrl IS NOT NULL", conn))
            {
                cmd.Parameters.AddWithValue("@Id", id);
                cmd.Parameters.AddWithValue("@Course", courseId);
                using (var r = cmd.ExecuteReader()) while (r.Read()) files.Add(r.GetString(0));
            }

            // Blocks and learners' progress on this chapter cascade.
            using (var cmd = new SqlCommand(
                "DELETE FROM dbo.CourseLessons WHERE LessonId = @Id AND CourseId = @Course", conn))
            {
                cmd.Parameters.AddWithValue("@Id", id);
                cmd.Parameters.AddWithValue("@Course", courseId);
                if (cmd.ExecuteNonQuery() == 0) throw new ApiError(404, "That chapter no longer exists.");
            }

            foreach (string f in files) LessonMedia.Delete(f);
            SyncLessonCount(conn, courseId);
            return new { ok = true };
        }

        // ---------- Blocks ----------

        private static object AddBlock(SqlConnection conn, int courseId, int chapterId, string type)
        {
            if (Array.IndexOf(BlockTypes, type) < 0) throw new ApiError(400, "Unknown block type.");
            EnsureChapter(conn, courseId, chapterId);

            string body = type == "Quiz"
                ? "{\"questions\":[{\"q\":\"\",\"options\":[\"\",\"\"],\"answer\":0}]}"
                : null;

            using (var cmd = new SqlCommand(@"
INSERT INTO dbo.LessonBlocks (LessonId, Position, BlockType, MediaKind, Body)
OUTPUT INSERTED.BlockId, INSERTED.LessonId, INSERTED.BlockType, INSERTED.MediaKind, INSERTED.MediaUrl, INSERTED.Body
VALUES (@Lesson, (SELECT ISNULL(MAX(Position), 0) + 1 FROM dbo.LessonBlocks WHERE LessonId = @Lesson),
        @Type, @Kind, @Body);", conn))
            {
                cmd.Parameters.AddWithValue("@Lesson", chapterId);
                cmd.Parameters.AddWithValue("@Type", type);
                cmd.Parameters.AddWithValue("@Kind", type == "Media" ? (object)"Image" : DBNull.Value);
                cmd.Parameters.AddWithValue("@Body", (object)body ?? DBNull.Value);
                using (var r = cmd.ExecuteReader())
                {
                    r.Read();
                    return BlockJson(r);
                }
            }
        }

        private static object UpdateBlock(SqlConnection conn, int courseId, System.Collections.Specialized.NameValueCollection form)
        {
            int id = Int(form["id"], "block");
            string type, oldUrl;

            using (var cmd = new SqlCommand(@"
SELECT b.BlockType, b.MediaUrl FROM dbo.LessonBlocks b
JOIN dbo.CourseLessons l ON l.LessonId = b.LessonId
WHERE b.BlockId = @Id AND l.CourseId = @Course", conn))
            {
                cmd.Parameters.AddWithValue("@Id", id);
                cmd.Parameters.AddWithValue("@Course", courseId);
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) throw new ApiError(404, "That item no longer exists.");
                    type = r.GetString(0);
                    oldUrl = r.IsDBNull(1) ? null : r.GetString(1);
                }
            }

            string body = form["body"] ?? string.Empty;
            string kind = null, url = null;

            if (type == "Quiz")
            {
                body = CleanQuiz(body);
            }
            else if (body.Length > 20000)
            {
                throw new ApiError(400, "Keep this to 20,000 characters.");
            }

            if (type == "Media")
            {
                kind = form["mediaKind"] == "Video" ? "Video" : "Image";
                url = Clean(form["mediaUrl"], 400);
                if (url.Length > 0 && !IsAllowedUrl(url))
                    throw new ApiError(400, "Use a link starting with https:// or upload a file.");
                if (url.Length == 0) url = null;
            }

            using (var cmd = new SqlCommand(
                "UPDATE dbo.LessonBlocks SET Body = @Body, MediaKind = @Kind, MediaUrl = @Url WHERE BlockId = @Id", conn))
            {
                cmd.Parameters.AddWithValue("@Body", body.Length > 0 ? (object)body : DBNull.Value);
                cmd.Parameters.AddWithValue("@Kind", (object)kind ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Url", (object)url ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Id", id);
                cmd.ExecuteNonQuery();
            }

            if (oldUrl != null && oldUrl != url) LessonMedia.Delete(oldUrl);
            return new { ok = true, body = body };
        }

        private static object DeleteBlock(SqlConnection conn, int courseId, int id)
        {
            using (var cmd = new SqlCommand(@"
DELETE b OUTPUT deleted.MediaUrl
FROM dbo.LessonBlocks b
JOIN dbo.CourseLessons l ON l.LessonId = b.LessonId
WHERE b.BlockId = @Id AND l.CourseId = @Course", conn))
            {
                cmd.Parameters.AddWithValue("@Id", id);
                cmd.Parameters.AddWithValue("@Course", courseId);
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) throw new ApiError(404, "That item no longer exists.");
                    if (!r.IsDBNull(0)) LessonMedia.Delete(r.GetString(0));
                }
            }

            return new { ok = true };
        }

        // ---------- Order (drag and drop) ----------

        private class Layout
        {
            public List<int> chapters { get; set; }
            public Dictionary<string, List<int>> blocks { get; set; }
        }

        // Saves the whole order in one go: chapter positions, and which chapter
        // each block sits in and where. Blocks can move between chapters.
        private static object Reorder(SqlConnection conn, int courseId, string json)
        {
            Layout layout;
            try
            {
                layout = new JavaScriptSerializer().Deserialize<Layout>(json ?? string.Empty);
            }
            catch (ArgumentException)
            {
                throw new ApiError(400, "The new order couldn't be read.");
            }

            if (layout == null || layout.chapters == null) throw new ApiError(400, "The new order couldn't be read.");

            var chapterIds = new HashSet<int>();
            var blockIds = new HashSet<int>();
            using (var cmd = new SqlCommand(@"
SELECT l.LessonId, b.BlockId FROM dbo.CourseLessons l
LEFT JOIN dbo.LessonBlocks b ON b.LessonId = l.LessonId
WHERE l.CourseId = @Course", conn))
            {
                cmd.Parameters.AddWithValue("@Course", courseId);
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        chapterIds.Add(r.GetInt32(0));
                        if (!r.IsDBNull(1)) blockIds.Add(r.GetInt32(1));
                    }
                }
            }

            // The order must name exactly this course's chapters and blocks.
            var sentBlocks = (layout.blocks ?? new Dictionary<string, List<int>>()).SelectMany(kv => kv.Value ?? new List<int>()).ToList();
            if (!chapterIds.SetEquals(layout.chapters) || layout.chapters.Count != chapterIds.Count ||
                !blockIds.SetEquals(sentBlocks) || sentBlocks.Count != blockIds.Count)
                throw new ApiError(409, "The course changed in another window. Reload to see the latest version.");

            using (var tx = conn.BeginTransaction())
            {
                // Park positions out of the way first: (CourseId, Position) is unique.
                using (var park = new SqlCommand(
                    "UPDATE dbo.CourseLessons SET Position = Position + 100000 WHERE CourseId = @Course", conn, tx))
                {
                    park.Parameters.AddWithValue("@Course", courseId);
                    park.ExecuteNonQuery();
                }

                for (int i = 0; i < layout.chapters.Count; i++)
                {
                    using (var cmd = new SqlCommand(
                        "UPDATE dbo.CourseLessons SET Position = @Pos WHERE LessonId = @Id", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@Pos", i + 1);
                        cmd.Parameters.AddWithValue("@Id", layout.chapters[i]);
                        cmd.ExecuteNonQuery();
                    }
                }

                foreach (var kv in layout.blocks ?? new Dictionary<string, List<int>>())
                {
                    int lessonId;
                    if (!int.TryParse(kv.Key, out lessonId) || !chapterIds.Contains(lessonId)) continue;

                    for (int i = 0; i < kv.Value.Count; i++)
                    {
                        using (var cmd = new SqlCommand(
                            "UPDATE dbo.LessonBlocks SET LessonId = @Lesson, Position = @Pos WHERE BlockId = @Id", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@Lesson", lessonId);
                            cmd.Parameters.AddWithValue("@Pos", i + 1);
                            cmd.Parameters.AddWithValue("@Id", kv.Value[i]);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                tx.Commit();
            }

            return new { ok = true };
        }

        // ---------- Uploads ----------

        private static object Upload(HttpRequest req)
        {
            string kind = req.Form["kind"] == "Video" ? "Video" : "Image";
            string error;
            string url = LessonMedia.Save(req.Files["file"], kind, out error);
            if (url == null) throw new ApiError(400, error);
            return new { url = url, kind = kind };
        }

        // ---------- Helpers ----------

        private static void EnsureCourse(SqlConnection conn, int courseId)
        {
            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.Courses WHERE CourseId = @Id", conn))
            {
                cmd.Parameters.AddWithValue("@Id", courseId);
                if ((int)cmd.ExecuteScalar() == 0) throw new ApiError(404, "That course no longer exists.");
            }
        }

        private static void EnsureChapter(SqlConnection conn, int courseId, int chapterId)
        {
            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.CourseLessons WHERE LessonId = @Id AND CourseId = @Course", conn))
            {
                cmd.Parameters.AddWithValue("@Id", chapterId);
                cmd.Parameters.AddWithValue("@Course", courseId);
                if ((int)cmd.ExecuteScalar() == 0) throw new ApiError(404, "That chapter no longer exists.");
            }
        }

        // Courses.Lessons follows the number of chapters, so cards and learner
        // progress stay right without anyone typing a count.
        private static void SyncLessonCount(SqlConnection conn, int courseId)
        {
            using (var cmd = new SqlCommand(
                "UPDATE dbo.Courses SET Lessons = (SELECT COUNT(*) FROM dbo.CourseLessons WHERE CourseId = @Id) WHERE CourseId = @Id", conn))
            {
                cmd.Parameters.AddWithValue("@Id", courseId);
                cmd.ExecuteNonQuery();
            }
        }

        private class Quiz
        {
            public List<Question> questions { get; set; }
        }

        private class Question
        {
            public string q { get; set; }
            public List<string> options { get; set; }
            public int answer { get; set; }
        }

        // Re-serialises the quiz so only the expected shape is stored.
        private static string CleanQuiz(string json)
        {
            Quiz quiz;
            try
            {
                quiz = new JavaScriptSerializer().Deserialize<Quiz>(json);
            }
            catch (ArgumentException)
            {
                throw new ApiError(400, "The quiz couldn't be read.");
            }

            var clean = new Quiz { questions = new List<Question>() };
            foreach (var q in (quiz == null ? null : quiz.questions) ?? new List<Question>())
            {
                var options = (q.options ?? new List<string>()).Take(6).Select(o => Clean(o, 300)).ToList();
                clean.questions.Add(new Question
                {
                    q = Clean(q.q, 500),
                    options = options,
                    answer = q.answer >= 0 && q.answer < options.Count ? q.answer : 0
                });
                if (clean.questions.Count == 50) break;
            }

            return new JavaScriptSerializer().Serialize(clean);
        }

        private static bool IsAllowedUrl(string url)
        {
            if (url.StartsWith(LessonMedia.Folder, StringComparison.OrdinalIgnoreCase)) return true;
            Uri uri;
            return Uri.TryCreate(url, UriKind.Absolute, out uri) && (uri.Scheme == Uri.UriSchemeHttps || uri.Scheme == Uri.UriSchemeHttp);
        }

        private static string Clean(string value, int max)
        {
            value = (value ?? string.Empty).Trim();
            return value.Length > max ? value.Substring(0, max) : value;
        }

        private static int Int(string value, string what)
        {
            int n;
            if (!int.TryParse(value, out n)) throw new ApiError(400, "Missing " + what + ".");
            return n;
        }

        private static void Write(HttpContext context, object value)
        {
            context.Response.Write(new JavaScriptSerializer().Serialize(value));
        }

        private static void Fail(HttpContext context, int status, string message)
        {
            context.Response.StatusCode = status;
            context.Response.TrySkipIisCustomErrors = true;
            Write(context, new { error = message });
        }
    }
}
