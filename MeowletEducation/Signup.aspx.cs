using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace MeowletEducation
{
    public partial class Signup : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnSignup_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            string role = hfRole.Value;
            if (role != "Student" && role != "Tutor")
                role = "Student";

            string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;

            try
            {
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    using (var check = new SqlCommand(
                        "SELECT COUNT(1) FROM Users WHERE Email = @Email", conn))
                    {
                        check.Parameters.AddWithValue("@Email", email);
                        int exists = (int)check.ExecuteScalar();
                        if (exists > 0)
                        {
                            ShowMessage("This email is already registered.", false);
                            return;
                        }
                    }

                    string hash = HashPassword(password);
                    using (var insert = new SqlCommand(
                        @"INSERT INTO Users (FullName, Email, PasswordHash, Role)
                          VALUES (@FullName, @Email, @PasswordHash, @Role)", conn))
                    {
                        insert.Parameters.AddWithValue("@FullName", fullName);
                        insert.Parameters.AddWithValue("@Email", email);
                        insert.Parameters.AddWithValue("@PasswordHash", hash);
                        insert.Parameters.AddWithValue("@Role", role);
                        insert.ExecuteNonQuery();
                    }
                }

                Response.Redirect("Signin.aspx?registered=1");
            }
            catch (Exception ex)
            {
                ShowMessage("Server error: " + ex.Message, false);
            }
        }

        private void ShowMessage(string text, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "msg msg--ok" : "msg msg--error";
            litMessage.Text = Server.HtmlEncode(text);
        }

        private static string HashPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                var sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }
    }
}