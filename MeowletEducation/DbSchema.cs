using System;
using System.Configuration;
using System.Data.SqlClient;

namespace MeowletEducation
{
    // Brings an existing database up to date with the columns the tutor
    // dashboard and tutor verification need, the same way Signin.aspx.cs adds
    // DeleteRequestedAt on the fly. Every step checks first, so it is safe to
    // run against any database; it runs once per application start.
    // App_Data/CreateDatabase.sql contains the same changes for fresh installs.
    public static class DbSchema
    {
        private static readonly object Gate = new object();
        private static bool done;

        // One batch per step: a column must exist before a later batch can use it.
        private static readonly string[] Steps =
        {
            @"IF COL_LENGTH('dbo.Courses', 'ReviewRequestedAt') IS NULL
                  ALTER TABLE dbo.Courses ADD ReviewRequestedAt DATETIME2 NULL;",

            @"IF COL_LENGTH('dbo.CourseLessons', 'ARSceneKey') IS NULL
                  ALTER TABLE dbo.CourseLessons ADD ARSceneKey NVARCHAR(50) NULL;",

            @"IF EXISTS (SELECT 1 FROM sys.check_constraints
                         WHERE name = 'CK_CourseLessons_ContentType' AND definition NOT LIKE '%''AR''%')
              BEGIN
                  ALTER TABLE dbo.CourseLessons DROP CONSTRAINT CK_CourseLessons_ContentType;
                  ALTER TABLE dbo.CourseLessons ADD CONSTRAINT CK_CourseLessons_ContentType
                      CHECK (ContentType IN ('Video', 'Article', 'Quiz', 'AR'));
              END",

            @"IF OBJECT_ID('dbo.CK_CourseLessons_ARScene', 'C') IS NULL
                  ALTER TABLE dbo.CourseLessons ADD CONSTRAINT CK_CourseLessons_ARScene
                      CHECK (ContentType <> 'AR' OR ARSceneKey IS NOT NULL);",

            @"IF COL_LENGTH('dbo.CourseReviews', 'TutorReply') IS NULL
                  ALTER TABLE dbo.CourseReviews ADD TutorReply NVARCHAR(1000) NULL;",

            @"IF COL_LENGTH('dbo.CourseReviews', 'TutorRepliedAt') IS NULL
                  ALTER TABLE dbo.CourseReviews ADD TutorRepliedAt DATETIME2 NULL;",

            @"IF COL_LENGTH('dbo.SessionReviews', 'TutorReply') IS NULL
                  ALTER TABLE dbo.SessionReviews ADD TutorReply NVARCHAR(1000) NULL;",

            @"IF COL_LENGTH('dbo.SessionReviews', 'TutorRepliedAt') IS NULL
                  ALTER TABLE dbo.SessionReviews ADD TutorRepliedAt DATETIME2 NULL;",

            // AR lessons: per-lesson scene settings (JSON) and every attempt a learner makes.
            @"IF COL_LENGTH('dbo.CourseLessons', 'ARConfig') IS NULL
                  ALTER TABLE dbo.CourseLessons ADD ARConfig NVARCHAR(MAX) NULL;",

            ArResultsTableSql,

            // Camera view (webcam behind the 3D scene) was added after the first AR release.
            @"IF EXISTS (SELECT 1 FROM sys.check_constraints
                         WHERE name = 'CK_ARActivityResults_Mode' AND definition NOT LIKE '%camera%')
              BEGIN
                  ALTER TABLE dbo.ARActivityResults DROP CONSTRAINT CK_ARActivityResults_Mode;
                  ALTER TABLE dbo.ARActivityResults ADD CONSTRAINT CK_ARActivityResults_Mode
                      CHECK (Mode IN ('ar', 'camera', '3d'));
              END",

