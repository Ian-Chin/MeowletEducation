-- Meowlet Education database schema.
-- Run against (localdb)\MSSQLLocalDB (see MeowletDb in Web.config):
--   sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i App_Data\CreateDatabase.sql
-- Safe to re-run: objects are only created when missing.

IF DB_ID('MeowletEducation') IS NULL
    CREATE DATABASE MeowletEducation;
GO

USE MeowletEducation;
GO

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
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);
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
