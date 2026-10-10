using System;
using System.IO;
using System.Web;

namespace MeowletEducation
{
    // Course cover pictures. Courses.ImageUrl holds a site-relative path:
    // seeded courses use their own Pexels photo (assets/img/courses/<code>.jpg),
    // and pictures uploaded from the admin dashboard go to
    // assets/img/courses/uploads/. A course without one shows a placeholder,
    // so no two courses share a photo.
    public static class CourseImages
    {
        public const string UploadFolder = "assets/img/courses/uploads/";
        public const int MaxBytes = 5 * 1024 * 1024;

        // <img> for the card, or an empty tile with an icon when there is no picture.
        public static string Cover(object imageUrl, string cssClass)
        {
            string url = Convert.ToString(imageUrl);
            if (string.IsNullOrWhiteSpace(url))
            {
                return "<div class=\"" + cssClass + " " + cssClass + "--empty\" aria-hidden=\"true\"><i class=\"bi bi-image\"></i></div>";
            }

            return "<img class=\"" + cssClass + "\" src=\"" + HttpUtility.HtmlAttributeEncode(url) + "\" alt=\"\" loading=\"lazy\" />";
        }

        // Saves an uploaded JPEG, PNG or WebP under a new name and returns its
        // site-relative path. Returns null and sets error when the file is refused.
        public static string SaveUpload(HttpPostedFile file, out string error)
        {
            error = null;
            string ext = Path.GetExtension(file.FileName ?? string.Empty).ToLowerInvariant();

            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".webp")
            {
                error = "The picture must be a JPG, PNG or WebP file.";
                return null;
            }

            if (file.ContentLength == 0 || file.ContentLength > MaxBytes)
            {
                error = "The picture must be smaller than 5 MB.";
                return null;
            }

            // Check the file really is an image, not just named like one.
            var head = new byte[12];
            int read = file.InputStream.Read(head, 0, head.Length);
            file.InputStream.Position = 0;
            bool jpeg = read >= 3 && head[0] == 0xFF && head[1] == 0xD8 && head[2] == 0xFF;
            bool png = read >= 4 && head[0] == 0x89 && head[1] == 0x50 && head[2] == 0x4E && head[3] == 0x47;
            bool webp = read >= 12 && head[0] == 'R' && head[1] == 'I' && head[2] == 'F' && head[3] == 'F' &&
                        head[8] == 'W' && head[9] == 'E' && head[10] == 'B' && head[11] == 'P';

            if (!jpeg && !png && !webp)
            {
                error = "That file isn't a picture we can use.";
                return null;
            }

            string folder = HttpContext.Current.Server.MapPath("~/" + UploadFolder);
            Directory.CreateDirectory(folder);

            string name = Guid.NewGuid().ToString("N") + (jpeg ? ".jpg" : png ? ".png" : ".webp");
            file.SaveAs(Path.Combine(folder, name));
            return UploadFolder + name;
        }

        // Removes a picture uploaded from the dashboard. Seeded photos are left alone.
        public static void DeleteUpload(string imageUrl)
        {
            if (string.IsNullOrEmpty(imageUrl) || !imageUrl.StartsWith(UploadFolder, StringComparison.OrdinalIgnoreCase))
                return;

            string name = Path.GetFileName(imageUrl);
            string path = Path.Combine(HttpContext.Current.Server.MapPath("~/" + UploadFolder), name);

            try
            {
                if (File.Exists(path)) File.Delete(path);
            }
            catch (IOException)
            {
                // A locked file only leaves an orphan picture behind.
            }
        }
    }
}
