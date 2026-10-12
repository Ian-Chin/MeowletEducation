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
        // Step 1 of 2. The details are held as a pending request, not a user:
        // existing admins see it in their notifications, generate a code and
        // send it over. Step 2 (AdminAccessCode.aspx) checks the code and only
        // then creates the Users row.
        protected void btnSignup_Click(object sender, EventArgs e)
        {
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

            string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;

            try
            {
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    using (var check = new SqlCommand(
                        @"SELECT (SELECT COUNT(1) FROM Users WHERE Email = @Email),
                                 (SELECT COUNT(1) FROM AdminAccessRequests WHERE Email = @Email)", conn))
                    {
                        check.Parameters.AddWithValue("@Email", email);
                        using (var reader = check.ExecuteReader())
                        {
                            reader.Read();
                            if (reader.GetInt32(0) > 0)
                            {
                                ShowMessage("This email is already registered.", false);
                                return;
                            }
                            if (reader.GetInt32(1) > 0)
                            {
                                ShowMessage("This email is already waiting for approval. Log in to enter your access code.", false);
                                return;
                            }
                        }
                    }

                    int requestId;
                    using (var insert = new SqlCommand(
                        @"INSERT INTO AdminAccessRequests (FullName, Email, PasswordHash)
                          OUTPUT INSERTED.RequestId
                          VALUES (@FullName, @Email, @PasswordHash);", conn))
                    {
                        insert.Parameters.AddWithValue("@FullName", fullName);
                        insert.Parameters.AddWithValue("@Email", email);
                        insert.Parameters.AddWithValue("@PasswordHash", HashPassword(password));
                        requestId = (int)insert.ExecuteScalar();
                    }

                    // The code page only opens for the request that was just sent.
                    Session["PendingAdminRequestId"] = requestId;
                }
            }
            catch (SqlException)
            {
                ShowMessage("The account could not be created. Try again in a moment.", false);
                return;
            }

            // Outside the try: Redirect aborts the thread, which a catch would swallow.
            Response.Redirect("AdminAccessCode.aspx");
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
