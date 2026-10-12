-- Meowlet Education database schema.
-- Run against (localdb)\MSSQLLocalDB (see MeowletDb in Web.config).
-- Easiest: run setup-db.cmd in the repo root (schema + sample data).
-- Safe to re-run: objects are only created when missing, and older
-- databases are upgraded in place. Full reference: DATABASE.md.
--
-- Sections:
--   1. Accounts and onboarding   Users, Tags, UserInterests, TutorSubjects, OnboardingAnswers
--   2. Courses and learning      Courses, CourseLessons (incl. AR lessons), Enrollments, LessonProgress,
--                                ARActivityResults, CourseReviews
--   3. Tutoring                  TutorProfiles, TutorVerifications, TutorAvailability,
--                                TutoringSessions, SessionReviews, Messages
--   4. Indexes
--   5. Views and procedures      vw_TutorDirectory, vw_CourseStats, usp_DeleteUser
--   6. Reference data            Tags

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;   -- required for filtered indexes and views
GO

IF DB_ID('MeowletEducation') IS NULL
    CREATE DATABASE MeowletEducation;
GO

USE MeowletEducation;
GO

/* ===========================================================================
   1. Accounts and onboarding
   =========================================================================== */

IF OBJECT_ID('dbo.Users', 'U') IS NULL
CREATE TABLE dbo.Users (
    UserId          INT IDENTITY(1,1) PRIMARY KEY,
    FullName        NVARCHAR(100)  NOT NULL,
    Email           NVARCHAR(256)  NOT NULL,
    PasswordHash    CHAR(64)       NOT NULL,          -- SHA-256 lowercase hex
    Role            NVARCHAR(20)   NOT NULL
        CONSTRAINT CK_Users_Role CHECK (Role IN ('Student', 'Tutor', 'Admin')),
    IsActive        BIT            NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT (1),
    HasOnboarded    BIT            NOT NULL CONSTRAINT DF_Users_HasOnboarded DEFAULT (0),
    Institution     NVARCHAR(200)  NULL,
    CertificatePath NVARCHAR(400)  NULL,
    IsVerified      BIT            NOT NULL CONSTRAINT DF_Users_IsVerified DEFAULT (0),
    CreatedAt       DATETIME2      NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSUTCDATETIME()),
    DeleteRequestedAt DATETIME2    NULL,              -- set when a user asks to delete their account
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);
GO

-- Upgrade databases created before DeleteRequestedAt existed.
IF COL_LENGTH('dbo.Users', 'DeleteRequestedAt') IS NULL
    ALTER TABLE dbo.Users ADD DeleteRequestedAt DATETIME2 NULL;
GO

IF OBJECT_ID('dbo.Tags', 'U') IS NULL
CREATE TABLE dbo.Tags (
    TagId        INT IDENTITY(1,1) PRIMARY KEY,
    TagName      NVARCHAR(50)  NOT NULL CONSTRAINT UQ_Tags_TagName UNIQUE,
    DisplayLabel NVARCHAR(100) NOT NULL
);
GO

-- Student topic interests (Onboarding, role = Student).
IF OBJECT_ID('dbo.UserInterests', 'U') IS NULL
CREATE TABLE dbo.UserInterests (
    UserId INT NOT NULL CONSTRAINT FK_UserInterests_Users REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    TagId  INT NOT NULL CONSTRAINT FK_UserInterests_Tags  REFERENCES dbo.Tags(TagId)  ON DELETE CASCADE,
    CONSTRAINT PK_UserInterests PRIMARY KEY (UserId, TagId)
);
GO

-- Subjects a tutor teaches (Onboarding, role = Tutor).
IF OBJECT_ID('dbo.TutorSubjects', 'U') IS NULL
CREATE TABLE dbo.TutorSubjects (
    UserId INT NOT NULL CONSTRAINT FK_TutorSubjects_Users REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    TagId  INT NOT NULL CONSTRAINT FK_TutorSubjects_Tags  REFERENCES dbo.Tags(TagId)  ON DELETE CASCADE,
    CONSTRAINT PK_TutorSubjects PRIMARY KEY (UserId, TagId)
);
GO

IF OBJECT_ID('dbo.OnboardingAnswers', 'U') IS NULL
CREATE TABLE dbo.OnboardingAnswers (
    UserId      INT           NOT NULL CONSTRAINT FK_OnboardingAnswers_Users REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    QuestionKey NVARCHAR(50)  NOT NULL,
    AnswerValue NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_OnboardingAnswers PRIMARY KEY (UserId, QuestionKey)
);
GO

