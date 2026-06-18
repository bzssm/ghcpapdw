-- Loan Tables: LoanProducts, LoanApplications, LoanDecisions, LoanPayments
-- Section 2.2 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE LoanProducts (
    LoanProductID       INT IDENTITY(1,1) PRIMARY KEY,
    ProductName         NVARCHAR(100) NOT NULL,
    ProductCode         NVARCHAR(20) NOT NULL UNIQUE,
    MinAmount           DECIMAL(18,2) NOT NULL,
    MaxAmount           DECIMAL(18,2) NOT NULL,
    MinTermMonths       INT NOT NULL,
    MaxTermMonths       INT NOT NULL,
    BaseInterestRate    DECIMAL(5,4) NOT NULL,
    RequiresCollateral  BIT DEFAULT 0,
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE LoanApplications (
    ApplicationID       INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    LoanProductID       INT NOT NULL REFERENCES LoanProducts(LoanProductID),
    RequestedAmount     DECIMAL(18,2) NOT NULL,
    ApprovedAmount      DECIMAL(18,2) NULL,
    InterestRate        DECIMAL(5,4) NULL,
    TermMonths          INT NOT NULL,
    Purpose             NVARCHAR(500),
    Status              NVARCHAR(30) DEFAULT 'Submitted',
    ApplicationDate     DATETIME DEFAULT GETDATE(),
    DecisionDate        DATETIME NULL,
    FundedDate          DATETIME NULL,
    DecisionNotes       NVARCHAR(MAX),
    AssignedOfficer     NVARCHAR(100),
    LoanAccountID       INT NULL REFERENCES Accounts(AccountID),
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE LoanDecisions (
    DecisionID          INT IDENTITY(1,1) PRIMARY KEY,
    ApplicationID       INT NOT NULL REFERENCES LoanApplications(ApplicationID),
    DecisionType        NVARCHAR(20) NOT NULL,
    DecisionBy          NVARCHAR(100),
    DecisionDate        DATETIME DEFAULT GETDATE(),
    Reason              NVARCHAR(MAX),
    CreditScoreAtTime   INT,
    RiskLevel           NVARCHAR(10),
    Conditions          NVARCHAR(MAX)
);
GO

CREATE TABLE LoanPayments (
    PaymentID           INT IDENTITY(1,1) PRIMARY KEY,
    ApplicationID       INT NOT NULL REFERENCES LoanApplications(ApplicationID),
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    PaymentAmount       DECIMAL(18,2) NOT NULL,
    PrincipalAmount     DECIMAL(18,2) NOT NULL,
    InterestAmount      DECIMAL(18,2) NOT NULL,
    PaymentDate         DATETIME DEFAULT GETDATE(),
    DueDate             DATETIME NOT NULL,
    Status              NVARCHAR(20) DEFAULT 'Pending',
    PaymentMethod       NVARCHAR(30),
    ConfirmationNumber  NVARCHAR(50),
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

PRINT 'Loan tables created successfully.';
GO
