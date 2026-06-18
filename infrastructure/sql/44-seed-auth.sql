USE [ZavaBankDB];
GO

-- ============================================================
-- 44-seed-auth.sql
-- Seeds: Users (10), Roles (5), UserRoles (15), SessionTokens (25)
-- ============================================================

-- ============================================================
-- Roles (5 rows)
-- ============================================================
SET IDENTITY_INSERT Roles ON;

INSERT INTO Roles (RoleID, RoleName, Description, CreatedDate) VALUES
(1, 'Admin', 'Full system administration access', '2024-01-01'),
(2, 'Teller', 'Branch teller - customer transactions and account inquiries', '2024-01-01'),
(3, 'LoanOfficer', 'Loan application review and decision authority', '2024-01-01'),
(4, 'FraudAnalyst', 'Fraud investigation and alert management', '2024-01-01'),
(5, 'Customer', 'Online banking customer access', '2024-01-01');

SET IDENTITY_INSERT Roles OFF;
GO

-- ============================================================
-- Users (10 rows)
-- ============================================================
SET IDENTITY_INSERT Users ON;

DECLARE @Salt NVARCHAR(64), @Hash NVARCHAR(128);

-- User 1: admin
SET @Salt = N'a1b2c3d4e5f6a7b8';
SET @Hash = N'A85924BF167290BE813E41160DAB30B57C5442CE'; -- SHA1(UTF8(salt+'Password1!'))
INSERT INTO Users (UserID, Username, PasswordHash, Salt, Email, FirstName, LastName, IsActive, FailedLoginAttempts, IsLockedOut, LastLoginDate, CreatedDate, ModifiedDate)
VALUES (1, 'admin', @Hash, @Salt, 'admin@zavabank.com', 'System', 'Administrator', 1, 0, 0, '2026-05-14 08:30:00', '2024-01-01', '2026-05-14');

-- User 2: teller.jones
SET @Salt = N'b2c3d4e5f6a7b8c9';
SET @Hash = N'9379A46864DC7992C11807819C4A3E0E69639D65'; -- SHA1(UTF8(salt+'Teller2024'))
INSERT INTO Users (UserID, Username, PasswordHash, Salt, Email, FirstName, LastName, IsActive, FailedLoginAttempts, IsLockedOut, LastLoginDate, CreatedDate, ModifiedDate)
VALUES (2, 'teller.jones', @Hash, @Salt, 'tjones@zavabank.com', 'Marcus', 'Jones', 1, 0, 0, '2026-05-14 09:15:00', '2024-01-01', '2026-05-14');

-- User 3: loan.officer.kim
SET @Salt = N'c3d4e5f6a7b8c9d0';
SET @Hash = N'4A320B5EE163FCB2E4A2E9D0C792EB600E31F9ED'; -- SHA1(UTF8(salt+'Loans2024'))
INSERT INTO Users (UserID, Username, PasswordHash, Salt, Email, FirstName, LastName, IsActive, FailedLoginAttempts, IsLockedOut, LastLoginDate, CreatedDate, ModifiedDate)
VALUES (3, 'loan.officer.kim', @Hash, @Salt, 'hkim@zavabank.com', 'Hannah', 'Kim', 1, 0, 0, '2026-05-13 16:45:00', '2024-01-01', '2026-05-14');

-- User 4: fraud.analyst.chen
SET @Salt = N'd4e5f6a7b8c9d0e1';
SET @Hash = N'EE532127D388A7559F7BDCDCF19F0CAC6432DF6C'; -- SHA1(UTF8(salt+'Fraud2024'))
INSERT INTO Users (UserID, Username, PasswordHash, Salt, Email, FirstName, LastName, IsActive, FailedLoginAttempts, IsLockedOut, LastLoginDate, CreatedDate, ModifiedDate)
VALUES (4, 'fraud.analyst.chen', @Hash, @Salt, 'wchen@zavabank.com', 'Wei', 'Chen', 1, 0, 0, '2026-05-14 10:00:00', '2024-01-01', '2026-05-14');