/* ===========================================================================
   2. Courses and learning
   =========================================================================== */

IF OBJECT_ID('dbo.Courses', 'U') IS NULL
CREATE TABLE dbo.Courses (
    CourseId    INT IDENTITY(1,1) PRIMARY KEY,
    CourseCode  NVARCHAR(20)   NOT NULL CONSTRAINT UQ_Courses_CourseCode UNIQUE,
    Title       NVARCHAR(200)  NOT NULL,
    Category    NVARCHAR(100)  NOT NULL,
    Level       NVARCHAR(20)   NOT NULL,
    Lessons     INT            NOT NULL CONSTRAINT DF_Courses_Lessons DEFAULT (0),  -- planned count, typed by the admin
    IsPublished BIT            NOT NULL CONSTRAINT DF_Courses_IsPublished DEFAULT (0),
    CreatedAt   DATETIME2      NOT NULL CONSTRAINT DF_Courses_CreatedAt DEFAULT (SYSUTCDATETIME())
);
GO

-- Upgrade: course description and the tutor who leads it.
IF COL_LENGTH('dbo.Courses', 'Description') IS NULL
    ALTER TABLE dbo.Courses ADD Description NVARCHAR(1000) NULL;
GO
IF COL_LENGTH('dbo.Courses', 'TutorId') IS NULL
    ALTER TABLE dbo.Courses ADD TutorId INT NULL
        CONSTRAINT FK_Courses_Tutor REFERENCES dbo.Users(UserId);   -- no cascade; usp_DeleteUser clears it
GO

-- Upgrade: a tutor can ask an admin to publish their draft (tutordashboard.aspx).
-- Set when the tutor clicks "Submit for review"; cleared when an admin publishes
-- the course or the tutor withdraws the request.
IF COL_LENGTH('dbo.Courses', 'ReviewRequestedAt') IS NULL
    ALTER TABLE dbo.Courses ADD ReviewRequestedAt DATETIME2 NULL;
GO

-- The lessons inside a course, in order.
IF OBJECT_ID('dbo.CourseLessons', 'U') IS NULL
CREATE TABLE dbo.CourseLessons (
    LessonId        INT IDENTITY(1,1) PRIMARY KEY,
    CourseId        INT            NOT NULL CONSTRAINT FK_CourseLessons_Courses REFERENCES dbo.Courses(CourseId) ON DELETE CASCADE,
    Position        INT            NOT NULL CONSTRAINT CK_CourseLessons_Position CHECK (Position >= 1),
    Title           NVARCHAR(200)  NOT NULL,
    ContentType     NVARCHAR(20)   NOT NULL
        CONSTRAINT CK_CourseLessons_ContentType CHECK (ContentType IN ('Video', 'Article', 'Quiz', 'AR')),
    ContentUrl      NVARCHAR(400)  NULL,              -- video link, or NULL when the content is in Body
    Body            NVARCHAR(MAX)  NULL,              -- article text / quiz JSON
    DurationMinutes INT            NOT NULL CONSTRAINT DF_CourseLessons_Duration DEFAULT (10)
        CONSTRAINT CK_CourseLessons_Duration CHECK (DurationMinutes > 0),
    CONSTRAINT UQ_CourseLessons_Position UNIQUE (CourseId, Position)
);
GO

-- Upgrade: AR lessons. ContentType 'AR' opens an augmented-reality scene in the
-- learner's phone browser; ARSceneKey names which scene (e.g. 'budget-jars').
-- The list of valid keys lives in tutordashboard.aspx.cs (ArScenes) and the AR plan.
IF COL_LENGTH('dbo.CourseLessons', 'ARSceneKey') IS NULL
    ALTER TABLE dbo.CourseLessons ADD ARSceneKey NVARCHAR(50) NULL;
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints
           WHERE name = 'CK_CourseLessons_ContentType' AND definition NOT LIKE '%''AR''%')
BEGIN
    ALTER TABLE dbo.CourseLessons DROP CONSTRAINT CK_CourseLessons_ContentType;
    ALTER TABLE dbo.CourseLessons ADD CONSTRAINT CK_CourseLessons_ContentType
        CHECK (ContentType IN ('Video', 'Article', 'Quiz', 'AR'));
