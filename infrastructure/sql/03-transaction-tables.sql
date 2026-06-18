-- Transaction Tables: TransactionTypes, Transactions, TransactionArchive
-- Section 2.3 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE TransactionTypes (
    TransactionTypeID   INT IDENTITY(1,1) PRIMARY KEY,
    TypeCode            NVARCHAR(10) NOT NULL UNIQUE,
    TypeName            NVARCHAR(50) NOT NULL,
    Description         NVARCHAR(255),
    IsDebit             BIT NOT NULL,
    IsActive            BIT DEFAULT 1
);
GO

CREATE TABLE Transactions (
    TransactionID       BIGINT IDENTITY(1,1) PRIMARY KEY,
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    TransactionTypeID   INT NOT NULL REFERENCES TransactionTypes(TransactionTypeID),
    Amount              DECIMAL(18,2) NOT NULL,
    BalanceAfter        DECIMAL(18,2) NOT NULL,
    Description         NVARCHAR(500),
    ReferenceNumber     NVARCHAR(50),
    TransactionDate     DATETIME DEFAULT GETDATE(),
    PostDate            DATETIME NULL,
    Status              NVARCHAR(20) DEFAULT 'Pending',
    Channel             NVARCHAR(20),
    CounterpartyAccount NVARCHAR(50) NULL,
    CheckNumber         NVARCHAR(20) NULL,
    Memo                NVARCHAR(255),
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE TransactionArchive (
    ArchiveID           BIGINT IDENTITY(1,1) PRIMARY KEY,
    TransactionID       BIGINT NOT NULL,
    AccountID           INT NOT NULL,
    TransactionTypeID   INT NOT NULL,
    Amount              DECIMAL(18,2) NOT NULL,
    BalanceAfter        DECIMAL(18,2) NOT NULL,
    Description         NVARCHAR(500),
    ReferenceNumber     NVARCHAR(50),
    TransactionDate     DATETIME,
    PostDate            DATETIME,
    Status              NVARCHAR(20),
    Channel             NVARCHAR(20),
    ArchivedDate        DATETIME DEFAULT GETDATE(),
    ArchiveReason       NVARCHAR(50) DEFAULT 'Aging'
);
GO

PRINT 'Transaction tables created successfully.';
GO
