-- Auth & Session Tables: Users, Roles, UserRoles, SessionTokens
-- Section 2.14 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE Users (
    UserID              INT IDENTITY(1,1) PRIMARY KEY,
    Username            NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash        NVARCHAR(128) NOT NULL,
    Salt                NVARCHAR(64) NOT NULL,
    Email               NVARCHAR(255) NOT NULL,
    FirstName           NVARCHAR(100) NOT NULL,
    LastName            NVARCHAR(100) NOT NULL,
    IsActive            BIT DEFAULT 1,
    FailedLoginAttempts INT DEFAULT 0,
    IsLockedOut         BIT DEFAULT 0,
    LastLoginDate       DATETIME NULL,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Roles (
    RoleID              INT IDENTITY(1,1) PRIMARY KEY,
    RoleName            NVARCHAR(50) NOT NULL UNIQUE,
    Description         NVARCHAR(255),
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE UserRoles (
    UserID              INT NOT NULL REFERENCES Users(UserID),
    RoleID              INT NOT NULL REFERENCES Roles(RoleID),
    AssignedDate        DATETIME DEFAULT GETDATE(),
    AssignedBy          NVARCHAR(100),
    PRIMARY KEY (UserID, RoleID)
);
GO

CREATE TABLE SessionTokens (
    TokenID             INT IDENTITY(1,1) PRIMARY KEY,
    UserID              INT NOT NULL REFERENCES Users(UserID),
    Token               NVARCHAR(64) NOT NULL UNIQUE,
    CreatedAt           DATETIME DEFAULT GETDATE(),
    ExpiresAt           DATETIME NOT NULL,
    SourceSystem        NVARCHAR(10) NOT NULL,
    IsActive            BIT DEFAULT 1,
    IPAddress           NVARCHAR(45),
    UserAgent           NVARCHAR(500)
);
GO

PRINT 'Auth and session tables created successfully.';
GO