END
GO
IF OBJECT_ID('dbo.CK_CourseLessons_ARScene', 'C') IS NULL
    ALTER TABLE dbo.CourseLessons ADD CONSTRAINT CK_CourseLessons_ARScene
        CHECK (ContentType <> 'AR' OR ARSceneKey IS NOT NULL);   -- an AR lesson must name its scene
GO
-- Upgrade: the tutor's settings for an AR scene, as JSON, e.g. budget-jars:
--   {"currency":"RM","income":3000,"cards":[{"name":"Rent","amount":900,"jar":"needs"}, ...]}
-- NULL = the scene's built-in defaults. Edited in Tutor Studio > Lessons.
IF COL_LENGTH('dbo.CourseLessons', 'ARConfig') IS NULL
    ALTER TABLE dbo.CourseLessons ADD ARConfig NVARCHAR(MAX) NULL;
GO

-- A student taking a course (admin dashboard counts these per user).
IF OBJECT_ID('dbo.Enrollments', 'U') IS NULL
CREATE TABLE dbo.Enrollments (
    UserId     INT       NOT NULL CONSTRAINT FK_Enrollments_Users   REFERENCES dbo.Users(UserId)     ON DELETE CASCADE,
    CourseId   INT       NOT NULL CONSTRAINT FK_Enrollments_Courses REFERENCES dbo.Courses(CourseId) ON DELETE CASCADE,
    EnrolledAt DATETIME2 NOT NULL CONSTRAINT DF_Enrollments_EnrolledAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Enrollments PRIMARY KEY (UserId, CourseId)
);
GO

-- Upgrade: when the learner finished every lesson.
IF COL_LENGTH('dbo.Enrollments', 'CompletedAt') IS NULL
    ALTER TABLE dbo.Enrollments ADD CompletedAt DATETIME2 NULL;
GO

-- One row per lesson a learner has finished.
IF OBJECT_ID('dbo.LessonProgress', 'U') IS NULL
CREATE TABLE dbo.LessonProgress (
    UserId      INT       NOT NULL CONSTRAINT FK_LessonProgress_Users   REFERENCES dbo.Users(UserId)           ON DELETE CASCADE,
    LessonId    INT       NOT NULL CONSTRAINT FK_LessonProgress_Lessons REFERENCES dbo.CourseLessons(LessonId) ON DELETE CASCADE,
    CompletedAt DATETIME2 NOT NULL CONSTRAINT DF_LessonProgress_CompletedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_LessonProgress PRIMARY KEY (UserId, LessonId)
);
GO

-- Every attempt a learner makes at an AR activity (assets/js/ar, saved by ArResult.ashx).
-- Finishing an attempt also marks the lesson done in LessonProgress.
IF OBJECT_ID('dbo.ARActivityResults', 'U') IS NULL
CREATE TABLE dbo.ARActivityResults (
    ResultId    INT IDENTITY(1,1) PRIMARY KEY,
    UserId      INT            NOT NULL CONSTRAINT FK_ARActivityResults_Users   REFERENCES dbo.Users(UserId)           ON DELETE CASCADE,
    LessonId    INT            NOT NULL CONSTRAINT FK_ARActivityResults_Lessons REFERENCES dbo.CourseLessons(LessonId) ON DELETE CASCADE,
    SceneKey    NVARCHAR(50)   NOT NULL,
    Mode        NVARCHAR(10)   NOT NULL CONSTRAINT CK_ARActivityResults_Mode  CHECK (Mode IN ('ar', 'card', 'camera', '3d')),   -- on a table (WebXR AR), on the printed Meowlet card (image tracking), camera (older builds), or 3D on screen
    Score       TINYINT        NULL     CONSTRAINT CK_ARActivityResults_Score CHECK (Score BETWEEN 0 AND 100), -- NULL for scenes without a score
    Summary     NVARCHAR(400)  NULL,     -- one readable line for the tutor
    ResultJson  NVARCHAR(MAX)  NULL,     -- what the learner did, scene-specific
    Seconds     INT            NULL,
    CompletedAt DATETIME2      NOT NULL CONSTRAINT DF_ARActivityResults_CompletedAt DEFAULT (SYSUTCDATETIME())
);
GO

-- Upgrade: 'camera' mode (webcam behind the 3D scene) for databases created before it existed.
IF EXISTS (SELECT 1 FROM sys.check_constraints
           WHERE name = 'CK_ARActivityResults_Mode' AND definition NOT LIKE '%camera%')
