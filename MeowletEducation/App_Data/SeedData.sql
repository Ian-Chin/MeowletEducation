-- Meowlet Education sample data for local development.
-- Run after CreateDatabase.sql (setup-db.cmd does both).
-- Safe to re-run: rows are matched on Email / CourseCode / keys and only
-- inserted when missing, so your own test edits are left alone.
--
-- Sign-in for every sample account (except the admin): Meowlet123!
-- Admin: meowlet@meowletedu.com / Meowmeowmeow
-- Passwords are stored the same way the app does it: SHA-256, lowercase hex.

USE MeowletEducation;
GO

SET QUOTED_IDENTIFIER ON;   -- required to write to tables with filtered indexes
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

------------------------------------------------------------------------------
-- 1. Users
------------------------------------------------------------------------------
MERGE dbo.Users AS t
USING (VALUES
--   FullName                  Email                                 Password        Role       Active Onb Ver  Institution                         CertificatePath                                   CreatedAt              DeleteRequestedAt
    (N'Meowlet Admin',         N'meowlet@meowletedu.com',            'Meowmeowmeow', N'Admin',   1, 1, 1, NULL,                                 NULL,                                             '2026-03-01T09:00:00', NULL),

    -- Tutors: verified
    (N'Nurul Aina Hassan',     N'nurul.aina@tutor.meowlet.test',     'Meowlet123!',  N'Tutor',   1, 1, 1, N'Universiti Malaya',                 N'App_Data/Certificates/4_20260918071738.jpg',    '2026-03-04T10:15:00', NULL),
    (N'Daniel Tan Wei Ming',   N'daniel.tan@tutor.meowlet.test',     'Meowlet123!',  N'Tutor',   1, 1, 1, N'Sunway University',                 N'App_Data/Certificates/4_20261001132732.pdf',    '2026-03-11T14:30:00', NULL),
    (N'Priya Ramasamy',        N'priya.r@tutor.meowlet.test',        'Meowlet123!',  N'Tutor',   1, 1, 1, N'Taylor''s University',              N'App_Data/Certificates/4_20260918071738.jpg',    '2026-04-02T08:45:00', NULL),
    (N'Ahmad Faiz Ismail',     N'ahmad.faiz@tutor.meowlet.test',     'Meowlet123!',  N'Tutor',   1, 1, 1, N'Securities Commission Malaysia',    N'App_Data/Certificates/4_20261001132732.pdf',    '2026-04-20T11:00:00', NULL),
    (N'Grace Lim Hui Shan',    N'grace.lim@tutor.meowlet.test',      'Meowlet123!',  N'Tutor',   1, 1, 1, N'Chartered Tax Institute of Malaysia', N'App_Data/Certificates/4_20260918071738.jpg',  '2026-05-09T16:20:00', NULL),
    -- Tutors: waiting for verification
    (N'Kevin Lau Chee Keong',  N'kevin.lau@tutor.meowlet.test',      'Meowlet123!',  N'Tutor',   1, 1, 0, N'Monash University Malaysia',        N'App_Data/Certificates/4_20261001132732.pdf',    '2026-09-22T09:10:00', NULL),
    (N'Siti Mariam Yusof',     N'siti.mariam@tutor.meowlet.test',    'Meowlet123!',  N'Tutor',   1, 1, 0, N'UiTM Shah Alam',                    NULL,                                             '2026-10-01T13:05:00', NULL),
    -- Tutor: deactivated by an admin
    (N'Marcus Wong',           N'marcus.wong@tutor.meowlet.test',    'Meowlet123!',  N'Tutor',   0, 1, 1, N'HELP University',                   N'App_Data/Certificates/4_20260918071738.jpg',    '2026-03-18T15:40:00', NULL),

    -- Students
    (N'Aisha Rahman',          N'aisha.rahman@student.meowlet.test', 'Meowlet123!',  N'Student', 1, 1, 0, NULL, NULL, '2026-03-06T19:00:00', NULL),
    (N'Jason Ong',             N'jason.ong@student.meowlet.test',    'Meowlet123!',  N'Student', 1, 1, 0, NULL, NULL, '2026-03-21T20:30:00', NULL),
    (N'Mei Ling Chua',         N'meiling.chua@student.meowlet.test', 'Meowlet123!',  N'Student', 1, 1, 0, NULL, NULL, '2026-04-08T12:10:00', NULL),
    (N'Arjun Nair',            N'arjun.nair@student.meowlet.test',   'Meowlet123!',  N'Student', 1, 1, 0, NULL, NULL, '2026-04-27T21:45:00', NULL),
    (N'Hafiz Zulkifli',        N'hafiz.z@student.meowlet.test',      'Meowlet123!',  N'Student', 1, 1, 0, NULL, NULL, '2026-05-14T18:25:00', NULL),
    (N'Chloe Teo',             N'chloe.teo@student.meowlet.test',    'Meowlet123!',  N'Student', 1, 1, 0, NULL, NULL, '2026-06-03T10:00:00', NULL),
    (N'Farah Nabilah',         N'farah.n@student.meowlet.test',      'Meowlet123!',  N'Student', 1, 1, 0, NULL, NULL, '2026-06-29T22:15:00', NULL),
    (N'Ryan Goh',              N'ryan.goh@student.meowlet.test',     'Meowlet123!',  N'Student', 1, 1, 0, NULL, NULL, '2026-07-16T17:35:00', NULL),
    (N'Kavitha Subramaniam',   N'kavitha.s@student.meowlet.test',    'Meowlet123!',  N'Student', 1, 1, 0, NULL, NULL, '2026-08-05T09:50:00', NULL),
    (N'Lucas Yap',             N'lucas.yap@student.meowlet.test',    'Meowlet123!',  N'Student', 1, 1, 0, NULL, NULL, '2026-08-30T14:05:00', NULL),
    -- Student who signed up but has not finished onboarding
    (N'Zara Iskandar',         N'zara.i@student.meowlet.test',       'Meowlet123!',  N'Student', 1, 0, 0, NULL, NULL, '2026-10-03T11:30:00', NULL),
    -- Student deactivated by an admin
    (N'Brandon Lee',           N'brandon.lee@student.meowlet.test',  'Meowlet123!',  N'Student', 0, 1, 0, NULL, NULL, '2026-05-02T08:00:00', NULL),
    -- Student who asked to delete their account
    (N'Nadia Kamal',           N'nadia.kamal@student.meowlet.test',  'Meowlet123!',  N'Student', 1, 1, 0, NULL, NULL, '2026-07-07T13:20:00', '2026-10-02T10:00:00'),
    (N'sohyewen',              N'tp078275@mail.apu.edu.my',          'sohyewen',     N'Student', 1, 1, 0, NULL, NULL, '2026-10-10T09:00:00', NULL)
) AS s (FullName, Email, Pwd, Role, IsActive, HasOnboarded, IsVerified, Institution, CertificatePath, CreatedAt, DeleteRequestedAt)
ON t.Email = s.Email
WHEN NOT MATCHED THEN
    INSERT (FullName, Email, PasswordHash, Role, IsActive, HasOnboarded, IsVerified,
            Institution, CertificatePath, CreatedAt, DeleteRequestedAt)
    VALUES (s.FullName, s.Email,
            LOWER(CONVERT(CHAR(64), HASHBYTES('SHA2_256', CAST(s.Pwd AS VARCHAR(100))), 2)),
            s.Role, s.IsActive, s.HasOnboarded, s.IsVerified,
            s.Institution, s.CertificatePath, s.CreatedAt, s.DeleteRequestedAt);

