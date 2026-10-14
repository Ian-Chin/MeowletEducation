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
        // Each enrolment with its progress and the first lesson not yet done.
        private const string MyCoursesSql = @"
SELECT c.CourseId, c.CourseCode, c.Title, c.Category, c.Level, c.Lessons, c.ImageUrl,
       ISNULL(t.FullName, N'Meowlet team') AS TutorName,
       e.EnrolledAt, e.CompletedAt,
       (SELECT COUNT(*) FROM dbo.CourseLessons l WHERE l.CourseId = c.CourseId) AS LessonRows,
       (SELECT COUNT(*) FROM dbo.LessonProgress p
          JOIN dbo.CourseLessons l ON l.LessonId = p.LessonId
         WHERE p.UserId = e.UserId AND l.CourseId = c.CourseId) AS DoneLessons,
       nx.LessonId AS NextLessonId, nx.Position AS NextPosition, nx.Title AS NextTitle
FROM dbo.Enrollments e
JOIN dbo.Courses c ON c.CourseId = e.CourseId
LEFT JOIN dbo.Users t ON t.UserId = c.TutorId
OUTER APPLY (SELECT TOP 1 l.LessonId, l.Position, l.Title
               FROM dbo.CourseLessons l
              WHERE l.CourseId = c.CourseId
                AND NOT EXISTS (SELECT 1 FROM dbo.LessonProgress p WHERE p.UserId = e.UserId AND p.LessonId = l.LessonId)
              ORDER BY l.Position) nx
WHERE e.UserId = @Id
ORDER BY e.EnrolledAt DESC;";

        // Tutor sessions the member has booked that haven't started yet.
        private const string SessionsSql = @"
SELECT s.SessionId, s.StartsAt, s.Status,
       t.FullName AS TutorName,
       ISNULL(g.DisplayLabel, N'General help') AS Topic
FROM dbo.TutoringSessions s
JOIN dbo.Users t ON t.UserId = s.TutorId
LEFT JOIN dbo.Tags g ON g.TagId = s.TagId
WHERE s.StudentId = @Id
  AND s.Status IN ('Requested', 'Confirmed')
  AND s.StartsAt > SYSUTCDATETIME()
ORDER BY s.StartsAt;";

        private const string ProfileSql = @"
SELECT u.FullName, u.Email, u.Role, u.CreatedAt,
       (SELECT AnswerValue FROM dbo.OnboardingAnswers a WHERE a.UserId = u.UserId AND a.QuestionKey = 'age_range') AS AgeRange,
       (SELECT AnswerValue FROM dbo.OnboardingAnswers a WHERE a.UserId = u.UserId AND a.QuestionKey = 'experience_level') AS ExperienceLevel
