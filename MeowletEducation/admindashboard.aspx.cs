using System;
using System.Web;
using System.Web.UI;

namespace MeowletEducation
{
    public partial class AdminDashboard : Page
    {
        // TODO: set back to false before submission / deployment.
        // While true, the login and role checks are skipped so the
        // dashboard layout can be opened directly.
        private const bool DevBypassAuth = true;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!DevBypassAuth)
            {
                // Must be logged in
                if (Session["UserId"] == null)
                {
                    Response.Redirect("Signin.aspx");
                    return;
                }

                // Admin only
                string role = Convert.ToString(Session["Role"]);

                if (!string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("Index.aspx");
                    return;
                }
            }

            if (!IsPostBack)
            {
                BindAdminBadge();
            }
        }

        private void BindAdminBadge()
        {
            string fullName = Convert.ToString(Session["FullName"]);

            if (string.IsNullOrWhiteSpace(fullName))
            {
                fullName = "Administrator";
            }

            litAdminName.Text = Server.HtmlEncode(fullName);
            litMenuName.Text = Server.HtmlEncode(fullName);

            // Greeting uses the first name only, e.g. "Welcome back, Ian".
            string firstName = fullName.Split(new[] { ' ' },
                StringSplitOptions.RemoveEmptyEntries)[0];

            litWelcomeName.Text = Server.HtmlEncode(firstName);

            // Rendered inside a JavaScript string literal, so it needs
            // JS escaping rather than HTML encoding.
            litAdminNameJs.Text = HttpUtility.JavaScriptStringEncode(firstName);
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Signin.aspx");
        }
    }
}