------------------------------------------------------------------------------
-- 2. Tutor subjects (TutorSubjects) and student interests (UserInterests)
------------------------------------------------------------------------------
INSERT INTO dbo.TutorSubjects (UserId, TagId)
SELECT u.UserId, g.TagId
FROM (VALUES
    (N'nurul.aina@tutor.meowlet.test',  'budgeting'),
    (N'nurul.aina@tutor.meowlet.test',  'saving'),
    (N'daniel.tan@tutor.meowlet.test',  'investing'),
    (N'daniel.tan@tutor.meowlet.test',  'retirement'),
    (N'priya.r@tutor.meowlet.test',     'debt'),
    (N'priya.r@tutor.meowlet.test',     'budgeting'),
    (N'ahmad.faiz@tutor.meowlet.test',  'investing'),
    (N'ahmad.faiz@tutor.meowlet.test',  'insurance'),
    (N'grace.lim@tutor.meowlet.test',   'taxes'),
    (N'grace.lim@tutor.meowlet.test',   'retirement'),
    (N'kevin.lau@tutor.meowlet.test',   'investing'),
    (N'kevin.lau@tutor.meowlet.test',   'saving'),
    (N'siti.mariam@tutor.meowlet.test', 'insurance'),
    (N'siti.mariam@tutor.meowlet.test', 'taxes'),
    (N'marcus.wong@tutor.meowlet.test', 'debt')
) AS s (Email, TagName)
JOIN dbo.Users u ON u.Email = s.Email
JOIN dbo.Tags  g ON g.TagName = s.TagName
WHERE NOT EXISTS (SELECT 1 FROM dbo.TutorSubjects x WHERE x.UserId = u.UserId AND x.TagId = g.TagId);

INSERT INTO dbo.UserInterests (UserId, TagId)
SELECT u.UserId, g.TagId
FROM (VALUES
    (N'aisha.rahman@student.meowlet.test', 'budgeting'),
    (N'aisha.rahman@student.meowlet.test', 'saving'),
    (N'jason.ong@student.meowlet.test',    'investing'),
    (N'meiling.chua@student.meowlet.test', 'taxes'),
    (N'meiling.chua@student.meowlet.test', 'budgeting'),
    (N'arjun.nair@student.meowlet.test',   'debt'),
    (N'arjun.nair@student.meowlet.test',   'budgeting'),
    (N'hafiz.z@student.meowlet.test',      'investing'),
    (N'hafiz.z@student.meowlet.test',      'retirement'),
    (N'chloe.teo@student.meowlet.test',    'saving'),
    (N'farah.n@student.meowlet.test',      'insurance'),
    (N'farah.n@student.meowlet.test',      'taxes'),
    (N'ryan.goh@student.meowlet.test',     'investing'),
    (N'ryan.goh@student.meowlet.test',     'saving'),
    (N'kavitha.s@student.meowlet.test',    'retirement'),
    (N'lucas.yap@student.meowlet.test',    'debt'),
    (N'brandon.lee@student.meowlet.test',  'investing'),
    (N'nadia.kamal@student.meowlet.test',  'budgeting')
) AS s (Email, TagName)
JOIN dbo.Users u ON u.Email = s.Email
JOIN dbo.Tags  g ON g.TagName = s.TagName
WHERE NOT EXISTS (SELECT 1 FROM dbo.UserInterests x WHERE x.UserId = u.UserId AND x.TagId = g.TagId);

------------------------------------------------------------------------------
-- 3. Onboarding answers (keys/values match Signup.aspx and Onboarding.aspx.cs)
------------------------------------------------------------------------------
INSERT INTO dbo.OnboardingAnswers (UserId, QuestionKey, AnswerValue)
SELECT u.UserId, s.QuestionKey, s.AnswerValue
FROM (VALUES
    -- Tutors
    (N'nurul.aina@tutor.meowlet.test',  'years_experience', '3y_plus'),
    (N'nurul.aina@tutor.meowlet.test',  'teaching_format',  'one_on_one'),
    (N'nurul.aina@tutor.meowlet.test',  'student_capacity', '3_5'),
    (N'nurul.aina@tutor.meowlet.test',  'student_level',    'beginner'),
    (N'daniel.tan@tutor.meowlet.test',  'years_experience', '3y_plus'),
    (N'daniel.tan@tutor.meowlet.test',  'teaching_format',  'group'),
    (N'daniel.tan@tutor.meowlet.test',  'student_capacity', '5_plus'),
    (N'daniel.tan@tutor.meowlet.test',  'student_level',    'some_basics'),
    (N'priya.r@tutor.meowlet.test',     'years_experience', '1_3y'),
    (N'priya.r@tutor.meowlet.test',     'teaching_format',  'either'),
    (N'priya.r@tutor.meowlet.test',     'student_capacity', '3_5'),
    (N'priya.r@tutor.meowlet.test',     'student_level',    'no_preference'),
    (N'ahmad.faiz@tutor.meowlet.test',  'years_experience', '3y_plus'),
    (N'ahmad.faiz@tutor.meowlet.test',  'teaching_format',  'one_on_one'),
    (N'ahmad.faiz@tutor.meowlet.test',  'student_capacity', '1_2'),
    (N'ahmad.faiz@tutor.meowlet.test',  'student_level',    'some_basics'),
    (N'grace.lim@tutor.meowlet.test',   'years_experience', '1_3y'),
    (N'grace.lim@tutor.meowlet.test',   'teaching_format',  'group'),
    (N'grace.lim@tutor.meowlet.test',   'student_capacity', '5_plus'),
    (N'grace.lim@tutor.meowlet.test',   'student_level',    'beginner'),
    (N'kevin.lau@tutor.meowlet.test',   'years_experience', 'under_1y'),
    (N'kevin.lau@tutor.meowlet.test',   'teaching_format',  'one_on_one'),
    (N'kevin.lau@tutor.meowlet.test',   'student_capacity', '1_2'),
    (N'kevin.lau@tutor.meowlet.test',   'student_level',    'beginner'),
    (N'siti.mariam@tutor.meowlet.test', 'years_experience', '1_3y'),
    (N'siti.mariam@tutor.meowlet.test', 'teaching_format',  'either'),
    (N'siti.mariam@tutor.meowlet.test', 'student_capacity', '3_5'),
    (N'siti.mariam@tutor.meowlet.test', 'student_level',    'no_preference'),
    (N'marcus.wong@tutor.meowlet.test', 'years_experience', '3y_plus'),
    (N'marcus.wong@tutor.meowlet.test', 'teaching_format',  'group'),
    (N'marcus.wong@tutor.meowlet.test', 'student_capacity', '3_5'),
    (N'marcus.wong@tutor.meowlet.test', 'student_level',    'some_basics'),

    -- Students
    (N'aisha.rahman@student.meowlet.test', 'age_range',        '18_24'),
    (N'aisha.rahman@student.meowlet.test', 'experience_level', 'beginner'),
    (N'aisha.rahman@student.meowlet.test', 'learning_goal',    'save_money'),
    (N'aisha.rahman@student.meowlet.test', 'time_commitment',  '1_3h'),
    (N'aisha.rahman@student.meowlet.test', 'learning_style',   'one_on_one'),
    (N'jason.ong@student.meowlet.test',    'age_range',        '25_34'),
    (N'jason.ong@student.meowlet.test',    'experience_level', 'some_basics'),
    (N'jason.ong@student.meowlet.test',    'learning_goal',    'start_investing'),
    (N'jason.ong@student.meowlet.test',    'time_commitment',  '3h_plus'),
    (N'jason.ong@student.meowlet.test',    'learning_style',   'video'),
    (N'meiling.chua@student.meowlet.test', 'age_range',        '25_34'),
    (N'meiling.chua@student.meowlet.test', 'experience_level', 'some_basics'),
    (N'meiling.chua@student.meowlet.test', 'learning_goal',    'just_curious'),
    (N'meiling.chua@student.meowlet.test', 'time_commitment',  'under_1h'),
    (N'meiling.chua@student.meowlet.test', 'learning_style',   'reading'),
    (N'arjun.nair@student.meowlet.test',   'age_range',        '18_24'),
    (N'arjun.nair@student.meowlet.test',   'experience_level', 'beginner'),
    (N'arjun.nair@student.meowlet.test',   'learning_goal',    'pay_debt'),
    (N'arjun.nair@student.meowlet.test',   'time_commitment',  '1_3h'),
    (N'arjun.nair@student.meowlet.test',   'learning_style',   'one_on_one'),
    (N'hafiz.z@student.meowlet.test',      'age_range',        '35_plus'),
    (N'hafiz.z@student.meowlet.test',      'experience_level', 'confident'),
    (N'hafiz.z@student.meowlet.test',      'learning_goal',    'retirement_plan'),
    (N'hafiz.z@student.meowlet.test',      'time_commitment',  '1_3h'),
    (N'hafiz.z@student.meowlet.test',      'learning_style',   'one_on_one'),
    (N'chloe.teo@student.meowlet.test',    'age_range',        'under_18'),
    (N'chloe.teo@student.meowlet.test',    'experience_level', 'beginner'),
    (N'chloe.teo@student.meowlet.test',    'learning_goal',    'save_money'),
    (N'chloe.teo@student.meowlet.test',    'time_commitment',  'under_1h'),
    (N'chloe.teo@student.meowlet.test',    'learning_style',   'video'),
    (N'farah.n@student.meowlet.test',      'age_range',        '25_34'),
    (N'farah.n@student.meowlet.test',      'experience_level', 'some_basics'),
    (N'farah.n@student.meowlet.test',      'learning_goal',    'just_curious'),
    (N'farah.n@student.meowlet.test',      'time_commitment',  '1_3h'),
    (N'farah.n@student.meowlet.test',      'learning_style',   'no_preference'),
    (N'ryan.goh@student.meowlet.test',     'age_range',        '18_24'),
    (N'ryan.goh@student.meowlet.test',     'experience_level', 'beginner'),
    (N'ryan.goh@student.meowlet.test',     'learning_goal',    'start_investing'),
    (N'ryan.goh@student.meowlet.test',     'time_commitment',  '3h_plus'),
    (N'ryan.goh@student.meowlet.test',     'learning_style',   'one_on_one'),
    (N'kavitha.s@student.meowlet.test',    'age_range',        '35_plus'),
    (N'kavitha.s@student.meowlet.test',    'experience_level', 'some_basics'),
    (N'kavitha.s@student.meowlet.test',    'learning_goal',    'retirement_plan'),
    (N'kavitha.s@student.meowlet.test',    'time_commitment',  'under_1h'),
    (N'kavitha.s@student.meowlet.test',    'learning_style',   'reading'),
    (N'lucas.yap@student.meowlet.test',    'age_range',        '18_24'),
    (N'lucas.yap@student.meowlet.test',    'experience_level', 'beginner'),
    (N'lucas.yap@student.meowlet.test',    'learning_goal',    'pay_debt'),
    (N'lucas.yap@student.meowlet.test',    'time_commitment',  '1_3h'),
    (N'lucas.yap@student.meowlet.test',    'learning_style',   'video'),
    (N'zara.i@student.meowlet.test',       'age_range',        '18_24'),
    (N'brandon.lee@student.meowlet.test',  'age_range',        '25_34'),
    (N'brandon.lee@student.meowlet.test',  'experience_level', 'confident'),
    (N'brandon.lee@student.meowlet.test',  'learning_goal',    'start_investing'),
    (N'nadia.kamal@student.meowlet.test',  'age_range',        '25_34'),
    (N'nadia.kamal@student.meowlet.test',  'experience_level', 'beginner'),
    (N'nadia.kamal@student.meowlet.test',  'learning_goal',    'save_money')
) AS s (Email, QuestionKey, AnswerValue)
JOIN dbo.Users u ON u.Email = s.Email
WHERE NOT EXISTS (SELECT 1 FROM dbo.OnboardingAnswers x WHERE x.UserId = u.UserId AND x.QuestionKey = s.QuestionKey);

