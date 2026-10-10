using System;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;

namespace MeowletEducation
{
    // Who is signed in, for static pages such as index.html that can't read
    // the session themselves.
    //   GET                   { signedIn, name, initials, role, dashboard, profile }
    //   POST action=logout    ends the session
    // POSTs must carry X-Requested-With, which a plain cross-site form can't send.
    public class Account : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            if (context.Request.HttpMethod == "POST")
            {
                if (context.Request.Headers["X-Requested-With"] != "fetch" ||
                    context.Request.Form["action"] != "logout")
                {
                    context.Response.StatusCode = 400;
                    Write(context, new { error = "Unsupported request." });
                    return;
                }

                context.Session.Clear();
                context.Session.Abandon();
                Write(context, new { signedIn = false });
                return;
            }

            if (context.Session["UserId"] == null)
            {
                Write(context, new { signedIn = false });
                return;
            }

            string name = Convert.ToString(context.Session["FullName"]);
            string role = Convert.ToString(context.Session["Role"]);
            bool isAdmin = string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase);
            bool isStudent = string.Equals(role, "Student", StringComparison.OrdinalIgnoreCase);

            Write(context, new
            {
                signedIn = true,
                name = name,
                initials = Initials(name),
                role = role,
                // Tutors have no dashboard yet, so their profile is their home.
                dashboard = isAdmin ? "admindashboard.aspx" : isStudent ? "memberdashboard.aspx" : "Profile.aspx",
                // Admins edit their profile inside the admin dashboard.
                profile = isAdmin ? null : "Profile.aspx"
            });
        }

        private static string Initials(string name)
        {
            string[] parts = (name ?? string.Empty).Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 0) return "?";
            string first = parts[0].Substring(0, 1);
            string last = parts.Length > 1 ? parts[parts.Length - 1].Substring(0, 1) : string.Empty;
            return (first + last).ToUpperInvariant();
        }

        private static void Write(HttpContext context, object value)
        {
            context.Response.Write(new JavaScriptSerializer().Serialize(value));
        }
    }
}
