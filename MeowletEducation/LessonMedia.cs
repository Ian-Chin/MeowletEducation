using System;
using System.IO;
using System.Web;

namespace MeowletEducation
{
    // Pictures and videos uploaded into lesson blocks from the course builder.
    // Files are checked by their first bytes, not just their names, and saved
    // under a new name in assets/media/lessons/.
    public static class LessonMedia
    {
        public const string Folder = "assets/media/lessons/";
        public const int MaxImageBytes = 10 * 1024 * 1024;
        public const int MaxVideoBytes = 100 * 1024 * 1024;

        // Returns the site-relative path, or null with error set when the file is refused.
        public static string Save(HttpPostedFile file, string kind, out string error)
        {
            error = null;
            bool video = kind == "Video";
            int max = video ? MaxVideoBytes : MaxImageBytes;

            if (file == null || file.ContentLength == 0)
            {
                error = "Choose a file to upload.";
                return null;
            }

            if (file.ContentLength > max)
            {
                error = video ? "Videos must be smaller than 100 MB." : "Pictures must be smaller than 10 MB.";
                return null;
            }

            var head = new byte[12];
            int read = file.InputStream.Read(head, 0, head.Length);
            file.InputStream.Position = 0;

            string ext = video ? VideoExtension(head, read) : ImageExtension(head, read);
            if (ext == null)
            {
                error = video ? "Upload an MP4 or WebM video." : "Upload a JPG, PNG, GIF or WebP picture.";
                return null;
            }

            string folder = HttpContext.Current.Server.MapPath("~/" + Folder);
            Directory.CreateDirectory(folder);

            string name = Guid.NewGuid().ToString("N") + ext;
            file.SaveAs(Path.Combine(folder, name));
            return Folder + name;
        }

        // Removes a file this class saved. Links to other sites are left alone.
        public static void Delete(string url)
        {
            if (string.IsNullOrEmpty(url) || !url.StartsWith(Folder, StringComparison.OrdinalIgnoreCase))
                return;

            string path = Path.Combine(HttpContext.Current.Server.MapPath("~/" + Folder), Path.GetFileName(url));
            try
            {
                if (File.Exists(path)) File.Delete(path);
            }
            catch (IOException)
            {
                // A locked file only leaves an orphan behind.
            }
        }

        private static string ImageExtension(byte[] h, int n)
        {
            if (n >= 3 && h[0] == 0xFF && h[1] == 0xD8 && h[2] == 0xFF) return ".jpg";
            if (n >= 4 && h[0] == 0x89 && h[1] == 0x50 && h[2] == 0x4E && h[3] == 0x47) return ".png";
            if (n >= 4 && h[0] == 'G' && h[1] == 'I' && h[2] == 'F' && h[3] == '8') return ".gif";
            if (n >= 12 && h[0] == 'R' && h[1] == 'I' && h[2] == 'F' && h[3] == 'F' &&
                h[8] == 'W' && h[9] == 'E' && h[10] == 'B' && h[11] == 'P') return ".webp";
            return null;
        }

        private static string VideoExtension(byte[] h, int n)
        {
            if (n >= 8 && h[4] == 'f' && h[5] == 't' && h[6] == 'y' && h[7] == 'p') return ".mp4";
            if (n >= 4 && h[0] == 0x1A && h[1] == 0x45 && h[2] == 0xDF && h[3] == 0xA3) return ".webm";
            return null;
        }
    }
}
