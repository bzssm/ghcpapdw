-- Payment Tables: PaymentMethods, Payments, PaymentBatches
-- Section 2.4 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE PaymentMethods (
    PaymentMethodID     INT IDENTITY(1,1) PRIMARY KEY,
    MethodName          NVARCHAR(50) NOT NULL,
    MethodCode          NVARCHAR(10) NOT NULL UNIQUE,
    ProcessingFee       DECIMAL(18,2) DEFAULT 0,
    MaxDailyLimit       DECIMAL(18,2),
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Payments (
    PaymentID           INT IDENTITY(1,1) PRIMARY KEY,
    SourceAccountID     INT NOT NULL REFERENCES Accounts(AccountID),
    DestinationAccount  NVARCHAR(50) NOT NULL,
    PaymentMethodID     INT NOT NULL REFERENCES PaymentMethods(PaymentMethodID),
    Amount              DECIMAL(18,2) NOT NULL,
    Currency            NVARCHAR(3) DEFAULT 'USD',
    Status              NVARCHAR(20) DEFAULT 'Initiated',
    ScheduledDate       DATETIME,
    ProcessedDate       DATETIME NULL,
    ReferenceNumber     NVARCHAR(50),
    PayeeName           NVARCHAR(200),
    PayeeRoutingNumber  NVARCHAR(20),
    Memo                NVARCHAR(255),
    RetryCount          INT DEFAULT 0,
    FailureReason       NVARCHAR(500) NULL,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE PaymentBatches (
    BatchID             INT IDENTITY(1,1) PRIMARY KEY,
    BatchName           NVARCHAR(100),
    BatchType           NVARCHAR(30),
    TotalAmount         DECIMAL(18,2),
    PaymentCount        INT DEFAULT 0,
    Status              NVARCHAR(20) DEFAULT 'Created',
    SubmittedBy         NVARCHAR(100),
    SubmittedDate       DATETIME DEFAULT GETDATE(),
    ProcessedDate       DATETIME NULL,
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

PRINT 'Payment tables created successfully.';
GO
