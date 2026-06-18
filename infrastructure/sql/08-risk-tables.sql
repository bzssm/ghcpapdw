-- Risk Tables: CreditScores, RiskFactors, RiskAssessments
-- Section 2.7 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE CreditScores (
    CreditScoreID       INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    Score               INT NOT NULL,
    ScoreSource         NVARCHAR(50),
    ReportDate          DATETIME DEFAULT GETDATE(),
    ExpiryDate          DATETIME,
    RawReportData       NVARCHAR(MAX),
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE RiskFactors (
    FactorID            INT IDENTITY(1,1) PRIMARY KEY,
    FactorName          NVARCHAR(100) NOT NULL,
    FactorCode          NVARCHAR(20) NOT NULL UNIQUE,
    Weight              DECIMAL(5,2) DEFAULT 1.0,
    Category            NVARCHAR(50),
    Description         NVARCHAR(500),
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE RiskAssessments (
    AssessmentID        INT IDENTITY(1,1) PRIMARY KEY,
    ApplicationID       INT NOT NULL REFERENCES LoanApplications(ApplicationID),
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    OverallRiskScore    DECIMAL(5,2) NOT NULL,
    RiskLevel           NVARCHAR(10) NOT NULL,
    DebtToIncomeRatio   DECIMAL(5,2) NULL,
    LoanToValueRatio    DECIMAL(5,2) NULL,
    FactorBreakdown     NVARCHAR(MAX),
    Recommendation      NVARCHAR(20),
    AssessedBy          NVARCHAR(100) DEFAULT 'SYSTEM',
    AssessedDate        DATETIME DEFAULT GETDATE(),
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

PRINT 'Risk tables created successfully.';
GO