BEGIN
    ALTER TABLE dbo.ARActivityResults DROP CONSTRAINT CK_ARActivityResults_Mode;
    ALTER TABLE dbo.ARActivityResults ADD CONSTRAINT CK_ARActivityResults_Mode
        CHECK (Mode IN ('ar', 'camera', '3d'));
END
GO

-- Upgrade: 'card' mode (image tracking on the printed Meowlet card).
IF EXISTS (SELECT 1 FROM sys.check_constraints
           WHERE name = 'CK_ARActivityResults_Mode' AND definition NOT LIKE '%''card''%')
BEGIN
    ALTER TABLE dbo.ARActivityResults DROP CONSTRAINT CK_ARActivityResults_Mode;
    ALTER TABLE dbo.ARActivityResults ADD CONSTRAINT CK_ARActivityResults_Mode
        CHECK (Mode IN ('ar', 'card', 'camera', '3d'));
END
GO

-- Learner reviews of a course (admin dashboard > Reviews). One per learner per course.
IF OBJECT_ID('dbo.CourseReviews', 'U') IS NULL
CREATE TABLE dbo.CourseReviews (
    ReviewId  INT IDENTITY(1,1) PRIMARY KEY,
    UserId    INT            NOT NULL CONSTRAINT FK_CourseReviews_Users   REFERENCES dbo.Users(UserId)     ON DELETE CASCADE,
    CourseId  INT            NOT NULL CONSTRAINT FK_CourseReviews_Courses REFERENCES dbo.Courses(CourseId) ON DELETE CASCADE,
    Rating    TINYINT        NOT NULL CONSTRAINT CK_CourseReviews_Rating CHECK (Rating BETWEEN 1 AND 5),
    Comment   NVARCHAR(1000) NULL,
    IsHidden  BIT            NOT NULL CONSTRAINT DF_CourseReviews_IsHidden DEFAULT (0),   -- hidden by an admin
    CreatedAt DATETIME2      NOT NULL CONSTRAINT DF_CourseReviews_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT UQ_CourseReviews_UserCourse UNIQUE (UserId, CourseId)
);
GO

-- Upgrade: the course's tutor can answer a review publicly (tutordashboard.aspx > Reviews).
IF COL_LENGTH('dbo.CourseReviews', 'TutorReply') IS NULL
    ALTER TABLE dbo.CourseReviews ADD TutorReply NVARCHAR(1000) NULL;
GO
IF COL_LENGTH('dbo.CourseReviews', 'TutorRepliedAt') IS NULL
    ALTER TABLE dbo.CourseReviews ADD TutorRepliedAt DATETIME2 NULL;
GO

/* ===========================================================================
   3. Tutoring
   =========================================================================== */

-- Public-facing tutor details. One row per tutor (Users.Role = 'Tutor').
IF OBJECT_ID('dbo.TutorProfiles', 'U') IS NULL
CREATE TABLE dbo.TutorProfiles (
    UserId              INT            NOT NULL PRIMARY KEY
        CONSTRAINT FK_TutorProfiles_Users REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    Headline            NVARCHAR(150)  NOT NULL,      -- one line under the tutor's name
    Bio                 NVARCHAR(2000) NULL,
    MeetingLink         NVARCHAR(400)  NULL,          -- default Meet/Zoom/Teams room
    IsAcceptingStudents BIT            NOT NULL CONSTRAINT DF_TutorProfiles_Accepting DEFAULT (1),
    UpdatedAt           DATETIME2      NOT NULL CONSTRAINT DF_TutorProfiles_UpdatedAt DEFAULT (SYSUTCDATETIME())
);
GO

