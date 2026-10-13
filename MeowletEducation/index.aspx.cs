using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace MeowletEducation
{
    public partial class Landing : Page
    {
        // How many courses are shown on the landing page (search still covers all of them)
        private const int FeaturedCount = 4;

        // JSON for the preview modal + global search (all published courses and their lesson outlines)
        protected string CoursePreviewJson = "[]";

        // ---- Course image column -------------------------------------------------
        // The image column is auto-detected (ImageUrl, ImagePath, Thumbnail, CoverImage, ...).
        // If your column has an unusual name, put it here, e.g. "CourseImage".
        private const string ImageColumnOverride = "";

        private static readonly string[] ImageColumnCandidates =
        {
            "ImageUrl", "ImagePath", "Image", "ImgUrl", "ImgPath", "Img",
            "ThumbnailUrl", "Thumbnail", "CoverImageUrl", "CoverImage", "CoverUrl",
            "PhotoUrl", "Photo", "BannerUrl", "Banner"
        };

        private static string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString; }
        }

        private static string FindImageColumn(DataTable table)
        {
            if (ImageColumnOverride.Length > 0 && table.Columns.Contains(ImageColumnOverride))
                return ImageColumnOverride;

            foreach (string name in ImageColumnCandidates)
                if (table.Columns.Contains(name)) return table.Columns[name].ColumnName;

            foreach (DataColumn col in table.Columns)
            {
                string n = col.ColumnName.ToLowerInvariant();
                if (n.Contains("image") || n.Contains("img") || n.Contains("thumb") ||
                    n.Contains("cover") || n.Contains("photo") || n.Contains("banner"))
                    return col.ColumnName;
            }
            return null;
        }

        // Supports a path / URL string ("assets/img/x.png", "~/assets/x.png", "https://...")
        // and a binary column (varbinary / image), which is turned into a data: URI.
        private static string ToImageSrc(object value)
        {
            if (value == null || value == DBNull.Value) return "";

            byte[] bytes = value as byte[];
            if (bytes != null)
            {
                if (bytes.Length == 0) return "";
                string mime = "image/png";
                if (bytes.Length > 3 && bytes[0] == 0xFF && bytes[1] == 0xD8) mime = "image/jpeg";
                else if (bytes.Length > 3 && bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) mime = "image/gif";
                else if (bytes.Length > 11 && bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[8] == 0x57) mime = "image/webp";
                return "data:" + mime + ";base64," + Convert.ToBase64String(bytes);
            }

            string s = Convert.ToString(value).Trim();
            if (s.Length == 0) return "";
            if (s.StartsWith("~/")) return VirtualPathUtility.ToAbsolute(s);
            return s;
        }

        private static void AddImageSrc(DataTable table)
        {
            string col = FindImageColumn(table);
            table.Columns.Add("ImageSrc", typeof(string));
            foreach (DataRow row in table.Rows)
                row["ImageSrc"] = col == null ? "" : ToImageSrc(row[col]);
        }

        private static Dictionary<int, List<object>> LoadLessons(SqlConnection conn)
        {
            var map = new Dictionary<int, List<object>>();
            using (var cmd = new SqlCommand(@"
SELECT l.CourseId, l.Position, l.Title, l.ContentType, l.DurationMinutes
FROM dbo.CourseLessons l
INNER JOIN dbo.Courses c ON c.CourseId = l.CourseId
WHERE c.IsPublished = 1
ORDER BY l.CourseId, l.Position;", conn))
            using (var r = cmd.ExecuteReader())
            {
                while (r.Read())
                {
                    int id = Convert.ToInt32(r["CourseId"]);
                    List<object> list;
                    if (!map.TryGetValue(id, out list))
                    {
                        list = new List<object>();
                        map[id] = list;
                    }
                    list.Add(new
                    {
                        position = Convert.ToInt32(r["Position"]),
                        title = Convert.ToString(r["Title"]),
                        contentType = Convert.ToString(r["ContentType"]),
                        durationMinutes = Convert.ToInt32(r["DurationMinutes"])
                    });
                }
            }
            return map;
        }

        // All published courses + tutor name + lesson count + ImageSrc.
        private static DataTable LoadCourses(SqlConnection conn)
        {
            var table = new DataTable();
            using (var cmd = new SqlCommand(@"
SELECT c.*,
       ISNULL(t.FullName, N'Meowlet team') AS TutorName,
       (SELECT COUNT(*) FROM dbo.CourseLessons l WHERE l.CourseId = c.CourseId) AS LessonCount
FROM dbo.Courses c
LEFT JOIN dbo.Users t ON t.UserId = c.TutorId
WHERE c.IsPublished = 1
ORDER BY c.Category, c.Level, c.Title;", conn))
            using (var adapter = new SqlDataAdapter(cmd))
            {
                adapter.Fill(table);
            }
            AddImageSrc(table);
            return table;
        }

        private static string BuildPreviewJson(DataTable table, Dictionary<int, List<object>> lessonMap)
        {
            var list = new List<object>();
            foreach (DataRow row in table.Rows)
            {
                int courseId = Convert.ToInt32(row["CourseId"]);
                List<object> lessons;
                if (!lessonMap.TryGetValue(courseId, out lessons)) lessons = new List<object>();

                string img = Convert.ToString(row["ImageSrc"]);
                if (img.StartsWith("data:", StringComparison.OrdinalIgnoreCase)) img = ""; // keep the JSON small

                list.Add(new
                {
                    id = courseId,
                    code = Convert.ToString(row["CourseCode"]),
                    title = Convert.ToString(row["Title"]),
                    category = Convert.ToString(row["Category"]),
                    level = Convert.ToString(row["Level"]),
                    description = Convert.ToString(row["Description"]),
                    tutorName = Convert.ToString(row["TutorName"]),
                    lessonCount = Convert.ToInt32(row["LessonCount"]),
                    image = img,
                    lessons = lessons
                });
            }

            var ser = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
            // "<" is escaped so a description can never close the <script> tag
            return ser.Serialize(list).Replace("<", "\\u003c");
        }

        protected static string Html(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value ?? ""));
        }

        protected static string ShortDesc(object value)
        {
            string s = Convert.ToString(value ?? "");
            if (s.Length <= 100) return HttpUtility.HtmlEncode(s);
            return HttpUtility.HtmlEncode(s.Substring(0, 100).TrimEnd()) + "…";
        }

        protected static string LevelClass(object level)
        {
            string s = Convert.ToString(level ?? "").Trim().ToLowerInvariant();
            s = Regex.Replace(s, "[^a-z0-9]+", "-").Trim('-');
            return "level-tag level-" + s;
        }

        protected static string ImgTag(object src)
        {
            string s = Convert.ToString(src ?? "");
            if (s.Length == 0) return "";
            return "<img src=\"" + HttpUtility.HtmlAttributeEncode(s) + "\" alt=\"\" loading=\"lazy\" onerror=\"this.remove()\" />";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            BindCourses();
        }

        private void BindCourses()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    DataTable all = LoadCourses(conn);
                    var lessonMap = LoadLessons(conn);

                    // Landing page grid: first N courses only
                    DataTable featured = all.Clone();
                    for (int i = 0; i < all.Rows.Count && i < FeaturedCount; i++)
                        featured.ImportRow(all.Rows[i]);

                    rptCourses.DataSource = featured;
                    rptCourses.DataBind();
                    pnlNoCourses.Visible = all.Rows.Count == 0;

                    CoursePreviewJson = BuildPreviewJson(all, lessonMap);
                }
            }
            catch (Exception ex)
            {
                rptCourses.DataSource = null;
                rptCourses.DataBind();
                pnlNoCourses.Visible = true;
                pnlNoCourses.Controls.Clear();
                pnlNoCourses.Controls.Add(new LiteralControl(
                    "<strong>Database error:</strong> " + Server.HtmlEncode(ex.Message)));
                CoursePreviewJson = "[]";
            }
        }
    }
}