------------------------------------------------------------------------------
-- 4. Courses (categories/levels match the admin dashboard dropdowns)
------------------------------------------------------------------------------
MERGE dbo.Courses AS t
USING (
    SELECT s.*, u.UserId AS TutorId
    FROM (VALUES
        (N'BUD101', N'Your First Monthly Budget',              N'Budgeting',           N'Beginner',     8, 1, '2026-03-02T09:00:00', N'nurul.aina@tutor.meowlet.test',
         N'Track a month of spending, split it into needs and wants, and build a budget you will actually keep.'),
        (N'BUD201', N'Zero-Based Budgeting in Practice',       N'Budgeting',           N'Intermediate', 10, 1, '2026-04-10T09:00:00', N'priya.r@tutor.meowlet.test',
         N'Give every ringgit a job. Plan irregular income, sinking funds and a monthly review routine.'),
        (N'SAV101', N'Building an Emergency Fund',             N'Saving',              N'Beginner',     6, 1, '2026-03-02T09:30:00', N'nurul.aina@tutor.meowlet.test',
         N'Work out how much cushion you need, where to keep it, and how to fill it without feeling the pinch.'),
        (N'SAV201', N'Saving for Big Goals',                   N'Saving',              N'Intermediate', 7, 1, '2026-05-01T09:00:00', N'nurul.aina@tutor.meowlet.test',
         N'Plan for a car, a wedding or a house deposit with timelines, targets and the right savings accounts.'),
        (N'INV101', N'Investing Basics: Stocks, Bonds, Funds', N'Investing',           N'Beginner',     12, 1, '2026-03-05T09:00:00', N'daniel.tan@tutor.meowlet.test',
         N'What you actually own when you invest, how returns and risk trade off, and how to start with a small amount.'),
        (N'INV301', N'Reading a Company''s Financials',        N'Investing',           N'Advanced',     14, 1, '2026-06-15T09:00:00', N'ahmad.faiz@tutor.meowlet.test',
         N'Income statements, balance sheets and cash flow, using real Bursa Malaysia annual reports.'),
        (N'DEB101', N'Getting Out of Credit Card Debt',        N'Debt Management',     N'Beginner',     6, 1, '2026-03-20T09:00:00', N'priya.r@tutor.meowlet.test',
         N'How card interest really works, avalanche vs snowball, and talking to your bank or AKPK.'),
        (N'TAX101', N'Malaysian Income Tax for First Jobbers', N'Taxes',               N'Beginner',     5, 1, '2026-04-01T09:00:00', N'grace.lim@tutor.meowlet.test',
         N'PCB, reliefs and filing your first e-Filing return without panic.'),
        (N'INS101', N'Insurance Without the Jargon',           N'Insurance',           N'Beginner',     6, 1, '2026-05-20T09:00:00', N'ahmad.faiz@tutor.meowlet.test',
         N'Medical, life and takaful cover explained: what you need, what you don''t, and how to compare policies.'),
        (N'RET201', N'EPF, PRS and Planning for Retirement',   N'Retirement Planning', N'Intermediate', 9, 1, '2026-06-01T09:00:00', N'daniel.tan@tutor.meowlet.test',
         N'Project your EPF balance, top up with PRS, and set a retirement number you can work towards.'),
        (N'FIN101', N'E-Wallets and Digital Banking Safely',   N'Fintech',             N'Beginner',     4, 0, '2026-09-10T09:00:00', NULL,
         N'Use e-wallets and digital banks with confidence, and spot the scams that target them.'),
        (N'TAX301', N'Tax Planning for Freelancers',           N'Taxes',               N'Advanced',     0, 0, '2026-09-28T09:00:00', N'grace.lim@tutor.meowlet.test',
         NULL)
    ) AS s (CourseCode, Title, Category, Level, Lessons, IsPublished, CreatedAt, TutorEmail, Description)
    LEFT JOIN dbo.Users u ON u.Email = s.TutorEmail
) AS s
ON t.CourseCode = s.CourseCode
WHEN MATCHED AND t.Description IS NULL AND t.TutorId IS NULL THEN
    -- Courses seeded before Description/TutorId existed get them filled in.
    UPDATE SET Description = s.Description, TutorId = s.TutorId
WHEN NOT MATCHED THEN
    INSERT (CourseCode, Title, Category, Level, Lessons, IsPublished, CreatedAt, Description, TutorId)
    VALUES (s.CourseCode, s.Title, s.Category, s.Level, s.Lessons, s.IsPublished, s.CreatedAt, s.Description, s.TutorId);