-- User 5: maria.rodriguez (CustomerID 1)
SET @Salt = N'e5f6a7b8c9d0e1f2';
SET @Hash = N'FB9E1AAE6B85EB5964170B224B9CCFFC225BE3C3'; -- SHA1(UTF8(salt+'Customer1'))
INSERT INTO Users (UserID, Username, PasswordHash, Salt, Email, FirstName, LastName, IsActive, FailedLoginAttempts, IsLockedOut, LastLoginDate, CreatedDate, ModifiedDate)
VALUES (5, 'maria.rodriguez', @Hash, @Salt, 'maria.rodriguez@email.com', 'Maria', 'Rodriguez', 1, 0, 0, '2026-05-12 14:20:00', '2024-01-01', '2026-05-14');

-- User 6: james.chen (CustomerID 2)
SET @Salt = N'f6a7b8c9d0e1f2a3';
SET @Hash = N'EF67D05FB8CA800E2FC675248B53047097DE44E3'; -- SHA1(UTF8(salt+'Customer2'))
INSERT INTO Users (UserID, Username, PasswordHash, Salt, Email, FirstName, LastName, IsActive, FailedLoginAttempts, IsLockedOut, LastLoginDate, CreatedDate, ModifiedDate)
VALUES (6, 'james.chen', @Hash, @Salt, 'james.chen@email.com', 'James', 'Chen', 1, 0, 0, '2026-05-13 11:30:00', '2024-01-01', '2026-05-14');

-- User 7: sarah.miller (CustomerID 4)
SET @Salt = N'a7b8c9d0e1f2a3b4';
SET @Hash = N'14847059FA13D58523E8DAFD8E1D7F5B37D36E55'; -- SHA1(UTF8(salt+'Customer3'))
INSERT INTO Users (UserID, Username, PasswordHash, Salt, Email, FirstName, LastName, IsActive, FailedLoginAttempts, IsLockedOut, LastLoginDate, CreatedDate, ModifiedDate)
VALUES (7, 'sarah.miller', @Hash, @Salt, 'sarah.miller@email.com', 'Sarah', 'Miller', 1, 1, 0, '2026-05-11 09:45:00', '2024-01-01', '2026-05-14');

-- User 8: david.park (CustomerID 5) - LOCKED OUT
SET @Salt = N'b8c9d0e1f2a3b4c5';
SET @Hash = N'F1BC6E3380DCB4F5E6EE80080E53D50EACA5C5B6'; -- SHA1(UTF8(salt+'Customer4'))
INSERT INTO Users (UserID, Username, PasswordHash, Salt, Email, FirstName, LastName, IsActive, FailedLoginAttempts, IsLockedOut, LastLoginDate, CreatedDate, ModifiedDate)
VALUES (8, 'david.park', @Hash, @Salt, 'david.park@email.com', 'David', 'Park', 1, 5, 1, '2026-05-10 08:00:00', '2024-01-01', '2026-05-14');

-- User 9: emily.johnson (CustomerID 6)
SET @Salt = N'c9d0e1f2a3b4c5d6';
SET @Hash = N'4AB1FE0F3694FA2292EFDAD48395DCC671C2EB66'; -- SHA1(UTF8(salt+'Customer5'))
INSERT INTO Users (UserID, Username, PasswordHash, Salt, Email, FirstName, LastName, IsActive, FailedLoginAttempts, IsLockedOut, LastLoginDate, CreatedDate, ModifiedDate)
VALUES (9, 'emily.johnson', @Hash, @Salt, 'emily.johnson@email.com', 'Emily', 'Johnson', 1, 0, 0, '2026-05-14 07:30:00', '2024-01-01', '2026-05-14');

-- User 10: viktor.petrov (CustomerID 3)
SET @Salt = N'd0e1f2a3b4c5d6e7';
SET @Hash = N'E0D8DEE3A3ECDD34ACDD659FF2AF4B33D9EECD77'; -- SHA1(UTF8(salt+'Customer6'))
INSERT INTO Users (UserID, Username, PasswordHash, Salt, Email, FirstName, LastName, IsActive, FailedLoginAttempts, IsLockedOut, LastLoginDate, CreatedDate, ModifiedDate)
VALUES (10, 'viktor.petrov', @Hash, @Salt, 'viktor.petrov@email.com', 'Viktor', 'Petrov', 1, 0, 0, '2026-05-13 15:00:00', '2024-01-01', '2026-05-14');

