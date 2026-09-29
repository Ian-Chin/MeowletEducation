using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Runtime.Remoting.Messaging;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace MeowletEducation
{
    public partial class Onboarding : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("Signin.aspx");
                return;
            }

            string role = Session["Role"] as string;
            if (string.IsNullOrEmpty(role)) role = "Student";

            if (!IsPostBack)
            {
                int userId = (int)Session["UserId"];

                if (IsAlreadyOnboarded(userId))
                {
                    Response.Redirect("Index.aspx");
                    return;
                }

                RenderInitData(role);
            }
        }

        private bool IsAlreadyOnboarded(int userId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(
                    "SELECT HasOnboarded FROM Users WHERE UserId = @UserId", conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    object result = cmd.ExecuteScalar();
                    return result != null && (bool)result;
                }
            }
        }

        // Pushes role-specific tags + question set into the page as JS globals,
        // replacing the hardcoded TODO block in Onboarding.aspx's <script>.
        private void RenderInitData(string role)
        {
            var tags = GetTags();
            var questions = role == "Tutor" ? BuildTutorQuestions() : BuildStudentQuestions();

            string q1Title = role == "Tutor" ? "What do you want to teach?" : "What do you want to learn?";
            string q1Sub = role == "Tutor"
                ? "Pick the topics you'd like to teach. This helps us match you with students."
                : "Pick the topics you're interested in. We'll recommend courses based on this.";

            var serializer = new JavaScriptSerializer();
            string script =
                "var TAGS = " + serializer.Serialize(tags) + ";" +
                "var QUESTIONS = " + serializer.Serialize(questions) + ";" +
                "var Q1_TITLE = " + serializer.Serialize(q1Title) + ";" +
                "var Q1_SUB = " + serializer.Serialize(q1Sub) + ";";

            ClientScript.RegisterStartupScript(GetType(), "obInitData", script, true);
        }

        private List<object> GetTags()
        {
            var list = new List<object>();
            string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT TagName, DisplayLabel FROM Tags", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new
                        {
                            key = reader.GetString(reader.GetOrdinal("TagName")),
                            label = reader.GetString(reader.GetOrdinal("DisplayLabel"))
                        });
                    }
                }
            }
            return list;
        }

        private List<object> BuildStudentQuestions()
        {
            return new List<object>
            {
                new {
                    key = "experience_level",
                    title = "How familiar are you with personal finance?",
                    sub = "This helps us pick the right starting point.",
                    options = new[] {
                        new { value = "beginner", label = "Just starting out" },
                        new { value = "some_basics", label = "I know some basics" },
                        new { value = "confident", label = "Pretty confident already" }
                    }
                },
                new {
                    key = "learning_goal",
                    title = "What's your main goal?",
                    sub = "Pick the one that matters most right now.",
                    options = new[] {
                        new { value = "save_money", label = "Save more money" },
                        new { value = "pay_debt", label = "Pay off debt" },
                        new { value = "start_investing", label = "Start investing" },
                        new { value = "retirement_plan", label = "Plan for retirement" },
                        new { value = "just_curious", label = "Just want to learn" }
                    }
                },
                new {
                    key = "time_commitment",
                    title = "How much time can you commit weekly?",
                    sub = "No pressure — you can always change this later.",
                    options = new[] {
                        new { value = "under_1h", label = "Less than 1 hour" },
                        new { value = "1_3h", label = "1–3 hours" },
                        new { value = "3h_plus", label = "3+ hours" }
                    }
                },
                new {
                    key = "learning_style",
                    title = "How do you like to learn?",
                    sub = "We'll surface more of this format for you.",
                    options = new[] {
                        new { value = "video", label = "Watching videos" },
                        new { value = "reading", label = "Reading articles" },
                        new { value = "one_on_one", label = "1-on-1 with a tutor" },
                        new { value = "no_preference", label = "No preference" }
                    }
                }
            };
        }

        private List<object> BuildTutorQuestions()
        {
            return new List<object>
            {
                new {
                    key = "years_experience",
                    title = "How many years have you taught or worked in this field?",
                    sub = "This helps students know your experience level.",
                    options = new[] {
                        new { value = "under_1y", label = "Less than 1 year" },
                        new { value = "1_3y", label = "1–3 years" },
                        new { value = "3y_plus", label = "3+ years" }
                    }
                },
                new {
                    key = "teaching_format",
                    title = "What format do you prefer to teach?",
                    sub = "You can offer more than one later from your profile.",
                    options = new[] {
                        new { value = "one_on_one", label = "1-on-1" },
                        new { value = "group", label = "Small groups" },
                        new { value = "either", label = "Either works" }
                    }
                },
                new {
                    key = "student_capacity",
                    title = "How many students can you take on weekly?",
                    sub = "This is just a starting estimate.",
                    options = new[] {
                        new { value = "1_2", label = "1–2 students" },
                        new { value = "3_5", label = "3–5 students" },
                        new { value = "5_plus", label = "5+ students" }
                    }
                },
                new {
                    key = "student_level",
                    title = "What level of student do you prefer teaching?",
                    sub = "We'll use this to match you with the right students.",
                    options = new[] {
                        new { value = "beginner", label = "Complete beginners" },
                        new { value = "some_basics", label = "Some existing basics" },
                        new { value = "no_preference", label = "No preference" }
                    }
                }
            };
        }

        protected void btnFinish_Click(object sender, EventArgs e)
        {
            int userId = (int)Session["UserId"];
            string role = Session["Role"] as string;
            if (string.IsNullOrEmpty(role)) role = "Student";

            string json = hidAnswersJson.Value;
            if (string.IsNullOrWhiteSpace(json))
            {
                ShowMessage("Something went wrong reading your answers. Please try again.", false);
                return;
            }

            try
            {
                var serializer = new JavaScriptSerializer();
                var payload = serializer.Deserialize<OnboardingPayload>(json);

                string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            SaveTags(conn, tx, userId, role, payload.tags ?? new List<string>());
                            SaveAnswers(conn, tx, userId, payload.answers ?? new Dictionary<string, string>());
                            MarkOnboarded(conn, tx, userId);
                            tx.Commit();
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }

                Response.Redirect("Index.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage("Server error: " + ex.Message, false);
            }
        }

        protected void btnSkip_Click(object sender, EventArgs e)
        {
            int userId = (int)Session["UserId"];
            string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;

            try
            {
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(
                        "UPDATE Users SET HasOnboarded = 1 WHERE UserId = @UserId", conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.ExecuteNonQuery();
                    }
                }

                Response.Redirect("Index.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage("Server error: " + ex.Message, false);
            }
        }

        // Table name comes from a fixed C# ternary (never user input), matching
        // the project's existing safe-interpolation convention for table names.
        private void SaveTags(SqlConnection conn, SqlTransaction tx, int userId, string role, List<string> tagNames)
        {
            string table = role == "Tutor" ? "TutorSubjects" : "UserInterests";

            using (var del = new SqlCommand(
                "DELETE FROM " + table + " WHERE UserId = @UserId", conn, tx))
            {
                del.Parameters.AddWithValue("@UserId", userId);
                del.ExecuteNonQuery();
            }

            foreach (var tagName in tagNames)
            {
                using (var insert = new SqlCommand(
                    "INSERT INTO " + table + " (UserId, TagId) SELECT @UserId, TagId FROM Tags WHERE TagName = @TagName",
                    conn, tx))
                {
                    insert.Parameters.AddWithValue("@UserId", userId);
                    insert.Parameters.AddWithValue("@TagName", tagName);
                    insert.ExecuteNonQuery();
                }
            }
        }

        private void SaveAnswers(SqlConnection conn, SqlTransaction tx, int userId, Dictionary<string, string> answers)
        {
            using (var del = new SqlCommand(
                "DELETE FROM OnboardingAnswers WHERE UserId = @UserId", conn, tx))
            {
                del.Parameters.AddWithValue("@UserId", userId);
                del.ExecuteNonQuery();
            }

            foreach (var kv in answers)
            {
                if (string.IsNullOrEmpty(kv.Value)) continue;

                using (var insert = new SqlCommand(
                    @"INSERT INTO OnboardingAnswers (UserId, QuestionKey, AnswerValue)
                      VALUES (@UserId, @QuestionKey, @AnswerValue)", conn, tx))
                {
                    insert.Parameters.AddWithValue("@UserId", userId);
                    insert.Parameters.AddWithValue("@QuestionKey", kv.Key);
                    insert.Parameters.AddWithValue("@AnswerValue", kv.Value);
                    insert.ExecuteNonQuery();
                }
            }
        }

        private void MarkOnboarded(SqlConnection conn, SqlTransaction tx, int userId)
        {
            using (var cmd = new SqlCommand(
                "UPDATE Users SET HasOnboarded = 1 WHERE UserId = @UserId", conn, tx))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.ExecuteNonQuery();
            }
        }

        private void ShowMessage(string text, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "msg msg--ok" : "msg msg--error";
            litMessage.Text = Server.HtmlEncode(text);
        }

        private class OnboardingPayload
        {
            public List<string> tags { get; set; }
            public Dictionary<string, string> answers { get; set; }
        }
    }
}