------------------------------------------------------------------------------
-- 4b. Course lessons (one row per lesson; counts match Courses.Lessons)
------------------------------------------------------------------------------
INSERT INTO dbo.CourseLessons (CourseId, Position, Title, ContentType, DurationMinutes)
SELECT c.CourseId, s.Position, s.Title, s.ContentType, s.DurationMinutes
FROM (VALUES
    (N'BUD101', 1, N'Why budgets fail (and how yours won''t)',   'Video',   8),
    (N'BUD101', 2, N'Tracking a month of spending',              'Article', 10),
    (N'BUD101', 3, N'Needs, wants and savings: the 50/30/20 rule','Video',   12),
    (N'BUD101', 4, N'Setting up your budget sheet',              'Video',   15),
    (N'BUD101', 5, N'The envelope method, digitally',            'Article', 8),
    (N'BUD101', 6, N'Handling bills that are not monthly',       'Video',   10),
    (N'BUD101', 7, N'Your first monthly review',                 'Article', 6),
    (N'BUD101', 8, N'Check your understanding',                  'Quiz',    10),

    (N'BUD201', 1, N'What zero-based budgeting means',           'Video',   9),
    (N'BUD201', 2, N'Listing every expense category',            'Article', 12),
    (N'BUD201', 3, N'Budgeting irregular income',                'Video',   14),
    (N'BUD201', 4, N'Sinking funds for annual costs',            'Video',   11),
    (N'BUD201', 5, N'Prioritising when money is short',          'Article', 10),
    (N'BUD201', 6, N'Couples and shared budgets',                'Video',   13),
    (N'BUD201', 7, N'Automating transfers on payday',            'Article', 7),
    (N'BUD201', 8, N'Mid-month course corrections',              'Video',   9),
    (N'BUD201', 9, N'Building a review habit',                   'Article', 6),
    (N'BUD201', 10, N'Final quiz',                               'Quiz',    15),

    (N'SAV101', 1, N'What an emergency fund is for',             'Video',   7),
    (N'SAV101', 2, N'How much is enough for you',                'Article', 9),
    (N'SAV101', 3, N'Where to keep it: savings, FD or money market', 'Video', 12),
    (N'SAV101', 4, N'Filling it on a tight income',              'Video',   10),
    (N'SAV101', 5, N'When to use it, and refilling after',       'Article', 6),
    (N'SAV101', 6, N'Check your understanding',                  'Quiz',    8),

    (N'SAV201', 1, N'Turning a wish into a savings goal',        'Video',   8),
    (N'SAV201', 2, N'Working backwards from a deadline',         'Article', 10),
    (N'SAV201', 3, N'Saving for a car without a huge loan',      'Video',   12),
    (N'SAV201', 4, N'House deposits and stamp duty',             'Video',   14),
    (N'SAV201', 5, N'Weddings and other one-off costs',          'Article', 8),
    (N'SAV201', 6, N'Juggling several goals at once',            'Video',   10),
    (N'SAV201', 7, N'Final quiz',                                'Quiz',    10),

    (N'INV101', 1, N'Saving vs investing',                       'Video',   8),
    (N'INV101', 2, N'Risk, return and time',                     'Video',   12),
    (N'INV101', 3, N'What a share really is',                    'Article', 9),
    (N'INV101', 4, N'Bonds and sukuk explained',                 'Video',   11),
    (N'INV101', 5, N'Unit trusts and ETFs',                      'Video',   13),
    (N'INV101', 6, N'Fees that quietly eat returns',             'Article', 8),
    (N'INV101', 7, N'Diversification in plain words',            'Video',   10),
    (N'INV101', 8, N'Opening a brokerage account',               'Article', 9),
    (N'INV101', 9, N'Robo-advisors: pros and cons',              'Video',   10),
    (N'INV101', 10, N'Dollar-cost averaging',                    'Article', 7),
    (N'INV101', 11, N'Staying calm when markets fall',           'Video',   9),
    (N'INV101', 12, N'Final quiz',                               'Quiz',    15),

    (N'INV301', 1, N'Where to find annual reports',              'Article', 6),
    (N'INV301', 2, N'Reading the income statement',              'Video',   18),
    (N'INV301', 3, N'Revenue quality and one-off items',         'Video',   14),
    (N'INV301', 4, N'The balance sheet line by line',            'Video',   20),
    (N'INV301', 5, N'Debt, liquidity and solvency ratios',       'Article', 15),
    (N'INV301', 6, N'Cash flow: the statement that doesn''t lie','Video',   17),
    (N'INV301', 7, N'Free cash flow',                            'Article', 10),
    (N'INV301', 8, N'Profitability ratios',                      'Video',   12),
    (N'INV301', 9, N'Dividends and payout policy',               'Article', 9),
    (N'INV301', 10, N'Reading the notes to the accounts',        'Video',   16),
    (N'INV301', 11, N'Red flags in a report',                    'Article', 12),
    (N'INV301', 12, N'Case study: a REIT',                       'Video',   22),
    (N'INV301', 13, N'Case study: a bank',                       'Video',   22),
    (N'INV301', 14, N'Final assessment',                         'Quiz',    25),

    (N'DEB101', 1, N'How card interest is calculated',           'Video',   10),
    (N'DEB101', 2, N'Listing every debt you owe',                'Article', 8),
    (N'DEB101', 3, N'Avalanche vs snowball',                     'Video',   12),
    (N'DEB101', 4, N'Balance transfers and consolidation loans', 'Article', 10),
    (N'DEB101', 5, N'Getting help from AKPK',                    'Video',   9),
    (N'DEB101', 6, N'Check your understanding',                  'Quiz',    10),

    (N'TAX101', 1, N'How PCB is deducted from your salary',      'Video',   9),
    (N'TAX101', 2, N'Tax reliefs you can claim',                 'Article', 12),
    (N'TAX101', 3, N'Registering for e-Filing',                  'Video',   8),
    (N'TAX101', 4, N'Filing your BE form step by step',          'Video',   15),
    (N'TAX101', 5, N'Check your understanding',                  'Quiz',    10),

    (N'INS101', 1, N'What insurance is for',                     'Video',   7),
    (N'INS101', 2, N'Medical cards and hospital plans',          'Video',   12),
    (N'INS101', 3, N'Life cover: term vs whole life',            'Article', 10),
    (N'INS101', 4, N'Takaful in brief',                          'Video',   6),
    (N'INS101', 5, N'Comparing two policies side by side',       'Article', 11),
    (N'INS101', 6, N'Check your understanding',                  'Quiz',    8),

    (N'RET201', 1, N'How much will you need?',                   'Video',   11),
    (N'RET201', 2, N'EPF accounts and dividends',                'Article', 10),
    (N'RET201', 3, N'Projecting your EPF balance',               'Video',   14),
    (N'RET201', 4, N'Voluntary EPF top-ups',                     'Article', 7),
    (N'RET201', 5, N'Private Retirement Schemes (PRS)',          'Video',   12),
    (N'RET201', 6, N'Tax relief on PRS contributions',           'Article', 6),
    (N'RET201', 7, N'Retiring early: what changes',              'Video',   13),
    (N'RET201', 8, N'Drawing down your savings',                 'Article', 10),
    (N'RET201', 9, N'Final quiz',                                'Quiz',    12),

    (N'FIN101', 1, N'How e-wallets hold your money',             'Video',   8),
    (N'FIN101', 2, N'Digital banks vs traditional banks',        'Article', 9),
    (N'FIN101', 3, N'Spotting phishing and APK scams',           'Video',   11),
    (N'FIN101', 4, N'Check your understanding',                  'Quiz',    8)
) AS s (CourseCode, Position, Title, ContentType, DurationMinutes)
JOIN dbo.Courses c ON c.CourseCode = s.CourseCode
WHERE NOT EXISTS (SELECT 1 FROM dbo.CourseLessons x WHERE x.CourseId = c.CourseId AND x.Position = s.Position);

