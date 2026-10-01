using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace MeowletEducation
{
    public partial class Profile : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;
        private int UserId => Convert.ToInt32(Session["UserId"]);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null) { Response.Redirect("Signin.aspx"); return; }
            EnsureDeleteColumn();
            if (!IsPostBack) LoadProfile();
            else BindNavChrome();
        }

        private void EnsureDeleteColumn()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("IF COL_LENGTH('dbo.Users', 'DeleteRequestedAt') IS NULL ALTER TABLE dbo.Users ADD DeleteRequestedAt DATETIME2 NULL;", conn))
                        cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private void LoadProfile()
        {
            string role = "Student";
            bool isVerified = false;
            DateTime? deleteAt = null;
            string ageRange = "";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT FullName, Email, Role, IsVerified, Institution, CertificatePath, DeleteRequestedAt FROM Users WHERE UserId = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", UserId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) { Response.Redirect("Signin.aspx"); return; }

                        string fullName = reader.GetString(reader.GetOrdinal("FullName"));
                        string email = reader.GetString(reader.GetOrdinal("Email"));
                        role = reader.GetString(reader.GetOrdinal("Role"));
                        isVerified = reader.GetBoolean(reader.GetOrdinal("IsVerified"));

                        txtInstitution.Text = reader.IsDBNull(reader.GetOrdinal("Institution")) ? "" : reader.GetString(reader.GetOrdinal("Institution"));

                        string cert = reader.IsDBNull(reader.GetOrdinal("CertificatePath")) ? null : reader.GetString(reader.GetOrdinal("CertificatePath"));
                        litCertPath.Text = string.IsNullOrEmpty(cert) ? "" : "<p style=\"font-size:12px;color:var(--text-secondary);margin-top:8px;\">On file: " + Server.HtmlEncode(Path.GetFileName(cert)) + "</p>";

                        if (!reader.IsDBNull(reader.GetOrdinal("DeleteRequestedAt")))
                            deleteAt = reader.GetDateTime(reader.GetOrdinal("DeleteRequestedAt"));

                        Session["FullName"] = fullName; Session["Email"] = email; Session["Role"] = role; Session["IsVerified"] = isVerified;

                        litFullName.Text = Server.HtmlEncode(fullName);
                        litEmail.Text = Server.HtmlEncode(email);
                        litRole.Text = Server.HtmlEncode(role);
                        txtFullName.Text = fullName;
                        txtEmail.Text = email;

                        string initial = string.IsNullOrEmpty(fullName) ? "?" : fullName.Substring(0, 1).ToUpperInvariant();
                        litAvatar.Text = Server.HtmlEncode(initial);
                        litNavInitial.Text = Server.HtmlEncode(initial);
                        litNavName.Text = Server.HtmlEncode(fullName);
                    }
                }

                using (var cmd = new SqlCommand("SELECT AnswerValue FROM OnboardingAnswers WHERE UserId = @Id AND QuestionKey = 'age_range'", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", UserId);
                    object result = cmd.ExecuteScalar();
                    if (result != null) ageRange = result.ToString();
                }

                LoadTags(conn);
                LoadAnswers(conn);
                LoadInterests(conn, role);
            }

            HtmlGenericControl roleBadge = (HtmlGenericControl)FindControl("roleBadge");
            if (roleBadge != null)
            {
                if (string.Equals(role, "Tutor", StringComparison.OrdinalIgnoreCase) && isVerified)
                    roleBadge.Attributes["style"] = "background: #dcffe4; color: #22863a; border-color: #34d058;";
                else if (string.Equals(role, "Tutor", StringComparison.OrdinalIgnoreCase))
                    roleBadge.Attributes["style"] = "background: #fff5b1; color: #735c0f; border-color: #e1b326;";
            }

            if (string.Equals(role, "Tutor", StringComparison.OrdinalIgnoreCase) && isVerified)
            {
                litVerifiedBadge.Text = "<span style=\"display:inline-block; padding: 4px 10px; background: #dcffe4; color: #22863a; border-radius: var(--radius-full); font-size: 11px; font-weight: 600; margin-bottom: 12px;\">✓ Verified Tutor</span>";
                litTutorStatus.Text = "<p style=\"font-size: 13px; color: #22863a; font-weight: 500; margin-bottom: 16px;\">Your account is verified.</p>";
            }
            else if (string.Equals(role, "Tutor", StringComparison.OrdinalIgnoreCase))
            {
                litVerifiedBadge.Text = "";
                litTutorStatus.Text = "<p style=\"font-size: 13px; color: var(--text-secondary); margin-bottom: 16px;\">Pending admin review after you upload your certificate.</p>";
            }
            else
            {
                litVerifiedBadge.Text = "";
            }

            pnlTutorVerify.Visible = string.Equals(role, "Tutor", StringComparison.OrdinalIgnoreCase);

            HtmlGenericControl displayAge = (HtmlGenericControl)FindControl("displayAge");
            if (displayAge != null)
            {
                string ageText = "Not specified";
                switch (ageRange)
                {
                    case "under_18": ageText = "Under 18"; break;
                    case "18_24": ageText = "18 - 24"; break;
                    case "25_34": ageText = "25 - 34"; break;
                    case "35_44": ageText = "35 - 44"; break;
                    case "45_plus": ageText = "45+"; break;
                }
                displayAge.InnerHtml = $"<span class=\"meta-tag\">{ageText}</span>";
            }

            HtmlGenericControl displayInterests = (HtmlGenericControl)FindControl("displayInterests");
            if (displayInterests != null)
            {
                displayInterests.Controls.Clear();
                bool hasInterests = false;
                foreach (ListItem item in cblInterests.Items)
                {
                    if (item.Selected)
                    {
                        hasInterests = true;
                        HtmlGenericControl tag = new HtmlGenericControl("span");
                        tag.Attributes["class"] = "meta-tag";
                        tag.InnerText = item.Text;
                        displayInterests.Controls.Add(tag);
                    }
                }
                if (!hasInterests)
                {
                    HtmlGenericControl emptyTag = new HtmlGenericControl("span");
                    emptyTag.Attributes["class"] = "meta-tag empty";
                    emptyTag.InnerText = "No interests selected";
                    displayInterests.Controls.Add(emptyTag);
                }
            }

            if (deleteAt.HasValue)
            {
                DateTime deadline = deleteAt.Value.AddDays(7);
                int daysLeft = (int)Math.Ceiling((deadline - DateTime.UtcNow).TotalDays);
                if (daysLeft < 0) daysLeft = 0;
                pnlDeletePending.Visible = true;
                pnlDeleteActions.Visible = false;
                litDeletePending.Text = $"Deletion requested. Sign in within {daysLeft} day(s) to cancel automatically. An admin must still approve final deletion.";
            }
            else
            {
                pnlDeletePending.Visible = false;
                pnlDeleteActions.Visible = true;
            }
        }

        private void BindNavChrome()
        {
            string fullName = Convert.ToString(Session["FullName"]) ?? "";
            string initial = string.IsNullOrEmpty(fullName) ? "?" : fullName.Substring(0, 1).ToUpperInvariant();
            litNavInitial.Text = Server.HtmlEncode(initial);
            litNavName.Text = Server.HtmlEncode(fullName);
        }

        private void LoadTags(SqlConnection conn)
        {
            cblInterests.Items.Clear();
            using (var cmd = new SqlCommand("SELECT TagName, DisplayLabel FROM Tags ORDER BY TagId", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read()) cblInterests.Items.Add(new ListItem(reader.GetString(1), reader.GetString(0)));
            }
            if (cblInterests.Items.Count == 0)
            {
                cblInterests.Items.Add(new ListItem("Budgeting", "budgeting"));
                cblInterests.Items.Add(new ListItem("Saving", "saving"));
                cblInterests.Items.Add(new ListItem("Investing", "investing"));
                cblInterests.Items.Add(new ListItem("Credit & Debt", "debt"));
            }
        }

        private void LoadAnswers(SqlConnection conn)
        {
            using (var cmd = new SqlCommand("SELECT QuestionKey, AnswerValue FROM OnboardingAnswers WHERE UserId = @Id", conn))
            {
                cmd.Parameters.AddWithValue("@Id", UserId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        if (reader.GetString(0) == "age_range")
                        {
                            string val = reader.GetString(1);
                            rbAge1.Checked = (val == "under_18");
                            rbAge2.Checked = (val == "18_24");
                            rbAge3.Checked = (val == "25_34");
                            rbAge4.Checked = (val == "35_44");
                            rbAge5.Checked = (val == "45_plus");
                        }
                    }
                }
            }
        }

        private void LoadInterests(SqlConnection conn, string role)
        {
            string table = string.Equals(role, "Tutor", StringComparison.OrdinalIgnoreCase) ? "TutorSubjects" : "UserInterests";
            using (var cmd = new SqlCommand("SELECT t.TagName FROM " + table + " ui JOIN Tags t ON t.TagId = ui.TagId WHERE ui.UserId = @Id", conn))
            {
                cmd.Parameters.AddWithValue("@Id", UserId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var item = cblInterests.Items.FindByValue(reader.GetString(0));
                        if (item != null) item.Selected = true;
                    }
                }
            }
        }

        protected void btnSaveBasic_Click(object sender, EventArgs e)
        {
            string name = txtFullName.Text.Trim();
            if (name.Length == 0) { ShowFlash("Enter your name.", false); return; }
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("UPDATE Users SET FullName = @Name WHERE UserId = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Name", name);
                    cmd.Parameters.AddWithValue("@Id", UserId);
                    cmd.ExecuteNonQuery();
                }
            }
            Session["FullName"] = name;
            ShowFlash("Details updated successfully.", true);
            LoadProfile();
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            string current = txtCurrentPassword.Text;
            string next = txtNewPassword.Text;
            string confirm = txtConfirmPassword.Text;

            if (next.Length < 8) { ShowFlash("New password must be at least 8 characters.", false); return; }
            if (next != confirm) { ShowFlash("New passwords do not match.", false); return; }

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("UPDATE Users SET PasswordHash = @New WHERE UserId = @Id AND PasswordHash = @Current", conn))
                {
                    cmd.Parameters.AddWithValue("@New", HashPassword(next));
                    cmd.Parameters.AddWithValue("@Current", HashPassword(current));
                    cmd.Parameters.AddWithValue("@Id", UserId);
                    if (cmd.ExecuteNonQuery() == 0) { ShowFlash("Current password is incorrect.", false); return; }
                }
            }
            txtCurrentPassword.Text = "";
            txtNewPassword.Text = "";
            txtConfirmPassword.Text = "";
            ShowFlash("Password changed successfully.", true);
        }

        protected void btnSavePrefs_Click(object sender, EventArgs e)
        {
            string role = Convert.ToString(Session["Role"]) ?? "Student";
            string interestTable = string.Equals(role, "Tutor", StringComparison.OrdinalIgnoreCase) ? "TutorSubjects" : "UserInterests";

            string selectedAge = "";
            if (rbAge1.Checked) selectedAge = "under_18";
            else if (rbAge2.Checked) selectedAge = "18_24";
            else if (rbAge3.Checked) selectedAge = "25_34";
            else if (rbAge4.Checked) selectedAge = "35_44";
            else if (rbAge5.Checked) selectedAge = "45_plus";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        using (var del = new SqlCommand("DELETE FROM OnboardingAnswers WHERE UserId = @Id AND QuestionKey = 'age_range'", conn, tx))
                        { del.Parameters.AddWithValue("@Id", UserId); del.ExecuteNonQuery(); }

                        if (!string.IsNullOrEmpty(selectedAge))
                        {
                            using (var ins = new SqlCommand("INSERT INTO OnboardingAnswers (UserId, QuestionKey, AnswerValue) VALUES (@Id, 'age_range', @Val)", conn, tx))
                            {
                                ins.Parameters.AddWithValue("@Id", UserId);
                                ins.Parameters.AddWithValue("@Val", selectedAge);
                                ins.ExecuteNonQuery();
                            }
                        }

                        using (var delTags = new SqlCommand("DELETE FROM " + interestTable + " WHERE UserId = @Id", conn, tx))
                        { delTags.Parameters.AddWithValue("@Id", UserId); delTags.ExecuteNonQuery(); }

                        foreach (ListItem item in cblInterests.Items)
                        {
                            if (!item.Selected) continue;
                            using (var ins = new SqlCommand("INSERT INTO " + interestTable + " (UserId, TagId) SELECT @Id, TagId FROM Tags WHERE TagName = @Tag", conn, tx))
                            {
                                ins.Parameters.AddWithValue("@Id", UserId);
                                ins.Parameters.AddWithValue("@Tag", item.Value);
                                ins.ExecuteNonQuery();
                            }
                        }

                        using (var onboard = new SqlCommand("UPDATE Users SET HasOnboarded = 1 WHERE UserId = @Id", conn, tx))
                        { onboard.Parameters.AddWithValue("@Id", UserId); onboard.ExecuteNonQuery(); }

                        tx.Commit();
                    }
                    catch { tx.Rollback(); throw; }
                }
            }
            ShowFlash("Preferences saved successfully.", true);
            LoadProfile();
        }

        protected void btnUploadCert_Click(object sender, EventArgs e)
        {
            if (!string.Equals(Convert.ToString(Session["Role"]), "Tutor", StringComparison.OrdinalIgnoreCase)) return;
            string institution = txtInstitution.Text.Trim();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                if (fuCertificate.HasFile)
                {
                    string ext = Path.GetExtension(fuCertificate.FileName).ToLowerInvariant();
                    if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".pdf") { ShowFlash("Only JPG, PNG or PDF allowed.", false); return; }
                    if (fuCertificate.PostedFile.ContentLength > 10 * 1024 * 1024) { ShowFlash("File must be under 10 MB.", false); return; }

                    string folder = Server.MapPath("~/App_Data/Certificates/");
                    if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);
                    string fileName = UserId + "_" + DateTime.UtcNow.ToString("yyyyMMddHHmmss") + ext;
                    fuCertificate.SaveAs(Path.Combine(folder, fileName));
                    string rel = "App_Data/Certificates/" + fileName;

                    using (var cmd = new SqlCommand("UPDATE Users SET CertificatePath = @Path, Institution = @Inst, IsVerified = 0 WHERE UserId = @Id", conn))
                    {
                        cmd.Parameters.AddWithValue("@Path", rel);
                        cmd.Parameters.AddWithValue("@Inst", string.IsNullOrEmpty(institution) ? (object)DBNull.Value : institution);
                        cmd.Parameters.AddWithValue("@Id", UserId);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    using (var cmd = new SqlCommand("UPDATE Users SET Institution = @Inst WHERE UserId = @Id", conn))
                    {
                        cmd.Parameters.AddWithValue("@Inst", string.IsNullOrEmpty(institution) ? (object)DBNull.Value : institution);
                        cmd.Parameters.AddWithValue("@Id", UserId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            Session["IsVerified"] = false;
            ShowFlash("Submitted. An admin will review your verification.", true);
            LoadProfile();
        }

        protected void btnRequestDelete_Click(object sender, EventArgs e)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("UPDATE Users SET DeleteRequestedAt = SYSUTCDATETIME() WHERE UserId = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", UserId);
                    cmd.ExecuteNonQuery();
                }
            }
            ShowFlash("Deletion requested. You have 7 days to cancel.", true);
            LoadProfile();
        }

        protected void btnCancelDelete_Click(object sender, EventArgs e)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("UPDATE Users SET DeleteRequestedAt = NULL WHERE UserId = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", UserId);
                    cmd.ExecuteNonQuery();
                }
            }
            ShowFlash("Deletion request cancelled.", true);
            LoadProfile();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Signin.aspx");
        }

        private void ShowFlash(string text, bool ok)
        {
            pnlFlash.Visible = true;
            pnlFlash.CssClass = ok ? "flash-notice flash-success" : "flash-notice flash-error";
            litFlash.Text = Server.HtmlEncode(text);
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