using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MeowletEducation
{
    public partial class MemberDashboard : Page
    {
        private const string MyCoursesSql = @"
SELECT c.CourseId, c.CourseCode, c.Title, c.Category, c.Level, c.Lessons,
       e.EnrolledAt, e.CompletedAt,
       (SELECT COUNT(*) FROM dbo.CourseLessons l WHERE l.CourseId = c.CourseId) AS LessonRows,
       (SELECT COUNT(*) FROM dbo.LessonProgress p
          JOIN dbo.CourseLessons l ON l.LessonId = p.LessonId
         WHERE p.UserId = e.UserId AND l.CourseId = c.CourseId) AS DoneLessons
FROM dbo.Enrollments e
JOIN dbo.Courses c ON c.CourseId = e.CourseId
WHERE e.UserId = @Id
ORDER BY e.EnrolledAt DESC;";

        private const string CatalogSql = @"
SELECT c.CourseId, c.CourseCode, c.Title, c.Category, c.Level, c.Lessons, c.Description, c.ImageUrl,
       ISNULL(t.FullName, N'Meowlet team') AS TutorName,
       (SELECT COUNT(*) FROM dbo.Enrollments x WHERE x.CourseId = c.CourseId) AS LearnerCount
FROM dbo.Courses c
LEFT JOIN dbo.Users t ON t.UserId = c.TutorId
WHERE c.IsPublished = 1
  AND NOT EXISTS (SELECT 1 FROM dbo.Enrollments e WHERE e.CourseId = c.CourseId AND e.UserId = @Id)
ORDER BY c.Title;";

        private const string ProfileSql = @"
SELECT u.FullName, u.Email, u.Role, u.CreatedAt,
       (SELECT AnswerValue FROM dbo.OnboardingAnswers a WHERE a.UserId = u.UserId AND a.QuestionKey = 'age_range') AS AgeRange,
       (SELECT AnswerValue FROM dbo.OnboardingAnswers a WHERE a.UserId = u.UserId AND a.QuestionKey = 'experience_level') AS ExperienceLevel
FROM dbo.Users u
WHERE u.UserId = @Id;";

        private static string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString; }
        }

        private int UserId
        {
            get { return Convert.ToInt32(Session["UserId"]); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Must be logged in
            if (Session["UserId"] == null)
            {
                Response.Redirect("Signin.aspx");
                return;
            }

            // Admins have their own panel
            if (string.Equals(Convert.ToString(Session["Role"]), "Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("admindashboard.aspx");
                return;
            }
        }

        // Data is bound after the button handlers run, so every list
        // reflects the change the member just made.
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            BindData();
        }

        // ---------- Loading ----------

        private void BindData()
        {
            var courses = new DataTable();
            var catalog = new DataTable();
            var profile = new DataTable();

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    profile = Query(conn, ProfileSql, new SqlParameter("@Id", UserId));
                    courses = Query(conn, MyCoursesSql, new SqlParameter("@Id", UserId));
                    catalog = Query(conn, CatalogSql, new SqlParameter("@Id", UserId));
                }
            }
            catch (SqlException)
            {
                ShowFlash("The database could not be reached. Run App_Data/CreateDatabase.sql, then reload.", false);
            }

            BindProfile(profile);
            BindCourses(courses);

            rptCatalog.DataSource = catalog;
            rptCatalog.DataBind();
            phNoCatalog.Visible = catalog.Rows.Count == 0;
        }

        private static DataTable Query(SqlConnection conn, string sql, params SqlParameter[] parameters)
        {
            var table = new DataTable();
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddRange(parameters);
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(table);
                }
            }
            return table;
        }

        private void BindProfile(DataTable profile)
        {
            string fullName = Convert.ToString(Session["FullName"]);
            string email = Convert.ToString(Session["Email"]);
            string role = Convert.ToString(Session["Role"]);

            if (profile.Rows.Count > 0)
            {
                DataRow row = profile.Rows[0];
                fullName = Convert.ToString(row["FullName"]);
                email = Convert.ToString(row["Email"]);
                role = Convert.ToString(row["Role"]);
                litProfileJoined.Text = FormatDate(row["CreatedAt"]);
                litProfileAge.Text = Server.HtmlEncode(AnswerLabel(row["AgeRange"]));
                litProfileLevel.Text = Server.HtmlEncode(AnswerLabel(row["ExperienceLevel"]));
            }

            if (string.IsNullOrWhiteSpace(fullName)) fullName = "Member";
            if (string.IsNullOrWhiteSpace(role)) role = "Student";

            // Greeting uses the first name only, e.g. "Welcome back, Aisha".
            string firstName = fullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries)[0];

            litWelcomeName.Text = Server.HtmlEncode(firstName);
            litMemberNameJs.Text = HttpUtility.JavaScriptStringEncode(firstName);
            litMemberName.Text = Server.HtmlEncode(fullName);
            litMenuName.Text = Server.HtmlEncode(fullName);
            litMenuEmail.Text = Server.HtmlEncode(email);
            litProfileName.Text = Server.HtmlEncode(fullName);
            litProfileEmail.Text = Server.HtmlEncode(email);
            litRole.Text = Server.HtmlEncode(role);
            litAvatar.Text = Server.HtmlEncode(fullName.Substring(0, 1).ToUpperInvariant());
        }

        private void BindCourses(DataTable courses)
        {
            courses.Columns.Add("TotalLessons", typeof(int));
            courses.Columns.Add("Percent", typeof(int));
            courses.Columns.Add("State", typeof(string));

            int completed = 0;

            foreach (DataRow row in courses.Rows)
            {
                // Lessons added to the course win; the admin's planned count is the fallback.
                int total = Convert.ToInt32(row["LessonRows"]);
                if (total == 0) total = Convert.ToInt32(row["Lessons"]);

                int done = Math.Min(Convert.ToInt32(row["DoneLessons"]), total);
                bool isDone = row["CompletedAt"] != DBNull.Value;

                row["TotalLessons"] = total;
                row["Percent"] = isDone ? 100 : (total == 0 ? 0 : done * 100 / total);
                row["State"] = isDone ? "completed" : "progress";

                if (isDone) completed++;
            }

            int enrolled = courses.Rows.Count;
            litStatEnrolled.Text = enrolled.ToString("N0");
            litStatCompleted.Text = completed.ToString("N0");
            litStatInProgress.Text = (enrolled - completed).ToString("N0");

            rptMyCourses.DataSource = courses;
            rptMyCourses.DataBind();
            phNoCourses.Visible = enrolled == 0;

            // five most recent for the dashboard
            DataTable recent = courses.Clone();
            for (int i = 0; i < courses.Rows.Count && i < 5; i++)
            {
                recent.ImportRow(courses.Rows[i]);
            }
            rptRecentCourses.DataSource = recent;
            rptRecentCourses.DataBind();
            phNoRecent.Visible = recent.Rows.Count == 0;
        }

        // ---------- Actions ----------

        protected void rptMyCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Drop") return;
            hdnPane.Value = "pane-courses";

            string result = Execute(@"
DELETE FROM dbo.Enrollments WHERE UserId = @User AND CourseId = @Course;
SELECT CASE WHEN @@ROWCOUNT = 0 THEN N''
            ELSE N'You dropped ' + (SELECT Title FROM dbo.Courses WHERE CourseId = @Course) + N'.' END;",
                new SqlParameter("@User", UserId),
                new SqlParameter("@Course", Convert.ToInt32(e.CommandArgument)));

            if (result != null) ShowFlash(result.Length == 0 ? "That course was already dropped." : result, true);
        }

        protected void rptCatalog_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Enrol") return;

            // Only published courses, and only once per member.
            string result = Execute(@"
INSERT INTO dbo.Enrollments (UserId, CourseId)
SELECT @User, c.CourseId
FROM dbo.Courses c
WHERE c.CourseId = @Course AND c.IsPublished = 1
  AND NOT EXISTS (SELECT 1 FROM dbo.Enrollments x WHERE x.UserId = @User AND x.CourseId = c.CourseId);
SELECT CASE WHEN @@ROWCOUNT = 0 THEN N''
            ELSE N'You enrolled in ' + (SELECT Title FROM dbo.Courses WHERE CourseId = @Course) + N'.' END;",
                new SqlParameter("@User", UserId),
                new SqlParameter("@Course", Convert.ToInt32(e.CommandArgument)));

            if (result == null) return;

            if (result.Length == 0)
            {
                hdnPane.Value = "pane-catalog";
                ShowFlash("That course isn't open for enrolment any more.", false);
            }
            else
            {
                // land on the list so the new course is visible
                hdnPane.Value = "pane-courses";
                ShowFlash(result, true);
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Signin.aspx");
        }

        // Runs one statement and returns the first column of its OUTPUT row.
        private string Execute(string sql, params SqlParameter[] parameters)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddRange(parameters);
                    conn.Open();
                    return Convert.ToString(cmd.ExecuteScalar());
                }
            }
            catch (SqlException)
            {
                ShowFlash("That change could not be saved. Check the database connection.", false);
                return null;
            }
        }

        private void ShowFlash(string message, bool ok)
        {
            litFlash.Text = "<p class=\"md-flash" + (ok ? "" : " md-flash--error") + "\" role=\"status\">" +
                Server.HtmlEncode(message) + "</p>";
        }

        // ---------- Template helpers ----------

        // Onboarding stores keys like "18_24", "under_18" or "some_basics".
        private static string AnswerLabel(object value)
        {
            string raw = value == null || value == DBNull.Value ? "" : Convert.ToString(value);
            if (raw.Length == 0) return "Not set";

            string[] parts = raw.Split('_');
            if (parts.Length == 2 && char.IsDigit(parts[0][0]) && char.IsDigit(parts[1][0]))
                return parts[0] + " - " + parts[1];

            string text = raw.Replace('_', ' ');
            return char.ToUpperInvariant(text[0]) + text.Substring(1);
        }

        protected static string FormatDate(object value)
        {
            return value == null || value == DBNull.Value
                ? string.Empty
                : Convert.ToDateTime(value).ToString("d MMM yyyy", CultureInfo.InvariantCulture);
        }

        protected static string Attr(object value)
        {
            return HttpUtility.HtmlAttributeEncode(Convert.ToString(value));
        }

        protected static string Html(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value));
        }
    }
}
