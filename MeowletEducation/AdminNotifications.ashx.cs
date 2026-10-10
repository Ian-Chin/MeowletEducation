using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;

namespace MeowletEducation
{
    // JSON feed behind the bell in the admin dashboard.
    //   GET                         pending admin sign ups
    //   POST action=generate&id=N   new access code for request N (returned once, stored hashed)
    //   POST action=decline&id=N    deletes the pending sign up (no Users row exists yet)
    // Admins only. POSTs must carry X-Requested-With, which a plain
    // cross-site form can't send.
    public class AdminNotifications : IHttpHandler, IRequiresSessionState
    {
        private const string PendingSql = @"
SELECT r.RequestId, r.FullName, r.Email, r.RequestedAt, r.CodeExpiresAt, r.FailedTries,
       g.FullName AS GeneratedByName
FROM dbo.AdminAccessRequests r
LEFT JOIN dbo.Users g ON g.UserId = r.GeneratedBy
ORDER BY r.RequestedAt DESC;";

        public bool IsReusable { get { return false; } }

        private static string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString; }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            if (!IsAdmin(context))
            {
                Fail(context, 401, "Log in as an admin.");
                return;
            }

            try
            {
                if (context.Request.HttpMethod == "GET")
                {
                    Write(context, new { items = LoadPending() });
                    return;
                }

                if (context.Request.HttpMethod != "POST" ||
                    context.Request.Headers["X-Requested-With"] != "fetch")
                {
                    Fail(context, 400, "Unsupported request.");
                    return;
                }

                int requestId;
                if (!int.TryParse(context.Request.Form["id"], out requestId))
                {
                    Fail(context, 400, "Missing request id.");
                    return;
                }

                switch (context.Request.Form["action"])
                {
                    case "generate": Generate(context, requestId); break;
                    case "decline": Decline(context, requestId); break;
                    default: Fail(context, 400, "Unknown action."); break;
                }
            }
            catch (SqlException)
            {
                Fail(context, 503, "The database could not be reached.");
            }
        }

        private static bool IsAdmin(HttpContext context)
        {
            if (AdminDashboard.DevBypassAuth) return true;
            return context.Session["UserId"] != null &&
                string.Equals(Convert.ToString(context.Session["Role"]), "Admin", StringComparison.OrdinalIgnoreCase);
        }

        private static List<object> LoadPending()
        {
            var items = new List<object>();

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(PendingSql, conn))
            {
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        DateTime? expires = reader.IsDBNull(4) ? (DateTime?)null : reader.GetDateTime(4);
                        bool locked = reader.GetInt32(5) >= AdminAccessCodes.MaxFailedTries;

                        // "waiting": no code yet, or the last one can't be used any more.
                        string status = !expires.HasValue ? "waiting"
                            : expires.Value < DateTime.UtcNow ? "expired"
                            : locked ? "locked"
                            : "sent";

                        items.Add(new
                        {
                            id = reader.GetInt32(0),
                            name = reader.GetString(1),
                            email = reader.GetString(2),
                            requestedAt = Iso(reader.GetDateTime(3)),
                            status = status,
                            expiresAt = expires.HasValue ? Iso(expires.Value) : null,
                            generatedBy = reader.IsDBNull(6) ? null : reader.GetString(6)
                        });
                    }
                }
            }

            return items;
        }

        private static void Generate(HttpContext context, int requestId)
        {
            string code = AdminAccessCodes.Generate();
            DateTime expires = DateTime.UtcNow.Add(AdminAccessCodes.Lifetime);
            object generatedBy = context.Session["UserId"] ?? (object)DBNull.Value;

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(
                @"UPDATE dbo.AdminAccessRequests
                  SET CodeHash = @Hash, CodeExpiresAt = @Expires, GeneratedBy = @By,
                      GeneratedAt = SYSUTCDATETIME(), FailedTries = 0
                  OUTPUT INSERTED.FullName, INSERTED.Email
                  WHERE RequestId = @Id;", conn))
            {
                cmd.Parameters.AddWithValue("@Hash", AdminAccessCodes.Hash(code));
                cmd.Parameters.AddWithValue("@Expires", expires);
                cmd.Parameters.AddWithValue("@By", generatedBy);
                cmd.Parameters.AddWithValue("@Id", requestId);
                conn.Open();

                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        Fail(context, 404, "That request was already approved or removed.");
                        return;
                    }

                    // The plain code leaves the server once, here, for the admin to send on.
                    Write(context, new
                    {
                        code = code,
                        name = reader.GetString(0),
                        email = reader.GetString(1),
                        expiresAt = Iso(expires)
                    });
                }
            }
        }

        private static void Decline(HttpContext context, int requestId)
        {
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(
                "DELETE FROM dbo.AdminAccessRequests WHERE RequestId = @Id;", conn))
            {
                cmd.Parameters.AddWithValue("@Id", requestId);
                conn.Open();

                if (cmd.ExecuteNonQuery() == 0)
                {
                    Fail(context, 404, "That request was already approved or removed.");
                    return;
                }
            }

            Write(context, new { ok = true });
        }

        private static string Iso(DateTime utc)
        {
            return DateTime.SpecifyKind(utc, DateTimeKind.Utc).ToString("o");
        }

        private static void Write(HttpContext context, object value)
        {
            context.Response.Write(new JavaScriptSerializer().Serialize(value));
        }

        private static void Fail(HttpContext context, int status, string message)
        {
            context.Response.StatusCode = status;
            Write(context, new { error = message });
        }
    }
}
