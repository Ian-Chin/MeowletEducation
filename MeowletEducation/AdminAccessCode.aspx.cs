using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace MeowletEducation
{
    // Step 2 of admin sign up. Opens only for the request that was just sent
    // (or a pending admin who logged in), so the only field is the code an
    // existing admin generated from the dashboard bell. A match creates the
    // Users row, deletes the request and signs them into the admin dashboard.
    public partial class AdminAccessCode : Page
    {
        private int? PendingRequestId
        {
            get { return Session["PendingAdminRequestId"] == null ? (int?)null : Convert.ToInt32(Session["PendingAdminRequestId"]); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!PendingRequestId.HasValue)
            {
                Response.Redirect("AdminSignup.aspx");
                return;
            }

            if (!IsPostBack && Request.QueryString["pending"] == "1")
                ShowMessage("Your admin account is waiting for an access code.", true);
        }

        protected void btnVerify_Click(object sender, EventArgs e)
        {
            int requestId = PendingRequestId.Value;
            int userId;
            string code = AdminAccessCodes.Normalize(txtCode.Text);

            if (code.Length == 0)
            {
                ShowMessage("Enter the access code.", false);
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;
            string fullName, email;

            try
            {
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    int failedTries;
                    string codeHash, passwordHash;
                    DateTime? expiresAt;

                    using (var find = new SqlCommand(
                        @"SELECT CodeHash, CodeExpiresAt, FailedTries, FullName, Email, PasswordHash
                          FROM AdminAccessRequests
                          WHERE RequestId = @Id", conn))
                    {
                        find.Parameters.AddWithValue("@Id", requestId);
                        using (var reader = find.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                // Declined by an admin, or already activated.
                                Session.Remove("PendingAdminRequestId");
                                ShowMessage("This sign up is no longer waiting for a code. Log in, or sign up again.", false);
                                btnVerify.Enabled = false;
                                return;
                            }

                            codeHash = reader.IsDBNull(0) ? null : reader.GetString(0);
                            expiresAt = reader.IsDBNull(1) ? (DateTime?)null : reader.GetDateTime(1);
                            failedTries = reader.GetInt32(2);
                            fullName = reader.GetString(3);
                            email = reader.GetString(4);
                            passwordHash = reader.GetString(5);
                        }
                    }

                    if (codeHash == null)
                    {
                        ShowMessage("No code has been generated for you yet. The admin team has been notified; try again once you receive it.", false);
                        return;
                    }

                    if (failedTries >= AdminAccessCodes.MaxFailedTries)
                    {
                        ShowMessage("Too many wrong tries. Ask an admin to generate a new code.", false);
                        return;
                    }

                    if (expiresAt.HasValue && expiresAt.Value < DateTime.UtcNow)
                    {
                        ShowMessage("This code has expired. Ask an admin to generate a new one.", false);
                        return;
                    }

                    if (!AdminAccessCodes.HashesMatch(AdminAccessCodes.Hash(code), codeHash))
                    {
                        using (var fail = new SqlCommand(
                            "UPDATE AdminAccessRequests SET FailedTries = FailedTries + 1 WHERE RequestId = @Id", conn))
                        {
                            fail.Parameters.AddWithValue("@Id", requestId);
                            fail.ExecuteNonQuery();
                        }

                        int left = AdminAccessCodes.MaxFailedTries - failedTries - 1;
                        ShowMessage(left > 0
                            ? "That code isn't right. " + left + (left == 1 ? " try" : " tries") + " left."
                            : "That code isn't right. Ask an admin to generate a new code.", false);
                        return;
                    }

                    // First and only write to Users. Admins skip onboarding, which
                    // only asks learner and tutor questions.
                    using (var tx = conn.BeginTransaction())
                    using (var approve = new SqlCommand(
                        @"INSERT INTO Users (FullName, Email, PasswordHash, Role, IsActive, HasOnboarded)
                          OUTPUT INSERTED.UserId
                          VALUES (@FullName, @Email, @PasswordHash, 'Admin', 1, 1);
                          DELETE FROM AdminAccessRequests WHERE RequestId = @Id;", conn, tx))
                    {
                        approve.Parameters.AddWithValue("@FullName", fullName);
                        approve.Parameters.AddWithValue("@Email", email);
                        approve.Parameters.AddWithValue("@PasswordHash", passwordHash);
                        approve.Parameters.AddWithValue("@Id", requestId);
                        userId = (int)approve.ExecuteScalar();
                        tx.Commit();
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("The database could not be reached. Try again in a moment.", false);
                return;
            }

            // Signed in, same session keys as AdminSignin.
            Session.Remove("PendingAdminRequestId");
            Session["UserId"] = userId;
            Session["FullName"] = fullName;
            Session["Email"] = email;
            Session["Role"] = "Admin";

            // Outside the try: Redirect aborts the thread, which a catch would swallow.
            Response.Redirect("admindashboard.aspx");
        }

        private void ShowMessage(string text, bool success)
        {
            litMessage.Text = "<p class=\"admin-auth__msg" + (success ? "" : " admin-auth__msg--error") +
                "\" role=\"" + (success ? "status" : "alert") + "\">" + Server.HtmlEncode(text) + "</p>";
        }
    }
}
