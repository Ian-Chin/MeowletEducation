using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace MeowletEducation
{
    public partial class Landing : Page
    {
        private static string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString; }
        }

        // JSON for the preview modal (courses + lesson outlines)
        protected string CoursePreviewJson = "[]";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            BindCourses();
        }

        private void BindCourses()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(@"
SELECT TOP 4
       c.CourseId, c.CourseCode, c.Title, c.Category, c.Level,
       ISNULL(c.Description, N'') AS Description,
       ISNULL(t.FullName, N'Meowlet team') AS TutorName,
       (SELECT COUNT(*) FROM dbo.CourseLessons l WHERE l.CourseId = c.CourseId) AS LessonCount
FROM dbo.Courses c
LEFT JOIN dbo.Users t ON t.UserId = c.TutorId
WHERE c.IsPublished = 1
ORDER BY c.Category, c.Level, c.Title;", conn))
                    {
                        var table = new DataTable();
                        using (var adapter = new SqlDataAdapter(cmd))
                            adapter.Fill(table);

                        rptCourses.DataSource = table;
                        rptCourses.DataBind();
                        pnlNoCourses.Visible = table.Rows.Count == 0;

                        var list = new List<object>();
                        foreach (DataRow row in table.Rows)
                        {
                            int courseId = Convert.ToInt32(row["CourseId"]);
                            var lessons = new List<object>();

                            using (var lessonCmd = new SqlCommand(@"
SELECT Position, Title, ContentType, DurationMinutes
FROM dbo.CourseLessons
WHERE CourseId = @Id
ORDER BY Position;", conn))
                            {
                                lessonCmd.Parameters.AddWithValue("@Id", courseId);
                                using (var r = lessonCmd.ExecuteReader())
                                {
                                    while (r.Read())
                                    {
                                        lessons.Add(new
                                        {
                                            position = r.GetInt32(0),
                                            title = r.GetString(1),
                                            contentType = r.GetString(2),
                                            durationMinutes = r.GetInt32(3)
                                        });
                                    }
                                }
                            }

                            list.Add(new
                            {
                                id = courseId,
                                code = Convert.ToString(row["CourseCode"]),
                                title = Convert.ToString(row["Title"]),
                                category = Convert.ToString(row["Category"]),
                                level = Convert.ToString(row["Level"]),
                                description = Convert.ToString(row["Description"]),
                                tutorName = Convert.ToString(row["TutorName"]),
                                lessonCount = Convert.ToInt32(row["LessonCount"]),
                                lessons = lessons
                            });
                        }

                        CoursePreviewJson = new JavaScriptSerializer().Serialize(list);
                    }
                }
            }
            catch (Exception ex)
            {
                rptCourses.DataSource = null;
                rptCourses.DataBind();
                pnlNoCourses.Visible = true;
                pnlNoCourses.Controls.Clear();
                pnlNoCourses.Controls.Add(new LiteralControl(
                    "<strong>Database error:</strong> " + Server.HtmlEncode(ex.Message)));
                CoursePreviewJson = "[]";
            }
        }

        protected static string Html(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value ?? ""));
        }

        protected static string ShortDesc(object value)
        {
            string s = Convert.ToString(value ?? "");
            if (s.Length <= 100) return HttpUtility.HtmlEncode(s);
            return HttpUtility.HtmlEncode(s.Substring(0, 100).TrimEnd()) + "…";
        }
    }
}