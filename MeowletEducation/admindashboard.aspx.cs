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
SELECT u.UserId, u.FullName, u.Email, u.Role, u.IsActive, u.IsVerified, u.CreatedAt,
       (SELECT COUNT(*) FROM dbo.Enrollments e WHERE e.UserId = u.UserId) AS EnrolledCount
FROM dbo.Users u
ORDER BY u.CreatedAt DESC;";

        private const string CoursesSql = @"
SELECT c.CourseId, c.CourseCode, c.Title, c.Category, c.Level, c.Lessons, c.IsPublished, c.ReviewRequestedAt,
       c.TutorId, t.FullName AS TutorName,
       (SELECT COUNT(*) FROM dbo.Enrollments e WHERE e.CourseId = c.CourseId) AS LearnerCount
FROM dbo.Courses c
LEFT JOIN dbo.Users t ON t.UserId = c.TutorId
ORDER BY CASE WHEN c.IsPublished = 0 AND c.ReviewRequestedAt IS NOT NULL THEN 0 ELSE 1 END,  -- tutor drafts waiting for review first
         c.CreatedAt DESC;";

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

        // ---------- Tutor verification ----------

        // Tutors who uploaded a certificate that nobody has approved yet.
        private const string VerifyPendingSql = @"
SELECT u.UserId, u.FullName, u.Email, u.Institution, u.CertificatePath,
       ISNULL(v.SubmittedAt, u.CreatedAt) AS SubmittedAt,
       (SELECT STRING_AGG(t.DisplayLabel, N', ')
          FROM dbo.TutorSubjects ts JOIN dbo.Tags t ON t.TagId = ts.TagId
         WHERE ts.UserId = u.UserId) AS Subjects,
       (SELECT COUNT(*) FROM dbo.TutorVerifications r
         WHERE r.TutorId = u.UserId AND r.Status = 'Rejected') AS RejectedBefore
FROM dbo.Users u
OUTER APPLY (SELECT TOP 1 x.SubmittedAt FROM dbo.TutorVerifications x
             WHERE x.TutorId = u.UserId AND x.Status = 'Pending'
             ORDER BY x.SubmittedAt DESC) v
WHERE u.Role = 'Tutor' AND u.IsVerified = 0 AND u.CertificatePath IS NOT NULL
ORDER BY SubmittedAt;";

        private const string VerifiedSql = @"
SELECT u.UserId, u.FullName, u.Email, u.Institution, u.IsActive, u.CertificatePath,
       (SELECT MAX(x.ReviewedAt) FROM dbo.TutorVerifications x
         WHERE x.TutorId = u.UserId AND x.Status = 'Approved') AS VerifiedAt
FROM dbo.Users u
WHERE u.Role = 'Tutor' AND u.IsVerified = 1
ORDER BY u.FullName;";

        // Unverified tutors with nothing to review (never uploaded, or rejected / revoked).
        private const string VerifyMissingSql = @"
SELECT u.UserId, u.FullName, u.Email, u.CreatedAt, r.Status AS LastStatus, r.ReviewNote AS LastNote
FROM dbo.Users u
OUTER APPLY (SELECT TOP 1 x.Status, x.ReviewNote FROM dbo.TutorVerifications x
             WHERE x.TutorId = u.UserId ORDER BY x.SubmittedAt DESC, x.VerificationId DESC) r
WHERE u.Role = 'Tutor' AND u.IsVerified = 0 AND u.CertificatePath IS NULL
ORDER BY u.CreatedAt DESC;";

        private const string VerifyHistorySql = @"
SELECT TOP 30 v.VerificationId, t.FullName AS TutorName, v.Status, v.SubmittedAt, v.ReviewedAt, v.ReviewNote,
       ISNULL(a.FullName, N'-') AS ReviewerName
FROM dbo.TutorVerifications v
JOIN dbo.Users t      ON t.UserId = v.TutorId
LEFT JOIN dbo.Users a ON a.UserId = v.ReviewedByUserId
WHERE v.Status <> 'Pending'
ORDER BY v.ReviewedAt DESC, v.VerificationId DESC;";

        // Active tutors an admin can put in charge of a course (they then add its lessons in Tutor Studio).
        private const string TutorChoicesSql = @"
