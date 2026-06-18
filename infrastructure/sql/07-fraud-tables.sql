-- Fraud Tables: FraudRules, FraudAlerts, FraudScores
-- Section 2.6 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE FraudRules (
    RuleID              INT IDENTITY(1,1) PRIMARY KEY,
    RuleName            NVARCHAR(100) NOT NULL,
    RuleDescription     NVARCHAR(500),
    RuleExpression      NVARCHAR(MAX),
    Severity            NVARCHAR(10) NOT NULL,
    IsActive            BIT DEFAULT 1,
    ThresholdAmount     DECIMAL(18,2) NULL,
    TimeWindowMinutes   INT NULL,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE FraudAlerts (
    AlertID             INT IDENTITY(1,1) PRIMARY KEY,
    TransactionID       BIGINT NULL REFERENCES Transactions(TransactionID),
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    RuleID              INT NULL REFERENCES FraudRules(RuleID),
    AlertType           NVARCHAR(50) NOT NULL,
    Severity            NVARCHAR(10) NOT NULL,
    Status              NVARCHAR(20) DEFAULT 'New',
    Description         NVARCHAR(MAX),
    AssignedTo          NVARCHAR(100),
    ResolvedDate        DATETIME NULL,
    ResolutionNotes     NVARCHAR(MAX),
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE FraudScores (
    ScoreID             INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    TransactionID       BIGINT NULL REFERENCES Transactions(TransactionID),
    Score               DECIMAL(5,2) NOT NULL,
    ModelVersion        NVARCHAR(20),
    Factors             NVARCHAR(MAX),
    EvaluatedDate       DATETIME DEFAULT GETDATE()
);
GO

PRINT 'Fraud tables created successfully.';
GO
