using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;

namespace MeowletEducation
{
    public partial class Profile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("Signin.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadUserProfile();
            }
        }

        private void LoadUserProfile()
        {
            string userId = Session["UserId"].ToString();
            string connectionString = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT FullName, Email, Role FROM Users WHERE UserId = @UserId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtFullName.Text = reader["FullName"].ToString();
                            txtEmail.Text = reader["Email"].ToString();
                            txtRole.Text = reader["Role"].ToString();

                            string name = reader["FullName"].ToString();
                            litName.Text = name;

                            if (!string.IsNullOrEmpty(name))
                            {
                                litInitial.Text = name.Substring(0, 1).ToUpper();
                            }
                        }
                    }
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string userId = Session["UserId"].ToString();
            string connectionString = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "UPDATE Users SET FullName = @FullName, Email = @Email WHERE UserId = @UserId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FullName", txtFullName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@UserId", userId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            Session["FullName"] = txtFullName.Text.Trim();
            Session["Email"] = txtEmail.Text.Trim();

            ShowMessage("Profile updated successfully!", true);

            litName.Text = txtFullName.Text.Trim();
            if (!string.IsNullOrEmpty(txtFullName.Text.Trim()))
            {
                litInitial.Text = txtFullName.Text.Trim().Substring(0, 1).ToUpper();
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            string newPass = txtNewPassword.Text;
            string confirmPass = txtConfirmPassword.Text;

            if (string.IsNullOrEmpty(newPass) || string.IsNullOrEmpty(confirmPass))
            {
                ShowMessage("Please enter and confirm your new password.", false);
                return;
            }

            // 检查新密码长度是否至少为 8 个字符
            if (newPass.Length < 8)
            {
                ShowMessage("New password must be at least 8 characters long.", false);
                return;
            }

            if (newPass != confirmPass)
            {
                ShowMessage("New passwords do not match.", false);
                return;
            }

            string userId = Session["UserId"].ToString();
            string connectionString = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;
            string newHash = HashPassword(newPass);

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string updateQuery = "UPDATE Users SET PasswordHash = @NewHash WHERE UserId = @UserId";
                using (SqlCommand updateCmd = new SqlCommand(updateQuery, conn))
                {
                    updateCmd.Parameters.AddWithValue("@NewHash", newHash);
                    updateCmd.Parameters.AddWithValue("@UserId", userId);
                    updateCmd.ExecuteNonQuery();
                }
            }

            txtNewPassword.Text = "";
            txtConfirmPassword.Text = "";

            ShowMessage("Password changed successfully!", true);
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Index.html");
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = isSuccess ? "msg-box msg-success" : "msg-box msg-error";
            lblMessage.Text = message;
        }

        private static string HashPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
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