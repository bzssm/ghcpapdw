-- File Staging Tables: FileImports, CheckImages, WireConfirmations, RegulatoryFeeds
-- Section 2.9 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE FileImports (
    ImportID            INT IDENTITY(1,1) PRIMARY KEY,
    FileName            NVARCHAR(255) NOT NULL,
    FileType            NVARCHAR(20) NOT NULL,
    SourcePath          NVARCHAR(500) NOT NULL,
    Status              NVARCHAR(20) DEFAULT 'PENDING',
    RecordCount         INT DEFAULT 0,
    ErrorCount          INT DEFAULT 0,
    ImportedAt          DATETIME NOT NULL DEFAULT GETDATE(),
    CompletedAt         DATETIME NULL,
    ErrorDetails        NVARCHAR(MAX),
    ProcessedBy         NVARCHAR(100),
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE CheckImages (
    ImageID             INT IDENTITY(1,1) PRIMARY KEY,
    CheckNumber         NVARCHAR(20) NOT NULL,
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    FrontImagePath      NVARCHAR(500) NOT NULL,
    BackImagePath       NVARCHAR(500),
    ScanStatus          NVARCHAR(20) DEFAULT 'PENDING',
    ScannedAt           DATETIME NOT NULL DEFAULT GETDATE(),
    ProcessedAt         DATETIME NULL,
    CheckAmount         DECIMAL(18,2),
    CheckDate           DATETIME,
    PayeeName           NVARCHAR(200),
    MICR                NVARCHAR(100),
    QualityScore        INT,
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE WireConfirmations (
    ConfirmationID      INT IDENTITY(1,1) PRIMARY KEY,
    TransactionID       BIGINT NOT NULL REFERENCES Transactions(TransactionID),
    ConfirmationNumber  NVARCHAR(50) NOT NULL UNIQUE,
    FilePath            NVARCHAR(500) NOT NULL,
    ReceivedAt          DATETIME NOT NULL DEFAULT GETDATE(),
    Status              NVARCHAR(20) DEFAULT 'RECEIVED',
    WireReference       NVARCHAR(100),
    BeneficiaryBank     NVARCHAR(100),
    BeneficiaryName     NVARCHAR(200),
    Amount              DECIMAL(18,2),
    Currency            NVARCHAR(3) DEFAULT 'USD',
    ExchangeRate        DECIMAL(18,6),
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE RegulatoryFeeds (
    FeedID              INT IDENTITY(1,1) PRIMARY KEY,
    FeedType            NVARCHAR(20) NOT NULL,
    FilePath            NVARCHAR(500) NOT NULL,
    ReportingPeriod     DATETIME NOT NULL,
    Status              NVARCHAR(20) DEFAULT 'PENDING',
    SubmittedAt         DATETIME NULL,
    AcknowledgedAt      DATETIME NULL,
    AcknowledgmentRef   NVARCHAR(100),
    RecordCount         INT DEFAULT 0,
    RejectionReason     NVARCHAR(500),
    RegulatoryAgency    NVARCHAR(100),
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

PRINT 'File staging tables created successfully.';
GO
