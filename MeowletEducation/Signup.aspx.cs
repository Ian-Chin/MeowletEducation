using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MeowletEducation
{
    public partial class Signup : Page
    {
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ShowStep(1);
                LoadInterestTags();
            }
            else
            {
                int step;
                if (!int.TryParse(hidStep.Value, out step)) step = 1;
                ShowStep(step);
            }
        }

        private void ShowStep(int step)
        {
            hidStep.Value = step.ToString();
            pnlStep1.Visible = (step == 1);
            pnlStep2.Visible = (step == 2);
            pnlStep3.Visible = (step == 3);
        }

        private void LoadInterestTags()
        {
            cblInterests.Items.Clear();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(
                        "SELECT TagName, DisplayLabel FROM Tags ORDER BY TagId", conn))
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            cblInterests.Items.Add(new ListItem(
                                reader.GetString(1),
                                reader.GetString(0)));
                        }
                    }
                }
            }
            catch
            {
                // DB not ready — leave empty; user can still skip
            }
        }

        // Step 1: validate + stash in Session, go to step 2 (no DB write yet)
        protected void btnStep1_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var check = new SqlCommand(
                        "SELECT COUNT(1) FROM Users WHERE Email = @Email", conn))
                    {
                        check.Parameters.AddWithValue("@Email", email);
                        if ((int)check.ExecuteScalar() > 0)
                        {
                            ShowMessage(pnlMessage, litMessage,
                                "This email is already registered.", false);
                            ShowStep(1);
                            return;
                        }
                    }
                }

                Session["Signup_FullName"] = fullName;
                Session["Signup_Email"] = email;
                Session["Signup_Password"] = password;

                ShowStep(2);
            }
            catch (Exception ex)
            {
                ShowMessage(pnlMessage, litMessage, "Server error: " + ex.Message, false);
                ShowStep(1);
            }
        }

        // Step 2: answered → HasOnboarded = 1
        protected void btnStep2_Click(object sender, EventArgs e)
        {
            FinishSignup(saveAnswers: true);
        }

        // Skip → HasOnboarded = 0 → first login goes to Onboarding
        protected void btnSkip_Click(object sender, EventArgs e)
        {
            FinishSignup(saveAnswers: false);
        }

        private void FinishSignup(bool saveAnswers)
        {
            string fullName = Session["Signup_FullName"] as string;
            string email = Session["Signup_Email"] as string;
            string password = Session["Signup_Password"] as string;

            if (string.IsNullOrEmpty(fullName) ||
                string.IsNullOrEmpty(email) ||
                string.IsNullOrEmpty(password))
            {
                ShowMessage(pnlMessage2, litMessage2,
                    "Session expired. Please start again.", false);
                ShowStep(1);
                return;
            }

            try
            {
                // 0 = must complete profile on first login
                // 1 = already done, go straight to Index
                int hasOnboarded = saveAnswers ? 1 : 0;

                int userId;
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            using (var insert = new SqlCommand(
                                @"INSERT INTO Users (FullName, Email, PasswordHash, Role, IsActive, HasOnboarded)
                                  VALUES (@FullName, @Email, @PasswordHash, 'Student', 1, @HasOnboarded);
                                  SELECT CAST(SCOPE_IDENTITY() AS INT);", conn, tx))
                            {
                                insert.Parameters.AddWithValue("@FullName", fullName);
                                insert.Parameters.AddWithValue("@Email", email);
                                insert.Parameters.AddWithValue("@PasswordHash", HashPassword(password));
                                insert.Parameters.AddWithValue("@HasOnboarded", hasOnboarded);
                                userId = (int)insert.ExecuteScalar();
                            }

                            if (saveAnswers)
                            {
                                SaveAnswer(conn, tx, userId, "age_range", rblAge.SelectedValue);

                                foreach (ListItem item in cblInterests.Items)
                                {
                                    if (!item.Selected) continue;
                                    using (var tagCmd = new SqlCommand(
                                        @"INSERT INTO UserInterests (UserId, TagId)
                                          SELECT @UserId, TagId FROM Tags WHERE TagName = @TagName",
                                        conn, tx))
                                    {
                                        tagCmd.Parameters.AddWithValue("@UserId", userId);
                                        tagCmd.Parameters.AddWithValue("@TagName", item.Value);
                                        tagCmd.ExecuteNonQuery();
                                    }
                                }
                            }

                            tx.Commit();
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }

                Session.Remove("Signup_FullName");
                Session.Remove("Signup_Email");
                Session.Remove("Signup_Password");

                ShowStep(3);
            }
            catch (Exception ex)
            {
                ShowMessage(pnlMessage2, litMessage2, "Server error: " + ex.Message, false);
                ShowStep(2);
            }
        }

        private static void SaveAnswer(SqlConnection conn, SqlTransaction tx,
            int userId, string key, string value)
        {
            if (string.IsNullOrEmpty(value)) return;
            using (var cmd = new SqlCommand(
                @"INSERT INTO OnboardingAnswers (UserId, QuestionKey, AnswerValue)
                  VALUES (@UserId, @QuestionKey, @AnswerValue)", conn, tx))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@QuestionKey", key);
                cmd.Parameters.AddWithValue("@AnswerValue", value);
                cmd.ExecuteNonQuery();
            }
        }

        private void ShowMessage(Panel panel, Literal lit, string text, bool success)
        {
            panel.Visible = true;
            panel.CssClass = success ? "msg msg--ok" : "msg msg--error";
            lit.Text = Server.HtmlEncode(text);
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
    }
}