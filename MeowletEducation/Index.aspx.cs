using System;

namespace MeowletEducation
{
    public partial class Index : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            if (Session["FullName"] != null)
            {
                string name = Session["FullName"].ToString();
                litIndexName.Text = name;

                if (!string.IsNullOrEmpty(name))
                {
                    litIndexInitial.Text = name.Substring(0, 1).ToUpper();
                }

                string role = Session["Role"] != null ? Session["Role"].ToString() : "Student";
                if (role.Equals("Teacher", StringComparison.OrdinalIgnoreCase))
                {
                    litRoleWelcome.Text = "<p style='font-size: 13px; text-transform: uppercase; letter-spacing: 1.5px; color: #2e7d32; font-weight:600; margin-bottom: 10px;'>Teacher Dashboard Portal</p>";
                }
                else
                {
                    litRoleWelcome.Text = "<p style='font-size: 13px; text-transform: uppercase; letter-spacing: 1.5px; color: #888; margin-bottom: 10px;'>Student Learning Portal</p>";
                }
            }
            else
            {
                litIndexName.Text = "Sign In";
                litIndexInitial.Text = "?";
            }
        }
    }
}