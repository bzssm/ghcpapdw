-- KYC and Compliance Tables: KYCRecords, KYCDocuments, ComplianceChecks, ComplianceReports
-- Section 2.5 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE KYCRecords (
    KYCID               INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    VerificationLevel   NVARCHAR(20) DEFAULT 'Basic',
    Status              NVARCHAR(20) DEFAULT 'Pending',
    VerifiedDate        DATETIME NULL,
    ExpiryDate          DATETIME NULL,
    VerifiedBy          NVARCHAR(100),
    Notes               NVARCHAR(MAX),
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE KYCDocuments (
    DocumentID          INT IDENTITY(1,1) PRIMARY KEY,
    KYCID               INT NOT NULL REFERENCES KYCRecords(KYCID),
    DocumentType        NVARCHAR(50) NOT NULL,
    DocumentNumber      NVARCHAR(100),
    IssuedDate          DATETIME,
    ExpiryDate          DATETIME,
    FilePath            NVARCHAR(500),
    VerificationStatus  NVARCHAR(20) DEFAULT 'Pending',
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE ComplianceChecks (
    CheckID             INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    CheckType           NVARCHAR(50) NOT NULL,
    Result              NVARCHAR(20) NOT NULL,
    Details             NVARCHAR(MAX),
    CheckedDate         DATETIME DEFAULT GETDATE(),
    CheckedBy           NVARCHAR(100),
    ExternalRefID       NVARCHAR(100)
);
GO

CREATE TABLE ComplianceReports (
    ReportID            INT IDENTITY(1,1) PRIMARY KEY,
    ReportType          NVARCHAR(50) NOT NULL,
    CustomerID          INT NULL REFERENCES Customers(CustomerID),
    FilingDate          DATETIME DEFAULT GETDATE(),
    Status              NVARCHAR(20) DEFAULT 'Draft',
    ReportData          NVARCHAR(MAX),
    FiledBy             NVARCHAR(100),
    RegulatoryBody      NVARCHAR(100),
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

PRINT 'KYC and compliance tables created successfully.';
GO
