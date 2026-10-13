using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace MeowletEducation
{
    // The course player: course.aspx?id=<CourseId>[&lesson=<LessonId>]
    // Enrolled learners read each lesson and mark it complete (LessonProgress),
    // which drives the progress bars on the member and tutor dashboards.
    // Published courses are open to guests in read-only preview (no progress).
    // The course's tutor and admins can also open unpublished drafts as preview.
    public partial class CoursePlayer : Page
    {
        private const string CourseSql = @"
SELECT c.CourseId, c.CourseCode, c.Title, c.Category, c.Level, c.Description, c.IsPublished, c.TutorId,
       ISNULL(t.FullName, N'Meowlet team') AS TutorName,
       CASE WHEN e.UserId IS NULL THEN 0 ELSE 1 END AS IsEnrolled,
       e.CompletedAt
FROM dbo.Courses c
LEFT JOIN dbo.Users t       ON t.UserId = c.TutorId
LEFT JOIN dbo.Enrollments e ON e.CourseId = c.CourseId AND e.UserId = @Me
WHERE c.CourseId = @Course;";

        private const string LessonsSql = @"
SELECT l.LessonId, l.Position, l.Title, l.ContentType, l.ContentUrl, l.Body, l.DurationMinutes, l.ARSceneKey, l.ARConfig,
       CASE WHEN p.LessonId IS NULL THEN 0 ELSE 1 END AS IsDone,
       ar.Summary AS LastArSummary, ar.CompletedAt AS LastArAt
FROM dbo.CourseLessons l
LEFT JOIN dbo.LessonProgress p ON p.LessonId = l.LessonId AND p.UserId = @Me
OUTER APPLY (SELECT TOP 1 r.Summary, r.CompletedAt FROM dbo.ARActivityResults r
             WHERE r.LessonId = l.LessonId AND r.UserId = @Me
             ORDER BY r.CompletedAt DESC) ar
WHERE l.CourseId = @Course
ORDER BY l.Position;";

        // What the course builder put inside each lesson (text, media, quiz).
        // Lessons without blocks fall back to CourseLessons.ContentUrl / Body.
        private const string BlocksSql = @"
IF OBJECT_ID('dbo.LessonBlocks', 'U') IS NOT NULL
    SELECT b.LessonId, b.BlockType, b.MediaKind, b.MediaUrl, b.Body
    FROM dbo.LessonBlocks b
    JOIN dbo.CourseLessons l ON l.LessonId = b.LessonId
    WHERE l.CourseId = @Course
    ORDER BY b.LessonId, b.Position;";

        private static string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString; }
        }

        // Guests (no session) use 0 so the LEFT JOINs still work; progress stays empty.
        private int Me { get { return Session["UserId"] == null ? 0 : Convert.ToInt32(Session["UserId"]); } }
        private string Role { get { return Convert.ToString(Session["Role"]); } }
        private bool IsGuest { get { return Session["UserId"] == null; } }

        private int courseId;
        private DataRow course;
        private DataTable lessons = new DataTable();
        private DataTable blocks = new DataTable();
        private bool isEnrolled, canView, isPreview;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Guests may open published courses in read-only preview mode.
            // Sign-in is only required for unpublished courses or to save progress.

            string schemaError = DbSchema.EnsureUpToDate();
            if (schemaError != null)
                ShowFlash("The database needs updating (" + schemaError + "). Run App_Data/CreateDatabase.sql, then reload.", false);

            lnkBack.NavigateUrl = BackUrl();

            int.TryParse(Request.QueryString["id"], out courseId);
            LoadCourse();
        }

        private void LoadCourse()
        {
            if (courseId <= 0) return;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    DataTable t = Query(conn, CourseSql, P("@Me", Me), P("@Course", courseId));
                    if (t.Rows.Count == 0) return;
                    course = t.Rows[0];
                    lessons = Query(conn, LessonsSql, P("@Me", Me), P("@Course", courseId));
                    blocks = Query(conn, BlocksSql, P("@Course", courseId));
                }
            }
            catch (SqlException ex)
            {
                ShowFlash("Database error: " + ex.Message, false);
                course = null;
                return;
            }

            bool isAdmin = string.Equals(Role, "Admin", StringComparison.OrdinalIgnoreCase);
            bool isOwnTutor = string.Equals(Role, "Tutor", StringComparison.OrdinalIgnoreCase) &&
                course["TutorId"] != DBNull.Value && Convert.ToInt32(course["TutorId"]) == Me;
            bool isPublished = Convert.ToBoolean(course["IsPublished"]);

            isEnrolled = Convert.ToInt32(course["IsEnrolled"]) == 1;
            // Published courses are open to everyone (guest preview or enrolled learner).
            // Unpublished courses stay limited to tutor + admin.
            canView = isEnrolled || isAdmin || isOwnTutor || isPublished;
            isPreview = !isEnrolled && canView;   // guest, tutor, or admin browsing without enrolment
        }

        // Bound last, after any button handler has run.
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            if (!IsPostBack)
            {
                if (Request.QueryString["enrolled"] == "1") ShowFlash("You're enrolled. Start with the first lesson below.", true);
                if (Request.QueryString["done"] == "1") ShowFlash("Lesson marked as complete.", true);
                if (Request.QueryString["finished"] == "1") ShowFlash("You've completed every lesson in this course. Well done!", true);
            }

            if (course == null)
            {
                litTitle.Text = "Course not found";
                ShowMessage("<strong>We couldn't find that course.</strong>It may have been removed. Go back and pick another one.", false);
                return;
            }

            litTitle.Text = Server.HtmlEncode(Convert.ToString(course["Title"]));
            Page.Title = Convert.ToString(course["Title"]) + " - Meowlet Education";
            litMeta.Text = Server.HtmlEncode(course["CourseCode"] + " · " + course["Level"] + " · " + course["Category"] + " · Tutor: " + course["TutorName"]);

            if (!canView)
            {
                bool open = Convert.ToBoolean(course["IsPublished"]) &&
                            string.Equals(Role, "Student", StringComparison.OrdinalIgnoreCase);
                string desc = Convert.ToString(course["Description"]);
                ShowMessage(open
                    ? "<strong>You're not enrolled in this course yet.</strong>" + Server.HtmlEncode(desc.Length > 0 ? desc : "Enrol to open its lessons and track your progress.")
                    : "<strong>This course isn't open to you.</strong>Only enrolled learners, its tutor and admins can open it.", open);
                return;
            }

            phPlayer.Visible = true;
            if (isPreview)
            {
                if (IsGuest)
                    litBanner.Text = "<p class=\"cp-banner\"><i class=\"bi bi-eye\" aria-hidden=\"true\"></i> Guest preview — you can open every lesson. " +
                        "<a href=\"Signup.aspx\">Create a free account</a> to save your progress.</p>";
                else
                    litBanner.Text = "<p class=\"cp-banner\"><i class=\"bi bi-eye\" aria-hidden=\"true\"></i> Preview: you're seeing this course the way learners do. Progress isn't recorded" +
                        (Convert.ToBoolean(course["IsPublished"]) ? "." : ", and learners can't see it until it's published.") + "</p>";
            }

            BindProgress();

            // Pick the lesson first so the list can highlight it.
            DataRow lesson = PickLesson();
            if (lesson != null) currentLessonId = Convert.ToInt32(lesson["LessonId"]);

            rptLessons.DataSource = lessons;
            rptLessons.DataBind();
            phNoLessons.Visible = lessons.Rows.Count == 0;

            phLesson.Visible = lesson != null;
            phNoLesson.Visible = lesson == null;
            if (lesson != null) BindLesson(lesson);
        }

        private void BindProgress()
        {
            if (!isEnrolled || lessons.Rows.Count == 0) return;

            int done = 0;
            foreach (DataRow r in lessons.Rows) if (Convert.ToInt32(r["IsDone"]) == 1) done++;

            int pct = done * 100 / lessons.Rows.Count;
            litProgress.Text =
                "<div class=\"md-progress cp-progress\">" +
                "<span class=\"md-progress__text\"><span>" + done + " of " + lessons.Rows.Count + " lessons</span><span>" + pct + "%</span></span>" +
                "<span class=\"md-progress__track\"><span class=\"md-progress__fill\" style=\"width:" + pct + "%\"></span></span></div>";
        }

        // ?lesson=<id> when valid; otherwise the first unfinished lesson (or the first one).
        private DataRow PickLesson()
        {
            if (lessons.Rows.Count == 0) return null;

            int wanted;
            if (IsPostBack) int.TryParse(hdnLessonId.Value, out wanted);
            else int.TryParse(Request.QueryString["lesson"], out wanted);

            foreach (DataRow r in lessons.Rows)
                if (Convert.ToInt32(r["LessonId"]) == wanted) return r;

            foreach (DataRow r in lessons.Rows)
                if (Convert.ToInt32(r["IsDone"]) == 0) return r;

            return lessons.Rows[0];
        }

        private int currentLessonId;

        private void BindLesson(DataRow lesson)
        {
            int index = lessons.Rows.IndexOf(lesson);
            currentLessonId = Convert.ToInt32(lesson["LessonId"]);
            hdnLessonId.Value = currentLessonId.ToString(CultureInfo.InvariantCulture);

            bool done = Convert.ToInt32(lesson["IsDone"]) == 1;
            string type = Convert.ToString(lesson["ContentType"]);

            litLessonKicker.Text = "Lesson " + (index + 1) + " of " + lessons.Rows.Count + " · " + TypeLabel(type) + " · " + lesson["DurationMinutes"] + " min";
            litLessonTitle.Text = Server.HtmlEncode(Convert.ToString(lesson["Title"]));
            litLessonState.Text = done ? "<span class=\"tag tag--ok\"><i class=\"bi bi-check-lg\" aria-hidden=\"true\"></i>Completed</span>" : "";

            string scene = Convert.ToString(lesson["ARSceneKey"]);
            bool interactiveAr = type == "AR" && InteractiveScenes.Contains(scene);

            string built = interactiveAr ? null : BlocksBody(currentLessonId);
            litLessonBody.Text = interactiveAr
                ? ArActivity(lesson, index) + LessonBody("ARSteps", null, Convert.ToString(lesson["Body"]), scene)
                : built ?? LessonBody(type, Convert.ToString(lesson["ContentUrl"]), Convert.ToString(lesson["Body"]), scene);

            btnComplete.Visible = isEnrolled && !done;
            if (interactiveAr)
            {
                // Finishing the activity completes the lesson. The button only appears
                // (from ar-lesson.js) if the device can't show the activity at all.
                btnComplete.Attributes["hidden"] = "hidden";
                btnComplete.Attributes["data-ar-fallback"] = "true";
            }

            lnkPrev.Visible = index > 0;
            if (index > 0) lnkPrev.NavigateUrl = LessonUrl(lessons.Rows[index - 1]["LessonId"]);

            lnkNext.Visible = index < lessons.Rows.Count - 1;
            if (index < lessons.Rows.Count - 1) lnkNext.NavigateUrl = LessonUrl(lessons.Rows[index + 1]["LessonId"]);
        }

        // ---------- Actions ----------

        protected void btnComplete_Click(object sender, EventArgs e)
        {
            int lessonId;
            if (course == null || !isEnrolled || !int.TryParse(hdnLessonId.Value, out lessonId)) return;

            string finished;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(@"
INSERT INTO dbo.LessonProgress (UserId, LessonId)
SELECT @Me, l.LessonId
FROM dbo.CourseLessons l
JOIN dbo.Enrollments e ON e.CourseId = l.CourseId AND e.UserId = @Me
WHERE l.LessonId = @Lesson AND l.CourseId = @Course
  AND NOT EXISTS (SELECT 1 FROM dbo.LessonProgress p WHERE p.UserId = @Me AND p.LessonId = l.LessonId);

-- Every lesson done: the enrollment is complete.
UPDATE dbo.Enrollments SET CompletedAt = SYSUTCDATETIME()
WHERE UserId = @Me AND CourseId = @Course AND CompletedAt IS NULL
  AND EXISTS (SELECT 1 FROM dbo.CourseLessons l WHERE l.CourseId = @Course)
  AND NOT EXISTS (SELECT 1 FROM dbo.CourseLessons l
                  WHERE l.CourseId = @Course
                    AND NOT EXISTS (SELECT 1 FROM dbo.LessonProgress p WHERE p.UserId = @Me AND p.LessonId = l.LessonId));

SELECT CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;", conn))
                {
                    cmd.Parameters.AddRange(new[] { P("@Me", Me), P("@Lesson", lessonId), P("@Course", courseId) });
                    conn.Open();
                    finished = Convert.ToString(cmd.ExecuteScalar());
                }
            }
            catch (SqlException ex)
            {
                ShowFlash("Your progress could not be saved: " + ex.Message, false);
                return;
            }

            if (finished == "1")
            {
                Response.Redirect("course.aspx?id=" + courseId + "&lesson=" + lessonId + "&finished=1");
                return;
            }

            // On to the next lesson that isn't done yet (after this one), or stay here.
            int next = lessonId;
            bool passed = false;
            foreach (DataRow r in lessons.Rows)
            {
                int id = Convert.ToInt32(r["LessonId"]);
                if (id == lessonId) { passed = true; continue; }
                if (passed && Convert.ToInt32(r["IsDone"]) == 0) { next = id; break; }
            }
            Response.Redirect("course.aspx?id=" + courseId + "&lesson=" + next + "&done=1");
        }

        protected void btnEnrol_Click(object sender, EventArgs e)
        {
            if (course == null || !string.Equals(Role, "Student", StringComparison.OrdinalIgnoreCase)) return;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(@"
INSERT INTO dbo.Enrollments (UserId, CourseId)
SELECT @Me, c.CourseId FROM dbo.Courses c
WHERE c.CourseId = @Course AND c.IsPublished = 1
  AND NOT EXISTS (SELECT 1 FROM dbo.Enrollments x WHERE x.UserId = @Me AND x.CourseId = c.CourseId);", conn))
                {
                    cmd.Parameters.AddRange(new[] { P("@Me", Me), P("@Course", courseId) });
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException ex)
            {
                ShowFlash("You couldn't be enrolled: " + ex.Message, false);
                return;
            }

            Response.Redirect("course.aspx?id=" + courseId + "&enrolled=1");
        }

        // ---------- AR activity ----------

        // Scenes with an interactive activity in assets/js/ar (see ar-lesson.js SCENES).
        private static readonly System.Collections.Generic.HashSet<string> InteractiveScenes =
            new System.Collections.Generic.HashSet<string> { "budget-jars", "compound-growth" };

        private string ArActivity(DataRow lesson, int index)
        {
            int lessonId = Convert.ToInt32(lesson["LessonId"]);
            int nextId = index < lessons.Rows.Count - 1 ? Convert.ToInt32(lessons.Rows[index + 1]["LessonId"]) : lessonId;

            string data = new JavaScriptSerializer().Serialize(new
            {
                lessonId,
                scene = Convert.ToString(lesson["ARSceneKey"]),
                config = Convert.ToString(lesson["ARConfig"]),
                canSave = isEnrolled,
                saveUrl = "ArResult.ashx",
                nextUrl = "course.aspx?id=" + courseId + "&lesson=" + nextId + "&done=1",
                finishedUrl = "course.aspx?id=" + courseId + "&lesson=" + lessonId + "&finished=1"
            }).Replace("<", "\\u003c");   // never let data close the <script> block

            string last = lesson["LastArAt"] == DBNull.Value ? "" :
                "<p class=\"ar-last\"><i class=\"bi bi-clock-history\" aria-hidden=\"true\"></i> Your last attempt (" +
                Convert.ToDateTime(lesson["LastArAt"]).AddHours(8).ToString("d MMM, h:mm tt", CultureInfo.InvariantCulture) + "): " +
                Html(lesson["LastArSummary"]) + "</p>";

            return
                "<div class=\"ar-stage\" id=\"arStage\">" +
                "<div class=\"ar-canvas\" id=\"arCanvas\"></div>" +
                "<div class=\"ar-ui\" id=\"arUi\">" +
                "<div class=\"ar-top\"><p class=\"ar-instruction ar-panel\" id=\"arInstruction\">Loading the activity...</p>" +
                "<button type=\"button\" class=\"btn btn--ghost btn--sm ar-exit\" id=\"arExit\" hidden=\"hidden\">Exit AR</button></div>" +
                "<div class=\"ar-bottom\" id=\"arControls\"></div>" +
                "</div></div>" +
                "<div class=\"ar-launch\">" +
                "<button type=\"button\" class=\"btn btn--primary btn--sm\" id=\"arStartAr\" hidden=\"hidden\"><i class=\"bi bi-badge-ar\" aria-hidden=\"true\"></i>&nbsp;Place it on my table</button>" +
                "<button type=\"button\" class=\"btn btn--ghost btn--sm\" id=\"arStartTrack\" hidden=\"hidden\"><i class=\"bi bi-qr-code-scan\" aria-hidden=\"true\"></i>&nbsp;Use the Meowlet card</button>" +
                "<a class=\"ar-print\" id=\"arPrintCard\" href=\"assets/ar/meowlet-card-print.html\" target=\"_blank\" rel=\"noopener\" hidden=\"hidden\">Print the card</a>" +
                "<span class=\"ar-hint\" id=\"arModeHint\"></span></div>" +
                last +
                "<script type=\"application/json\" id=\"arData\">" + data + "</script>" +
                "<script type=\"module\" src=\"assets/js/ar/ar-lesson.js\"></script>";
        }

        // ---------- Lesson content ----------

        private static readonly Regex YouTubeId = new Regex("^[A-Za-z0-9_-]{6,20}$");

        private string LessonBody(string type, string url, string body, string scene)
        {
            var html = new StringBuilder();

            if (type == "Video")
            {
                string embed = YouTubeEmbed(url);
                if (embed != null)
                    html.Append("<div class=\"cp-video\"><iframe src=\"").Append(HttpUtility.HtmlAttributeEncode(embed))
                        .Append("\" title=\"Lesson video\" allow=\"accelerometer; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"allowfullscreen\"></iframe></div>");
                else if (IsWebLink(url))
                    html.Append("<p><a class=\"btn btn--primary btn--sm\" href=\"").Append(HttpUtility.HtmlAttributeEncode(url))
                        .Append("\" target=\"_blank\" rel=\"noopener\"><i class=\"bi bi-play-circle\" aria-hidden=\"true\"></i>&nbsp;Watch the video</a></p>");
                else
                    html.Append(Note("bi-camera-video", "The tutor hasn't added the video for this lesson yet."));
            }
            else if (type == "ARSteps")
            {
                // Under an interactive activity: the tutor's own notes for it.
                if (!string.IsNullOrWhiteSpace(body))
                    html.Append("<p class=\"cp-kicker\">Notes from your tutor</p>");
                else
                    return string.Empty;
            }
            else if (type == "AR")
            {
                string label;
                if (!TutorDashboard.ArScenes.TryGetValue(scene ?? "", out label)) label = scene;
                html.Append(Note("bi-badge-ar", "<strong>AR activity: " + Html(label) + "</strong><br />" +
                    "The AR viewer is being built (phase 1 of the AR plan). For now, follow the steps below with pen and paper, then mark the lesson complete."));
            }
            else if (type == "Quiz")
            {
                html.Append(Note("bi-patch-question", "Work through the questions below, then mark the lesson complete."));
            }

            if (!string.IsNullOrWhiteSpace(body))
                html.Append("<p class=\"cp-text\">").Append(Html(body)).Append("</p>");
            else if (type != "Video" && type != "ARSteps")
                html.Append("<p class=\"md-row__meta\">The tutor hasn't written this lesson's content yet.</p>");

            return html.ToString();
        }

        // The lesson's builder blocks as HTML, or null when it has none.
        private string BlocksBody(int lessonId)
        {
            var html = new StringBuilder();
            int quizNo = 0;

            foreach (DataRow b in blocks.Rows)
            {
                if (Convert.ToInt32(b["LessonId"]) != lessonId) continue;

                string body = Convert.ToString(b["Body"]);
                string url = Convert.ToString(b["MediaUrl"]);

                switch (Convert.ToString(b["BlockType"]))
                {
                    case "Text":
                        if (!string.IsNullOrWhiteSpace(body))
                            html.Append("<p class=\"cp-text\">").Append(Linkify(body)).Append("</p>");
                        break;

                    case "Media":
                        html.Append(MediaBlock(Convert.ToString(b["MediaKind"]), url, body));
                        break;

                    case "Quiz":
                        html.Append(QuizBlock(body, ++quizNo));
                        break;
                }
            }

            return html.Length == 0 ? null : html.ToString();
        }

        private static string MediaBlock(string kind, string url, string caption)
        {
            bool local = (url ?? "").StartsWith(LessonMedia.Folder, StringComparison.OrdinalIgnoreCase);
            if (!local && !IsWebLink(url)) return string.Empty;

            var html = new StringBuilder("<figure class=\"cp-figure\">");
            string src = HttpUtility.HtmlAttributeEncode(url);

            if (kind == "Image")
                html.Append("<img src=\"").Append(src).Append("\" alt=\"").Append(HttpUtility.HtmlAttributeEncode(caption ?? "")).Append("\" loading=\"lazy\" />");
            else if (YouTubeEmbed(url) != null)
                html.Append("<div class=\"cp-video\"><iframe src=\"").Append(HttpUtility.HtmlAttributeEncode(YouTubeEmbed(url)))
                    .Append("\" title=\"Lesson video\" allow=\"accelerometer; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"allowfullscreen\" loading=\"lazy\"></iframe></div>");
            else if (local)
                html.Append("<video class=\"cp-media\" src=\"").Append(src).Append("\" controls=\"controls\" preload=\"metadata\"></video>");
            else
                html.Append("<p><a class=\"btn btn--primary btn--sm\" href=\"").Append(src)
                    .Append("\" target=\"_blank\" rel=\"noopener\"><i class=\"bi bi-play-circle\" aria-hidden=\"true\"></i>&nbsp;Watch the video</a></p>");

            if (!string.IsNullOrWhiteSpace(caption))
                html.Append("<figcaption class=\"cp-caption\">").Append(Linkify(caption)).Append("</figcaption>");

            return html.Append("</figure>").ToString();
        }

        // Quiz JSON: {"questions":[{"q":"...","options":["..."],"answer":0}]}.
        // Each answer stays hidden until the learner opens it.
        private static string QuizBlock(string json, int quizNo)
        {
            System.Collections.ArrayList questions;
            try
            {
                var quiz = new JavaScriptSerializer().Deserialize<System.Collections.Generic.Dictionary<string, object>>(json ?? "");
                questions = quiz != null && quiz.ContainsKey("questions") ? quiz["questions"] as System.Collections.ArrayList : null;
            }
            catch (ArgumentException) { questions = null; }
            catch (InvalidOperationException) { questions = null; }

            if (questions == null || questions.Count == 0) return string.Empty;

            var html = new StringBuilder();
            html.Append(Note("bi-patch-question", "Answer each question in your head first, then open it to check."));
            html.Append("<ol class=\"cp-quiz\">");

            foreach (object item in questions)
            {
                var q = item as System.Collections.Generic.Dictionary<string, object>;
                var options = q == null ? null : (q.ContainsKey("options") ? q["options"] as System.Collections.ArrayList : null);
                if (q == null || options == null || !q.ContainsKey("q")) continue;

                int answer = q.ContainsKey("answer") && q["answer"] is int ? (int)q["answer"] : 0;

                html.Append("<li class=\"cp-quiz__item\"><p class=\"cp-quiz__q\">").Append(Html(q["q"])).Append("</p><ol class=\"cp-quiz__options\" type=\"A\">");
                foreach (object o in options) html.Append("<li>").Append(Html(o)).Append("</li>");
                html.Append("</ol>");

                if (answer >= 0 && answer < options.Count)
                    html.Append("<details class=\"cp-quiz__answer\"><summary>Show answer</summary><p>")
                        .Append((char)('A' + answer)).Append(". ").Append(Html(options[answer])).Append("</p></details>");

                html.Append("</li>");
            }

            return html.Append("</ol>").ToString();
        }

        private static readonly Regex UrlInText = new Regex(@"https?://[^\s<]+[^\s<.,;:!?)\]]", RegexOptions.Compiled);

        // HTML-encodes text and turns bare https links (the sources lists) into links.
        private static string Linkify(string text)
        {
            return UrlInText.Replace(HttpUtility.HtmlEncode(text ?? ""), m =>
                "<a href=\"" + m.Value + "\" target=\"_blank\" rel=\"noopener\">" + m.Value + "</a>");
        }

        // youtube.com/watch?v=ID, youtu.be/ID, youtube.com/shorts/ID or /embed/ID -> privacy-friendly embed URL.
        private static string YouTubeEmbed(string url)
        {
            Uri uri;
            if (!Uri.TryCreate(url ?? "", UriKind.Absolute, out uri)) return null;

            string host = uri.Host.ToLowerInvariant();
            string id = null;

            if (host == "youtu.be")
                id = uri.AbsolutePath.Trim('/');
            else if (host.EndsWith("youtube.com"))
            {
                string path = uri.AbsolutePath;
                if (path.StartsWith("/embed/") || path.StartsWith("/shorts/"))
                    id = path.Substring(path.IndexOf('/', 1) + 1).Trim('/');
                else
                    id = HttpUtility.ParseQueryString(uri.Query)["v"];
            }

            return id != null && YouTubeId.IsMatch(id) ? "https://www.youtube-nocookie.com/embed/" + id : null;
        }

        private static string Note(string icon, string html)
        {
            return "<div class=\"cp-note\"><i class=\"bi " + icon + "\" aria-hidden=\"true\"></i><div>" + html + "</div></div>";
        }

        private static bool IsWebLink(string url)
        {
            Uri uri;
            return Uri.TryCreate(url ?? "", UriKind.Absolute, out uri) &&
                (uri.Scheme == Uri.UriSchemeHttps || uri.Scheme == Uri.UriSchemeHttp);
        }

        // ---------- Helpers ----------

        private string BackUrl()
        {
            if (IsGuest) return "index.html#courses";
            if (string.Equals(Role, "Tutor", StringComparison.OrdinalIgnoreCase)) return "tutordashboard.aspx?pane=courses";
            if (string.Equals(Role, "Admin", StringComparison.OrdinalIgnoreCase)) return "admindashboard.aspx";
            return "memberdashboard.aspx?pane=courses";
        }

        private void ShowMessage(string html, bool canEnrol)
        {
            phMessage.Visible = true;
            litMessage.Text = html;
            btnEnrol.Visible = canEnrol;
        }

        private void ShowFlash(string message, bool ok)
        {
            litFlash.Text = "<p class=\"md-flash" + (ok ? "" : " md-flash--error") + "\" role=\"status\">" +
                Server.HtmlEncode(message) + "</p>";
        }

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

        protected static string Html(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value));
        }

        protected string LessonUrl(object lessonId)
        {
            return "course.aspx?id=" + courseId + "&lesson=" + Convert.ToString(lessonId, CultureInfo.InvariantCulture);
        }

        protected string LessonCss(object lessonId, object isDone)
        {
            string css = "cp-lesson-link";
            if (Convert.ToInt32(isDone) == 1) css += " is-done";
            if (Convert.ToInt32(lessonId) == currentLessonId) css += " is-current";
            return css;
        }

        protected static string TypeLabel(object type)
        {
            switch (Convert.ToString(type))
            {
                case "AR": return "AR activity";
                case "Article": return "Reading";
                default: return Html(type);
            }
        }
    }
}