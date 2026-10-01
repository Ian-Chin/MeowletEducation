using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace MeowletEducation
{
    public partial class Index : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            if (Session["UserId"] != null && Session["FullName"] != null)
            {
                string name = Session["FullName"].ToString();
                litIndexName.Text = Server.HtmlEncode(name);

                if (!string.IsNullOrEmpty(name))
                    litIndexInitial.Text = Server.HtmlEncode(name.Substring(0, 1).ToUpper());

                string role = Session["Role"] != null ? Session["Role"].ToString() : "Student";
                if (role.Equals("Tutor", StringComparison.OrdinalIgnoreCase)
                    || role.Equals("Teacher", StringComparison.OrdinalIgnoreCase))
                {
                    litRoleWelcome.Text = "<p style='font-size: 13px; text-transform: uppercase; letter-spacing: 1.5px; color: #2e7d32; font-weight:600; margin-bottom: 10px;'>Tutor Dashboard Portal</p>";
                }
                else
                {
                    litRoleWelcome.Text = "<p style='font-size: 13px; text-transform: uppercase; letter-spacing: 1.5px; color: #888; margin-bottom: 10px;'>Student Learning Portal</p>";
                }

                bool verified = false;
                if (Session["IsVerified"] != null)
                    verified = Convert.ToBoolean(Session["IsVerified"]);
                else
                    verified = LoadVerifiedFlag(); 

                if (role.Equals("Tutor", StringComparison.OrdinalIgnoreCase) && verified)
                {
                    litVerifiedMark.Text = "<span class=\"verified-dot\" title=\"Verified\">&#10003;</span>";
                    phAccountLoggedIn.CssClass = "account-badge account-badge--gold";
                }
                else
                {
                    litVerifiedMark.Text = "";
                    phAccountLoggedIn.CssClass = "account-badge";
                }


                phAccountLoggedIn.Visible = true;
                phAccountGuest.Visible = false;
            }
            else
            {

                phAccountLoggedIn.Visible = false;
                phAccountGuest.Visible = true;
                litRoleWelcome.Text = "<p style='font-size: 13px; text-transform: uppercase; letter-spacing: 1.5px; color: #888; margin-bottom: 10px;'>Fintech &amp; Personal Finance Portal</p>";
            }
        }
        private bool LoadVerifiedFlag()
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;
                using (var conn = new SqlConnection(connStr))
                using (var cmd = new SqlCommand("SELECT IsVerified FROM Users WHERE UserId = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", Session["UserId"]);
                    conn.Open();

                    object o = cmd.ExecuteScalar();
                    bool v = o != null && o != DBNull.Value && Convert.ToBoolean(o);
                    Session["IsVerified"] = v;
                    return v;
                }
            }
            catch
            {
                return false;
            }
        }

    }
}