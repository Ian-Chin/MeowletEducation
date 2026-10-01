using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace MeowletEducation
{
    public partial class SignupTutor : Page
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
        }

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
                    using (var check = new SqlCommand("SELECT COUNT(1) FROM Users WHERE Email = @Email", conn))
                    {
                        check.Parameters.AddWithValue("@Email", email);
                        if ((int)check.ExecuteScalar() > 0)
                        {
                            ShowMessage(pnlMessage, litMessage, "This email is already registered.", false);
                            ShowStep(1);
                            return;
                        }
                    }
                }

                Session["TutorSignup_FullName"] = fullName;
                Session["TutorSignup_Email"] = email;
                Session["TutorSignup_Password"] = password;

                ShowStep(2);
            }
            catch (Exception ex)
            {
                ShowMessage(pnlMessage, litMessage, "Server error: " + ex.Message, false);
                ShowStep(1);
            }
        }

        protected void btnVerify_Click(object sender, EventArgs e)
        {
            FinishTutorSignup(requireFile: true);
        }

        protected void btnSkipVerify_Click(object sender, EventArgs e)
        {
            FinishTutorSignup(requireFile: false);
        }

        private void FinishTutorSignup(bool requireFile)
        {
            string fullName = Session["TutorSignup_FullName"] as string;
            string email = Session["TutorSignup_Email"] as string;
            string password = Session["TutorSignup_Password"] as string;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                ShowMessage(pnlMessage2, litMessage2, "Session expired. Please start again.", false);
                ShowStep(1);
                return;
            }

            string certPath = null;

            if (requireFile)
            {
                if (!fuCertificate.HasFile)
                {
                    ShowMessage(pnlMessage2, litMessage2, "Please upload an ID or certificate, or skip for now.", false);
                    ShowStep(2);
                    return;
                }

                string ext = Path.GetExtension(fuCertificate.FileName).ToLowerInvariant();
                if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".pdf")
                {
                    ShowMessage(pnlMessage2, litMessage2, "Only JPG, PNG or PDF files are allowed.", false);
                    ShowStep(2);
                    return;
                }

                if (fuCertificate.PostedFile.ContentLength > 10 * 1024 * 1024)
                {
                    ShowMessage(pnlMessage2, litMessage2, "File must be under 10 MB.", false);
                    ShowStep(2);
                    return;
                }
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    int userId;
                    using (var insert = new SqlCommand(
                        @"INSERT INTO Users (FullName, Email, PasswordHash, Role, IsActive, HasOnboarded, IsVerified)
                          VALUES (@FullName, @Email, @PasswordHash, 'Tutor', 1, 1, 0);
                          SELECT CAST(SCOPE_IDENTITY() AS INT);", conn))
                    {
                        insert.Parameters.AddWithValue("@FullName", fullName);
                        insert.Parameters.AddWithValue("@Email", email);
                        insert.Parameters.AddWithValue("@PasswordHash", HashPassword(password));
                        userId = (int)insert.ExecuteScalar();
                    }

                    if (fuCertificate.HasFile)
                    {
                        string folder = Server.MapPath("~/App_Data/Certificates/");
                        if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);

                        string ext = Path.GetExtension(fuCertificate.FileName).ToLowerInvariant();
                        string fileName = userId + "_" + DateTime.UtcNow.ToString("yyyyMMddHHmmss") + ext;
                        string fullPath = Path.Combine(folder, fileName);
                        fuCertificate.SaveAs(fullPath);
                        certPath = "App_Data/Certificates/" + fileName;

                        using (var upd = new SqlCommand(
                            "UPDATE Users SET CertificatePath = @Path WHERE UserId = @UserId", conn))
                        {
                            upd.Parameters.AddWithValue("@Path", certPath);
                            upd.Parameters.AddWithValue("@UserId", userId);
                            upd.ExecuteNonQuery();
                        }
                    }
                }

                Session.Remove("TutorSignup_FullName");
                Session.Remove("TutorSignup_Email");
                Session.Remove("TutorSignup_Password");

                // pending=1 → Signin shows “wait for admin approval” style message
                Response.Redirect("Signin.aspx?registered=1");
            }
            catch (Exception ex)
            {
                ShowMessage(pnlMessage2, litMessage2, "Server error: " + ex.Message, false);
                ShowStep(2);
            }
        }

        private void ShowMessage(System.Web.UI.WebControls.Panel panel,
            System.Web.UI.WebControls.Literal lit, string text, bool success)
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