FROM dbo.Users u
WHERE u.UserId = @Id;";

        // Timestamps are stored in UTC. Malaysia has no daylight saving, so UTC+8 all year.
        private static readonly TimeSpan MalaysiaOffset = TimeSpan.FromHours(8);

        private static string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString; }
        }

        private int UserId
        {
            get { return Convert.ToInt32(Session["UserId"]); }
        }

        // Read by the continue-learning card.
        protected int HeroPercent { get; private set; }
        protected string HeroHref { get; private set; }

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

            // course.aspx links back here with ?pane=courses
            if (!IsPostBack && Request.QueryString["pane"] != null)
                hdnPane.Value = "pane-" + System.Text.RegularExpressions.Regex.Replace(Request.QueryString["pane"], "[^a-z]", "");

            // ...and so do tutors (Tutor Studio)
            if (string.Equals(Convert.ToString(Session["Role"]), "Tutor", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("tutordashboard.aspx");
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
            var sessions = new DataTable();
            var profile = new DataTable();

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    profile = Query(conn, ProfileSql, new SqlParameter("@Id", UserId));
                    courses = Query(conn, MyCoursesSql, new SqlParameter("@Id", UserId));
                    sessions = Query(conn, SessionsSql, new SqlParameter("@Id", UserId));
                }
            }
            catch (SqlException)
            {
                ShowFlash("The database could not be reached. Run App_Data/CreateDatabase.sql, then reload.", false);
            }

            BindProfile(profile);
            BindCourses(courses);
            BindSessions(sessions);
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

            // Greeting uses the first name only, e.g. "Good morning, Aisha".
            string firstName = fullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries)[0];
            int hour = DateTime.UtcNow.Add(MalaysiaOffset).Hour;

            litGreeting.Text = hour < 12 ? "Good morning" : hour < 18 ? "Good afternoon" : "Good evening";
            litWelcomeName.Text = Server.HtmlEncode(firstName);
            litMenuName.Text = Server.HtmlEncode(fullName);
            litMenuEmail.Text = Server.HtmlEncode(email);
            litProfileName.Text = Server.HtmlEncode(fullName);
            litProfileEmail.Text = Server.HtmlEncode(email);
            litRole.Text = Server.HtmlEncode(role);
            litAvatar.Text = Server.HtmlEncode(fullName.Substring(0, 1).ToUpperInvariant());
            litMenuAvatar.Text = litAvatar.Text;
        }

        private void BindCourses(DataTable courses)
        {
            courses.Columns.Add("TotalLessons", typeof(int));
            courses.Columns.Add("Percent", typeof(int));
            courses.Columns.Add("State", typeof(string));

            int completed = 0, lessonsDone = 0, lessonsTotal = 0;
            DataRow resume = null;      // newest course that isn't finished
            DataRow closest = null;     // unfinished course with the most progress

            foreach (DataRow row in courses.Rows)
            {
                // Lessons added to the course win; the admin's planned count is the fallback.
                int total = Convert.ToInt32(row["LessonRows"]);
                if (total == 0) total = Convert.ToInt32(row["Lessons"]);

                bool isDone = row["CompletedAt"] != DBNull.Value;
                int done = isDone ? total : Math.Min(Convert.ToInt32(row["DoneLessons"]), total);

                row["DoneLessons"] = done;
                row["TotalLessons"] = total;
                row["Percent"] = isDone ? 100 : (total == 0 ? 0 : done * 100 / total);
                row["State"] = isDone ? "completed" : "progress";

                lessonsDone += done;
                lessonsTotal += total;

                if (isDone) { completed++; continue; }
                if (resume == null) resume = row;
                if (closest == null || (int)row["Percent"] > (int)closest["Percent"]) closest = row;
            }

            int enrolled = courses.Rows.Count;
            litStatInProgress.Text = (enrolled - completed).ToString("N0");
            litStatCompleted.Text = completed.ToString("N0");
            litStatEnrolled.Text = enrolled.ToString("N0");
            litStatNext.Text = closest != null
                ? "Next to finish: " + Server.HtmlEncode(Convert.ToString(closest["Title"]))
                : enrolled > 0 ? "Every course finished" : "Nothing enrolled yet";

            litStatLessons.Text = lessonsDone.ToString("N0");
            litStatLessonsSub.Text = lessonsTotal == 0
                ? "<p class=\"md-stat__sub\">No lessons yet</p>"
                : "<p class=\"md-stat__sub md-stat__sub--good\">" + (lessonsDone * 100 / lessonsTotal) + "% of your lessons</p>";

            BindHero(resume, enrolled);

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

        private void BindHero(DataRow course, int enrolled)
        {
            phHero.Visible = course != null;
            phHeroEmpty.Visible = course == null;

            if (course == null)
            {
                litHeroEmpty.Text = enrolled > 0 ? "You've finished every course you're in" : "Pick your first course";
                return;
            }

            int courseId = Convert.ToInt32(course["CourseId"]);
            HeroPercent = (int)course["Percent"];
            HeroHref = "course.aspx?id=" + courseId +
                (course["NextLessonId"] == DBNull.Value ? "" : "&lesson=" + course["NextLessonId"]);

            litHeroCover.Text = HasImage(course["ImageUrl"])
                ? "<img src=\"" + Attr(course["ImageUrl"]) + "\" alt=\"\" />"
                : "<span><i class=\"bi bi-image\" aria-hidden=\"true\"></i>Course cover</span>";
            litHeroTitle.Text = Server.HtmlEncode(Convert.ToString(course["Title"]));
            litHeroLesson.Text = course["NextLessonId"] == DBNull.Value
                ? Server.HtmlEncode(course["TotalLessons"] + " lessons · " + course["TutorName"])
                : Server.HtmlEncode("Lesson " + course["NextPosition"] + " of " + course["TotalLessons"] + " - " + course["NextTitle"]);
        }

        private void BindSessions(DataTable sessions)
        {
            int count = sessions.Rows.Count;
            litStatSessions.Text = count.ToString("N0");

            if (count == 0)
            {
                litStatSessionSub.Text = "<p class=\"md-stat__sub\">None booked</p>";
            }
            else
            {
                DateTime next = ToMalaysia(sessions.Rows[0]["StartsAt"]);
                bool soon = (next.Date - DateTime.UtcNow.Add(MalaysiaOffset).Date).TotalDays <= 2;
                litStatSessionSub.Text = "<p class=\"md-stat__sub" + (soon ? " md-stat__sub--warn" : "") + "\">Next: " +
                    next.ToString("ddd d MMM, h:mm tt", CultureInfo.InvariantCulture) + "</p>";
            }

            DataTable top = sessions.Clone();
            for (int i = 0; i < count && i < 3; i++) top.ImportRow(sessions.Rows[i]);
            rptSessions.DataSource = top;
            rptSessions.DataBind();
            phNoSessions.Visible = count == 0;
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

        // Tutors share a 6-digit game PIN to let members into a live quiz.
        // Nothing hosts quizzes by PIN yet, so a well-formed PIN finds no game.
        protected void btnJoinQuiz_Click(object sender, EventArgs e)
        {
            hdnPane.Value = "pane-overview";
            string code = (txtQuizCode.Text ?? "").Replace(" ", "");

            if (!System.Text.RegularExpressions.Regex.IsMatch(code, @"^\d{6}$"))
            {
                ShowFlash("Game PINs are 6 digits. Check the PIN and try again.", false);
                return;
            }

            ShowFlash("No live quiz is running with PIN " + code + ". Check the PIN with your tutor.", false);
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

        private static DateTime ToMalaysia(object utc)
        {
            return DateTime.SpecifyKind(Convert.ToDateTime(utc), DateTimeKind.Utc).Add(MalaysiaOffset);
        }

        private static bool HasImage(object url)
        {
            return url != null && url != DBNull.Value && Convert.ToString(url).Trim().Length > 0;
        }

        // Course picture for a list row, or nothing (the striped placeholder shows).
        protected static string Thumb(object url)
        {
            return HasImage(url) ? "<img src=\"" + Attr(url) + "\" alt=\"\" />" : string.Empty;
        }

        protected static string StatusPill(object state)
        {
            return Convert.ToString(state) == "completed"
                ? "<span class=\"md-pill md-pill--done\"><i class=\"bi bi-check2\" aria-hidden=\"true\"></i>Completed</span>"
                : "<span class=\"md-pill\">In progress</span>";
        }

        // "Today", "Tomorrow" or "In 2 days" in red; later dates in grey, e.g. "Fri, 2 Oct".
        protected static string DuePill(object startsAt)
        {
            DateTime when = ToMalaysia(startsAt);
            int days = (int)(when.Date - DateTime.UtcNow.Add(MalaysiaOffset).Date).TotalDays;
            string time = when.ToString("h:mm tt", CultureInfo.InvariantCulture);

            if (days <= 2)
            {
                string label = days <= 0 ? "Today" : days == 1 ? "Tomorrow" : "In 2 days";
                return "<span class=\"md-pill md-pill--warn\">" + label + ", " + time + "</span>";
            }
            return "<span class=\"md-pill\">" + when.ToString("ddd, d MMM", CultureInfo.InvariantCulture) + ", " + time + "</span>";
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