-- Every certificate a tutor submits, and what an admin decided.
-- Users.IsVerified / CertificatePath stay the quick "current state" the app reads.
IF OBJECT_ID('dbo.TutorVerifications', 'U') IS NULL
CREATE TABLE dbo.TutorVerifications (
    VerificationId   INT IDENTITY(1,1) PRIMARY KEY,
    TutorId          INT            NOT NULL CONSTRAINT FK_TutorVerifications_Tutor    REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    CertificatePath  NVARCHAR(400)  NOT NULL,
    Institution      NVARCHAR(200)  NULL,
    Status           NVARCHAR(20)   NOT NULL CONSTRAINT DF_TutorVerifications_Status DEFAULT ('Pending')
        CONSTRAINT CK_TutorVerifications_Status CHECK (Status IN ('Pending', 'Approved', 'Rejected')),
    SubmittedAt      DATETIME2      NOT NULL CONSTRAINT DF_TutorVerifications_SubmittedAt DEFAULT (SYSUTCDATETIME()),
    ReviewedByUserId INT            NULL     CONSTRAINT FK_TutorVerifications_Reviewer REFERENCES dbo.Users(UserId),
    ReviewedAt       DATETIME2      NULL,
    ReviewNote       NVARCHAR(500)  NULL,
    CONSTRAINT CK_TutorVerifications_Reviewed CHECK (
        (Status = 'Pending'  AND ReviewedAt IS NULL) OR
        (Status <> 'Pending' AND ReviewedAt IS NOT NULL))
);
GO

-- Weekly recurring slots a tutor can teach in. DayOfWeek: 1 = Monday ... 7 = Sunday.
-- Times are Malaysia local time (UTC+8).
IF OBJECT_ID('dbo.TutorAvailability', 'U') IS NULL
CREATE TABLE dbo.TutorAvailability (
    AvailabilityId INT IDENTITY(1,1) PRIMARY KEY,
    TutorId        INT     NOT NULL CONSTRAINT FK_TutorAvailability_Tutor REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    DayOfWeek      TINYINT NOT NULL CONSTRAINT CK_TutorAvailability_Day CHECK (DayOfWeek BETWEEN 1 AND 7),
    StartTime      TIME(0) NOT NULL,
    EndTime        TIME(0) NOT NULL,
    CONSTRAINT CK_TutorAvailability_Range CHECK (EndTime > StartTime),
    CONSTRAINT UQ_TutorAvailability_Slot UNIQUE (TutorId, DayOfWeek, StartTime)
);
GO

-- A 1-on-1 booking between a student and a tutor.
-- Lifecycle: Requested -> Confirmed -> Completed
--            Requested -> Declined   (tutor says no)
--            Requested/Confirmed -> Cancelled (either side)
-- StartsAt is stored in UTC like every other timestamp.
IF OBJECT_ID('dbo.TutoringSessions', 'U') IS NULL
CREATE TABLE dbo.TutoringSessions (
    SessionId         INT IDENTITY(1,1) PRIMARY KEY,
    TutorId           INT            NOT NULL CONSTRAINT FK_TutoringSessions_Tutor   REFERENCES dbo.Users(UserId),
    StudentId         INT            NOT NULL CONSTRAINT FK_TutoringSessions_Student REFERENCES dbo.Users(UserId),
    TagId             INT            NULL     CONSTRAINT FK_TutoringSessions_Tag     REFERENCES dbo.Tags(TagId),
    StartsAt          DATETIME2      NOT NULL,
    DurationMinutes   INT            NOT NULL CONSTRAINT DF_TutoringSessions_Duration DEFAULT (60)
        CONSTRAINT CK_TutoringSessions_Duration CHECK (DurationMinutes BETWEEN 15 AND 240),
    Status            NVARCHAR(20)   NOT NULL CONSTRAINT DF_TutoringSessions_Status DEFAULT ('Requested')
        CONSTRAINT CK_TutoringSessions_Status CHECK (Status IN ('Requested', 'Confirmed', 'Completed', 'Cancelled', 'Declined')),
    StudentNote       NVARCHAR(1000) NULL,            -- what the student wants help with
    TutorNote         NVARCHAR(1000) NULL,            -- tutor's summary / homework after the session
    MeetingLink       NVARCHAR(400)  NULL,            -- overrides TutorProfiles.MeetingLink
    CancelledByUserId INT            NULL     CONSTRAINT FK_TutoringSessions_CancelledBy REFERENCES dbo.Users(UserId),
    CreatedAt         DATETIME2      NOT NULL CONSTRAINT DF_TutoringSessions_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt         DATETIME2      NOT NULL CONSTRAINT DF_TutoringSessions_UpdatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT CK_TutoringSessions_People CHECK (TutorId <> StudentId)
);
GO