------------------------------------------------------------------------------
-- 5. Enrollments (spread Mar–Oct 2026 so the dashboard chart has a shape)
------------------------------------------------------------------------------
INSERT INTO dbo.Enrollments (UserId, CourseId, EnrolledAt)
SELECT u.UserId, c.CourseId, s.EnrolledAt
FROM (VALUES
    (N'aisha.rahman@student.meowlet.test', N'BUD101', '2026-03-07T19:30:00'),
    (N'aisha.rahman@student.meowlet.test', N'SAV101', '2026-03-15T20:00:00'),
    (N'jason.ong@student.meowlet.test',    N'INV101', '2026-03-22T21:00:00'),
    (N'aisha.rahman@student.meowlet.test', N'SAV201', '2026-05-03T19:00:00'),
    (N'meiling.chua@student.meowlet.test', N'TAX101', '2026-04-09T12:30:00'),
    (N'meiling.chua@student.meowlet.test', N'BUD101', '2026-04-12T13:00:00'),
    (N'arjun.nair@student.meowlet.test',   N'DEB101', '2026-04-28T22:00:00'),
    (N'arjun.nair@student.meowlet.test',   N'BUD101', '2026-05-02T21:30:00'),
    (N'jason.ong@student.meowlet.test',    N'INV301', '2026-06-20T20:15:00'),
    (N'hafiz.z@student.meowlet.test',      N'INV101', '2026-05-15T18:40:00'),
    (N'hafiz.z@student.meowlet.test',      N'RET201', '2026-06-05T19:10:00'),
    (N'brandon.lee@student.meowlet.test',  N'INV101', '2026-05-04T08:30:00'),
    (N'chloe.teo@student.meowlet.test',    N'SAV101', '2026-06-04T10:20:00'),
    (N'chloe.teo@student.meowlet.test',    N'BUD101', '2026-06-18T11:00:00'),
    (N'farah.n@student.meowlet.test',      N'INS101', '2026-06-30T22:30:00'),
    (N'farah.n@student.meowlet.test',      N'TAX101', '2026-07-08T21:00:00'),
    (N'ryan.goh@student.meowlet.test',     N'INV101', '2026-07-17T18:00:00'),
    (N'ryan.goh@student.meowlet.test',     N'SAV201', '2026-07-25T18:30:00'),
    (N'nadia.kamal@student.meowlet.test',  N'BUD101', '2026-07-08T14:00:00'),
    (N'hafiz.z@student.meowlet.test',      N'INV301', '2026-07-29T19:45:00'),
    (N'kavitha.s@student.meowlet.test',    N'RET201', '2026-08-06T10:15:00'),
    (N'kavitha.s@student.meowlet.test',    N'INS101', '2026-08-14T10:45:00'),
    (N'meiling.chua@student.meowlet.test', N'BUD201', '2026-08-21T12:00:00'),
    (N'lucas.yap@student.meowlet.test',    N'DEB101', '2026-08-31T15:00:00'),
    (N'arjun.nair@student.meowlet.test',   N'BUD201', '2026-09-05T21:15:00'),
    (N'lucas.yap@student.meowlet.test',    N'BUD101', '2026-09-09T15:30:00'),
    (N'jason.ong@student.meowlet.test',    N'RET201', '2026-09-14T20:45:00'),
    (N'ryan.goh@student.meowlet.test',     N'INV301', '2026-09-23T18:10:00'),
    (N'chloe.teo@student.meowlet.test',    N'SAV201', '2026-09-27T11:20:00'),
    (N'aisha.rahman@student.meowlet.test', N'TAX101', '2026-10-02T19:40:00'),
    (N'kavitha.s@student.meowlet.test',    N'TAX101', '2026-10-04T09:30:00')
) AS s (Email, CourseCode, EnrolledAt)
JOIN dbo.Users   u ON u.Email = s.Email
JOIN dbo.Courses c ON c.CourseCode = s.CourseCode
WHERE NOT EXISTS (SELECT 1 FROM dbo.Enrollments x WHERE x.UserId = u.UserId AND x.CourseId = c.CourseId);

------------------------------------------------------------------------------
-- 6. Lesson progress
--    Rule, so the numbers look natural and stay the same on every machine:
--    a learner finishes 2 lessons per week since enrolling (plus the first
--    one on day 1), one lesson every 3 days, measured up to 2026-10-06.
------------------------------------------------------------------------------
DECLARE @AsOf DATETIME2 = '2026-10-06T00:00:00';

INSERT INTO dbo.LessonProgress (UserId, LessonId, CompletedAt)
SELECT e.UserId, l.LessonId, DATEADD(DAY, (l.Position - 1) * 3 + 1, e.EnrolledAt)
FROM dbo.Enrollments e
JOIN dbo.Users u          ON u.UserId = e.UserId AND u.Email LIKE N'%@student.meowlet.test'
JOIN dbo.CourseLessons l  ON l.CourseId = e.CourseId
WHERE l.Position <= (DATEDIFF(DAY, e.EnrolledAt, @AsOf) / 7) * 2 + 1
  AND DATEADD(DAY, (l.Position - 1) * 3 + 1, e.EnrolledAt) <= @AsOf
  AND NOT EXISTS (SELECT 1 FROM dbo.LessonProgress x WHERE x.UserId = e.UserId AND x.LessonId = l.LessonId);

-- An enrollment is complete once every lesson in the course is done.
UPDATE e
SET CompletedAt = p.LastDone
FROM dbo.Enrollments e
CROSS APPLY (
    SELECT COUNT(*) AS Done, MAX(lp.CompletedAt) AS LastDone
    FROM dbo.LessonProgress lp
    JOIN dbo.CourseLessons l ON l.LessonId = lp.LessonId
    WHERE lp.UserId = e.UserId AND l.CourseId = e.CourseId
) p
WHERE e.CompletedAt IS NULL
  AND p.Done > 0
  AND p.Done = (SELECT COUNT(*) FROM dbo.CourseLessons l WHERE l.CourseId = e.CourseId);

------------------------------------------------------------------------------
-- 7. Course reviews (feeds admin dashboard > Reviews)
------------------------------------------------------------------------------
INSERT INTO dbo.CourseReviews (UserId, CourseId, Rating, Comment, IsHidden, CreatedAt)
SELECT u.UserId, c.CourseId, s.Rating, s.Comment, s.IsHidden, s.CreatedAt
FROM (VALUES
    (N'aisha.rahman@student.meowlet.test', N'BUD101', 5, N'Finally a budget I actually stick to. The needs/wants split clicked for me.', 0, '2026-04-02T20:00:00'),
    (N'aisha.rahman@student.meowlet.test', N'SAV101', 4, N'Short and practical. Would love a calculator built into the page.',          0, '2026-04-05T21:10:00'),
    (N'jason.ong@student.meowlet.test',    N'INV101', 5, N'Explains ETFs better than any YouTube video I''ve watched.',                0, '2026-05-30T22:00:00'),
    (N'meiling.chua@student.meowlet.test', N'TAX101', 4, N'Clear walkthrough of e-Filing. A section on side income would help.',       0, '2026-04-28T13:30:00'),
    (N'meiling.chua@student.meowlet.test', N'BUD101', 3, N'The quiz in lesson 8 doesn''t quite match the videos.',                      0, '2026-05-10T12:45:00'),
    (N'arjun.nair@student.meowlet.test',   N'DEB101', 5, N'The avalanche vs snowball lesson changed how I''m paying off my card.',     0, '2026-05-20T22:30:00'),
    (N'hafiz.z@student.meowlet.test',      N'RET201', 4, N'Good EPF projections. Wish it covered retiring abroad.',                    0, '2026-07-30T19:00:00'),
    (N'chloe.teo@student.meowlet.test',    N'SAV101', 5, N'Easy enough for me as a student. Started saving RM50 a month!',            0, '2026-06-25T11:15:00'),
    (N'farah.n@student.meowlet.test',      N'INS101', 3, N'Useful, but the takaful lesson was far too short.',                         0, '2026-07-25T22:40:00'),
    (N'ryan.goh@student.meowlet.test',     N'INV101', 4, N'Solid basics. The fees lesson was eye-opening.',                            0, '2026-09-01T18:20:00'),
    (N'kavitha.s@student.meowlet.test',    N'RET201', 5, N'Exactly what I needed at 40. Very clear on PRS relief.',                    0, '2026-09-10T10:00:00'),
    (N'brandon.lee@student.meowlet.test',  N'INV101', 1, N'CHECK OUT MY CRYPTO SIGNALS GROUP, 10X GUARANTEED!!!',                       1, '2026-05-06T02:13:00')
) AS s (Email, CourseCode, Rating, Comment, IsHidden, CreatedAt)
JOIN dbo.Users   u ON u.Email = s.Email
JOIN dbo.Courses c ON c.CourseCode = s.CourseCode
WHERE NOT EXISTS (SELECT 1 FROM dbo.CourseReviews x WHERE x.UserId = u.UserId AND x.CourseId = c.CourseId);

