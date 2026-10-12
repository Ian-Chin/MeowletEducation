using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

namespace MeowletEducation
{
    // Tutor Studio: the tutor's counterpart to memberdashboard.aspx.
    // Every query is scoped to the signed-in tutor (TutorId = @Me), so a tutor
    // can only see and change their own sessions, courses, lessons and replies.
    public partial class TutorDashboard : Page
    {
        // Same lists as the admin dashboard's "Create course" form.
        private static readonly string[] CourseCategories =
        {
            "Budgeting", "Saving", "Investing", "Debt Management",
            "Taxes", "Insurance", "Retirement Planning", "Fintech"
        };

        private static readonly string[] CourseLevels = { "Beginner", "Intermediate", "Advanced" };

        private static readonly string[] LessonTypes = { "Video", "Article", "Quiz", "AR" };

        // AR scenes a lesson can open (CourseLessons.ARSceneKey -> label).
        // Each key is one WebXR / model-viewer scene described in the AR plan.
        internal static readonly Dictionary<string, string> ArScenes = new Dictionary<string, string>
        {
            { "budget-jars",           "Budget jars: sort a month of spending into needs, wants and savings" },
            { "compound-growth",       "Compound growth tree: watch savings grow year by year" },
            { "debt-snowball",         "Debt snowball: stack debts and knock them down in order" },
            { "price-tag-hours",       "Price tag in hours: see how many work hours a purchase costs" },
            { "emergency-fund-shield", "Emergency fund shield: how many months of expenses you are covered for" }
        };

        private static readonly string[] DayNames = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" };

        // Timestamps are stored in UTC. Malaysia has no daylight saving, so UTC+8 all year.
        private static readonly TimeSpan MalaysiaOffset = TimeSpan.FromHours(8);

        // ---------- SQL ----------

        private const string ProfileSql = @"
SELECT u.FullName, u.Email, u.IsVerified, u.CertificatePath,
       lv.Status AS LastVerifyStatus, lv.ReviewNote AS LastVerifyNote,
       p.Headline, p.Bio, p.MeetingLink, p.IsAcceptingStudents,
       (SELECT STRING_AGG(t.DisplayLabel, N', ') WITHIN GROUP (ORDER BY t.DisplayLabel)
          FROM dbo.TutorSubjects ts JOIN dbo.Tags t ON t.TagId = ts.TagId
         WHERE ts.UserId = u.UserId) AS Subjects,
       (SELECT COUNT(*) FROM dbo.TutorAvailability a WHERE a.TutorId = u.UserId) AS SlotCount,
       (SELECT COUNT(*) FROM dbo.Messages m WHERE m.RecipientId = u.UserId AND m.ReadAt IS NULL) AS UnreadCount
FROM dbo.Users u
LEFT JOIN dbo.TutorProfiles p ON p.UserId = u.UserId
OUTER APPLY (SELECT TOP 1 v.Status, v.ReviewNote
             FROM dbo.TutorVerifications v
             WHERE v.TutorId = u.UserId
             ORDER BY v.SubmittedAt DESC, v.VerificationId DESC) lv
WHERE u.UserId = @Me;";

        private const string SessionsSql = @"
SELECT s.SessionId, s.StartsAt, s.DurationMinutes, s.Status, s.StudentNote, s.TutorNote,
       COALESCE(s.MeetingLink, p.MeetingLink) AS Link,
       st.FullName AS StudentName,
       ISNULL(g.DisplayLabel, N'General') AS Topic,
       sr.Rating
FROM dbo.TutoringSessions s
JOIN dbo.Users st              ON st.UserId = s.StudentId
LEFT JOIN dbo.Tags g           ON g.TagId = s.TagId
LEFT JOIN dbo.TutorProfiles p  ON p.UserId = s.TutorId
LEFT JOIN dbo.SessionReviews sr ON sr.SessionId = s.SessionId AND sr.IsHidden = 0
WHERE s.TutorId = @Me
ORDER BY s.StartsAt;";

        private const string RatingSql = @"
SELECT CAST(AVG(CAST(sr.Rating AS DECIMAL(4,2))) AS DECIMAL(3,2)) AS AvgRating, COUNT(*) AS ReviewCount
FROM dbo.SessionReviews sr
JOIN dbo.TutoringSessions s ON s.SessionId = sr.SessionId
WHERE s.TutorId = @Me AND sr.IsHidden = 0;";

        private const string CoursesSql = @"
SELECT c.CourseId, c.CourseCode, c.Title, c.Category, c.Level, c.IsPublished, c.ReviewRequestedAt,
       (SELECT COUNT(*) FROM dbo.CourseLessons l WHERE l.CourseId = c.CourseId) AS LessonCount,
       (SELECT COUNT(*) FROM dbo.Enrollments e WHERE e.CourseId = c.CourseId) AS LearnerCount,
       (SELECT COUNT(*) FROM dbo.Enrollments e WHERE e.CourseId = c.CourseId AND e.CompletedAt IS NOT NULL) AS CompletedCount,
       (SELECT CAST(AVG(CAST(r.Rating AS DECIMAL(4,2))) AS DECIMAL(3,2))
          FROM dbo.CourseReviews r WHERE r.CourseId = c.CourseId AND r.IsHidden = 0) AS AvgRating
FROM dbo.Courses c
WHERE c.TutorId = @Me
ORDER BY c.IsPublished DESC, c.CreatedAt DESC;";

        private const string LessonsSql = @"
SELECT l.LessonId, l.Position, l.Title, l.ContentType, l.ContentUrl, l.ARSceneKey, l.DurationMinutes,
       (SELECT COUNT(*) FROM dbo.LessonProgress p WHERE p.LessonId = l.LessonId) AS DoneCount
FROM dbo.CourseLessons l
JOIN dbo.Courses c ON c.CourseId = l.CourseId
WHERE l.CourseId = @Course AND c.TutorId = @Me
ORDER BY l.Position;";

        private const string LearnersSql = @"
SELECT u.FullName, u.Email, c.CourseCode, c.Title, c.Lessons, e.EnrolledAt, e.CompletedAt,
       (SELECT COUNT(*) FROM dbo.CourseLessons l WHERE l.CourseId = c.CourseId) AS LessonRows,
       (SELECT COUNT(*) FROM dbo.LessonProgress p
          JOIN dbo.CourseLessons l ON l.LessonId = p.LessonId
         WHERE p.UserId = e.UserId AND l.CourseId = c.CourseId) AS DoneLessons
FROM dbo.Enrollments e
JOIN dbo.Courses c ON c.CourseId = e.CourseId
JOIN dbo.Users u   ON u.UserId = e.UserId
WHERE c.TutorId = @Me
ORDER BY e.EnrolledAt DESC;";

        private const string ReviewsSql = @"
SELECT 'C' AS Kind, r.ReviewId AS ReviewKey, u.FullName AS StudentName,
       c.CourseCode + N' · ' + c.Title AS Subject,
       r.Rating, r.Comment, r.TutorReply, r.TutorRepliedAt, r.CreatedAt
FROM dbo.CourseReviews r
JOIN dbo.Courses c ON c.CourseId = r.CourseId
JOIN dbo.Users u   ON u.UserId = r.UserId
WHERE c.TutorId = @Me AND r.IsHidden = 0
UNION ALL
SELECT 'S', sr.SessionId, u.FullName,
       N'1-on-1 session' + ISNULL(N' · ' + g.DisplayLabel, N''),
       sr.Rating, sr.Comment, sr.TutorReply, sr.TutorRepliedAt, sr.CreatedAt
FROM dbo.SessionReviews sr
JOIN dbo.TutoringSessions s ON s.SessionId = sr.SessionId
JOIN dbo.Users u            ON u.UserId = s.StudentId
LEFT JOIN dbo.Tags g        ON g.TagId = s.TagId
WHERE s.TutorId = @Me AND sr.IsHidden = 0
ORDER BY CreatedAt DESC;";