SELECT UserId, FullName, IsVerified
FROM dbo.Users
WHERE Role = 'Tutor' AND IsActive = 1
ORDER BY FullName;";

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

            // Adds any columns the tutor pages need that an older database is missing.
            string schemaError = DbSchema.EnsureUpToDate();
            if (schemaError != null)
                ShowFlash("The database needs updating (" + schemaError + "). Run App_Data/CreateDatabase.sql, then reload.", false);

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
            var tutors = new DataTable();
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
                    tutors = Query(conn, TutorChoicesSql);
                    enrollments = Query(conn, EnrollmentsSql);
                    byMonth = Query(conn, EnrollmentsByMonthSql, new SqlParameter("@From", chartFrom));

                    DataTable totals = Query(conn, EnrollmentTotalsSql, new SqlParameter("@MonthStart", monthStart));
                    enrollTotal = Convert.ToInt32(totals.Rows[0]["Total"]);
                    enrollThisMonth = totals.Rows[0]["ThisMonth"] == DBNull.Value
                        ? 0 : Convert.ToInt32(totals.Rows[0]["ThisMonth"]);
                }
            }
            catch (SqlException ex)
            {
                ShowFlash("Database error: " + ex.Message + " If a column or table is missing, run App_Data/CreateDatabase.sql, then reload.", false);
            }

            BindUsers(users);
            BindVerification();
            BindTutorChoices(courses, tutors);
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

        // Fills the tutor dropdowns (New course form + "Assign a tutor"), keeping what was picked.
        private void BindTutorChoices(DataTable courses, DataTable tutors)
        {
            string keepCourse = ddlAssignCourse.SelectedValue;
            string keepTutor = ddlAssignTutor.SelectedValue;
            string keepNew = ddlCourseTutor.SelectedValue;

            ddlAssignCourse.Items.Clear();
            foreach (DataRow row in courses.Rows)
            {
                string tutor = row["TutorName"] == DBNull.Value ? "no tutor" : Convert.ToString(row["TutorName"]);
                ddlAssignCourse.Items.Add(new ListItem(
                    row["CourseCode"] + " · " + row["Title"] + " (" + tutor + ")",
                    Convert.ToString(row["CourseId"])));
            }

            ddlAssignTutor.Items.Clear();
            ddlCourseTutor.Items.Clear();
            ddlAssignTutor.Items.Add(new ListItem("No tutor", ""));
            ddlCourseTutor.Items.Add(new ListItem("No tutor yet", ""));
            foreach (DataRow row in tutors.Rows)
            {
                string text = Convert.ToString(row["FullName"]) + (Convert.ToBoolean(row["IsVerified"]) ? "" : " (not verified)");
                string id = Convert.ToString(row["UserId"]);
                ddlAssignTutor.Items.Add(new ListItem(text, id));
                ddlCourseTutor.Items.Add(new ListItem(text, id));
            }

            if (ddlAssignCourse.Items.FindByValue(keepCourse) != null) ddlAssignCourse.SelectedValue = keepCourse;
            if (ddlAssignTutor.Items.FindByValue(keepTutor) != null) ddlAssignTutor.SelectedValue = keepTutor;
            if (ddlCourseTutor.Items.FindByValue(keepNew) != null) ddlCourseTutor.SelectedValue = keepNew;
            phAssignTutor.Visible = courses.Rows.Count > 0;
        }

        protected void btnAssignTutor_Click(object sender, EventArgs e)
        {
            hdnPane.Value = "pane-courses/sub-course-list";
            int courseId, tutorId;
            if (!int.TryParse(ddlAssignCourse.SelectedValue, out courseId)) return;
            object tutor = int.TryParse(ddlAssignTutor.SelectedValue, out tutorId) ? (object)tutorId : DBNull.Value;

            string result = Execute(@"
UPDATE dbo.Courses SET TutorId = @Tutor
WHERE CourseId = @Course
  AND (@Tutor IS NULL OR EXISTS (SELECT 1 FROM dbo.Users u WHERE u.UserId = @Tutor AND u.Role = 'Tutor'));
IF @@ROWCOUNT = 0
    SELECT N'';
ELSE
    SELECT c.Title + CASE WHEN @Tutor IS NULL THEN N' has no tutor now.'
                          ELSE N' is now taught by ' + t.FullName + N'. They can add its lessons in Tutor Studio.' END
    FROM dbo.Courses c
    LEFT JOIN dbo.Users t ON t.UserId = @Tutor
    WHERE c.CourseId = @Course;",
                new SqlParameter("@Course", courseId),
                new SqlParameter("@Tutor", System.Data.SqlDbType.Int) { Value = tutor });

            if (result == null) return;
            ShowFlash(result.Length == 0 ? "That course or tutor no longer exists." : result, result.Length > 0);
        }

        private void BindVerification()
        {
            DataTable pending = new DataTable(), verified = new DataTable(),
                      missing = new DataTable(), history = new DataTable();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    pending = Query(conn, VerifyPendingSql);
                    verified = Query(conn, VerifiedSql);
                    missing = Query(conn, VerifyMissingSql);
                    history = Query(conn, VerifyHistorySql);
                }
            }
            catch (SqlException ex)
            {
                ShowFlash("Tutor verification could not be loaded: " + ex.Message, false);
            }

            rptVerifyPending.DataSource = pending;
            rptVerifyPending.DataBind();
            phNoVerifyPending.Visible = pending.Rows.Count == 0;

            rptVerified.DataSource = verified;
            rptVerified.DataBind();
            phNoVerified.Visible = verified.Rows.Count == 0;

            rptVerifyMissing.DataSource = missing;
            rptVerifyMissing.DataBind();
            phNoVerifyMissing.Visible = missing.Rows.Count == 0;

            rptVerifyHistory.DataSource = history;
            rptVerifyHistory.DataBind();
            phNoVerifyHistory.Visible = history.Rows.Count == 0;

            litVerifyBadge.Text = pending.Rows.Count > 0
                ? "<span class=\"ad-nav__count\">" + pending.Rows.Count + "</span>"
                : string.Empty;
        }

        // ---------- Actions ----------

        // Approve or reject a certificate in the review queue.
        protected void rptVerifyPending_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            hdnPane.Value = "pane-verify";
            int tutorId = Convert.ToInt32(e.CommandArgument);
            var box = e.Item.FindControl("txtVerifyNote") as TextBox;
            string note = box == null ? string.Empty : box.Text.Trim();
            if (note.Length > 500) note = note.Substring(0, 500);

            string sql;
            if (e.CommandName == "Approve")
            {
                sql = @"
DECLARE @path NVARCHAR(400), @inst NVARCHAR(200), @name NVARCHAR(100);
SELECT @path = CertificatePath, @inst = Institution, @name = FullName
FROM dbo.Users WHERE UserId = @Id AND Role = 'Tutor' AND IsVerified = 0 AND CertificatePath IS NOT NULL;
IF @path IS NULL BEGIN SELECT N''; RETURN; END;

SET XACT_ABORT ON;
BEGIN TRANSACTION;
UPDATE dbo.Users SET IsVerified = 1 WHERE UserId = @Id;
UPDATE dbo.TutorVerifications
SET Status = 'Approved', ReviewedByUserId = @Admin, ReviewedAt = SYSUTCDATETIME(), ReviewNote = @Note
WHERE TutorId = @Id AND Status = 'Pending';
IF @@ROWCOUNT = 0
    INSERT INTO dbo.TutorVerifications (TutorId, CertificatePath, Institution, Status, ReviewedByUserId, ReviewedAt, ReviewNote)
    VALUES (@Id, @path, @inst, 'Approved', @Admin, SYSUTCDATETIME(), @Note);
COMMIT TRANSACTION;
SELECT @name + N' is now a verified tutor. Students can find and book them.';";
            }
            else if (e.CommandName == "Reject")
            {
                if (note.Length == 0)
                {
                    ShowFlash("Write a short reason before rejecting. The tutor sees it on their dashboard.", false);
                    return;
                }

                // The certificate is cleared from the account (it stays in the history),
                // so the tutor is asked to upload a new one.
                sql = @"
DECLARE @path NVARCHAR(400), @inst NVARCHAR(200), @name NVARCHAR(100);
SELECT @path = CertificatePath, @inst = Institution, @name = FullName
FROM dbo.Users WHERE UserId = @Id AND Role = 'Tutor' AND IsVerified = 0 AND CertificatePath IS NOT NULL;
IF @path IS NULL BEGIN SELECT N''; RETURN; END;

SET XACT_ABORT ON;
BEGIN TRANSACTION;
UPDATE dbo.Users SET CertificatePath = NULL WHERE UserId = @Id;
UPDATE dbo.TutorVerifications
SET Status = 'Rejected', ReviewedByUserId = @Admin, ReviewedAt = SYSUTCDATETIME(), ReviewNote = @Note
WHERE TutorId = @Id AND Status = 'Pending';
IF @@ROWCOUNT = 0
    INSERT INTO dbo.TutorVerifications (TutorId, CertificatePath, Institution, Status, ReviewedByUserId, ReviewedAt, ReviewNote)
    VALUES (@Id, @path, @inst, 'Rejected', @Admin, SYSUTCDATETIME(), @Note);
COMMIT TRANSACTION;
SELECT @name + N'''s certificate was rejected. They will see your reason and can upload a new one.';";
            }
            else
            {
                return;
            }

            string result = Execute(sql,
                new SqlParameter("@Id", tutorId),
                new SqlParameter("@Admin", (object)SignedInUserId ?? DBNull.Value),
                new SqlParameter("@Note", note.Length == 0 ? (object)DBNull.Value : note));

            if (result == null) return;
            if (result.Length == 0)
                ShowFlash("That certificate was already reviewed.", false);
            else
                ShowFlash(result, true);
        }

        // Take verification away from a tutor (e.g. a certificate turned out to be invalid).
        protected void rptVerified_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Revoke") return;
            hdnPane.Value = "pane-verify";

            var box = e.Item.FindControl("txtRevokeNote") as TextBox;
            string note = box == null ? string.Empty : box.Text.Trim();
            if (note.Length == 0)
            {
                ShowFlash("Write a short reason before revoking. The tutor sees it on their dashboard.", false);
                return;
            }
            if (note.Length > 480) note = note.Substring(0, 480);

            string result = Execute(@"
DECLARE @path NVARCHAR(400), @inst NVARCHAR(200), @name NVARCHAR(100);
SELECT @path = CertificatePath, @inst = Institution, @name = FullName
FROM dbo.Users WHERE UserId = @Id AND Role = 'Tutor' AND IsVerified = 1;
IF @name IS NULL BEGIN SELECT N''; RETURN; END;

SET XACT_ABORT ON;
BEGIN TRANSACTION;
UPDATE dbo.Users SET IsVerified = 0, CertificatePath = NULL WHERE UserId = @Id;
INSERT INTO dbo.TutorVerifications (TutorId, CertificatePath, Institution, Status, ReviewedByUserId, ReviewedAt, ReviewNote)
VALUES (@Id, ISNULL(@path, N'(no file)'), @inst, 'Rejected', @Admin, SYSUTCDATETIME(), N'Verification revoked: ' + @Note);
COMMIT TRANSACTION;
SELECT @name + N' is no longer verified and has been asked to upload a new certificate.';",
                new SqlParameter("@Id", Convert.ToInt32(e.CommandArgument)),
                new SqlParameter("@Admin", (object)SignedInUserId ?? DBNull.Value),
                new SqlParameter("@Note", note));

            if (result == null) return;
            ShowFlash(result.Length == 0 ? "That tutor was already unverified." : result, result.Length > 0);
        }

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
UPDATE dbo.Courses SET IsPublished = CASE WHEN IsPublished = 1 THEN 0 ELSE 1 END,
                       ReviewRequestedAt = NULL   -- a tutor's review request is answered either way
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
INSERT INTO dbo.Courses (CourseCode, Title, Category, Level, Lessons, IsPublished, TutorId)
VALUES (@Code, @Title, @Category, @Level, @Lessons, @Published, @Tutor);", conn))
                {
                    int tutorId;
                    cmd.Parameters.Add(new SqlParameter("@Tutor", SqlDbType.Int)
                    {
                        Value = int.TryParse(ddlCourseTutor.SelectedValue, out tutorId) ? (object)tutorId : DBNull.Value
                    });
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
            catch (SqlException ex)
            {
                ShowFlash("That change could not be saved: " + ex.Message, false);
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

        protected static string NotSet(object value)
        {
            string text = Convert.ToString(value);
            return text.Length == 0 ? "<span class=\"quiet\">Not given</span>" : Html(text);
        }

        protected static string FileKind(object path)
        {
            return Convert.ToString(path).EndsWith(".pdf", StringComparison.OrdinalIgnoreCase) ? "PDF" : "image";
        }

        protected static string VerifyStatusTag(object status)
        {
            switch (Convert.ToString(status))
            {
                case "Approved": return "<span class=\"tag tag--ok\">Approved</span>";
                case "Rejected": return "<span class=\"tag tag--warn\">Rejected</span>";
                default: return "<span class=\"tag tag--accent\">" + Html(status) + "</span>";
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