-- The student's rating of a session. At most one per session.
IF OBJECT_ID('dbo.SessionReviews', 'U') IS NULL
CREATE TABLE dbo.SessionReviews (
    SessionId INT            NOT NULL PRIMARY KEY
        CONSTRAINT FK_SessionReviews_Sessions REFERENCES dbo.TutoringSessions(SessionId) ON DELETE CASCADE,
    Rating    TINYINT        NOT NULL CONSTRAINT CK_SessionReviews_Rating CHECK (Rating BETWEEN 1 AND 5),
    Comment   NVARCHAR(1000) NULL,
    IsHidden  BIT            NOT NULL CONSTRAINT DF_SessionReviews_IsHidden DEFAULT (0),
    CreatedAt DATETIME2      NOT NULL CONSTRAINT DF_SessionReviews_CreatedAt DEFAULT (SYSUTCDATETIME())
);
GO

-- Upgrade: the tutor can answer a session review (tutordashboard.aspx > Reviews).
IF COL_LENGTH('dbo.SessionReviews', 'TutorReply') IS NULL
    ALTER TABLE dbo.SessionReviews ADD TutorReply NVARCHAR(1000) NULL;
GO
IF COL_LENGTH('dbo.SessionReviews', 'TutorRepliedAt') IS NULL
    ALTER TABLE dbo.SessionReviews ADD TutorRepliedAt DATETIME2 NULL;
GO

-- Direct messages between a student and a tutor, optionally about one session.
IF OBJECT_ID('dbo.Messages', 'U') IS NULL
CREATE TABLE dbo.Messages (
    MessageId   INT IDENTITY(1,1) PRIMARY KEY,
    SenderId    INT            NOT NULL CONSTRAINT FK_Messages_Sender    REFERENCES dbo.Users(UserId),
    RecipientId INT            NOT NULL CONSTRAINT FK_Messages_Recipient REFERENCES dbo.Users(UserId),
    SessionId   INT            NULL     CONSTRAINT FK_Messages_Session   REFERENCES dbo.TutoringSessions(SessionId) ON DELETE SET NULL,
    Body        NVARCHAR(2000) NOT NULL,
    SentAt      DATETIME2      NOT NULL CONSTRAINT DF_Messages_SentAt DEFAULT (SYSUTCDATETIME()),
    ReadAt      DATETIME2      NULL,
    CONSTRAINT CK_Messages_People CHECK (SenderId <> RecipientId)
);
GO

