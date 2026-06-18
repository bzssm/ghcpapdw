-- Core Banking Tables: AccountTypes, Customers, Accounts
-- Section 2.1 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE AccountTypes (
    AccountTypeID       INT IDENTITY(1,1) PRIMARY KEY,
    TypeName            NVARCHAR(50) NOT NULL,
    Description         NVARCHAR(255),
    InterestRate        DECIMAL(5,4) DEFAULT 0,
    MinimumBalance      DECIMAL(18,2) DEFAULT 0,
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Customers (
    CustomerID          INT IDENTITY(1,1) PRIMARY KEY,
    FirstName           NVARCHAR(100) NOT NULL,
    LastName            NVARCHAR(100) NOT NULL,
    MiddleName          NVARCHAR(100),
    DateOfBirth         DATE NOT NULL,
    SSN                 NVARCHAR(11) NOT NULL,
    Email               NVARCHAR(255),
    Phone               NVARCHAR(20),
    AddressLine1        NVARCHAR(255),
    AddressLine2        NVARCHAR(255),
    City                NVARCHAR(100),
    State               NVARCHAR(2),
    ZipCode             NVARCHAR(10),
    Country             NVARCHAR(50) DEFAULT 'US',
    CustomerSince       DATETIME DEFAULT GETDATE(),
    Status              NVARCHAR(20) DEFAULT 'Active',
    RiskRating          NVARCHAR(10) DEFAULT 'Medium',
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE(),
    CreatedBy           NVARCHAR(100),
    ModifiedBy          NVARCHAR(100)
);
GO

CREATE TABLE Accounts (
    AccountID           INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    AccountTypeID       INT NOT NULL REFERENCES AccountTypes(AccountTypeID),
    AccountNumber       NVARCHAR(20) NOT NULL UNIQUE,
    Balance             DECIMAL(18,2) DEFAULT 0,
    AvailableBalance    DECIMAL(18,2) DEFAULT 0,
    Status              NVARCHAR(20) DEFAULT 'Active',
    OpenDate            DATETIME DEFAULT GETDATE(),
    CloseDate           DATETIME NULL,
    LastActivityDate    DATETIME DEFAULT GETDATE(),
    OverdraftLimit      DECIMAL(18,2) DEFAULT 0,
    InterestAccrued     DECIMAL(18,2) DEFAULT 0,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);
GO

PRINT 'Core banking tables created successfully.';
GO
