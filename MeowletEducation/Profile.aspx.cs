using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace MeowletEducation
{
    public partial class Profile : System.Web.UI.Page
    {
        private static readonly string[] AllowedExtensions = { ".pdf", ".jpg", ".jpeg", ".png" };
        private const int MaxFileSizeBytes = 5 * 1024 * 1024;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("Signin.aspx");
                return;
            }

            string role = Session["Role"] != null ? Session["Role"].ToString() : "Student";
            pnlInstitution.Visible = role.Equals("Tutor", StringComparison.OrdinalIgnoreCase);

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
                string query = "SELECT FullName, Email, Role, Institution, CertificatePath, IsVerified FROM Users WHERE UserId = @UserId";

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

                            int institutionOrdinal = reader.GetOrdinal("Institution");
                            txtInstitution.Text = reader.IsDBNull(institutionOrdinal)
                                ? string.Empty
                                : reader.GetString(institutionOrdinal);

                            string name = reader["FullName"].ToString();
                            litName.Text = name;

                            if (!string.IsNullOrEmpty(name))
                            {
                                litInitial.Text = name.Substring(0, 1).ToUpper();
                            }

                            if (pnlInstitution.Visible)
                            {
                                int certOrdinal = reader.GetOrdinal("CertificatePath");
                                string certPath = reader.IsDBNull(certOrdinal) ? null : reader.GetString(certOrdinal);
                                bool isVerified = reader.GetBoolean(reader.GetOrdinal("IsVerified"));

                                RenderCertificateStatus(isVerified, certPath);
                            }
                        }
                    }
                }
            }
        }

        private void RenderCertificateStatus(bool isVerified, string certPath)
        {
            litCertBadge.Text = isVerified
                ? "<span style=\"background:#eef9ec;color:#2e7d32;padding:4px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;\">&#10003; Verified</span>"
                : "<span style=\"background:#fff3e0;color:#e65100;padding:4px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;\">Unverified</span>";

            if (!string.IsNullOrEmpty(certPath))
            {
                string displayName = Path.GetFileName(certPath);
                litCertFileName.Text = "<p style=\"font-size:0.85rem;color:#666;margin:0 0 10px;\">Current file: " +
                    Server.HtmlEncode(displayName) + "</p>";
            }
            else
            {
                litCertFileName.Text = "<p style=\"font-size:0.85rem;color:#888;margin:0 0 10px;\">No certificate uploaded yet.</p>";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string userId = Session["UserId"].ToString();
            string connectionString = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;
            bool isTutor = pnlInstitution.Visible;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = isTutor
                    ? "UPDATE Users SET FullName = @FullName, Email = @Email, Institution = @Institution WHERE UserId = @UserId"
                    : "UPDATE Users SET FullName = @FullName, Email = @Email WHERE UserId = @UserId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FullName", txtFullName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@UserId", userId);

                    if (isTutor)
                    {
                        string institution = txtInstitution.Text.Trim();
                        cmd.Parameters.AddWithValue("@Institution",
                            string.IsNullOrEmpty(institution) ? (object)DBNull.Value : institution);
                    }

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

        protected void btnUploadCertificate_Click(object sender, EventArgs e)
        {
            if (!fuCertificate.HasFile)
            {
                ShowMessage("Please choose a file to upload.", false);
                return;
            }

            string originalFileName = fuCertificate.FileName;
            string extension = Path.GetExtension(originalFileName).ToLowerInvariant();

            if (Array.IndexOf(AllowedExtensions, extension) < 0)
            {
                ShowMessage("Only PDF, JPG, or PNG files are allowed.", false);
                return;
            }

            if (fuCertificate.PostedFile.ContentLength > MaxFileSizeBytes)
            {
                ShowMessage("File is too large. Maximum size is 5MB.", false);
                return;
            }

            string userId = Session["UserId"].ToString();
            string safeFileName = string.Format("{0}_{1}{2}",
                userId,
                DateTime.UtcNow.ToString("yyyyMMddHHmmss"),
                extension);

            string folderPath = Server.MapPath("~/App_Data/Certificates/");
            if (!Directory.Exists(folderPath))
            {
                Directory.CreateDirectory(folderPath);
            }

            string fullPath = Path.Combine(folderPath, safeFileName);

            try
            {
                fuCertificate.SaveAs(fullPath);
            }
            catch (Exception ex)
            {
                ShowMessage("Upload failed: " + ex.Message, false);
                return;
            }

            string relativePath = "App_Data/Certificates/" + safeFileName;

            string connectionString = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "UPDATE Users SET CertificatePath = @CertificatePath, IsVerified = 0 WHERE UserId = @UserId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CertificatePath", relativePath);
                    cmd.Parameters.AddWithValue("@UserId", userId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            RenderCertificateStatus(false, relativePath);
            ShowMessage("Certificate uploaded. An admin will review it shortly.", true);
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