            // 'card' = image tracking on the printed Meowlet card (assets/js/ar/ar-card.js).
            @"IF EXISTS (SELECT 1 FROM sys.check_constraints
                         WHERE name = 'CK_ARActivityResults_Mode' AND definition NOT LIKE '%''card''%')
              BEGIN
                  ALTER TABLE dbo.ARActivityResults DROP CONSTRAINT CK_ARActivityResults_Mode;
                  ALTER TABLE dbo.ARActivityResults ADD CONSTRAINT CK_ARActivityResults_Mode
                      CHECK (Mode IN ('ar', 'card', 'camera', '3d'));
              END",

            @"IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ARActivityResults_Lesson')
                  CREATE INDEX IX_ARActivityResults_Lesson ON dbo.ARActivityResults (LessonId, UserId, CompletedAt);"
        };

        // Same definition as in App_Data/CreateDatabase.sql.
        private const string ArResultsTableSql = @"
IF OBJECT_ID('dbo.ARActivityResults', 'U') IS NULL
CREATE TABLE dbo.ARActivityResults (
    ResultId    INT IDENTITY(1,1) PRIMARY KEY,
    UserId      INT            NOT NULL CONSTRAINT FK_ARActivityResults_Users   REFERENCES dbo.Users(UserId)           ON DELETE CASCADE,
    LessonId    INT            NOT NULL CONSTRAINT FK_ARActivityResults_Lessons REFERENCES dbo.CourseLessons(LessonId) ON DELETE CASCADE,
    SceneKey    NVARCHAR(50)   NOT NULL,
    Mode        NVARCHAR(10)   NOT NULL CONSTRAINT CK_ARActivityResults_Mode  CHECK (Mode IN ('ar', 'card', 'camera', '3d')),
    Score       TINYINT        NULL     CONSTRAINT CK_ARActivityResults_Score CHECK (Score BETWEEN 0 AND 100),
    Summary     NVARCHAR(400)  NULL,
    ResultJson  NVARCHAR(MAX)  NULL,
    Seconds     INT            NULL,
    CompletedAt DATETIME2      NOT NULL CONSTRAINT DF_ARActivityResults_CompletedAt DEFAULT (SYSUTCDATETIME())
);";

        // Called after a tutor uploads a certificate (Profile.aspx, SignupTutor.aspx):
        // queues it for an admin in TutorVerifications. An older upload that was never
        // reviewed is replaced, so the admin only sees the newest file.
        // Never blocks the upload itself; Users.CertificatePath already holds the file.
        public static void RecordCertificateUpload(SqlConnection conn, int tutorId, string certificatePath, string institution)
        {
            try
            {
                using (var cmd = new SqlCommand(@"
DELETE FROM dbo.TutorVerifications WHERE TutorId = @Id AND Status = 'Pending';
INSERT INTO dbo.TutorVerifications (TutorId, CertificatePath, Institution) VALUES (@Id, @Path, @Inst);", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", tutorId);
                    cmd.Parameters.AddWithValue("@Path", certificatePath);
                    cmd.Parameters.AddWithValue("@Inst", string.IsNullOrEmpty(institution) ? (object)DBNull.Value : institution);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException)
            {
                // TutorVerifications missing on a very old database: the admin queue
                // still finds the tutor through Users.CertificatePath.
            }
        }

        // Returns null when the database is up to date, otherwise the reason it isn't.
        public static string EnsureUpToDate()
        {
            if (done) return null;

            lock (Gate)
            {
                if (done) return null;

                try
                {
                    string connStr = ConfigurationManager.ConnectionStrings["MeowletDb"].ConnectionString;
                    using (var conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        foreach (string step in Steps)
                        {
                            using (var cmd = new SqlCommand(step, conn))
                            {
                                cmd.ExecuteNonQuery();
                            }
                        }
                    }
                    done = true;
                    return null;
                }
                catch (SqlException ex)
                {
                    // Not marked done, so the next request tries again.
                    return ex.Message;
                }
            }
        }
    }
}