        private const string SlotsSql = @"
SELECT AvailabilityId, DayOfWeek, StartTime, EndTime
FROM dbo.TutorAvailability
WHERE TutorId = @Me
ORDER BY DayOfWeek, StartTime;";

        // Latest attempts at AR activities in this tutor's courses (assets/js/ar, saved by ArResult.ashx).
        private const string ArResultsSql = @"
SELECT TOP 50 u.FullName, c.CourseCode, l.Title AS LessonTitle, r.SceneKey, r.Score, r.Summary, r.Mode, r.Seconds, r.CompletedAt
FROM dbo.ARActivityResults r
JOIN dbo.CourseLessons l ON l.LessonId = r.LessonId
JOIN dbo.Courses c       ON c.CourseId = l.CourseId
JOIN dbo.Users u         ON u.UserId = r.UserId
WHERE c.TutorId = @Me
ORDER BY r.CompletedAt DESC;";

        private const string MessagesSql = @"
SELECT TOP 50 m.MessageId, m.Body, m.SentAt, m.ReadAt,
       CASE WHEN m.SenderId = @Me THEN 1 ELSE 0 END AS IsMine,
       other.FullName AS OtherName
FROM dbo.Messages m
JOIN dbo.Users other ON other.UserId = CASE WHEN m.SenderId = @Me THEN m.RecipientId ELSE m.SenderId END
WHERE m.SenderId = @Me OR m.RecipientId = @Me
ORDER BY m.SentAt DESC;";

        // ---------- State ----------

