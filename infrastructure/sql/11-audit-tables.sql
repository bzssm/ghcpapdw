-- Audit Tables: AuditActions, AuditLog
-- Section 2.10 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE AuditActions (
    ActionID            INT IDENTITY(1,1) PRIMARY KEY,
    ActionName          NVARCHAR(50) NOT NULL UNIQUE,
    Description         NVARCHAR(255),
    Severity            NVARCHAR(10) DEFAULT 'Info'
);
GO

CREATE TABLE AuditLog (
    AuditID             BIGINT IDENTITY(1,1) PRIMARY KEY,
    ActionID            INT NOT NULL REFERENCES AuditActions(ActionID),
    UserName            NVARCHAR(100),
    IPAddress           NVARCHAR(45),
    TableName           NVARCHAR(128),
    RecordID            NVARCHAR(50),
    OldValues           NVARCHAR(MAX),
    NewValues           NVARCHAR(MAX),
    Description         NVARCHAR(500),
    Timestamp           DATETIME DEFAULT GETDATE(),
    SessionID           NVARCHAR(100),
    MachineName         NVARCHAR(100)
);
GO

PRINT 'Audit tables created successfully.';
GO
