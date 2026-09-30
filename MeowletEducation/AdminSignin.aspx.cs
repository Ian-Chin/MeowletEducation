using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace MeowletEducation
{
    public partial class AdminSignin : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Request.QueryString["registered"] == "1")
                ShowMessage("Admin account created. Log in to continue.", true);
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            if (email.Length == 0 || password.Length == 0)
            {
                ShowMessage("Enter your email and password.", false);
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;

            try
            {
                using (var conn = new SqlConnection(connStr))
                using (var cmd = new SqlCommand(
                    @"SELECT UserId, FullName, Role, IsActive
                      FROM Users WHERE Email = @Email AND PasswordHash = @Hash", conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@Hash", HashPassword(password));
                    conn.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            ShowMessage("That email and password don't match an account.", false);
                            return;
                        }

                        string role = reader.GetString(reader.GetOrdinal("Role"));
                        if (!string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
                        {
                            ShowMessage("This account doesn't have admin access. Use the regular log in page.", false);
                            return;
                        }

                        if (!reader.GetBoolean(reader.GetOrdinal("IsActive")))
                        {
                            ShowMessage("This admin account is disabled. Ask another admin to enable it.", false);
                            return;
                        }

                        string fullName = reader.GetString(reader.GetOrdinal("FullName"));

                        Session["UserId"] = reader.GetInt32(reader.GetOrdinal("UserId"));
                        Session["FullName"] = fullName;
                        Session["Email"] = email;
                        Session["Role"] = role;

                        ShowWelcome(fullName);
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("The database could not be reached. Try again in a moment.", false);
            }
        }

        // The page re-renders with the greeting; its script plays the fade
        // and then moves on to the dashboard.
        private void ShowWelcome(string fullName)
        {
            string[] parts = fullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            litFirstName.Text = Server.HtmlEncode(parts.Length > 0 ? parts[0] : fullName);
            phWelcome.Visible = true;
            btnLogin.Enabled = false;
            txtPassword.Text = string.Empty;
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
