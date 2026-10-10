using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace MeowletEducation
{
    // Course builder: chapters on the left, the selected chapter's content on
    // the right. Everything after the header is drawn and saved by
    // assets/js/course-builder.js through AdminCourseApi.ashx.
    public partial class AdminCourse : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AdminDashboard.DevBypassAuth &&
                (Session["UserId"] == null ||
                 !string.Equals(Convert.ToString(Session["Role"]), "Admin", StringComparison.OrdinalIgnoreCase)))
            {
                Response.Redirect("AdminSignin.aspx");
                return;
            }

            int courseId;
            if (!int.TryParse(Request.QueryString["id"], out courseId) || !BindCourse(courseId))
            {
                Response.Redirect("admindashboard.aspx#courses");
            }
        }

        private bool BindCourse(int courseId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;

            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand(
                "SELECT CourseCode, Title, IsPublished, ImageUrl FROM dbo.Courses WHERE CourseId = @Id", conn))
            {
                cmd.Parameters.AddWithValue("@Id", courseId);
                conn.Open();

                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return false;

                    string title = r.GetString(1);
                    Title = title + " - Course builder - Meowlet Education";
                    litCourseId.Text = courseId.ToString();
                    litCode.Text = Server.HtmlEncode(r.GetString(0));
                    litTitle.Text = Server.HtmlEncode(title);
                    litStatus.Text = r.GetBoolean(2)
                        ? "<span class=\"tag tag--live\">Published</span>"
                        : "<span class=\"tag\">Draft</span>";
                    litCover.Text = CourseImages.Cover(r.IsDBNull(3) ? null : r.GetString(3), "cb-top__cover");
                    return true;
                }
            }
        }
    }
}