        private static string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString; }
        }

        private int Me
        {
            get { return Convert.ToInt32(Session["UserId"]); }
        }

        private bool? isVerified;

        // Read from the database, not the session: an admin may have approved
        // (or a new certificate upload may have reset) the tutor since sign-in.
        private bool IsVerified
        {
            get
            {
                if (!isVerified.HasValue)
                {
                    string value = Execute("SELECT CAST(IsVerified AS INT) FROM dbo.Users WHERE UserId = @Me;", P("@Me", Me));
                    isVerified = value == "1";
                    Session["IsVerified"] = isVerified.Value;
                }
                return isVerified.Value;
            }
        }

        // Set by actions that should open the Lessons pane on a given course.
        private string lessonCourseToSelect;

        // ---------- Page lifecycle ----------

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("Signin.aspx");
                return;
            }

            string role = Convert.ToString(Session["Role"]);
            if (string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("admindashboard.aspx");
                return;
            }
            if (!string.Equals(role, "Tutor", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("memberdashboard.aspx");
                return;
            }

            // Adds any columns this page needs that an older database is missing.
            string schemaError = DbSchema.EnsureUpToDate();
            if (schemaError != null)
                ShowFlash("The database needs updating (" + schemaError + "). Run App_Data/CreateDatabase.sql, then reload.", false);

            if (!IsPostBack)
            {
                ddlCategory.DataSource = CourseCategories;
                ddlCategory.DataBind();
                ddlLevel.DataSource = CourseLevels;
                ddlLevel.DataBind();

                foreach (var scene in ArScenes)
                    ddlArScene.Items.Add(new ListItem(scene.Value, scene.Key));

                if (Request.QueryString["pane"] != null)
                    hdnPane.Value = "pane-" + Regex.Replace(Request.QueryString["pane"], "[^a-z]", "");
            }
        }

        // Data is bound after the button handlers run, so every list
        // reflects the change the tutor just made.
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            BindData();
        }

        // ---------- Loading ----------

        private void BindData()
        {
            DataTable profile = new DataTable(), sessions = new DataTable(), rating = new DataTable(),
                      courses = new DataTable(), learners = new DataTable(), reviews = new DataTable(),
                      slots = new DataTable(), messages = new DataTable(), arResults = new DataTable();

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    profile = Query(conn, ProfileSql, P("@Me", Me));
                    sessions = Query(conn, SessionsSql, P("@Me", Me));
                    rating = Query(conn, RatingSql, P("@Me", Me));
                    courses = Query(conn, CoursesSql, P("@Me", Me));
                    learners = Query(conn, LearnersSql, P("@Me", Me));
                    reviews = Query(conn, ReviewsSql, P("@Me", Me));
                    slots = Query(conn, SlotsSql, P("@Me", Me));
                    messages = Query(conn, MessagesSql, P("@Me", Me));
                    arResults = Query(conn, ArResultsSql, P("@Me", Me));
                }
            }
            catch (SqlException ex)
            {
                ShowFlash("Database error: " + ex.Message + " If a column or table is missing, run App_Data/CreateDatabase.sql, then reload.", false);
            }

            BindProfile(profile);
            BindSessions(sessions, rating);
            BindCourses(courses);
            BindLearners(learners);

            rptReviews.DataSource = reviews;
            rptReviews.DataBind();
            phNoReviews.Visible = reviews.Rows.Count == 0;

            rptSlots.DataSource = slots;
            rptSlots.DataBind();
            phNoSlots.Visible = slots.Rows.Count == 0;

            rptMessages.DataSource = messages;
            rptMessages.DataBind();
            phNoMessages.Visible = messages.Rows.Count == 0;

            rptArResults.DataSource = arResults;
            rptArResults.DataBind();
            phNoArResults.Visible = arResults.Rows.Count == 0;
        }

        private void BindProfile(DataTable profile)
        {
            string fullName = Convert.ToString(Session["FullName"]);
            string email = Convert.ToString(Session["Email"]);
            bool verified = false;
            int unread = 0;
            string verifyNote = "Upload your certificate on Account &amp; Verification so an admin can check it. " +
                "Until then students can't find or book you, but you can still prepare draft courses, lessons and your availability.";

            if (profile.Rows.Count > 0)
            {
                DataRow row = profile.Rows[0];
                fullName = Convert.ToString(row["FullName"]);
                email = Convert.ToString(row["Email"]);
                verified = Convert.ToBoolean(row["IsVerified"]);
                unread = Convert.ToInt32(row["UnreadCount"]);

                // What the "not verified" banner says depends on where the tutor is in review.
                if (row["CertificatePath"] != DBNull.Value)
                {
                    verifyNote = "Your certificate is waiting for an admin to review it. Students can't find or book you until it's approved; " +
                        "meanwhile you can prepare draft courses, lessons and your availability.";
                }
                else if (Convert.ToString(row["LastVerifyStatus"]) == "Rejected")
                {
                    string reason = Convert.ToString(row["LastVerifyNote"]);
                    verifyNote = "Your last certificate wasn't approved" +
                        (reason.Length > 0 ? ": &ldquo;" + Server.HtmlEncode(reason) + "&rdquo;" : ".") +
                        " Please upload a new one.";
                }

                string headline = Convert.ToString(row["Headline"]);
                bool hasProfile = row["IsAcceptingStudents"] != DBNull.Value;
                bool accepting = hasProfile && Convert.ToBoolean(row["IsAcceptingStudents"]);

                litProfileHeadline.Text = headline.Length == 0 ? "Add a headline so students know what you teach." : Server.HtmlEncode(headline);
                string subjects = Convert.ToString(row["Subjects"]);
                litProfileSubjects.Text = subjects.Length == 0 ? "Not set" : Server.HtmlEncode(subjects);
                litProfileAccepting.Text = !hasProfile ? "Profile not set up" : (accepting ? "Accepting new students" : "Not taking new students");
                litProfileSlots.Text = Convert.ToInt32(row["SlotCount"]).ToString("N0");

                // Only fill the form on first load so a failed save keeps what was typed.
                if (!IsPostBack)
                {
                    txtHeadline.Text = headline;
                    txtBio.Text = Convert.ToString(row["Bio"]);
                    txtMeetingLink.Text = Convert.ToString(row["MeetingLink"]);
                    chkAccepting.Checked = !hasProfile || accepting;
                }
            }

            if (string.IsNullOrWhiteSpace(fullName)) fullName = "Tutor";
            string firstName = fullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries)[0];

            litWelcomeName.Text = Server.HtmlEncode(firstName);
            litTutorNameJs.Text = HttpUtility.JavaScriptStringEncode(firstName);
            litTutorName.Text = Server.HtmlEncode(fullName);
            litMenuName.Text = Server.HtmlEncode(fullName);
            litMenuEmail.Text = Server.HtmlEncode(email);
            litProfileName.Text = Server.HtmlEncode(fullName);
            litProfileEmail.Text = Server.HtmlEncode(email);
            litAvatar.Text = Server.HtmlEncode(fullName.Substring(0, 1).ToUpperInvariant());

            phUnverified.Visible = !verified;
            litVerifyNote.Text = verifyNote;
            litVerifyTag.Text = verified
                ? "<span class=\"tag tag--ok\"><i class=\"bi bi-patch-check\" aria-hidden=\"true\"></i>Verified</span>"
                : "<span class=\"tag tag--warn\">Not verified</span>";
            litMsgBadge.Text = unread > 0 ? "<span class=\"td-badge\">" + unread + "</span>" : "";
        }

        private void BindSessions(DataTable sessions, DataTable rating)
        {
            DateTime nowUtc = DateTime.UtcNow;

            sessions.Columns.Add("HasStarted", typeof(bool));
            sessions.Columns.Add("DisplayStatus", typeof(string));

            DataTable requests = sessions.Clone(), upcoming = sessions.Clone(),
                      history = sessions.Clone(), next = sessions.Clone();
            int upcomingCount = 0;

            foreach (DataRow row in sessions.Rows)
            {
                DateTime starts = Convert.ToDateTime(row["StartsAt"]);
                string status = Convert.ToString(row["Status"]);
                row["HasStarted"] = starts <= nowUtc;
                row["DisplayStatus"] = status;

                if (status == "Requested" && starts > nowUtc)
                {
                    requests.ImportRow(row);
                    next.ImportRow(row);
                }
                else if (status == "Confirmed")
                {
                    upcoming.ImportRow(row);
                    if (starts > nowUtc)
                    {
                        upcomingCount++;
                        next.ImportRow(row);
                    }
                }
                else
                {
                    // A request nobody answered before its start time has expired.
                    if (status == "Requested") row["DisplayStatus"] = "Expired";
                    history.ImportRow(row);
                }
            }

            // newest first for the history table
            DataView historyView = history.DefaultView;
            historyView.Sort = "StartsAt DESC";

            DataView nextView = next.DefaultView;
            nextView.Sort = "StartsAt ASC";
            DataTable nextFive = nextView.ToTable().Clone();
            foreach (DataRowView v in nextView)
            {
                if (nextFive.Rows.Count == 5) break;
                nextFive.ImportRow(v.Row);
            }

            rptRequests.DataSource = requests;
            rptRequests.DataBind();
            phNoRequests.Visible = requests.Rows.Count == 0;

            rptUpcoming.DataSource = upcoming;
            rptUpcoming.DataBind();
            phNoUpcoming.Visible = upcoming.Rows.Count == 0;

            rptHistory.DataSource = historyView;
            rptHistory.DataBind();
            phNoHistory.Visible = history.Rows.Count == 0;

            rptNextSessions.DataSource = nextFive;
            rptNextSessions.DataBind();
            phNoNext.Visible = nextFive.Rows.Count == 0;

            litStatUpcoming.Text = upcomingCount.ToString("N0");
            litStatRequests.Text = requests.Rows.Count.ToString("N0");
            litReqBadge.Text = requests.Rows.Count > 0 ? "<span class=\"td-badge\">" + requests.Rows.Count + "</span>" : "";

            if (rating.Rows.Count > 0 && rating.Rows[0]["AvgRating"] != DBNull.Value)
            {
                int count = Convert.ToInt32(rating.Rows[0]["ReviewCount"]);
                litStatRating.Text = Convert.ToDecimal(rating.Rows[0]["AvgRating"]).ToString("0.0", CultureInfo.InvariantCulture);
                litStatRatingNote.Text = "From " + count + (count == 1 ? " review" : " reviews");
            }
        }

        private void BindCourses(DataTable courses)
        {
            rptCourses.DataSource = courses;
            rptCourses.DataBind();
            phNoCourses.Visible = courses.Rows.Count == 0;

            // ---- Lessons pane: course picker ----
            string want = lessonCourseToSelect ?? ddlLessonCourse.SelectedValue;
            ddlLessonCourse.Items.Clear();
            DataRow selected = null;

            foreach (DataRow row in courses.Rows)
            {
                string id = Convert.ToString(row["CourseId"]);
                string text = row["CourseCode"] + " · " + row["Title"] + ((bool)row["IsPublished"] ? "" : " (draft)");
                ddlLessonCourse.Items.Add(new ListItem(text, id));
                if (id == want) selected = row;
            }

            if (selected == null && courses.Rows.Count > 0) selected = courses.Rows[0];

            bool hasCourses = selected != null;
            phNoCourseForLessons.Visible = !hasCourses;
            pnlLessons.Visible = hasCourses;
            if (!hasCourses) return;

            ddlLessonCourse.SelectedValue = Convert.ToString(selected["CourseId"]);

            DataTable lessons = new DataTable();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    lessons = Query(conn, LessonsSql, P("@Me", Me), P("@Course", Convert.ToInt32(selected["CourseId"])));
                }
            }
            catch (SqlException)
            {
                ShowFlash("Lessons could not be loaded. Check the database connection.", false);
            }

            rptLessons.DataSource = lessons;
            rptLessons.DataBind();
            phNoLessons.Visible = lessons.Rows.Count == 0;

            int minutes = 0;
            foreach (DataRow l in lessons.Rows) minutes += Convert.ToInt32(l["DurationMinutes"]);

            litLessonCourseInfo.Text = Server.HtmlEncode(
                lessons.Rows.Count + (lessons.Rows.Count == 1 ? " lesson" : " lessons") + ", about " + minutes + " minutes. " +
                ((bool)selected["IsPublished"]
                    ? "This course is published, so changes are live for enrolled learners."
                    : "This course is a draft; learners can't see it yet."));
        }

        private void BindLearners(DataTable learners)
        {
            learners.Columns.Add("TotalLessons", typeof(int));
            learners.Columns.Add("Percent", typeof(int));

            var distinct = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (DataRow row in learners.Rows)
            {
                // Same rule as the member dashboard: real lesson rows win, the planned count is the fallback.
                int total = Convert.ToInt32(row["LessonRows"]);
                if (total == 0) total = Convert.ToInt32(row["Lessons"]);
                int done = Math.Min(Convert.ToInt32(row["DoneLessons"]), total);
                bool isDone = row["CompletedAt"] != DBNull.Value;

                row["TotalLessons"] = total;
                row["Percent"] = isDone ? 100 : (total == 0 ? 0 : done * 100 / total);
                distinct.Add(Convert.ToString(row["Email"]));
            }

            litStatLearners.Text = distinct.Count.ToString("N0");

            rptLearners.DataSource = learners;
            rptLearners.DataBind();
            phNoLearners.Visible = learners.Rows.Count == 0;
        }

        // ---------- Sessions ----------

        protected void rptSessions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            hdnPane.Value = "pane-sessions";
            int sessionId = Convert.ToInt32(e.CommandArgument);
            string sql, ok, fail;
            var parameters = new List<SqlParameter> { P("@Me", Me), P("@Id", sessionId) };

            switch (e.CommandName)
            {
                case "Accept":
                    // Only a future request, and only if it doesn't overlap another confirmed session.
                    sql = @"
UPDATE s SET Status = 'Confirmed', UpdatedAt = SYSUTCDATETIME()
FROM dbo.TutoringSessions s
WHERE s.SessionId = @Id AND s.TutorId = @Me AND s.Status = 'Requested' AND s.StartsAt > SYSUTCDATETIME()
  AND NOT EXISTS (SELECT 1 FROM dbo.TutoringSessions o
                  WHERE o.TutorId = @Me AND o.Status = 'Confirmed' AND o.SessionId <> s.SessionId
                    AND o.StartsAt < DATEADD(MINUTE, s.DurationMinutes, s.StartsAt)
                    AND DATEADD(MINUTE, o.DurationMinutes, o.StartsAt) > s.StartsAt);
SELECT @@ROWCOUNT;";
                    ok = "Session confirmed. It's now in your confirmed sessions.";
                    fail = "That request can't be accepted. It may have expired, been withdrawn, or clash with another confirmed session.";
                    break;

                case "Decline":
                    sql = @"
UPDATE dbo.TutoringSessions SET Status = 'Declined', UpdatedAt = SYSUTCDATETIME()
WHERE SessionId = @Id AND TutorId = @Me AND Status = 'Requested';
SELECT @@ROWCOUNT;";
                    ok = "Request declined.";
                    fail = "That request was already answered.";
                    break;

                case "Cancel":
                    sql = @"
UPDATE dbo.TutoringSessions
SET Status = 'Cancelled', CancelledByUserId = @Me, UpdatedAt = SYSUTCDATETIME()
WHERE SessionId = @Id AND TutorId = @Me AND Status = 'Confirmed' AND StartsAt > SYSUTCDATETIME();
SELECT @@ROWCOUNT;";
                    ok = "Session cancelled. Consider messaging the student to rebook.";
                    fail = "That session can't be cancelled any more.";
                    break;

                case "Complete":
                    var noteBox = e.Item.FindControl("txtTutorNote") as TextBox;
                    string note = noteBox == null ? "" : noteBox.Text.Trim();
                    if (note.Length > 1000) note = note.Substring(0, 1000);
                    parameters.Add(P("@Note", note));
                    sql = @"
UPDATE dbo.TutoringSessions
SET Status = 'Completed', TutorNote = COALESCE(NULLIF(@Note, N''), TutorNote), UpdatedAt = SYSUTCDATETIME()
WHERE SessionId = @Id AND TutorId = @Me AND Status = 'Confirmed' AND StartsAt <= SYSUTCDATETIME();
SELECT @@ROWCOUNT;";
                    ok = "Marked as completed. The student can now review the session.";
                    fail = "Only a confirmed session that has already started can be completed.";
                    break;

                default:
                    return;
            }

            string result = Execute(sql, parameters.ToArray());
            if (result != null) ShowFlash(result == "1" ? ok : fail, result == "1");
        }

        // ---------- Availability ----------

        protected void btnAddSlot_Click(object sender, EventArgs e)
        {
            hdnPane.Value = "pane-availability";

            TimeSpan start, end;
            int day;
            if (!int.TryParse(ddlDay.SelectedValue, out day) || day < 1 || day > 7 ||
                !TryParseClock(txtSlotStart.Text, out start) || !TryParseClock(txtSlotEnd.Text, out end))
            {
                ShowFlash("Pick a day and enter both times as HH:MM.", false);
                return;
            }
            if (end <= start)
            {
                ShowFlash("The end time must be after the start time.", false);
                return;
            }
            if ((end - start).TotalMinutes < 30)
            {
                ShowFlash("A slot should be at least 30 minutes long.", false);
                return;
            }

            string result = Execute(@"
INSERT INTO dbo.TutorAvailability (TutorId, DayOfWeek, StartTime, EndTime)
SELECT @Me, @Day, @Start, @End
WHERE NOT EXISTS (SELECT 1 FROM dbo.TutorAvailability
                  WHERE TutorId = @Me AND DayOfWeek = @Day AND StartTime < @End AND EndTime > @Start);
SELECT @@ROWCOUNT;",
                P("@Me", Me), P("@Day", day),
                new SqlParameter("@Start", SqlDbType.Time) { Value = start },
                new SqlParameter("@End", SqlDbType.Time) { Value = end });

            if (result == null) return;
            if (result == "1")
                ShowFlash("Added " + DayNames[day - 1] + ", " + Clock(start) + " to " + Clock(end) + ".", true);
            else
                ShowFlash("That overlaps a slot you already have on " + DayNames[day - 1] + ".", false);
        }

        protected void rptSlots_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "DeleteSlot") return;
            hdnPane.Value = "pane-availability";

            string result = Execute(@"
DELETE FROM dbo.TutorAvailability WHERE AvailabilityId = @Id AND TutorId = @Me;
SELECT @@ROWCOUNT;", P("@Me", Me), P("@Id", Convert.ToInt32(e.CommandArgument)));

            if (result != null) ShowFlash(result == "1" ? "Slot removed." : "That slot was already removed.", true);
        }

        // ---------- Messages ----------

        protected void rptMessages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Reply") return;
            hdnPane.Value = "pane-messages";

            var box = e.Item.FindControl("txtMsgReply") as TextBox;
            string body = box == null ? "" : box.Text.Trim();
            if (body.Length == 0)
            {
                ShowFlash("Type a reply first.", false);
                return;
            }
            if (body.Length > 2000) body = body.Substring(0, 2000);

            // Reply goes back to whoever sent the message, on the same booking thread.
            string result = Execute(@"
INSERT INTO dbo.Messages (SenderId, RecipientId, SessionId, Body)
SELECT @Me, m.SenderId, m.SessionId, @Body
FROM dbo.Messages m
WHERE m.MessageId = @Id AND m.RecipientId = @Me;
DECLARE @sent INT = @@ROWCOUNT;
UPDATE dbo.Messages SET ReadAt = SYSUTCDATETIME() WHERE MessageId = @Id AND RecipientId = @Me AND ReadAt IS NULL;
SELECT @sent;", P("@Me", Me), P("@Id", Convert.ToInt32(e.CommandArgument)), P("@Body", body));

            if (result != null) ShowFlash(result == "1" ? "Reply sent." : "That message can't be answered.", result == "1");
        }

        protected void btnMarkRead_Click(object sender, EventArgs e)
        {
            hdnPane.Value = "pane-messages";
            string result = Execute(@"
UPDATE dbo.Messages SET ReadAt = SYSUTCDATETIME() WHERE RecipientId = @Me AND ReadAt IS NULL;
SELECT @@ROWCOUNT;", P("@Me", Me));
            if (result != null) ShowFlash(result == "0" ? "Everything was already read." : "Marked " + result + " message(s) as read.", true);
        }

        // ---------- Courses ----------

        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int courseId = Convert.ToInt32(e.CommandArgument);
            hdnPane.Value = "pane-courses";
            string result;

            switch (e.CommandName)
            {
                case "Lessons":
                    lessonCourseToSelect = courseId.ToString(CultureInfo.InvariantCulture);
                    ResetLessonForm();
                    hdnPane.Value = "pane-lessons";
                    return;

                case "EditCourse":
                    LoadCourseIntoForm(courseId);
                    return;

                case "Submit":
                    if (!IsVerified)
                    {
                        ShowFlash("Only verified tutors can submit courses for publishing. Upload your certificate on Account & Verification.", false);
                        return;
                    }
                    result = Execute(@"
UPDATE dbo.Courses SET ReviewRequestedAt = SYSUTCDATETIME()
WHERE CourseId = @Id AND TutorId = @Me AND IsPublished = 0 AND ReviewRequestedAt IS NULL
  AND EXISTS (SELECT 1 FROM dbo.CourseLessons l WHERE l.CourseId = @Id)
  AND Description IS NOT NULL AND LEN(Description) > 0;
SELECT @@ROWCOUNT;", P("@Me", Me), P("@Id", courseId));
                    if (result != null)
                        ShowFlash(result == "1"
                            ? "Submitted. An admin will review and publish it."
                            : "Add a description and at least one lesson before submitting.", result == "1");
                    return;

                case "Withdraw":
                    result = Execute(@"
UPDATE dbo.Courses SET ReviewRequestedAt = NULL
WHERE CourseId = @Id AND TutorId = @Me AND IsPublished = 0;
SELECT @@ROWCOUNT;", P("@Me", Me), P("@Id", courseId));
                    if (result != null) ShowFlash("Review request withdrawn. The course is back to a private draft.", true);
                    return;

                case "DeleteCourse":
                    // Drafts with no learners only; lessons cascade.
                    result = Execute(@"
DELETE FROM dbo.Courses
WHERE CourseId = @Id AND TutorId = @Me AND IsPublished = 0
  AND NOT EXISTS (SELECT 1 FROM dbo.Enrollments e WHERE e.CourseId = @Id);
SELECT @@ROWCOUNT;", P("@Me", Me), P("@Id", courseId));
                    if (result != null)
                    {
                        ShowFlash(result == "1" ? "Draft deleted." : "Only unpublished courses without learners can be deleted.", result == "1");
                        if (hdnCourseId.Value == courseId.ToString(CultureInfo.InvariantCulture)) ResetCourseForm();
                    }
                    return;
            }
        }

        private void LoadCourseIntoForm(int courseId)
        {
            DataTable t;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    t = Query(conn, @"
SELECT CourseCode, Title, Category, Level, Description
FROM dbo.Courses WHERE CourseId = @Id AND TutorId = @Me;", P("@Me", Me), P("@Id", courseId));
                }
            }
            catch (SqlException)
            {
                ShowFlash("That course could not be loaded.", false);
                return;
            }

            if (t.Rows.Count == 0)
            {
                ShowFlash("That course isn't one of yours.", false);
                return;
            }

            DataRow row = t.Rows[0];
            hdnCourseId.Value = courseId.ToString(CultureInfo.InvariantCulture);
            txtCourseCode.Text = Convert.ToString(row["CourseCode"]);
            txtCourseCode.ReadOnly = true;
            txtCourseTitle.Text = Convert.ToString(row["Title"]);
            SelectOrAdd(ddlCategory, Convert.ToString(row["Category"]));
            SelectOrAdd(ddlLevel, Convert.ToString(row["Level"]));
            txtCourseDesc.Text = Convert.ToString(row["Description"]);
            litCourseFormTitle.Text = "Edit " + Server.HtmlEncode(txtCourseCode.Text);
            btnSaveCourse.Text = "Save changes";
            btnCancelCourse.Text = "Cancel editing";
            litFocusForm.Text = "courseForm";
        }

        protected void btnSaveCourse_Click(object sender, EventArgs e)
        {
            hdnPane.Value = "pane-courses";

            string code = txtCourseCode.Text.Trim().ToUpperInvariant();
            string title = txtCourseTitle.Text.Trim();
            string category = ddlCategory.SelectedValue;
            string level = ddlLevel.SelectedValue;
            string desc = txtCourseDesc.Text.Trim();
            bool editing = hdnCourseId.Value.Length > 0;

            if (!editing && !Regex.IsMatch(code, "^[A-Z0-9-]{3,20}$"))
            {
                ShowFlash("Course code must be 3-20 letters, numbers or dashes, e.g. SAV150.", false);
                return;
            }
            if (title.Length == 0 || title.Length > 200)
            {
                ShowFlash("Give the course a title (up to 200 characters).", false);
                return;
            }
            if (Array.IndexOf(CourseLevels, level) < 0 || category.Length == 0)
            {
                ShowFlash("Pick a category and level.", false);
                return;
            }
            if (desc.Length > 1000)
            {
                ShowFlash("The description can be at most 1,000 characters.", false);
                return;
            }

            object descValue = desc.Length == 0 ? (object)DBNull.Value : desc;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    if (editing)
                    {
                        using (var cmd = new SqlCommand(@"
UPDATE dbo.Courses SET Title = @Title, Category = @Category, Level = @Level, Description = @Desc
WHERE CourseId = @Id AND TutorId = @Me;", conn))
                        {
                            cmd.Parameters.AddRange(new[] { P("@Title", title), P("@Category", category), P("@Level", level),
                                P("@Desc", descValue), P("@Id", Convert.ToInt32(hdnCourseId.Value)), P("@Me", Me) });
                            if (cmd.ExecuteNonQuery() == 0)
                            {
                                ShowFlash("That course isn't one of yours any more.", false);
                                return;
                            }
                        }
                        ShowFlash(title + " was updated.", true);
                    }
                    else
                    {
                        using (var cmd = new SqlCommand(@"
INSERT INTO dbo.Courses (CourseCode, Title, Category, Level, Lessons, IsPublished, Description, TutorId)
VALUES (@Code, @Title, @Category, @Level, 0, 0, @Desc, @Me);
SELECT CAST(SCOPE_IDENTITY() AS INT);", conn))
                        {
                            cmd.Parameters.AddRange(new[] { P("@Code", code), P("@Title", title), P("@Category", category),
                                P("@Level", level), P("@Desc", descValue), P("@Me", Me) });
                            int newId = Convert.ToInt32(cmd.ExecuteScalar());

                            // Straight to the lessons for the new course.
                            lessonCourseToSelect = newId.ToString(CultureInfo.InvariantCulture);
                            hdnPane.Value = "pane-lessons";
                        }
                        ShowFlash("Draft " + code + " created. Now add its lessons.", true);
                    }
                }
                ResetCourseForm();
            }
            catch (SqlException ex)
            {
                // 2627 / 2601 = unique key violation (UQ_Courses_CourseCode)
                ShowFlash(ex.Number == 2627 || ex.Number == 2601
                    ? "The code " + code + " is already used by another course."
                    : "The course could not be saved. Check the database connection.", false);
            }
        }

        protected void btnCancelCourse_Click(object sender, EventArgs e)
        {
            hdnPane.Value = "pane-courses";
            ResetCourseForm();
        }

        private void ResetCourseForm()
        {
            hdnCourseId.Value = string.Empty;
            txtCourseCode.Text = txtCourseTitle.Text = txtCourseDesc.Text = string.Empty;
            txtCourseCode.ReadOnly = false;
            ddlCategory.SelectedIndex = 0;
            ddlLevel.SelectedIndex = 0;
            litCourseFormTitle.Text = "Create a course";
            btnSaveCourse.Text = "Save draft";
            btnCancelCourse.Text = "Clear";
        }

        // ---------- Lessons ----------

        protected void ddlLessonCourse_SelectedIndexChanged(object sender, EventArgs e)
        {
            hdnPane.Value = "pane-lessons";
            ResetLessonForm();
        }

        protected void rptLessons_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            hdnPane.Value = "pane-lessons";
            int lessonId = Convert.ToInt32(e.CommandArgument);
            string result;

            switch (e.CommandName)
            {
                case "Up":
                case "Down":
                    // Swap positions with the neighbour in one statement (the unique
                    // (CourseId, Position) key is checked when the statement ends).
                    result = Execute(@"
DECLARE @Course INT, @Pos INT, @Other INT, @OtherPos INT;
SELECT @Course = l.CourseId, @Pos = l.Position
FROM dbo.CourseLessons l JOIN dbo.Courses c ON c.CourseId = l.CourseId
WHERE l.LessonId = @Id AND c.TutorId = @Me;

SELECT TOP 1 @Other = LessonId, @OtherPos = Position
FROM dbo.CourseLessons
WHERE CourseId = @Course AND ((@Dir = -1 AND Position < @Pos) OR (@Dir = 1 AND Position > @Pos))
ORDER BY CASE WHEN @Dir = -1 THEN -Position ELSE Position END;

IF @Other IS NULL
    SELECT 0;
ELSE
BEGIN
    UPDATE dbo.CourseLessons
    SET Position = CASE WHEN LessonId = @Id THEN @OtherPos ELSE @Pos END
    WHERE LessonId IN (@Id, @Other);
    SELECT 1;
END", P("@Me", Me), P("@Id", lessonId), P("@Dir", e.CommandName == "Up" ? -1 : 1));
                    if (result == "0") ShowFlash(e.CommandName == "Up" ? "That lesson is already first." : "That lesson is already last.", true);
                    return;

                case "EditLesson":
                    LoadLessonIntoForm(lessonId);
                    return;

                case "DeleteLesson":
                    // Delete, close the gap in positions, keep Courses.Lessons in step.
                    result = Execute(@"
DECLARE @Course INT, @Pos INT;
SELECT @Course = l.CourseId, @Pos = l.Position
FROM dbo.CourseLessons l JOIN dbo.Courses c ON c.CourseId = l.CourseId
WHERE l.LessonId = @Id AND c.TutorId = @Me;

IF @Course IS NULL
    SELECT 0;
ELSE
BEGIN
    DELETE FROM dbo.CourseLessons WHERE LessonId = @Id;
    UPDATE dbo.CourseLessons SET Position = Position - 1 WHERE CourseId = @Course AND Position > @Pos;
    UPDATE dbo.Courses SET Lessons = (SELECT COUNT(*) FROM dbo.CourseLessons WHERE CourseId = @Course)
    WHERE CourseId = @Course;
    SELECT 1;
END", P("@Me", Me), P("@Id", lessonId));
                    if (result != null)
                    {
                        ShowFlash(result == "1" ? "Lesson deleted." : "That lesson was already deleted.", true);
                        if (hdnLessonId.Value == lessonId.ToString(CultureInfo.InvariantCulture)) ResetLessonForm();
                    }
                    return;
            }
        }

        private void LoadLessonIntoForm(int lessonId)
        {
            DataTable t;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    t = Query(conn, @"
SELECT l.CourseId, l.Position, l.Title, l.ContentType, l.ContentUrl, l.Body, l.DurationMinutes, l.ARSceneKey, l.ARConfig
FROM dbo.CourseLessons l JOIN dbo.Courses c ON c.CourseId = l.CourseId
WHERE l.LessonId = @Id AND c.TutorId = @Me;", P("@Me", Me), P("@Id", lessonId));
                }
            }
            catch (SqlException)
            {
                ShowFlash("That lesson could not be loaded.", false);
                return;
            }

            if (t.Rows.Count == 0)
            {
                ShowFlash("That lesson isn't in one of your courses.", false);
                return;
            }

            DataRow row = t.Rows[0];
            lessonCourseToSelect = Convert.ToString(row["CourseId"]);
            hdnLessonId.Value = lessonId.ToString(CultureInfo.InvariantCulture);
            txtLessonTitle.Text = Convert.ToString(row["Title"]);
            SelectOrAdd(ddlLessonType, Convert.ToString(row["ContentType"]));
            txtLessonMinutes.Text = Convert.ToString(row["DurationMinutes"]);
            txtLessonUrl.Text = Convert.ToString(row["ContentUrl"]);
            txtLessonBody.Text = Convert.ToString(row["Body"]);
            string scene = Convert.ToString(row["ARSceneKey"]);
            if (ddlArScene.Items.FindByValue(scene) != null) ddlArScene.SelectedValue = scene;
            FillArSettings(scene, Convert.ToString(row["ARConfig"]));

            litLessonFormTitle.Text = "Edit lesson " + Convert.ToString(row["Position"]);
            btnSaveLesson.Text = "Save lesson";
            btnCancelLesson.Text = "Cancel editing";
            litFocusForm.Text = "lessonForm";
        }

        protected void btnSaveLesson_Click(object sender, EventArgs e)
        {
            hdnPane.Value = "pane-lessons";

            int courseId;
            if (!int.TryParse(ddlLessonCourse.SelectedValue, out courseId))
            {
                ShowFlash("Pick a course first.", false);
                return;
            }

            string title = txtLessonTitle.Text.Trim();
            string type = ddlLessonType.SelectedValue;
            string url = txtLessonUrl.Text.Trim();
            string body = txtLessonBody.Text.Trim();
            string scene = ddlArScene.SelectedValue;
            int minutes;

            if (title.Length == 0 || title.Length > 200)
            {
                ShowFlash("Give the lesson a title (up to 200 characters).", false);
                return;
            }
            if (Array.IndexOf(LessonTypes, type) < 0)
            {
                ShowFlash("Pick a lesson type.", false);
                return;
            }
            if (!int.TryParse(txtLessonMinutes.Text.Trim(), out minutes) || minutes < 1 || minutes > 240)
            {
                ShowFlash("Minutes must be a whole number from 1 to 240.", false);
                return;
            }
            if (type == "Video" && !IsWebLink(url))
            {
                ShowFlash("A video lesson needs a link starting with https://.", false);
                return;
            }
            if (type == "AR" && !ArScenes.ContainsKey(scene))
            {
                ShowFlash("Pick the AR scene this lesson opens.", false);
                return;
            }

            // Store only what the chosen type uses.
            object urlValue = type == "Video" ? (object)url : DBNull.Value;
            object sceneValue = type == "AR" ? (object)scene : DBNull.Value;
            object bodyValue = type != "Video" && body.Length > 0 ? (object)body : DBNull.Value;
            bool editing = hdnLessonId.Value.Length > 0;

            object configValue = DBNull.Value;
            if (type == "AR")
            {
                string configError;
                string config = BuildArConfig(scene, out configError);
                if (configError != null)
                {
                    ShowFlash(configError, false);
                    return;
                }
                if (config != null) configValue = config;
            }

            var parameters = new[]
            {
                P("@Me", Me), P("@Course", courseId), P("@Title", title), P("@Type", type),
                P("@Url", urlValue), P("@Body", bodyValue), P("@Minutes", minutes), P("@Scene", sceneValue),
                new SqlParameter("@Config", SqlDbType.NVarChar, -1) { Value = configValue },
                P("@Id", editing ? Convert.ToInt32(hdnLessonId.Value) : 0)
            };

            string sql = editing
                ? @"
UPDATE l SET Title = @Title, ContentType = @Type, ContentUrl = @Url, Body = @Body,
             DurationMinutes = @Minutes, ARSceneKey = @Scene, ARConfig = @Config
FROM dbo.CourseLessons l JOIN dbo.Courses c ON c.CourseId = l.CourseId
WHERE l.LessonId = @Id AND c.TutorId = @Me;
SELECT @@ROWCOUNT;"
                : @"
INSERT INTO dbo.CourseLessons (CourseId, Position, Title, ContentType, ContentUrl, Body, DurationMinutes, ARSceneKey, ARConfig)
SELECT c.CourseId,
       ISNULL((SELECT MAX(Position) FROM dbo.CourseLessons x WHERE x.CourseId = c.CourseId), 0) + 1,
       @Title, @Type, @Url, @Body, @Minutes, @Scene, @Config
FROM dbo.Courses c
WHERE c.CourseId = @Course AND c.TutorId = @Me;
DECLARE @added INT = @@ROWCOUNT;
UPDATE dbo.Courses SET Lessons = (SELECT COUNT(*) FROM dbo.CourseLessons WHERE CourseId = @Course)
WHERE CourseId = @Course AND TutorId = @Me;
SELECT @added;";

            string result = Execute(sql, parameters);
            if (result == null) return;

            if (result == "1")
            {
                ShowFlash(editing ? "Lesson saved." : "Lesson added to the end of the course.", true);
                lessonCourseToSelect = courseId.ToString(CultureInfo.InvariantCulture);
                ResetLessonForm();
            }
            else
            {
                ShowFlash("That lesson could not be saved to this course.", false);
            }
        }

        protected void btnCancelLesson_Click(object sender, EventArgs e)
        {
            hdnPane.Value = "pane-lessons";
            ResetLessonForm();
        }

        private void ResetLessonForm()
        {
            hdnLessonId.Value = string.Empty;
            txtLessonTitle.Text = txtLessonUrl.Text = txtLessonBody.Text = string.Empty;
            txtLessonMinutes.Text = "10";
            ddlLessonType.SelectedIndex = 0;
            if (ddlArScene.Items.Count > 0) ddlArScene.SelectedIndex = 0;
            txtArIncome.Text = txtArCards.Text = txtArMonthly.Text = txtArRate.Text = txtArYears.Text = string.Empty;
            litLessonFormTitle.Text = "Add a lesson";
            btnSaveLesson.Text = "Add lesson";
            btnCancelLesson.Text = "Clear";
        }

        // ---------- AR activity settings (CourseLessons.ARConfig) ----------
        // The JSON shapes match what assets/js/ar/budget-jars.js and compound-growth.js read.

        private string BuildArConfig(string scene, out string error)
        {
            error = null;
            var json = new JavaScriptSerializer();

            if (scene == "budget-jars")
            {
                string incomeText = txtArIncome.Text.Trim();
                string cardsText = txtArCards.Text.Trim();
                if (incomeText.Length == 0 && cardsText.Length == 0) return null; // built-in example month

                var config = new Dictionary<string, object> { { "currency", "RM" } };
                decimal income;
                if (incomeText.Length > 0)
                {
                    if (!decimal.TryParse(incomeText, NumberStyles.Number, CultureInfo.InvariantCulture, out income) || income <= 0 || income > 1000000)
                    {
                        error = "Monthly income must be a number above 0, without \"RM\".";
                        return null;
                    }
                    config["income"] = income;
                }

                var cards = new List<object>();
                string[] lines = cardsText.Split('\n');
                for (int i = 0; i < lines.Length; i++)
                {
                    string line = lines[i].Trim();
                    if (line.Length == 0) continue;
                    string[] parts = line.Split(',');
                    decimal amount;
                    string jar = parts.Length == 3 ? parts[2].Trim().ToLowerInvariant() : "";
                    if (parts.Length != 3 || parts[0].Trim().Length == 0 || parts[0].Trim().Length > 30 ||
                        !decimal.TryParse(parts[1].Trim(), NumberStyles.Number, CultureInfo.InvariantCulture, out amount) || amount <= 0 ||
                        (jar != "needs" && jar != "wants" && jar != "savings"))
                    {
                        error = "Expense card line " + (i + 1) + " should look like: Rent, 900, needs (name up to 30 characters, amount without commas, then needs, wants or savings).";
                        return null;
                    }
                    cards.Add(new Dictionary<string, object> { { "name", parts[0].Trim() }, { "amount", amount }, { "jar", jar } });
                }
                if (cardsText.Length > 0 && (cards.Count < 2 || cards.Count > 12))
                {
                    error = "Give the budget jars activity between 2 and 12 expense cards.";
                    return null;
                }
                if (cards.Count > 0) config["cards"] = cards;
                return json.Serialize(config);
            }

            if (scene == "compound-growth")
            {
                var config = new Dictionary<string, object> { { "currency", "RM" } };
                decimal value;
                if (!ReadOptional(txtArMonthly.Text, 10, 2000, out value, ref error, "Monthly saving must be between 10 and 2000.")) return null;
                if (value > 0) config["monthly"] = value;
                if (!ReadOptional(txtArRate.Text, 0, 12, out value, ref error, "Interest per year must be between 0 and 12 (%).")) return null;
                if (txtArRate.Text.Trim().Length > 0) config["ratePercent"] = value;
                if (!ReadOptional(txtArYears.Text, 1, 40, out value, ref error, "Years must be between 1 and 40.")) return null;
                if (value > 0) config["years"] = (int)value;
                return config.Count == 1 ? null : json.Serialize(config);
            }

            return null; // other scenes have no settings yet
        }

        private static bool ReadOptional(string text, decimal min, decimal max, out decimal value, ref string error, string message)
        {
            value = 0;
            text = (text ?? "").Trim();
            if (text.Length == 0) return true;
            if (decimal.TryParse(text, NumberStyles.Number, CultureInfo.InvariantCulture, out value) && value >= min && value <= max) return true;
            error = message;
            return false;
        }

        private void FillArSettings(string scene, string configJson)
        {
            txtArIncome.Text = txtArCards.Text = txtArMonthly.Text = txtArRate.Text = txtArYears.Text = string.Empty;
            if (string.IsNullOrWhiteSpace(configJson)) return;

            Dictionary<string, object> config;
            try { config = new JavaScriptSerializer().Deserialize<Dictionary<string, object>>(configJson); }
            catch (ArgumentException) { return; }
            catch (InvalidOperationException) { return; }
            if (config == null) return;

            Func<string, string> get = key => config.ContainsKey(key) && config[key] != null
                ? Convert.ToString(config[key], CultureInfo.InvariantCulture) : string.Empty;

            if (scene == "budget-jars")
            {
                txtArIncome.Text = get("income");
                var cards = config.ContainsKey("cards") ? config["cards"] as System.Collections.ArrayList : null;
                if (cards != null)
                {
                    var lines = new List<string>();
                    foreach (object item in cards)
                    {
                        var card = item as Dictionary<string, object>;
                        if (card == null || !card.ContainsKey("name") || !card.ContainsKey("amount") || !card.ContainsKey("jar")) continue;
                        lines.Add(Convert.ToString(card["name"]) + ", " +
                                  Convert.ToString(card["amount"], CultureInfo.InvariantCulture) + ", " +
                                  Convert.ToString(card["jar"]));
                    }
                    txtArCards.Text = string.Join("\n", lines);
                }
            }
            else if (scene == "compound-growth")
            {
                txtArMonthly.Text = get("monthly");
                txtArRate.Text = get("ratePercent");
                txtArYears.Text = get("years");
            }
        }

        // ---------- Reviews ----------

        protected void rptReviews_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Reply") return;
            hdnPane.Value = "pane-reviews";

            string[] parts = Convert.ToString(e.CommandArgument).Split(':');
            int key;
            if (parts.Length != 2 || !int.TryParse(parts[1], out key)) return;

            var box = e.Item.FindControl("txtReply") as TextBox;
            string reply = box == null ? "" : box.Text.Trim();
            if (reply.Length == 0)
            {
                ShowFlash("Write your reply first.", false);
                return;
            }
            if (reply.Length > 1000) reply = reply.Substring(0, 1000);

            // One reply per review; only on reviews of this tutor's courses / sessions.
            string sql = parts[0] == "C"
                ? @"
UPDATE r SET TutorReply = @Reply, TutorRepliedAt = SYSUTCDATETIME()
FROM dbo.CourseReviews r JOIN dbo.Courses c ON c.CourseId = r.CourseId
WHERE r.ReviewId = @Key AND c.TutorId = @Me AND r.TutorReply IS NULL;
SELECT @@ROWCOUNT;"
                : @"
UPDATE sr SET TutorReply = @Reply, TutorRepliedAt = SYSUTCDATETIME()
FROM dbo.SessionReviews sr JOIN dbo.TutoringSessions s ON s.SessionId = sr.SessionId
WHERE sr.SessionId = @Key AND s.TutorId = @Me AND sr.TutorReply IS NULL;
SELECT @@ROWCOUNT;";

            string result = Execute(sql, P("@Me", Me), P("@Key", key), P("@Reply", reply));
            if (result != null) ShowFlash(result == "1" ? "Reply posted." : "That review already has a reply.", result == "1");
        }

        // ---------- Teaching profile ----------

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            hdnPane.Value = "pane-profile";

            string headline = txtHeadline.Text.Trim();
            string bio = txtBio.Text.Trim();
            string link = txtMeetingLink.Text.Trim();

            if (headline.Length == 0 || headline.Length > 150)
            {
                ShowFlash("Add a headline (up to 150 characters).", false);
                return;
            }
            if (bio.Length > 2000)
            {
                ShowFlash("About you can be at most 2,000 characters.", false);
                return;
            }
            if (link.Length > 0 && !IsWebLink(link))
            {
                ShowFlash("The meeting link must start with https://.", false);
                return;
            }

            string result = Execute(@"
UPDATE dbo.TutorProfiles
SET Headline = @Headline, Bio = @Bio, MeetingLink = @Link, IsAcceptingStudents = @Accepting, UpdatedAt = SYSUTCDATETIME()
WHERE UserId = @Me;
IF @@ROWCOUNT = 0
    INSERT INTO dbo.TutorProfiles (UserId, Headline, Bio, MeetingLink, IsAcceptingStudents)
    VALUES (@Me, @Headline, @Bio, @Link, @Accepting);
SELECT 1;",
                P("@Me", Me), P("@Headline", headline),
                P("@Bio", bio.Length == 0 ? (object)DBNull.Value : bio),
                P("@Link", link.Length == 0 ? (object)DBNull.Value : link),
                P("@Accepting", chkAccepting.Checked));

            if (result != null) ShowFlash("Teaching profile saved.", true);
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Signin.aspx");
        }

        // ---------- Data helpers ----------

        private static SqlParameter P(string name, object value)
        {
            return new SqlParameter(name, value ?? DBNull.Value);
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

        // Runs a batch and returns the first column of its last result, or null on a database error.
        private string Execute(string sql, params SqlParameter[] parameters)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddRange(parameters);
                    conn.Open();
                    string last = null;
                    using (var reader = cmd.ExecuteReader())
                    {
                        do
                        {
                            while (reader.Read()) last = Convert.ToString(reader.GetValue(0), CultureInfo.InvariantCulture);
                        } while (reader.NextResult());
                    }
                    return last ?? string.Empty;
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

        private static void SelectOrAdd(DropDownList list, string value)
        {
            if (string.IsNullOrEmpty(value)) return;
            if (list.Items.FindByValue(value) == null) list.Items.Add(new ListItem(value, value));
            list.SelectedValue = value;
        }

        private static bool TryParseClock(string text, out TimeSpan value)
        {
            // <input type="time"> posts "HH:mm" (sometimes "HH:mm:ss").
            return TimeSpan.TryParseExact((text ?? "").Trim(), new[] { @"hh\:mm", @"hh\:mm\:ss", @"h\:mm" },
                CultureInfo.InvariantCulture, out value) && value < TimeSpan.FromDays(1);
        }

        private static bool IsWebLink(string url)
        {
            Uri uri;
            return Uri.TryCreate(url, UriKind.Absolute, out uri) && uri.Scheme == Uri.UriSchemeHttps;
        }

        // ---------- Template helpers ----------

        protected static string Html(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value));
        }

        protected static string Attr(object value)
        {
            return HttpUtility.HtmlAttributeEncode(Convert.ToString(value));
        }

        private static DateTime ToMalaysia(object utc)
        {
            return DateTime.SpecifyKind(Convert.ToDateTime(utc), DateTimeKind.Utc).Add(MalaysiaOffset);
        }

        protected static string FormatDate(object utc)
        {
            return utc == null || utc == DBNull.Value
                ? string.Empty
                : ToMalaysia(utc).ToString("d MMM yyyy", CultureInfo.InvariantCulture);
        }

        // Session times, e.g. "Wed 14 Oct 2026, 7:00 PM" (Malaysia time).
        protected static string Myt(object utc)
        {
            return utc == null || utc == DBNull.Value
                ? string.Empty
                : ToMalaysia(utc).ToString("ddd d MMM yyyy, h:mm tt", CultureInfo.InvariantCulture);
        }

        protected static string Clock(object time)
        {
            if (time == null || time == DBNull.Value) return string.Empty;
            TimeSpan t = (TimeSpan)time;
            return DateTime.Today.Add(t).ToString("h:mm tt", CultureInfo.InvariantCulture);
        }

        protected static string DayName(object day)
        {
            int d = Convert.ToInt32(day);
            return d >= 1 && d <= 7 ? DayNames[d - 1] : string.Empty;
        }

        protected static string StatusTag(object status)
        {
            string s = Convert.ToString(status);
            string css;
            switch (s)
            {
                case "Requested": css = "tag tag--accent"; break;
                case "Confirmed": css = "tag tag--ok"; break;
                case "Completed": css = "tag"; break;
                default: css = "tag tag--warn"; break;   // Cancelled, Declined, Expired
            }
            return "<span class=\"" + css + "\">" + Html(s) + "</span>";
        }

        protected static string CourseStatusTag(object isPublished, object reviewRequestedAt)
        {
            if (Convert.ToBoolean(isPublished)) return "<span class=\"tag tag--live\">Published</span>";
            if (reviewRequestedAt != null && reviewRequestedAt != DBNull.Value)
                return "<span class=\"tag tag--accent\" title=\"Submitted " + FormatDate(reviewRequestedAt) + "\">In review</span>";
            return "<span class=\"tag\">Draft</span>";
        }

        protected static string TypeTag(object type)
        {
            string t = Convert.ToString(type);
            return t == "AR"
                ? "<span class=\"tag tag--accent\"><i class=\"bi bi-badge-ar\" aria-hidden=\"true\"></i>AR</span>"
                : "<span class=\"tag\">" + Html(t) + "</span>";
        }

        protected static string LessonDetail(object type, object url, object scene)
        {
            string t = Convert.ToString(type);
            string detail = null;
            string sceneKey = Convert.ToString(scene);
            string link = Convert.ToString(url);

            if (t == "AR" && sceneKey.Length > 0)
            {
                string label;
                detail = ArScenes.TryGetValue(sceneKey, out label) ? label : sceneKey;
            }
            else if (t == "Video" && link.Length > 0)
            {
                Uri uri;
                detail = Uri.TryCreate(link, UriKind.Absolute, out uri) ? uri.Host : link;
            }

            return detail == null ? string.Empty : "<br /><span class=\"md-row__meta\">" + Html(detail) + "</span>";
        }

        protected static string LinkHtml(object link)
        {
            string url = Convert.ToString(link);
            if (!IsWebLink(url)) return string.Empty;
            return " · <a href=\"" + Attr(url) + "\" target=\"_blank\" rel=\"noopener\">Meeting link</a>";
        }

        // A short quoted note: a student's request, a review, or the tutor's reply.
        protected static string Quote(object text, string label, bool fromTutor)
        {
            string value = Convert.ToString(text);
            if (value.Length == 0) return string.Empty;
            return "<p class=\"td-quote" + (fromTutor ? " td-quote--tutor" : "") + "\">" +
                (label == null ? "" : "<small>" + Html(label) + "</small>") + Html(value) + "</p>";
        }

        protected static string Stars(object rating)
        {
            if (rating == null || rating == DBNull.Value) return "<span class=\"md-row__meta\">-</span>";
            double r = Convert.ToDouble(rating, CultureInfo.InvariantCulture);
            int full = (int)Math.Round(r, MidpointRounding.AwayFromZero);
            full = Math.Max(0, Math.Min(5, full));
            string shown = r.ToString("0.0", CultureInfo.InvariantCulture);
            return "<span class=\"td-stars\" title=\"" + shown + " out of 5\" aria-label=\"" + shown + " out of 5\">" +
                new string('★', full) + new string('☆', 5 - full) + "</span>";
        }

        protected static string MessageCss(object isMine, object readAt)
        {
            bool mine = Convert.ToInt32(isMine) == 1;
            if (mine) return "td-msg td-msg--mine";
            return readAt == null || readAt == DBNull.Value ? "td-msg td-msg--unread" : "td-msg";
        }
    }
}
