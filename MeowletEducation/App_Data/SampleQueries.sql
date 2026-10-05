-- Meowlet Education: reference queries against the sample data.
-- Open in Visual Studio (SQL Server Object Explorer > (localdb)\MSSQLLocalDB >
-- MeowletEducation > New Query), select one block and press Ctrl+Shift+E.
-- In app code, swap the hard-coded values for @parameters.

USE MeowletEducation;
GO

SET QUOTED_IDENTIFIER ON;   -- needed for FOR XML below; sqlcmd defaults it off
GO

/* ===========================================================================
   Accounts
   =========================================================================== */

-- Sign in (what Signin.aspx does). Password: Meowlet123!
SELECT UserId, FullName, Role, IsActive, HasOnboarded, IsVerified, DeleteRequestedAt
FROM dbo.Users
WHERE Email = N'aisha.rahman@student.meowlet.test'
  AND PasswordHash = LOWER(CONVERT(CHAR(64), HASHBYTES('SHA2_256', CAST('Meowlet123!' AS VARCHAR(100))), 2));

-- Everyone, newest first, with how many courses they are in.
SELECT u.UserId, u.FullName, u.Email, u.Role, u.IsActive, u.CreatedAt,
       (SELECT COUNT(*) FROM dbo.Enrollments e WHERE e.UserId = u.UserId) AS EnrolledCount
FROM dbo.Users u
ORDER BY u.CreatedAt DESC;

-- A user's onboarding answers and interests (Profile.aspx).
SELECT QuestionKey, AnswerValue
FROM dbo.OnboardingAnswers
WHERE UserId = (SELECT UserId FROM dbo.Users WHERE Email = N'jason.ong@student.meowlet.test');

SELECT t.TagName, t.DisplayLabel
FROM dbo.UserInterests ui
JOIN dbo.Tags t ON t.TagId = ui.TagId
WHERE ui.UserId = (SELECT UserId FROM dbo.Users WHERE Email = N'jason.ong@student.meowlet.test');

-- Accounts waiting to be deleted.
SELECT UserId, FullName, Email, DeleteRequestedAt
FROM dbo.Users
WHERE DeleteRequestedAt IS NOT NULL;


/* ===========================================================================
   Tutors (starting point for the tutor feature)
   =========================================================================== */

