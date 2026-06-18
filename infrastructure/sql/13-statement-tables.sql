-- Statement Tables: StatementRequests, StatementArchive
-- Section 2.12 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE StatementRequests (
    RequestID           INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    StatementType       NVARCHAR(20) NOT NULL,
    PeriodStart         DATETIME NOT NULL,
    PeriodEnd           DATETIME NOT NULL,
    Format              NVARCHAR(10) DEFAULT 'PDF',
    Status              NVARCHAR(20) DEFAULT 'Requested',
    RequestedDate       DATETIME DEFAULT GETDATE(),
    CompletedDate       DATETIME NULL,
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE StatementArchive (
    ArchiveID           INT IDENTITY(1,1) PRIMARY KEY,
    RequestID           INT NOT NULL REFERENCES StatementRequests(RequestID),
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    FilePath            NVARCHAR(500),
    FileSize            INT,
    GeneratedDate       DATETIME DEFAULT GETDATE(),
    ExpiryDate          DATETIME,
    Checksum            NVARCHAR(64)
);
GO

PRINT 'Statement tables created successfully.';
GO