------------------------------------------------------------------------------
-- 8. Tutor profiles
------------------------------------------------------------------------------
INSERT INTO dbo.TutorProfiles (UserId, Headline, Bio, MeetingLink, IsAcceptingStudents, UpdatedAt)
SELECT u.UserId, s.Headline, s.Bio, s.MeetingLink, s.Accepting, s.UpdatedAt
FROM (VALUES
    (N'nurul.aina@tutor.meowlet.test',  N'Budgeting coach for first jobbers',
     N'Economics lecturer at UM. I help fresh graduates turn their first salary into a plan they can stick to.',
     N'https://meet.google.com/nur-aina-001', 1, '2026-03-05T10:00:00'),
    (N'daniel.tan@tutor.meowlet.test',  N'Licensed financial planner, investing and retirement',
     N'Ten years advising families on unit trusts, ETFs and EPF. I like to start from your goals, not from products.',
     N'https://zoom.us/j/5550100200', 1, '2026-03-12T15:00:00'),
    (N'priya.r@tutor.meowlet.test',     N'Debt-free since 2021, now helping you get there',
     N'I paid off RM40k of card and PTPTN debt. Sessions are judgement-free and practical.',
     N'https://meet.google.com/priya-debt', 1, '2026-04-06T09:00:00'),
    (N'ahmad.faiz@tutor.meowlet.test',  N'Equity analyst: read a stock like a pro',
     N'Former research analyst. I teach how to read annual reports and how to buy insurance without being oversold.',
     N'https://teams.microsoft.com/l/meetup-join/ahmad-faiz', 1, '2026-04-21T12:00:00'),
    (N'grace.lim@tutor.meowlet.test',   N'Tax agent, e-Filing made simple',
     N'Chartered tax adviser. Busiest in March and April, so book early for filing season.',
     N'https://meet.google.com/grace-tax', 0, '2026-09-15T08:00:00'),
    (N'kevin.lau@tutor.meowlet.test',   N'Final-year finance student, investing for beginners',
     N'Monash finance student and student investment club lead. Waiting on verification.',
     NULL, 1, '2026-09-22T09:30:00'),
    (N'siti.mariam@tutor.meowlet.test', N'Insurance and takaful, explained simply',
     NULL, NULL, 1, '2026-10-01T13:10:00'),
    (N'marcus.wong@tutor.meowlet.test', N'Debt restructuring specialist',
     N'Account deactivated by an admin.', NULL, 0, '2026-09-05T09:00:00')
) AS s (Email, Headline, Bio, MeetingLink, Accepting, UpdatedAt)
JOIN dbo.Users u ON u.Email = s.Email
WHERE NOT EXISTS (SELECT 1 FROM dbo.TutorProfiles x WHERE x.UserId = u.UserId);

------------------------------------------------------------------------------
-- 9. Tutor verifications (history; Users.IsVerified holds the current state)
------------------------------------------------------------------------------
INSERT INTO dbo.TutorVerifications
    (TutorId, CertificatePath, Institution, Status, SubmittedAt, ReviewedByUserId, ReviewedAt, ReviewNote)
SELECT u.UserId, s.CertificatePath, s.Institution, s.Status, s.SubmittedAt,
       CASE WHEN s.Status = 'Pending' THEN NULL ELSE adm.UserId END, s.ReviewedAt, s.ReviewNote
FROM (VALUES
    (N'nurul.aina@tutor.meowlet.test',  N'App_Data/Certificates/4_20260918071738.jpg', N'Universiti Malaya',              'Approved', '2026-03-04T10:20:00', '2026-03-05T09:00:00', NULL),
    (N'daniel.tan@tutor.meowlet.test',  N'App_Data/Certificates/4_20261001132732.pdf', N'Sunway University',              'Approved', '2026-03-11T14:35:00', '2026-03-12T10:30:00', N'CFP licence checked.'),
    (N'priya.r@tutor.meowlet.test',     N'App_Data/Certificates/4_20260918071738.jpg', N'Taylor''s University',           'Rejected', '2026-04-02T08:50:00', '2026-04-03T11:00:00', N'Image too blurry to read the name. Please upload a clearer scan.'),
    (N'priya.r@tutor.meowlet.test',     N'App_Data/Certificates/4_20260918071738.jpg', N'Taylor''s University',           'Approved', '2026-04-05T19:15:00', '2026-04-06T09:00:00', NULL),
    (N'ahmad.faiz@tutor.meowlet.test',  N'App_Data/Certificates/4_20261001132732.pdf', N'Securities Commission Malaysia', 'Approved', '2026-04-20T11:05:00', '2026-04-21T10:00:00', NULL),
    (N'grace.lim@tutor.meowlet.test',   N'App_Data/Certificates/4_20260918071738.jpg', N'Chartered Tax Institute of Malaysia', 'Approved', '2026-05-09T16:25:00', '2026-05-11T09:30:00', NULL),
    (N'marcus.wong@tutor.meowlet.test', N'App_Data/Certificates/4_20260918071738.jpg', N'HELP University',                'Approved', '2026-03-18T15:45:00', '2026-03-19T10:00:00', NULL),
    (N'kevin.lau@tutor.meowlet.test',   N'App_Data/Certificates/4_20261001132732.pdf', N'Monash University Malaysia',     'Pending',  '2026-09-22T09:15:00', NULL, NULL)
) AS s (Email, CertificatePath, Institution, Status, SubmittedAt, ReviewedAt, ReviewNote)
JOIN dbo.Users u   ON u.Email = s.Email
JOIN dbo.Users adm ON adm.Email = N'meowlet@meowletedu.com'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TutorVerifications x WHERE x.TutorId = u.UserId AND x.SubmittedAt = s.SubmittedAt);

------------------------------------------------------------------------------
-- 10. Tutor weekly availability (Malaysia time; 1 = Monday ... 7 = Sunday)
------------------------------------------------------------------------------
INSERT INTO dbo.TutorAvailability (TutorId, DayOfWeek, StartTime, EndTime)
SELECT u.UserId, s.DayOfWeek, s.StartTime, s.EndTime
FROM (VALUES
    (N'nurul.aina@tutor.meowlet.test',  2, '19:00', '22:00'),
    (N'nurul.aina@tutor.meowlet.test',  4, '19:00', '22:00'),
    (N'nurul.aina@tutor.meowlet.test',  6, '10:00', '13:00'),
    (N'daniel.tan@tutor.meowlet.test',  1, '20:00', '22:00'),
    (N'daniel.tan@tutor.meowlet.test',  3, '20:00', '22:00'),
    (N'daniel.tan@tutor.meowlet.test',  5, '20:00', '23:00'),
    (N'priya.r@tutor.meowlet.test',     6, '09:00', '12:00'),
    (N'priya.r@tutor.meowlet.test',     7, '14:00', '18:00'),
    (N'ahmad.faiz@tutor.meowlet.test',  3, '19:00', '21:00'),
    (N'ahmad.faiz@tutor.meowlet.test',  6, '19:00', '22:00'),
    (N'grace.lim@tutor.meowlet.test',   2, '10:00', '12:00'),
    (N'grace.lim@tutor.meowlet.test',   6, '10:00', '12:00'),
    (N'kevin.lau@tutor.meowlet.test',   5, '15:00', '18:00'),
    (N'kevin.lau@tutor.meowlet.test',   7, '10:00', '13:00'),
    (N'siti.mariam@tutor.meowlet.test', 1, '09:00', '11:00'),
    (N'siti.mariam@tutor.meowlet.test', 4, '09:00', '11:00')
) AS s (Email, DayOfWeek, StartTime, EndTime)
JOIN dbo.Users u ON u.Email = s.Email
WHERE NOT EXISTS (SELECT 1 FROM dbo.TutorAvailability x
                  WHERE x.TutorId = u.UserId AND x.DayOfWeek = s.DayOfWeek AND x.StartTime = s.StartTime);