SET IDENTITY_INSERT Users OFF;
GO

-- ============================================================
-- UserRoles (15 rows)
-- ============================================================
INSERT INTO UserRoles (UserID, RoleID, AssignedDate, AssignedBy) VALUES
(1, 1, '2024-01-15', 'admin'),   -- admin → Admin
(1, 2, '2024-01-15', 'admin'),   -- admin → Teller
(1, 3, '2024-01-15', 'admin'),   -- admin → LoanOfficer
(2, 2, '2024-01-15', 'admin'),   -- teller.jones → Teller
(3, 3, '2024-01-15', 'admin'),   -- loan.officer.kim → LoanOfficer
(4, 4, '2024-01-15', 'admin'),   -- fraud.analyst.chen → FraudAnalyst
(5, 5, '2024-01-15', 'admin'),   -- maria.rodriguez → Customer
(6, 5, '2024-01-15', 'admin'),   -- james.chen → Customer
(7, 5, '2024-01-15', 'admin'),   -- sarah.miller → Customer
(8, 5, '2024-01-15', 'admin'),   -- david.park → Customer
(9, 5, '2024-01-15', 'admin'),   -- emily.johnson → Customer
(10, 5, '2024-01-15', 'admin'),  -- viktor.petrov → Customer
(2, 5, '2024-01-15', 'admin'),   -- teller.jones also Customer (testing)
(3, 5, '2024-01-15', 'admin'),   -- loan.officer.kim also Customer
(4, 5, '2024-01-15', 'admin');   -- fraud.analyst.chen also Customer
GO

-- ============================================================
-- SessionTokens (25 rows: 20 active, 5 expired)
-- ============================================================
SET IDENTITY_INSERT SessionTokens ON;

