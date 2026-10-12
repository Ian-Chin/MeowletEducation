using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.SessionState;

namespace MeowletEducation
{
    // Streams a tutor's certificate from App_Data/Certificates, which the web
    // server never serves directly. Only an admin, or the tutor themselves, may see it.
    //   Certificate.ashx?user=12          the tutor's current certificate
    //   Certificate.ashx?verification=34  the file attached to one review in TutorVerifications
    public class Certificate : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            var session = context.Session;
            bool isAdmin = session != null &&
                string.Equals(Convert.ToString(session["Role"]), "Admin", StringComparison.OrdinalIgnoreCase);
            int viewerId = session != null && session["UserId"] != null ? Convert.ToInt32(session["UserId"]) : 0;

            int userId, verificationId;
            int.TryParse(context.Request.QueryString["user"], out userId);
            int.TryParse(context.Request.QueryString["verification"], out verificationId);

            // Look the path up in the database; never take a file name from the URL.
            string relPath = null;
            int ownerId = 0;
            string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;
            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand(verificationId > 0
                ? "SELECT TutorId, CertificatePath FROM dbo.TutorVerifications WHERE VerificationId = @Id"
                : "SELECT UserId, CertificatePath FROM dbo.Users WHERE UserId = @Id AND Role = 'Tutor'", conn))
            {
                cmd.Parameters.AddWithValue("@Id", verificationId > 0 ? verificationId : userId);
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read() && !reader.IsDBNull(1))
                    {
                        ownerId = reader.GetInt32(0);
                        relPath = reader.GetString(1);
                    }
                }
            }

            if (!isAdmin && (viewerId == 0 || viewerId != ownerId))
            {
                Fail(context, 403, "Log in as an admin to view tutor certificates.");
                return;
            }

            if (string.IsNullOrEmpty(relPath))
            {
                Fail(context, 404, "No certificate has been uploaded.");
                return;
            }

            string folder = Path.GetFullPath(context.Server.MapPath("~/App_Data/Certificates/"));
            string fullPath = Path.GetFullPath(context.Server.MapPath("~/" + relPath.TrimStart('~', '/')));

            if (!fullPath.StartsWith(folder, StringComparison.OrdinalIgnoreCase) || !File.Exists(fullPath))
            {
                Fail(context, 404, "The certificate file is missing from App_Data/Certificates.");
                return;
            }

            string ext = Path.GetExtension(fullPath).ToLowerInvariant();
            string type;
            switch (ext)
            {
                case ".pdf": type = "application/pdf"; break;
                case ".png": type = "image/png"; break;
                case ".jpg":
                case ".jpeg": type = "image/jpeg"; break;
                default:
                    Fail(context, 415, "This file type can't be shown.");
                    return;
            }

            context.Response.ContentType = type;
            context.Response.AddHeader("Content-Disposition", "inline; filename=\"" + Path.GetFileName(fullPath) + "\"");
            context.Response.AddHeader("X-Content-Type-Options", "nosniff");
            context.Response.Cache.SetCacheability(HttpCacheability.Private);
            context.Response.TransmitFile(fullPath);
        }

        private static void Fail(HttpContext context, int status, string message)
        {
            context.Response.StatusCode = status;
            context.Response.ContentType = "text/plain";
            context.Response.Write(message);
        }
    }
}