------------------------------------------------------------------------------
-- 11. Tutoring sessions (StartsAt in UTC; 12:00 UTC = 8 pm in Malaysia)
--     Past sessions are Completed / Cancelled / Declined; from 2026-10-07 on
--     they are Requested or Confirmed.
------------------------------------------------------------------------------
INSERT INTO dbo.TutoringSessions
    (TutorId, StudentId, TagId, StartsAt, DurationMinutes, Status, StudentNote, TutorNote, CancelledByUserId, CreatedAt, UpdatedAt)
SELECT tu.UserId, st.UserId, g.TagId, s.StartsAt, s.Minutes, s.Status, s.StudentNote, s.TutorNote,
       CASE s.CancelledBy WHEN 'tutor' THEN tu.UserId WHEN 'student' THEN st.UserId END,
       s.CreatedAt, ISNULL(s.UpdatedAt, s.CreatedAt)
FROM (VALUES
--   Tutor                               Student                               Topic        StartsAt               Min  Status       StudentNote                                            TutorNote                                                 CancelledBy CreatedAt              UpdatedAt
    (N'nurul.aina@tutor.meowlet.test',  N'aisha.rahman@student.meowlet.test', 'budgeting', '2026-03-20T12:00:00', 60, 'Completed', N'First salary, no idea where it goes.',                N'Set up 50/30/20 sheet. Homework: track 2 weeks.',      NULL,      '2026-03-16T09:00:00', '2026-03-20T13:05:00'),
    (N'daniel.tan@tutor.meowlet.test',  N'jason.ong@student.meowlet.test',    'investing', '2026-04-02T13:00:00', 60, 'Completed', N'Choosing between two ETFs.',                          N'Compared fees and tracking error. He picked the cheaper one.', NULL, '2026-03-28T20:00:00', '2026-04-02T14:00:00'),
    (N'grace.lim@tutor.meowlet.test',   N'meiling.chua@student.meowlet.test', 'taxes',     '2026-04-15T10:00:00', 30, 'Completed', N'Which reliefs can I claim this year?',                N'Lifestyle + medical reliefs. Filed together.',          NULL,      '2026-04-10T08:00:00', '2026-04-15T10:35:00'),
    (N'priya.r@tutor.meowlet.test',     N'arjun.nair@student.meowlet.test',   'debt',      '2026-05-10T11:00:00', 45, 'Completed', N'Two credit cards maxed out.',                         N'Avalanche plan drafted; call bank re: rate.',           NULL,      '2026-05-05T22:00:00', '2026-05-10T11:50:00'),
    (N'ahmad.faiz@tutor.meowlet.test',  N'brandon.lee@student.meowlet.test',  'investing', '2026-05-20T12:00:00', 60, 'Declined',  N'Want to discuss my trading signals group.',           NULL,                                                     NULL,      '2026-05-06T02:20:00', '2026-05-06T09:00:00'),
    (N'ahmad.faiz@tutor.meowlet.test',  N'hafiz.z@student.meowlet.test',      'investing', '2026-06-12T12:00:00', 60, 'Completed', N'Walk me through a REIT annual report.',               N'Went through IGB REIT report; next: gearing ratios.',   NULL,      '2026-06-07T19:00:00', '2026-06-12T13:10:00'),
    (N'nurul.aina@tutor.meowlet.test',  N'chloe.teo@student.meowlet.test',    'saving',    '2026-06-20T03:00:00', 30, 'Completed', N'How do I save on a student allowance?',               N'Set a RM50/month auto-transfer.',                       NULL,      '2026-06-15T10:30:00', '2026-06-20T03:35:00'),
    (N'daniel.tan@tutor.meowlet.test',  N'hafiz.z@student.meowlet.test',      'retirement','2026-07-03T12:00:00', 60, 'Completed', N'Am I on track for retiring at 55?',                   N'Projected EPF; suggested PRS top-up of RM3k/yr.',       NULL,      '2026-06-28T18:00:00', '2026-07-03T13:00:00'),
    (N'ahmad.faiz@tutor.meowlet.test',  N'ryan.goh@student.meowlet.test',     'investing', '2026-08-01T12:00:00', 60, 'Completed', N'Robo-advisor or DIY?',                                N'Compared fees; he''ll start with a robo-advisor.',     NULL,      '2026-07-27T17:00:00', '2026-08-01T13:00:00'),
    (N'grace.lim@tutor.meowlet.test',   N'farah.n@student.meowlet.test',      'taxes',     '2026-08-20T02:00:00', 30, 'Cancelled', N'Freelance income question.',                          NULL,                                                     'student', '2026-08-15T21:00:00', '2026-08-19T08:00:00'),
    (N'marcus.wong@tutor.meowlet.test', N'lucas.yap@student.meowlet.test',    'debt',      '2026-09-02T12:00:00', 60, 'Completed', N'PTPTN and a car loan, where do I start?',             N'Short session.',                                        NULL,      '2026-08-31T16:00:00', '2026-09-02T12:40:00'),
    (N'priya.r@tutor.meowlet.test',     N'aisha.rahman@student.meowlet.test', 'budgeting', '2026-09-10T12:00:00', 60, 'Completed', N'Budget review after 6 months.',                       N'Moved to zero-based budget; recommended BUD201.',      NULL,      '2026-09-05T20:00:00', '2026-09-10T13:00:00'),
    (N'daniel.tan@tutor.meowlet.test',  N'ryan.goh@student.meowlet.test',     'investing', '2026-09-24T13:00:00', 60, 'Completed', N'Rebalancing my first portfolio.',                     N'Rebalanced to 70/30.',                                  NULL,      '2026-09-20T18:00:00', '2026-09-24T14:00:00'),
    (N'nurul.aina@tutor.meowlet.test',  N'arjun.nair@student.meowlet.test',   'budgeting', '2026-09-30T12:00:00', 60, 'Cancelled', N'Budget around my new rent.',                          NULL,                                                     'tutor',   '2026-09-25T21:00:00', '2026-09-29T07:00:00'),
    (N'nurul.aina@tutor.meowlet.test',  N'arjun.nair@student.meowlet.test',   'budgeting', '2026-10-07T12:00:00', 60, 'Confirmed', N'Rebooked: budget around my new rent.',                NULL,                                                     NULL,      '2026-09-29T08:00:00', '2026-09-29T10:00:00'),
    (N'nurul.aina@tutor.meowlet.test',  N'aisha.rahman@student.meowlet.test', 'saving',    '2026-10-08T12:00:00', 60, 'Confirmed', N'Building a 6-month emergency fund.',                   NULL,                                                     NULL,      '2026-10-01T19:00:00', '2026-10-02T09:00:00'),
    (N'daniel.tan@tutor.meowlet.test',  N'jason.ong@student.meowlet.test',    'retirement','2026-10-09T13:00:00', 60, 'Confirmed', N'Should I open a PRS account?',                        NULL,                                                     NULL,      '2026-10-03T20:30:00', '2026-10-04T08:00:00'),
    (N'grace.lim@tutor.meowlet.test',   N'kavitha.s@student.meowlet.test',    'taxes',     '2026-10-10T02:00:00', 30, 'Requested', N'Tax relief for my parents'' medical bills.',          NULL,                                                     NULL,      '2026-10-04T10:00:00', NULL),
    (N'priya.r@tutor.meowlet.test',     N'lucas.yap@student.meowlet.test',    'debt',      '2026-10-12T03:00:00', 45, 'Requested', N'Second opinion on my debt plan.',                     NULL,                                                     NULL,      '2026-10-05T15:00:00', NULL),
    (N'ahmad.faiz@tutor.meowlet.test',  N'farah.n@student.meowlet.test',      'insurance', '2026-10-14T11:00:00', 60, 'Confirmed', N'Compare two medical card quotes.',                    NULL,                                                     NULL,      '2026-10-02T22:00:00', '2026-10-03T09:00:00'),
    (N'daniel.tan@tutor.meowlet.test',  N'hafiz.z@student.meowlet.test',      'investing', '2026-10-15T12:00:00', 60, 'Requested', N'Follow-up: dividend stocks for retirement income.',  NULL,                                                     NULL,      '2026-10-05T19:30:00', NULL)
) AS s (TutorEmail, StudentEmail, TagName, StartsAt, Minutes, Status, StudentNote, TutorNote, CancelledBy, CreatedAt, UpdatedAt)
JOIN dbo.Users tu ON tu.Email = s.TutorEmail
JOIN dbo.Users st ON st.Email = s.StudentEmail
LEFT JOIN dbo.Tags g ON g.TagName = s.TagName
WHERE NOT EXISTS (SELECT 1 FROM dbo.TutoringSessions x
                  WHERE x.TutorId = tu.UserId AND x.StudentId = st.UserId AND x.StartsAt = s.StartsAt);

