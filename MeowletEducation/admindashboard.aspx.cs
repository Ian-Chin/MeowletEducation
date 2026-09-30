using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MeowletEducation
{
    public partial class AdminDashboard : Page
    {
        // TODO: set back to false before submission / deployment.
        // While true, the login and role checks are skipped so the
        // dashboard layout can be opened directly.
        private const bool DevBypassAuth = true;

        // Shown on the enrollment chart, labelled as sample data, only while
        // the Enrollments table has nothing in the last eight months.
        private static readonly int[] SampleEnrollments = { 92, 108, 134, 123, 158, 172, 191, 214 };

        private static readonly string[] CourseCategories =
        {
            "Budgeting", "Saving", "Investing", "Debt Management",
            "Taxes", "Insurance", "Retirement Planning", "Fintech"
        };

        private static readonly string[] CourseLevels = { "Beginner", "Intermediate", "Advanced" };

        private const string UsersSql = @"
SELECT u.UserId, u.FullName, u.Email, u.Role, u.IsActive, u.CreatedAt,
       (SELECT COUNT(*) FROM dbo.Enrollments e WHERE e.UserId = u.UserId) AS EnrolledCount
FROM dbo.Users u
ORDER BY u.CreatedAt DESC;";

        private const string CoursesSql = @"
SELECT c.CourseId, c.CourseCode, c.Title, c.Category, c.Level, c.Lessons, c.IsPublished,
       (SELECT COUNT(*) FROM dbo.Enrollments e WHERE e.CourseId = c.CourseId) AS LearnerCount
FROM dbo.Courses c
ORDER BY c.CreatedAt DESC;";

        private const string EnrollmentsSql = @"
SELECT TOP 100 u.FullName, u.Email, c.Title, c.CourseCode, e.EnrolledAt
FROM dbo.Enrollments e
JOIN dbo.Users u   ON u.UserId = e.UserId
JOIN dbo.Courses c ON c.CourseId = e.CourseId
ORDER BY e.EnrolledAt DESC;";

        private const string EnrollmentTotalsSql = @"
SELECT COUNT(*) AS Total,
       SUM(CASE WHEN EnrolledAt >= @MonthStart THEN 1 ELSE 0 END) AS ThisMonth
FROM dbo.Enrollments;";

        private const string EnrollmentsByMonthSql = @"
SELECT YEAR(EnrolledAt) AS Y, MONTH(EnrolledAt) AS M, COUNT(*) AS N
FROM dbo.Enrollments
WHERE EnrolledAt >= @From
GROUP BY YEAR(EnrolledAt), MONTH(EnrolledAt);";

        private static string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!DevBypassAuth)
            {
                // Must be logged in
                if (Session["UserId"] == null)
                {
                    Response.Redirect("AdminSignin.aspx");
                    return;
                }

                // Admin only
                string role = Convert.ToString(Session["Role"]);

                if (!string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("AdminSignin.aspx");
                    return;
                }
            }

            if (!IsPostBack)
            {
                BindAdminBadge();
                BindCourseForm();
                BindProfile();
            }
        }

        // Data is bound after the button handlers run, so every list
        // reflects the change the admin just made.
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            BindData();
        }

        private void BindAdminBadge()
        {
            string fullName = Convert.ToString(Session["FullName"]);

            if (string.IsNullOrWhiteSpace(fullName))
            {
                fullName = "Administrator";
            }

            litAdminName.Text = Server.HtmlEncode(fullName);
            litMenuName.Text = Server.HtmlEncode(fullName);

            // Greeting uses the first name only, e.g. "Welcome back, Ian".
            string firstName = fullName.Split(new[] { ' ' },
                StringSplitOptions.RemoveEmptyEntries)[0];

            litWelcomeName.Text = Server.HtmlEncode(firstName);

            // Rendered inside a JavaScript string literal, so it needs
            // JS escaping rather than HTML encoding.
            litAdminNameJs.Text = HttpUtility.JavaScriptStringEncode(firstName);
        }

        private void BindCourseForm()
        {
            ddlCategory.DataSource = CourseCategories;
            ddlCategory.DataBind();
            ddlLevel.DataSource = CourseLevels;
            ddlLevel.DataBind();
        }

        // ---------- Loading ----------

        private void BindData()
        {
            var users = new DataTable();
            var courses = new DataTable();
            var enrollments = new DataTable();
            var byMonth = new DataTable();
            int enrollTotal = 0, enrollThisMonth = 0;

            DateTime now = DateTime.UtcNow;
            var monthStart = new DateTime(now.Year, now.Month, 1);
            DateTime chartFrom = monthStart.AddMonths(-(SampleEnrollments.Length - 1));

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    users = Query(conn, UsersSql);
                    courses = Query(conn, CoursesSql);
                    enrollments = Query(conn, EnrollmentsSql);
                    byMonth = Query(conn, EnrollmentsByMonthSql, new SqlParameter("@From", chartFrom));

                    DataTable totals = Query(conn, EnrollmentTotalsSql, new SqlParameter("@MonthStart", monthStart));
                    enrollTotal = Convert.ToInt32(totals.Rows[0]["Total"]);
                    enrollThisMonth = totals.Rows[0]["ThisMonth"] == DBNull.Value
                        ? 0 : Convert.ToInt32(totals.Rows[0]["ThisMonth"]);
                }
            }
            catch (SqlException)
            {
                ShowFlash("The database could not be reached. Run App_Data/CreateDatabase.sql, then reload.", false);
            }

            BindUsers(users);
            BindCourses(courses);
            BindEnrollments(enrollments, enrollTotal, enrollThisMonth);
            BindChart(byMonth, chartFrom);

            int published = 0;
            foreach (DataRow row in courses.Rows)
            {
                if (Convert.ToBoolean(row["IsPublished"])) published++;
            }

            litStatCourses.Text = courses.Rows.Count.ToString("N0");
            litStatCoursesNote.Text = published.ToString("N0") + " published";
            litStatEnrollments.Text = enrollTotal.ToString("N0");
            litStatEnrollmentsNote.Text = enrollThisMonth.ToString("N0") + " this month";
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

        private void BindUsers(DataTable users)
        {
            rptUsers.DataSource = users;
            rptUsers.DataBind();
            phNoUsers.Visible = users.Rows.Count == 0;

            // newest five accounts for the overview
            DataTable newest = users.Clone();
            for (int i = 0; i < users.Rows.Count && i < 5; i++)
            {
                newest.ImportRow(users.Rows[i]);
            }
            rptNewUsers.DataSource = newest;
            rptNewUsers.DataBind();
            phNoNewUsers.Visible = newest.Rows.Count == 0;

            var roleCounts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
            {
                { "Student", 0 }, { "Tutor", 0 }, { "Admin", 0 }
            };

            foreach (DataRow row in users.Rows)
            {
                string role = Convert.ToString(row["Role"]);
                if (roleCounts.ContainsKey(role)) roleCounts[role]++;
            }

            int total = users.Rows.Count;
            litCountAll.Text = total.ToString("N0");
            litCountStudent.Text = roleCounts["Student"].ToString("N0");
            litCountTutor.Text = roleCounts["Tutor"].ToString("N0");
            litCountAdmin.Text = roleCounts["Admin"].ToString("N0");

            litStatUsers.Text = total.ToString("N0");
            litStatStudents.Text = roleCounts["Student"].ToString("N0");
            litStatTutors.Text = roleCounts["Tutor"].ToString("N0");

            BindRolePie(roleCounts, total);
        }

        private void BindCourses(DataTable courses)
        {
            rptCourses.DataSource = courses;
            rptCourses.DataBind();
            phNoCourses.Visible = courses.Rows.Count == 0;
            litCourseTabCount.Text = courses.Rows.Count.ToString("N0");
        }

        private void BindEnrollments(DataTable enrollments, int total, int thisMonth)
        {
            rptEnrollments.DataSource = enrollments;
            rptEnrollments.DataBind();
            phNoEnrollments.Visible = enrollments.Rows.Count == 0;
            litEnrollTotal.Text = total.ToString("N0");
            litEnrollMonth.Text = thisMonth.ToString("N0");
        }

        // Last eight months of enrollments, handed to the page script as JSON.
        private void BindChart(DataTable byMonth, DateTime from)
        {
            var counts = new Dictionary<string, int>();
            foreach (DataRow row in byMonth.Rows)
            {
                counts[row["Y"] + "-" + row["M"]] = Convert.ToInt32(row["N"]);
            }

            var points = new List<object>();
            int sum = 0;
            for (int i = 0; i < SampleEnrollments.Length; i++)
            {
                DateTime month = from.AddMonths(i);
                int n;
                counts.TryGetValue(month.Year + "-" + month.Month, out n);
                sum += n;
                points.Add(new { label = month.ToString("MMM", CultureInfo.InvariantCulture), value = n });
            }

            bool sample = sum == 0;
            if (sample)
            {
                for (int i = 0; i < points.Count; i++)
                {
                    DateTime month = from.AddMonths(i);
                    points[i] = new { label = month.ToString("MMM", CultureInfo.InvariantCulture), value = SampleEnrollments[i] };
                }
            }

            phChartSample.Visible = sample;
            litChartJson.Text = new JavaScriptSerializer().Serialize(points);
        }

        // Pie on the overview: accounts split by role, drawn with a conic-gradient.
        private void BindRolePie(Dictionary<string, int> roleCounts, int total)
        {
            var slices = new[]
            {
                // CSS variables, so the slices follow the light / dark theme
                new { Role = "Student", Label = "Learners", Color = "var(--ad-pie-1)" },
                new { Role = "Tutor",   Label = "Tutors",   Color = "var(--ad-pie-2)" },
                new { Role = "Admin",   Label = "Admins",   Color = "var(--ad-pie-3)" }
            };

            var gradient = new StringBuilder();
            var legend = new StringBuilder();
            double start = 0;

            foreach (var slice in slices)
            {
                int count = roleCounts[slice.Role];
                double share = total == 0 ? 0 : count * 100.0 / total;
                double end = start + share;

                if (share > 0)
                {
                    if (gradient.Length > 0) gradient.Append(", ");
                    gradient.AppendFormat(CultureInfo.InvariantCulture,
                        "{0} {1:0.##}% {2:0.##}%", slice.Color, start, end);
                }

                legend.AppendFormat(CultureInfo.InvariantCulture,
                    "<li><span class=\"ad-pie__swatch\" style=\"background:{0}\"></span>" +
                    "<span class=\"ad-pie__label\">{1}</span>" +
                    "<span class=\"ad-pie__value\">{2:N0}</span>" +
                    "<span class=\"ad-pie__share\">{3:0}%</span></li>",
                    slice.Color, slice.Label, count, share);

                start = end;
            }

            string background = gradient.Length == 0
                ? "var(--beige)"
                : "conic-gradient(" + gradient + ")";

            litRolePie.Text =
                "<div class=\"ad-pie__disc\" role=\"img\" aria-label=\"Accounts by role\" style=\"background:" + background + "\">" +
                "<span class=\"ad-pie__hole\"><strong>" + total.ToString("N0") + "</strong>accounts</span></div>" +
                "<ul class=\"ad-pie__legend\">" + legend + "</ul>";
        }

        // ---------- Actions ----------

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ToggleActive") return;

            int userId = Convert.ToInt32(e.CommandArgument);

            if (Session["UserId"] != null && Convert.ToInt32(Session["UserId"]) == userId)
            {
                ShowFlash("You can't disable the account you're signed in with.", false);
                return;
            }

            // The last active admin is never disabled, or nobody could get back in.
            string result = Execute(@"
UPDATE dbo.Users SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END
OUTPUT inserted.FullName + CASE WHEN inserted.IsActive = 1 THEN ' can sign in again.' ELSE ' is disabled and can''t sign in.' END
WHERE UserId = @Id
  AND NOT (IsActive = 1 AND Role = 'Admin'
           AND (SELECT COUNT(*) FROM dbo.Users WHERE Role = 'Admin' AND IsActive = 1) <= 1);",
                new SqlParameter("@Id", userId));

            if (result == null) return;

            if (result.Length == 0)
                ShowFlash("That's the only active admin account, so it stays enabled.", false);
            else
                ShowFlash(result, true);
        }

        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int courseId = Convert.ToInt32(e.CommandArgument);
            string result = null;

            if (e.CommandName == "TogglePublish")
            {
                result = Execute(@"
UPDATE dbo.Courses SET IsPublished = CASE WHEN IsPublished = 1 THEN 0 ELSE 1 END
OUTPUT inserted.Title + CASE WHEN inserted.IsPublished = 1 THEN ' is published.' ELSE ' is back in draft.' END
WHERE CourseId = @Id;", new SqlParameter("@Id", courseId));
            }
            else if (e.CommandName == "Delete")
            {
                result = Execute(@"
DELETE FROM dbo.Courses OUTPUT deleted.Title + ' was deleted.' WHERE CourseId = @Id;",
                    new SqlParameter("@Id", courseId));
            }

            if (result != null) ShowFlash(result, true);
        }

        protected void btnCreateCourse_Click(object sender, EventArgs e)
        {
            string title = txtCourseTitle.Text.Trim();
            string code = txtCourseCode.Text.Trim().ToUpperInvariant();
            int lessons;

            if (title.Length == 0 || code.Length == 0)
            {
                ShowCourseMessage("Give the course a title and a code.", false);
                return;
            }

            if (!int.TryParse(txtLessons.Text.Trim(), out lessons) || lessons < 0)
            {
                ShowCourseMessage("Lessons must be a whole number, 0 or more.", false);
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(@"
INSERT INTO dbo.Courses (CourseCode, Title, Category, Level, Lessons, IsPublished)
VALUES (@Code, @Title, @Category, @Level, @Lessons, @Published);", conn))
                {
                    cmd.Parameters.AddWithValue("@Code", code);
                    cmd.Parameters.AddWithValue("@Title", title);
                    cmd.Parameters.AddWithValue("@Category", ddlCategory.SelectedValue);
                    cmd.Parameters.AddWithValue("@Level", ddlLevel.SelectedValue);
                    cmd.Parameters.AddWithValue("@Lessons", lessons);
                    cmd.Parameters.AddWithValue("@Published", chkPublish.Checked);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
            {
                ShowCourseMessage("Another course already uses the code " + code + ".", false);
                return;
            }
            catch (SqlException)
            {
                ShowCourseMessage("The course could not be saved. Check the database connection.", false);
                return;
            }

            ShowFlash(title + (chkPublish.Checked ? " is published." : " was added as a draft."), true);
            txtCourseTitle.Text = txtCourseCode.Text = txtLessons.Text = string.Empty;
            chkPublish.Checked = false;

            // land on the list so the new course is visible
            hdnPane.Value = "pane-courses/sub-course-list";
        }

        // ---------- My profile ----------

        private int? SignedInUserId
        {
            get { return Session["UserId"] == null ? (int?)null : Convert.ToInt32(Session["UserId"]); }
        }

        private void BindProfile()
        {
            int? userId = SignedInUserId;
            phProfile.Visible = userId.HasValue;
            phProfileSignedOut.Visible = !userId.HasValue;
            if (!userId.HasValue) return;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT FullName, Email FROM dbo.Users WHERE UserId = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", userId.Value);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtProfileName.Text = reader.GetString(0);
                            txtProfileEmail.Text = reader.GetString(1);
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowFormMessage(litProfileMsg, "Your profile could not be loaded.", false);
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            hdnPane.Value = "pane-profile";
            int? userId = SignedInUserId;
            if (!userId.HasValue) return;

            string name = txtProfileName.Text.Trim();
            string email = txtProfileEmail.Text.Trim().ToLowerInvariant();

            if (name.Length == 0)
            {
                ShowFormMessage(litProfileMsg, "Your name can't be empty.", false);
                return;
            }

            if (email.IndexOf('@') < 1 || email.LastIndexOf('.') < email.IndexOf('@'))
            {
                ShowFormMessage(litProfileMsg, "Enter a valid email address.", false);
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "UPDATE dbo.Users SET FullName = @Name, Email = @Email WHERE UserId = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Name", name);
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@Id", userId.Value);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
            {
                ShowFormMessage(litProfileMsg, "Another account already uses that email.", false);
                return;
            }
            catch (SqlException)
            {
                ShowFormMessage(litProfileMsg, "Your changes could not be saved.", false);
                return;
            }

            Session["FullName"] = name;
            Session["Email"] = email;
            txtProfileEmail.Text = email;
            BindAdminBadge();
            ShowFormMessage(litProfileMsg, "Profile saved.", true);
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            hdnPane.Value = "pane-profile";
            int? userId = SignedInUserId;
            if (!userId.HasValue) return;

            string current = txtCurrentPassword.Text;
            string next = txtNewPassword.Text;

            if (current.Length == 0 || next.Length == 0)
            {
                ShowFormMessage(litPasswordMsg, "Fill in your current and new password.", false);
                return;
            }

            if (next.Length < 8)
            {
                ShowFormMessage(litPasswordMsg, "Use a new password of at least 8 characters.", false);
                return;
            }

            if (next != txtConfirmPassword.Text)
            {
                ShowFormMessage(litPasswordMsg, "The new passwords don't match.", false);
                return;
            }

            int changed;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "UPDATE dbo.Users SET PasswordHash = @New WHERE UserId = @Id AND PasswordHash = @Current", conn))
                {
                    cmd.Parameters.AddWithValue("@New", HashPassword(next));
                    cmd.Parameters.AddWithValue("@Current", HashPassword(current));
                    cmd.Parameters.AddWithValue("@Id", userId.Value);
                    conn.Open();
                    changed = cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException)
            {
                ShowFormMessage(litPasswordMsg, "Your password could not be changed.", false);
                return;
            }

            if (changed == 0)
            {
                ShowFormMessage(litPasswordMsg, "Your current password isn't right.", false);
                return;
            }

            ShowFormMessage(litPasswordMsg, "Password changed.", true);
        }

        private void ShowFormMessage(Literal target, string message, bool ok)
        {
            target.Text = "<p class=\"ad-flash" + (ok ? "" : " ad-flash--error") + "\" role=\"" +
                (ok ? "status" : "alert") + "\">" + Server.HtmlEncode(message) + "</p>";
        }

        private static string HashPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                var sb = new StringBuilder();
                foreach (byte b in bytes) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("AdminSignin.aspx");
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
            litFlash.Text = "<p class=\"ad-flash" + (ok ? "" : " ad-flash--error") + "\" role=\"status\">" +
                Server.HtmlEncode(message) + "</p>";
        }

        private void ShowCourseMessage(string message, bool ok)
        {
            litCourseMsg.Text = "<p class=\"ad-flash" + (ok ? "" : " ad-flash--error") + "\" role=\"alert\">" +
                Server.HtmlEncode(message) + "</p>";
            hdnPane.Value = "pane-courses/sub-course-create";
        }

        // ---------- Template helpers ----------

        protected static string RoleTagClass(object role)
        {
            switch (Convert.ToString(role).ToLowerInvariant())
            {
                case "admin": return "tag ad-tag--ink";
                case "tutor": return "tag tag--accent";
                default: return "tag";
            }
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
