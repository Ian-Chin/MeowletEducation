INSERT INTO Users (FullName, Email, PasswordHash, Role, IsActive, HasOnboarded, IsVerified)
VALUES (
    N'Meowlet Admin',
    'meowlet@meowletedu.com',
    LOWER(CONVERT(CHAR(64), HASHBYTES('SHA2_256', CAST('Meowmeowmeow' AS VARCHAR(100))), 2)),
    'Admin', 1, 1, 1
);