/* ===========================================================================
   4. Indexes (foreign keys and the lookups the pages run most)
   =========================================================================== */

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Users_Role')
    CREATE INDEX IX_Users_Role ON dbo.Users (Role, IsActive, IsVerified);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Enrollments_CourseId')
    CREATE INDEX IX_Enrollments_CourseId ON dbo.Enrollments (CourseId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_LessonProgress_LessonId')
    CREATE INDEX IX_LessonProgress_LessonId ON dbo.LessonProgress (LessonId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ARActivityResults_Lesson')
    CREATE INDEX IX_ARActivityResults_Lesson ON dbo.ARActivityResults (LessonId, UserId, CompletedAt);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CourseReviews_CourseId')
    CREATE INDEX IX_CourseReviews_CourseId ON dbo.CourseReviews (CourseId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TutorVerifications_Tutor')
    CREATE INDEX IX_TutorVerifications_Tutor ON dbo.TutorVerifications (TutorId, SubmittedAt);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TutoringSessions_Tutor')
    CREATE INDEX IX_TutoringSessions_Tutor ON dbo.TutoringSessions (TutorId, StartsAt);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TutoringSessions_Student')
    CREATE INDEX IX_TutoringSessions_Student ON dbo.TutoringSessions (StudentId, StartsAt);
-- A tutor cannot hold two live bookings that start at the same moment.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_TutoringSessions_TutorSlot')
    CREATE UNIQUE INDEX UX_TutoringSessions_TutorSlot ON dbo.TutoringSessions (TutorId, StartsAt)
        WHERE Status IN ('Requested', 'Confirmed', 'Completed');
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Messages_Recipient')
    CREATE INDEX IX_Messages_Recipient ON dbo.Messages (RecipientId, ReadAt, SentAt);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Messages_Sender')
    CREATE INDEX IX_Messages_Sender ON dbo.Messages (SenderId, SentAt);
GO

/* ===========================================================================
   5. Views and procedures
   =========================================================================== */

-- Active, verified tutors with subjects and rating. Use for "Find a tutor".
CREATE OR ALTER VIEW dbo.vw_TutorDirectory AS
SELECT u.UserId,
       u.FullName,
       u.Email,
       u.Institution,
       p.Headline,
       p.Bio,
       ISNULL(p.IsAcceptingStudents, 0) AS IsAcceptingStudents,
       (SELECT STRING_AGG(t.DisplayLabel, N', ') WITHIN GROUP (ORDER BY t.DisplayLabel)
        FROM dbo.TutorSubjects ts JOIN dbo.Tags t ON t.TagId = ts.TagId
        WHERE ts.UserId = u.UserId) AS Subjects,
       r.AvgRating,
       ISNULL(r.ReviewCount, 0) AS ReviewCount,
       (SELECT COUNT(*) FROM dbo.TutoringSessions s
        WHERE s.TutorId = u.UserId AND s.Status = 'Completed') AS CompletedSessions
FROM dbo.Users u
LEFT JOIN dbo.TutorProfiles p ON p.UserId = u.UserId
OUTER APPLY (
    SELECT CAST(AVG(CAST(sr.Rating AS DECIMAL(4,2))) AS DECIMAL(3,2)) AS AvgRating,
           COUNT(*) AS ReviewCount
    FROM dbo.SessionReviews sr
    JOIN dbo.TutoringSessions s ON s.SessionId = sr.SessionId
    WHERE s.TutorId = u.UserId AND sr.IsHidden = 0
) r
WHERE u.Role = 'Tutor' AND u.IsActive = 1 AND u.IsVerified = 1;
GO

-- One row per course with real lesson count, learners, completions and rating.
CREATE OR ALTER VIEW dbo.vw_CourseStats AS
SELECT c.CourseId,
       c.CourseCode,
       c.Title,
       c.Category,
       c.Level,
       c.IsPublished,
       c.TutorId,
       tutor.FullName AS TutorName,
       c.Lessons AS PlannedLessons,
       (SELECT COUNT(*) FROM dbo.CourseLessons l WHERE l.CourseId = c.CourseId) AS LessonCount,
       (SELECT COUNT(*) FROM dbo.Enrollments e WHERE e.CourseId = c.CourseId) AS LearnerCount,
       (SELECT COUNT(*) FROM dbo.Enrollments e WHERE e.CourseId = c.CourseId AND e.CompletedAt IS NOT NULL) AS CompletedCount,
       (SELECT CAST(AVG(CAST(r.Rating AS DECIMAL(4,2))) AS DECIMAL(3,2))
        FROM dbo.CourseReviews r WHERE r.CourseId = c.CourseId AND r.IsHidden = 0) AS AvgRating,
       (SELECT COUNT(*) FROM dbo.CourseReviews r WHERE r.CourseId = c.CourseId AND r.IsHidden = 0) AS ReviewCount
FROM dbo.Courses c
LEFT JOIN dbo.Users tutor ON tutor.UserId = c.TutorId;
GO

-- Permanently delete a user. Most child rows cascade; this clears the
-- references that can't (sessions, messages, reviewer/canceller links,
-- courses they lead) first. Use it instead of a bare DELETE FROM Users.
CREATE OR ALTER PROCEDURE dbo.usp_DeleteUser
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;

    DELETE FROM dbo.Messages WHERE SenderId = @UserId OR RecipientId = @UserId;
    DELETE FROM dbo.TutoringSessions WHERE TutorId = @UserId OR StudentId = @UserId;   -- reviews cascade
    UPDATE dbo.TutoringSessions   SET CancelledByUserId = NULL WHERE CancelledByUserId = @UserId;
    UPDATE dbo.TutorVerifications SET ReviewedByUserId  = NULL WHERE ReviewedByUserId  = @UserId;
    UPDATE dbo.Courses            SET TutorId           = NULL WHERE TutorId           = @UserId;
    DELETE FROM dbo.Users WHERE UserId = @UserId;   -- everything else cascades

    COMMIT TRANSACTION;
END;
GO

/* ===========================================================================
   6. Reference data
   =========================================================================== */

-- Seed topic tags (matches topics on the landing page).
MERGE dbo.Tags AS t
USING (VALUES
    ('budgeting',  'Budgeting'),
    ('saving',     'Saving'),
    ('investing',  'Investing'),
    ('debt',       'Debt Management'),
    ('taxes',      'Taxes'),
    ('insurance',  'Insurance'),
    ('retirement', 'Retirement Planning')
) AS s (TagName, DisplayLabel)
ON t.TagName = s.TagName
WHEN NOT MATCHED THEN
    INSERT (TagName, DisplayLabel) VALUES (s.TagName, s.DisplayLabel);
GO