INSERT INTO SessionTokens (TokenID, UserID, Token, CreatedAt, ExpiresAt, SourceSystem, IsActive, IPAddress, UserAgent) VALUES
-- Active tokens (20)
-- admin: 3 active (2 DotNet, 1 Java)
(1,  1, 'A1B2C3D4-E5F6-7890-ABCD-EF1234567890', '2026-05-14 06:00:00', '2026-05-14 14:00:00', 'DotNet', 1, '10.0.1.10',    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),
(2,  1, 'B2C3D4E5-F6A7-8901-BCDE-F12345678901', '2026-05-14 07:30:00', '2026-05-14 15:30:00', 'DotNet', 1, '10.0.1.11',    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),
(3,  1, 'C3D4E5F6-A7B8-9012-CDEF-123456789012', '2026-05-14 08:00:00', '2026-05-14 16:00:00', 'Java',   1, '10.0.1.12',    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.Java/17.0'),

-- teller.jones: 2 active (DotNet)
(4,  2, 'D4E5F6A7-B8C9-0123-DEFA-234567890123', '2026-05-14 08:45:00', '2026-05-14 16:45:00', 'DotNet', 1, '10.0.1.20',    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),
(5,  2, 'E5F6A7B8-C9D0-1234-EFAB-345678901234', '2026-05-14 09:00:00', '2026-05-14 17:00:00', 'DotNet', 1, '10.0.1.21',    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),

-- loan.officer.kim: 2 active (DotNet)
(6,  3, 'F6A7B8C9-D0E1-2345-FABC-456789012345', '2026-05-14 07:00:00', '2026-05-14 15:00:00', 'DotNet', 1, '10.0.1.30',    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),
(7,  3, 'A7B8C9D0-E1F2-3456-ABCD-567890123456', '2026-05-14 09:30:00', '2026-05-14 17:30:00', 'DotNet', 1, '192.168.1.50', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),

-- fraud.analyst.chen: 2 active (1 DotNet, 1 Java)
(8,  4, 'B8C9D0E1-F2A3-4567-BCDE-678901234567', '2026-05-14 09:00:00', '2026-05-14 17:00:00', 'DotNet', 1, '10.0.1.40',    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),
(9,  4, 'C9D0E1F2-A3B4-5678-CDEF-789012345678', '2026-05-14 09:15:00', '2026-05-14 17:15:00', 'Java',   1, '10.0.1.41',    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.Java/17.0'),

-- maria.rodriguez: 2 active (1 DotNet, 1 Java)
(10, 5, 'D0E1F2A3-B4C5-6789-DEFA-890123456789', '2026-05-14 06:30:00', '2026-05-14 14:30:00', 'DotNet', 1, '192.168.2.10', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),
(11, 5, 'E1F2A3B4-C5D6-7890-EFAB-901234567890', '2026-05-14 07:00:00', '2026-05-14 15:00:00', 'Java',   1, '192.168.2.11', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.Java/17.0'),

-- james.chen: 2 active (DotNet)
(12, 6, 'F2A3B4C5-D6E7-8901-FABC-012345678901', '2026-05-14 08:00:00', '2026-05-14 16:00:00', 'DotNet', 1, '192.168.3.10', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),
(13, 6, 'A3B4C5D6-E7F8-9012-ABCD-123456789012', '2026-05-14 10:00:00', '2026-05-14 18:00:00', 'DotNet', 1, '192.168.3.11', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),

-- sarah.miller: 1 active (DotNet)
(14, 7, 'B4C5D6E7-F8A9-0123-BCDE-234567890123', '2026-05-14 09:00:00', '2026-05-14 17:00:00', 'DotNet', 1, '192.168.4.10', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),

-- emily.johnson: 2 active (1 DotNet, 1 Java)
(15, 9, 'C5D6E7F8-A9B0-1234-CDEF-345678901234', '2026-05-14 06:45:00', '2026-05-14 14:45:00', 'DotNet', 1, '192.168.5.10', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),
(16, 9, 'D6E7F8A9-B0C1-2345-DEFA-456789012345', '2026-05-14 07:15:00', '2026-05-14 15:15:00', 'Java',   1, '192.168.5.11', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.Java/17.0'),

-- viktor.petrov: 2 active (DotNet)
(17, 10, 'E7F8A9B0-C1D2-3456-EFAB-567890123456', '2026-05-14 08:30:00', '2026-05-14 16:30:00', 'DotNet', 1, '192.168.6.10', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),
(18, 10, 'F8A9B0C1-D2E3-4567-FABC-678901234567', '2026-05-14 10:30:00', '2026-05-14 18:30:00', 'DotNet', 1, '192.168.6.11', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),

-- david.park: 0 active (locked out)
-- (no active tokens)

-- Additional active tokens to reach 20
(19, 2, 'A9B0C1D2-E3F4-5678-ABCD-789012345678', '2026-05-14 10:15:00', '2026-05-14 18:15:00', 'DotNet', 1, '10.0.1.22',    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),
(20, 7, 'B0C1D2E3-F4A5-6789-BCDE-890123456789', '2026-05-14 10:45:00', '2026-05-14 18:45:00', 'DotNet', 1, '192.168.4.11', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),

-- Expired tokens (5)
-- david.park: 2 expired (before lockout)
(21, 8, 'C1D2E3F4-A5B6-7890-CDEF-901234567890', '2026-05-08 09:00:00', '2026-05-08 17:00:00', 'DotNet', 0, '192.168.7.10', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),
(22, 8, 'D2E3F4A5-B6C7-8901-DEFA-012345678901', '2026-05-09 10:00:00', '2026-05-09 18:00:00', 'DotNet', 0, '192.168.7.11', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),

-- admin: 1 expired
(23, 1, 'E3F4A5B6-C7D8-9012-EFAB-123456789012', '2026-05-10 06:00:00', '2026-05-10 14:00:00', 'DotNet', 0, '10.0.1.10',    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),

-- teller.jones: 1 expired
(24, 2, 'F4A5B6C7-D8E9-0123-FABC-234567890123', '2026-05-07 08:00:00', '2026-05-07 16:00:00', 'DotNet', 0, '10.0.1.20',    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8'),

-- james.chen: 1 expired
(25, 6, 'A5B6C7D8-E9F0-1234-ABCD-345678901234', '2026-05-11 07:00:00', '2026-05-11 15:00:00', 'DotNet', 0, '192.168.3.12', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ZavaBank.NET/4.8');

SET IDENTITY_INSERT SessionTokens OFF;
GO

PRINT 'Auth seed data loaded successfully.';