-- Tutor directory: active, verified tutors with their subjects in one column.
SELECT u.UserId, u.FullName, u.Institution,
       STUFF((SELECT N', ' + t.DisplayLabel
              FROM dbo.TutorSubjects ts
              JOIN dbo.Tags t ON t.TagId = ts.TagId
              WHERE ts.UserId = u.UserId
              ORDER BY t.DisplayLabel
              FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, N'') AS Subjects
FROM dbo.Users u
WHERE u.Role = 'Tutor' AND u.IsActive = 1 AND u.IsVerified = 1
ORDER BY u.FullName;

-- Tutors who teach one subject (e.g. a "Find a tutor: Investing" filter).
SELECT u.UserId, u.FullName, u.Institution
FROM dbo.Users u
JOIN dbo.TutorSubjects ts ON ts.UserId = u.UserId
JOIN dbo.Tags t           ON t.TagId = ts.TagId
WHERE u.Role = 'Tutor' AND u.IsActive = 1 AND u.IsVerified = 1
  AND t.TagName = 'investing'
ORDER BY u.FullName;

-- One tutor's profile: details plus onboarding answers as columns.
SELECT u.UserId, u.FullName, u.Email, u.Institution, u.IsVerified, u.CertificatePath,
       MAX(CASE WHEN a.QuestionKey = 'years_experience' THEN a.AnswerValue END) AS YearsExperience,
       MAX(CASE WHEN a.QuestionKey = 'teaching_format'  THEN a.AnswerValue END) AS TeachingFormat,
       MAX(CASE WHEN a.QuestionKey = 'student_capacity' THEN a.AnswerValue END) AS StudentCapacity,
       MAX(CASE WHEN a.QuestionKey = 'student_level'    THEN a.AnswerValue END) AS StudentLevel
FROM dbo.Users u
LEFT JOIN dbo.OnboardingAnswers a ON a.UserId = u.UserId
WHERE u.Email = N'daniel.tan@tutor.meowlet.test'
GROUP BY u.UserId, u.FullName, u.Email, u.Institution, u.IsVerified, u.CertificatePath;

-- Match tutors to a student: verified tutors ranked by shared topics.
SELECT tutor.UserId, tutor.FullName, COUNT(*) AS SharedTopics,
       STRING_AGG(t.DisplayLabel, N', ') AS Topics   -- needs SQL Server 2017+ (LocalDB 2019+ is fine)
FROM dbo.UserInterests ui
JOIN dbo.TutorSubjects ts ON ts.TagId = ui.TagId
JOIN dbo.Users tutor      ON tutor.UserId = ts.UserId
JOIN dbo.Tags t           ON t.TagId = ui.TagId
WHERE ui.UserId = (SELECT UserId FROM dbo.Users WHERE Email = N'hafiz.z@student.meowlet.test')
  AND tutor.Role = 'Tutor' AND tutor.IsActive = 1 AND tutor.IsVerified = 1
GROUP BY tutor.UserId, tutor.FullName
ORDER BY SharedTopics DESC, tutor.FullName;

-- Students who want 1-on-1 help, with the tutors who could take them.
SELECT s.FullName AS Student, tutor.FullName AS Tutor, t.DisplayLabel AS Topic
FROM dbo.Users s
JOIN dbo.OnboardingAnswers a ON a.UserId = s.UserId
                            AND a.QuestionKey = 'learning_style' AND a.AnswerValue = 'one_on_one'
JOIN dbo.UserInterests ui    ON ui.UserId = s.UserId
JOIN dbo.TutorSubjects ts    ON ts.TagId = ui.TagId
JOIN dbo.Users tutor         ON tutor.UserId = ts.UserId
                            AND tutor.Role = 'Tutor' AND tutor.IsActive = 1 AND tutor.IsVerified = 1
JOIN dbo.Tags t              ON t.TagId = ui.TagId
WHERE s.Role = 'Student' AND s.IsActive = 1
ORDER BY s.FullName, tutor.FullName;

-- Verification queue: tutors waiting for an admin, oldest first.
SELECT UserId, FullName, Email, Institution, CertificatePath, CreatedAt
FROM dbo.Users
WHERE Role = 'Tutor' AND IsVerified = 0 AND IsActive = 1
ORDER BY CreatedAt;

-- Approve a tutor (run inside a transaction while testing, then ROLLBACK).
BEGIN TRANSACTION;
UPDATE dbo.Users SET IsVerified = 1
WHERE Email = N'kevin.lau@tutor.meowlet.test' AND Role = 'Tutor';
SELECT FullName, IsVerified FROM dbo.Users WHERE Email = N'kevin.lau@tutor.meowlet.test';
ROLLBACK TRANSACTION;

-- How many tutors cover each subject, so you can spot gaps.
SELECT t.DisplayLabel,
       COUNT(u.UserId) AS VerifiedTutors
FROM dbo.Tags t
LEFT JOIN dbo.TutorSubjects ts ON ts.TagId = t.TagId
LEFT JOIN dbo.Users u          ON u.UserId = ts.UserId
                              AND u.Role = 'Tutor' AND u.IsActive = 1 AND u.IsVerified = 1
GROUP BY t.DisplayLabel
ORDER BY VerifiedTutors, t.DisplayLabel;


/* ===========================================================================
   Courses and enrollments
   =========================================================================== */

-- Course catalogue with learner counts (admin dashboard).
SELECT c.CourseCode, c.Title, c.Category, c.Level, c.Lessons, c.IsPublished,
       (SELECT COUNT(*) FROM dbo.Enrollments e WHERE e.CourseId = c.CourseId) AS LearnerCount
FROM dbo.Courses c
ORDER BY c.CreatedAt DESC;

-- One student's courses.
SELECT c.CourseCode, c.Title, e.EnrolledAt
FROM dbo.Enrollments e
JOIN dbo.Courses c ON c.CourseId = e.CourseId
WHERE e.UserId = (SELECT UserId FROM dbo.Users WHERE Email = N'aisha.rahman@student.meowlet.test')
ORDER BY e.EnrolledAt;

-- Enrollments per month (the dashboard chart).
SELECT YEAR(EnrolledAt) AS Y, MONTH(EnrolledAt) AS M, COUNT(*) AS N
FROM dbo.Enrollments
GROUP BY YEAR(EnrolledAt), MONTH(EnrolledAt)
ORDER BY Y, M;

-- Course stats in one go (lessons, learners, completions, rating).
SELECT * FROM dbo.vw_CourseStats ORDER BY LearnerCount DESC;

-- A course's lesson list, with a tick for one learner.
SELECT l.Position, l.Title, l.ContentType, l.DurationMinutes,
       CASE WHEN lp.UserId IS NULL THEN 0 ELSE 1 END AS IsDone, lp.CompletedAt
FROM dbo.CourseLessons l
JOIN dbo.Courses c ON c.CourseId = l.CourseId
LEFT JOIN dbo.LessonProgress lp
       ON lp.LessonId = l.LessonId
      AND lp.UserId = (SELECT UserId FROM dbo.Users WHERE Email = N'jason.ong@student.meowlet.test')
WHERE c.CourseCode = N'INV301'
ORDER BY l.Position;

-- "Continue learning": each of a learner's courses with % done and the next lesson.
SELECT c.CourseCode, c.Title,
       CAST(100.0 * COUNT(lp.LessonId) / NULLIF(COUNT(l.LessonId), 0) AS INT) AS PercentDone,
       (SELECT TOP 1 n.Title FROM dbo.CourseLessons n
        WHERE n.CourseId = c.CourseId
          AND NOT EXISTS (SELECT 1 FROM dbo.LessonProgress p WHERE p.LessonId = n.LessonId AND p.UserId = e.UserId)
        ORDER BY n.Position) AS NextLesson
FROM dbo.Enrollments e
JOIN dbo.Courses c            ON c.CourseId = e.CourseId
LEFT JOIN dbo.CourseLessons l ON l.CourseId = c.CourseId
LEFT JOIN dbo.LessonProgress lp ON lp.LessonId = l.LessonId AND lp.UserId = e.UserId
WHERE e.UserId = (SELECT UserId FROM dbo.Users WHERE Email = N'ryan.goh@student.meowlet.test')
GROUP BY c.CourseId, c.CourseCode, c.Title, e.UserId;

-- Mark a lesson done (app: INSERT only if not already there).
BEGIN TRANSACTION;
INSERT INTO dbo.LessonProgress (UserId, LessonId)
SELECT u.UserId, l.LessonId
FROM dbo.Users u
JOIN dbo.CourseLessons l ON l.CourseId = (SELECT CourseId FROM dbo.Courses WHERE CourseCode = N'INV301') AND l.Position = 5
WHERE u.Email = N'jason.ong@student.meowlet.test'
  AND NOT EXISTS (SELECT 1 FROM dbo.LessonProgress x WHERE x.UserId = u.UserId AND x.LessonId = l.LessonId);
ROLLBACK TRANSACTION;

-- Reviews screen on the admin dashboard (newest first, hidden ones flagged).
SELECT u.FullName AS Learner, c.Title AS Course, r.Rating, r.Comment, r.IsHidden, r.CreatedAt
FROM dbo.CourseReviews r
JOIN dbo.Users u   ON u.UserId = r.UserId
JOIN dbo.Courses c ON c.CourseId = r.CourseId
ORDER BY r.CreatedAt DESC;


/* ===========================================================================
   Tutoring: profiles, verification, availability, sessions, messages
   =========================================================================== */

-- "Find a tutor" page, ready to bind: subjects, rating, sessions taught.
SELECT * FROM dbo.vw_TutorDirectory
WHERE IsAcceptingStudents = 1
ORDER BY AvgRating DESC, CompletedSessions DESC;

-- A tutor's weekly timetable.
SELECT CHOOSE(a.DayOfWeek, 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun') AS Day,
       a.StartTime, a.EndTime
FROM dbo.TutorAvailability a
WHERE a.TutorId = (SELECT UserId FROM dbo.Users WHERE Email = N'nurul.aina@tutor.meowlet.test')
ORDER BY a.DayOfWeek, a.StartTime;

-- Verification history for one tutor (rejection then approval).
SELECT v.Status, v.SubmittedAt, v.ReviewedAt, adm.FullName AS ReviewedBy, v.ReviewNote
FROM dbo.TutorVerifications v
LEFT JOIN dbo.Users adm ON adm.UserId = v.ReviewedByUserId
WHERE v.TutorId = (SELECT UserId FROM dbo.Users WHERE Email = N'priya.r@tutor.meowlet.test')
ORDER BY v.SubmittedAt;

-- Approve a pending verification: update both the history row and the user.
BEGIN TRANSACTION;
DECLARE @Admin INT = (SELECT UserId FROM dbo.Users WHERE Email = N'meowlet@meowletedu.com');
DECLARE @Tutor INT = (SELECT UserId FROM dbo.Users WHERE Email = N'kevin.lau@tutor.meowlet.test');
UPDATE dbo.TutorVerifications
SET Status = 'Approved', ReviewedByUserId = @Admin, ReviewedAt = SYSUTCDATETIME()
WHERE TutorId = @Tutor AND Status = 'Pending';
UPDATE dbo.Users SET IsVerified = 1 WHERE UserId = @Tutor;
SELECT FullName, IsVerified FROM dbo.Users WHERE UserId = @Tutor;
ROLLBACK TRANSACTION;

-- Tutor dashboard: upcoming bookings (times shown in Malaysia time).
SELECT s.SessionId, st.FullName AS Student, t.DisplayLabel AS Topic,
       DATEADD(HOUR, 8, s.StartsAt) AS StartsAtMYT, s.DurationMinutes, s.Status, s.StudentNote,
       COALESCE(s.MeetingLink, p.MeetingLink) AS MeetingLink
FROM dbo.TutoringSessions s
JOIN dbo.Users st             ON st.UserId = s.StudentId
LEFT JOIN dbo.Tags t          ON t.TagId = s.TagId
LEFT JOIN dbo.TutorProfiles p ON p.UserId = s.TutorId
WHERE s.TutorId = (SELECT UserId FROM dbo.Users WHERE Email = N'daniel.tan@tutor.meowlet.test')
  AND s.Status IN ('Requested', 'Confirmed')
  AND s.StartsAt >= SYSUTCDATETIME()
ORDER BY s.StartsAt;

-- Student view: all my sessions, with the review I left.
SELECT tu.FullName AS Tutor, DATEADD(HOUR, 8, s.StartsAt) AS StartsAtMYT, s.Status,
       s.TutorNote, r.Rating, r.Comment
FROM dbo.TutoringSessions s
JOIN dbo.Users tu              ON tu.UserId = s.TutorId
LEFT JOIN dbo.SessionReviews r ON r.SessionId = s.SessionId
WHERE s.StudentId = (SELECT UserId FROM dbo.Users WHERE Email = N'aisha.rahman@student.meowlet.test')
ORDER BY s.StartsAt DESC;

-- Book a session. The filtered unique index stops a double booking of the
-- same tutor at the same start time; also check the slot fits availability.
BEGIN TRANSACTION;
DECLARE @T INT = (SELECT UserId FROM dbo.Users WHERE Email = N'nurul.aina@tutor.meowlet.test');
DECLARE @S INT = (SELECT UserId FROM dbo.Users WHERE Email = N'chloe.teo@student.meowlet.test');
DECLARE @StartMYT DATETIME2 = '2026-10-13T20:00:00';   -- Tuesday 8 pm Malaysia time
DECLARE @Minutes INT = 60;
IF EXISTS (SELECT 1 FROM dbo.TutorAvailability a
           WHERE a.TutorId = @T
             AND a.DayOfWeek = (DATEPART(WEEKDAY, @StartMYT) + @@DATEFIRST - 2) % 7 + 1   -- Monday = 1
             AND CAST(@StartMYT AS TIME(0)) >= a.StartTime
             AND CAST(DATEADD(MINUTE, @Minutes, @StartMYT) AS TIME(0)) <= a.EndTime)
    INSERT INTO dbo.TutoringSessions (TutorId, StudentId, TagId, StartsAt, DurationMinutes, StudentNote)
    VALUES (@T, @S, (SELECT TagId FROM dbo.Tags WHERE TagName = 'saving'),
            DATEADD(HOUR, -8, @StartMYT), @Minutes, N'Saving for a laptop');
SELECT TOP 1 SessionId, Status, StartsAt FROM dbo.TutoringSessions WHERE StudentId = @S ORDER BY SessionId DESC;
ROLLBACK TRANSACTION;

-- Tutor accepts / declines / completes; either side cancels.
--   UPDATE dbo.TutoringSessions SET Status = 'Confirmed', UpdatedAt = SYSUTCDATETIME() WHERE SessionId = @Id AND Status = 'Requested';
--   UPDATE dbo.TutoringSessions SET Status = 'Declined',  UpdatedAt = SYSUTCDATETIME() WHERE SessionId = @Id AND Status = 'Requested';
--   UPDATE dbo.TutoringSessions SET Status = 'Completed', TutorNote = @Note, UpdatedAt = SYSUTCDATETIME() WHERE SessionId = @Id AND Status = 'Confirmed';
--   UPDATE dbo.TutoringSessions SET Status = 'Cancelled', CancelledByUserId = @Me, UpdatedAt = SYSUTCDATETIME()
--       WHERE SessionId = @Id AND Status IN ('Requested', 'Confirmed') AND @Me IN (TutorId, StudentId);

-- Inbox: one row per conversation partner, latest message and unread count.
DECLARE @Me INT = (SELECT UserId FROM dbo.Users WHERE Email = N'priya.r@tutor.meowlet.test');
WITH Conv AS (
    SELECT CASE WHEN m.SenderId = @Me THEN m.RecipientId ELSE m.SenderId END AS OtherId, m.*
    FROM dbo.Messages m
    WHERE @Me IN (m.SenderId, m.RecipientId)
)
SELECT o.FullName,
       (SELECT TOP 1 c2.Body FROM Conv c2 WHERE c2.OtherId = c.OtherId ORDER BY c2.SentAt DESC) AS LastMessage,
       MAX(c.SentAt) AS LastAt,
       SUM(CASE WHEN c.RecipientId = @Me AND c.ReadAt IS NULL THEN 1 ELSE 0 END) AS Unread
FROM Conv c
JOIN dbo.Users o ON o.UserId = c.OtherId
GROUP BY c.OtherId, o.FullName
ORDER BY LastAt DESC;

-- Admin: tutors with poor ratings (2 or below) to follow up on.
SELECT tu.FullName AS Tutor, st.FullName AS Student, r.Rating, r.Comment, s.StartsAt
FROM dbo.SessionReviews r
JOIN dbo.TutoringSessions s ON s.SessionId = r.SessionId
JOIN dbo.Users tu ON tu.UserId = s.TutorId
JOIN dbo.Users st ON st.UserId = s.StudentId
WHERE r.Rating <= 2
ORDER BY s.StartsAt DESC;

-- Delete a user safely (handles sessions, messages and links). Rolled back here.
BEGIN TRANSACTION;
DECLARE @DeleteId INT = (SELECT UserId FROM dbo.Users WHERE Email = N'lucas.yap@student.meowlet.test');
EXEC dbo.usp_DeleteUser @UserId = @DeleteId;
SELECT COUNT(*) AS StillThere FROM dbo.Users WHERE UserId = @DeleteId;   -- 0
ROLLBACK TRANSACTION;
