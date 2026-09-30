using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace MeowletEducation
{
    public partial class AdminSignup : Page
    {
        // Set in Web.config. Empty or missing closes admin sign-up.
        private static string SignupCode
        {
            get { return (ConfigurationManager.AppSettings["AdminSignupCode"] ?? string.Empty).Trim(); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (SignupCode.Length == 0)
            {
                phForm.Visible = false;
                ShowMessage("Admin sign-up is closed. Ask an existing admin to create your account.", false);
            }
        }

        protected void btnSignup_Click(object sender, EventArgs e)
        {
            if (SignupCode.Length == 0) return;

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            if (fullName.Length == 0 || email.Length == 0 || password.Length == 0)
            {
                ShowMessage("Fill in your name, email and password.", false);
                return;
            }

            if (email.IndexOf('@') < 1 || email.LastIndexOf('.') < email.IndexOf('@'))
            {
                ShowMessage("Enter a valid email address.", false);
                return;
            }

            if (password.Length < 8)
            {
                ShowMessage("Use a password of at least 8 characters.", false);
                return;
            }

            if (password != txtConfirm.Text)
            {
                ShowMessage("The two passwords don't match.", false);
                return;
            }

            if (!CodesMatch(txtCode.Text.Trim(), SignupCode))
            {
                ShowMessage("That access code isn't right.", false);
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;

            try
            {
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    using (var check = new SqlCommand("SELECT COUNT(1) FROM Users WHERE Email = @Email", conn))
                    {
                        check.Parameters.AddWithValue("@Email", email);
                        if ((int)check.ExecuteScalar() > 0)
                        {
                            ShowMessage("This email is already registered.", false);
                            return;
                        }
                    }

                    // Admins skip onboarding, which only asks learner and tutor questions.
                    using (var insert = new SqlCommand(
                        @"INSERT INTO Users (FullName, Email, PasswordHash, Role, IsActive, HasOnboarded)
                          VALUES (@FullName, @Email, @PasswordHash, 'Admin', 1, 1)", conn))
                    {
                        insert.Parameters.AddWithValue("@FullName", fullName);
                        insert.Parameters.AddWithValue("@Email", email);
                        insert.Parameters.AddWithValue("@PasswordHash", HashPassword(password));
                        insert.ExecuteNonQuery();
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("The account could not be created. Try again in a moment.", false);
                return;
            }

            // Outside the try: Redirect aborts the thread, which a catch would swallow.
            Response.Redirect("AdminSignin.aspx?registered=1");
        }

        // Compares every character so the time taken doesn't hint at how much matched.
        private static bool CodesMatch(string given, string expected)
        {
            if (given.Length != expected.Length) return false;
            int diff = 0;
            for (int i = 0; i < given.Length; i++) diff |= given[i] ^ expected[i];
            return diff == 0;
        }

        private void ShowMessage(string text, bool success)
        {
            litMessage.Text = "<p class=\"admin-auth__msg" + (success ? "" : " admin-auth__msg--error") +
                "\" role=\"" + (success ? "status" : "alert") + "\">" + Server.HtmlEncode(text) + "</p>";
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
