using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace MeowletEducation
{
    public partial class SignupTutor : Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnSignup_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;
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
                        if ((int)check.ExecuteScalar() > 0)
                        {
                            ShowMessage("This email is already registered.", false);
                            return;
                        }
                    }

                    string hash = HashPassword(password);

                    // Institution is no longer collected at signup; the tutor adds it
                    // (together with their certificate) later from Profile.aspx.
                    // IsVerified defaults to 0 here; an admin manually flips it to 1
                    // via SQL after reviewing the tutor's certificate.
                    using (var insert = new SqlCommand(
                        @"INSERT INTO Users (FullName, Email, PasswordHash, Role, IsActive, Institution, IsVerified)
                          VALUES (@FullName, @Email, @PasswordHash, @Role, 1, @Institution, @IsVerified)", conn))
                    {
                        insert.Parameters.AddWithValue("@FullName", fullName);
                        insert.Parameters.AddWithValue("@Email", email);
                        insert.Parameters.AddWithValue("@PasswordHash", hash);
                        insert.Parameters.AddWithValue("@Role", "Tutor");
                        insert.Parameters.AddWithValue("@Institution", DBNull.Value);
                        insert.Parameters.AddWithValue("@IsVerified", 0);
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