------------------------------------------------------------------------------
-- 12. Session reviews (only on Completed sessions)
------------------------------------------------------------------------------
INSERT INTO dbo.SessionReviews (SessionId, Rating, Comment, IsHidden, CreatedAt)
SELECT ts.SessionId, s.Rating, s.Comment, 0, s.CreatedAt
FROM (VALUES
    (N'nurul.aina@tutor.meowlet.test',  N'aisha.rahman@student.meowlet.test', '2026-03-20T12:00:00', 5, N'Patient and super practical. I left with a working budget.', '2026-03-20T15:00:00'),
    (N'daniel.tan@tutor.meowlet.test',  N'jason.ong@student.meowlet.test',    '2026-04-02T13:00:00', 5, N'Cleared up weeks of confusion in an hour.',                   '2026-04-02T16:00:00'),
    (N'grace.lim@tutor.meowlet.test',   N'meiling.chua@student.meowlet.test', '2026-04-15T10:00:00', 4, N'Quick and accurate. Saved me RM600 in reliefs.',             '2026-04-15T12:00:00'),
    (N'priya.r@tutor.meowlet.test',     N'arjun.nair@student.meowlet.test',   '2026-05-10T11:00:00', 4, N'Felt no judgement at all. Clear next steps.',                 '2026-05-10T14:00:00'),
    (N'ahmad.faiz@tutor.meowlet.test',  N'hafiz.z@student.meowlet.test',      '2026-06-12T12:00:00', 5, N'Knows annual reports inside out.',                            '2026-06-12T15:00:00'),
    (N'daniel.tan@tutor.meowlet.test',  N'hafiz.z@student.meowlet.test',      '2026-07-03T12:00:00', 4, N'Helpful projections, a bit rushed at the end.',               '2026-07-03T16:00:00'),
    (N'ahmad.faiz@tutor.meowlet.test',  N'ryan.goh@student.meowlet.test',     '2026-08-01T12:00:00', 5, N'Honest advice, didn''t push any product.',                    '2026-08-01T15:30:00'),
    (N'marcus.wong@tutor.meowlet.test', N'lucas.yap@student.meowlet.test',    '2026-09-02T12:00:00', 2, N'Tutor was 20 minutes late and ended early.',                  '2026-09-02T14:00:00'),
    (N'priya.r@tutor.meowlet.test',     N'aisha.rahman@student.meowlet.test', '2026-09-10T12:00:00', 4, N'Great follow-up session.',                                    '2026-09-11T09:00:00')
) AS s (TutorEmail, StudentEmail, StartsAt, Rating, Comment, CreatedAt)
JOIN dbo.Users tu ON tu.Email = s.TutorEmail
JOIN dbo.Users st ON st.Email = s.StudentEmail
JOIN dbo.TutoringSessions ts ON ts.TutorId = tu.UserId AND ts.StudentId = st.UserId
                            AND ts.StartsAt = s.StartsAt AND ts.Status = 'Completed'
WHERE NOT EXISTS (SELECT 1 FROM dbo.SessionReviews x WHERE x.SessionId = ts.SessionId);

------------------------------------------------------------------------------
-- 13. Messages (SessionStartsAt links the message to that booking, or NULL)
------------------------------------------------------------------------------
INSERT INTO dbo.Messages (SenderId, RecipientId, SessionId, Body, SentAt, ReadAt)
SELECT snd.UserId, rcp.UserId, ts.SessionId, s.Body, s.SentAt, s.ReadAt
FROM (VALUES
    (N'aisha.rahman@student.meowlet.test', N'nurul.aina@tutor.meowlet.test',     '2026-03-20T12:00:00', N'Hi! Should I bring my bank statements?',                     '2026-03-17T08:00:00', '2026-03-17T12:00:00'),
    (N'nurul.aina@tutor.meowlet.test',     N'aisha.rahman@student.meowlet.test', '2026-03-20T12:00:00', N'Yes please, last two months is enough.',                     '2026-03-17T12:05:00', '2026-03-17T13:00:00'),
    (N'arjun.nair@student.meowlet.test',   N'priya.r@tutor.meowlet.test',        '2026-05-10T11:00:00', N'Thanks again. The bank agreed to lower my rate!',            '2026-05-24T21:00:00', '2026-05-25T08:00:00'),
    (N'nurul.aina@tutor.meowlet.test',     N'arjun.nair@student.meowlet.test',   '2026-09-30T12:00:00', N'So sorry, I have to cancel Wednesday. Can we do the 7th?',   '2026-09-29T07:00:00', '2026-09-29T07:45:00'),
    (N'arjun.nair@student.meowlet.test',   N'nurul.aina@tutor.meowlet.test',     '2026-10-07T12:00:00', N'7th works, booked it.',                                      '2026-09-29T08:00:00', '2026-09-29T10:00:00'),
    (N'jason.ong@student.meowlet.test',    N'daniel.tan@tutor.meowlet.test',     '2026-10-09T13:00:00', N'I''ll send my EPF statement before the session.',            '2026-10-04T09:00:00', '2026-10-04T20:00:00'),
    (N'kavitha.s@student.meowlet.test',    N'grace.lim@tutor.meowlet.test',      '2026-10-10T02:00:00', N'Is 10am Saturday OK? I can also do Tuesday.',                '2026-10-04T10:05:00', NULL),
    (N'lucas.yap@student.meowlet.test',    N'priya.r@tutor.meowlet.test',        '2026-10-12T03:00:00', N'Hi Priya, my previous tutor left the platform. Can you help?', '2026-10-05T15:05:00', NULL),
    (N'ryan.goh@student.meowlet.test',     N'ahmad.faiz@tutor.meowlet.test',     NULL,                  N'Do you also cover Shariah-compliant funds?',                  '2026-10-05T21:00:00', NULL)
) AS s (SenderEmail, RecipientEmail, SessionStartsAt, Body, SentAt, ReadAt)
JOIN dbo.Users snd ON snd.Email = s.SenderEmail
JOIN dbo.Users rcp ON rcp.Email = s.RecipientEmail
LEFT JOIN dbo.TutoringSessions ts
       ON ts.StartsAt = s.SessionStartsAt
      AND ts.TutorId   IN (snd.UserId, rcp.UserId)
      AND ts.StudentId IN (snd.UserId, rcp.UserId)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Messages x WHERE x.SenderId = snd.UserId AND x.SentAt = s.SentAt);

COMMIT TRANSACTION;
GO

-- Quick summary so you can see the seed worked.
SELECT
    (SELECT COUNT(*) FROM dbo.Users WHERE Role = 'Admin')   AS Admins,
    (SELECT COUNT(*) FROM dbo.Users WHERE Role = 'Tutor')   AS Tutors,
    (SELECT COUNT(*) FROM dbo.Users WHERE Role = 'Student') AS Students,
    (SELECT COUNT(*) FROM dbo.Courses)                      AS Courses,
    (SELECT COUNT(*) FROM dbo.CourseLessons)                AS Lessons,
    (SELECT COUNT(*) FROM dbo.Enrollments)                  AS Enrollments,
    (SELECT COUNT(*) FROM dbo.LessonProgress)               AS LessonsDone,
    (SELECT COUNT(*) FROM dbo.CourseReviews)                AS CourseReviews;
SELECT
    (SELECT COUNT(*) FROM dbo.TutorProfiles)                AS TutorProfiles,
    (SELECT COUNT(*) FROM dbo.TutorVerifications)           AS Verifications,
    (SELECT COUNT(*) FROM dbo.TutorAvailability)            AS AvailabilitySlots,
    (SELECT COUNT(*) FROM dbo.TutoringSessions)             AS Sessions,
    (SELECT COUNT(*) FROM dbo.SessionReviews)               AS SessionReviews,
    (SELECT COUNT(*) FROM dbo.Messages)                     AS Messages;
GO
