using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace MeowletEducation
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Request.QueryString["registered"] == "1")
            {
                ShowMessage("Account created. Please log in.", true);
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;
            string hash = HashPassword(password);

            string connStr = ConfigurationManager
                .ConnectionStrings["MeowletDb"]
                .ConnectionString;

            try
            {
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        @"SELECT UserId, FullName, Role, IsActive
                          FROM Users
                          WHERE Email = @Email AND PasswordHash = @Hash", conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Hash", hash);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                ShowMessage("Invalid email or password.", false);
                                return;
                            }

                            bool isActive = reader.GetBoolean(
                                reader.GetOrdinal("IsActive"));

                            if (!isActive)
                            {
                                ShowMessage("This account is disabled.", false);
                                return;
                            }

                            int userId = reader.GetInt32(
                                reader.GetOrdinal("UserId"));

                            string fullName = reader.GetString(
                                reader.GetOrdinal("FullName"));

                            string role = reader.GetString(
                                reader.GetOrdinal("Role"));

                            // Save login information into Session
                            Session["UserId"] = userId;
                            Session["FullName"] = fullName;
                            Session["Email"] = email;
                            Session["Role"] = role;
                        }
                    }
                }

                // Login successful
                // Go back to Landing Page
                Response.Redirect("Index.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage("Server error: " + ex.Message, false);
            }
        }

        private void ShowMessage(string text, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success
                ? "msg msg--ok"
                : "msg msg--error";

            litMessage.Text = Server.HtmlEncode(text);
        }

        private static string HashPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(
                    Encoding.UTF8.GetBytes(password));

                var sb = new StringBuilder();

                foreach (byte b in bytes)
                {
                    sb.Append(b.ToString("x2"));
                }

                return sb.ToString();
            }
        }
    }
}