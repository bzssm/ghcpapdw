# Zava Bank — Database Topology

> **Author:** expert_database (Livingston)
> **Date:** 2026-05-12
> **Status:** Design — Phase 1

---

## 1. Database Architecture Overview

Zava Bank runs on a **single shared SQL Server instance** — `ZavaBankDB`. Every service in the portfolio connects to this one database. This is era-appropriate: in the 2005–2015 timeframe, the "shared database" pattern was the default integration strategy. Services didn't own their data; they all read and wrote the same tables, often stepping on each other.

<!-- TODO: expert_mermaid will add Mermaid diagram here — shared SQL Server with 12 domain groups (Core Banking, Loans, Fraud, KYC/Compliance, Transactions, Payments, Risk, Notifications, Audit, Currency, Statements, Alerts) and connections from .NET Apps (ADO.NET), Java Apps (JDBC), Background Workers, Reports (SSRS), and Admin Tools -->

### Key Characteristics

| Trait | Detail |
|---|---|
| **Instance** | Single SQL Server 2019 (Linux, Docker) |
| **Database** | `ZavaBankDB` — one database for everything |
| **Integration** | Shared database — no service boundaries at the data layer |
| **Auth** | SQL authentication (`sa` / app-specific logins) |
| **Collation** | `SQL_Latin1_General_CP1_CI_AS` |
| **Recovery Model** | Simple (it's demoware) |
| **Port** | 1433 (default) |

### Repository & Folder Layout

Each of the 20+ application nodes lives in its **own folder off the repo root** (e.g., `zava-loan-portal/`, `zava-pay-gateway/`). Each app folder will eventually become its own repository. The database infrastructure — SQL init scripts, schema, stored procedures, and seed data — lives in a shared **`infrastructure/sql/`** folder at the root.

<!-- TODO: expert_mermaid will add Mermaid diagram here — repo root folder layout showing infrastructure/sql/ and 20+ app folders -->

**Folders at repo root:**

- `infrastructure/sql/` — all SQL init scripts (`01-create-database.sql` through `50-seed-demo-data.sql`) plus `init-db.sh`
- `zava-loan-portal/` — ASP.NET Web Forms (has its own `Web.config` with connection string)
- `zava-account-manager/` — .NET Framework (has its own `app.config` with connection string)
- `zava-risk-engine/` — WCF (has its own `Web.config` with connection string)
- `zava-pay-gateway/` — Java Struts 1.x (has its own `jdbc.properties`)
- `zava-ledger/` — Java 17 (has its own `jdbc.properties`)
- `zava-fraud-detector/` — Java Struts 2.x (has its own `jdbc.properties`)
- `zava-kyc-service/` — Java Servlets (has its own `jdbc.properties`)
- *(20+ app folders total)*
- `docker-compose.yml`

**Key rules:**
- **Database infrastructure is centralized** — `infrastructure/sql/` is the single source of truth for schema, procs, and seed data. No SQL DDL scripts live inside individual app folders.
- **Connection strings are per-app** — each app folder contains its own config file (`web.config`, `app.config`, or `jdbc.properties`) with the connection string. They all point to the same `ZavaBankDB` instance but each app owns its own config.
- **Data access code is per-app** — ADO.NET helpers, JDBC utility classes, EF6 `.edmx` files, and `SqlDataSource` controls all live inside their respective app folders. There is no shared data access library. Every app has its own copy of database helper code — this is intentional duplication (era-appropriate, and a modernization pain point).

### Service-to-Database Connections

Every service connects directly. There is no API gateway, no data access layer service, no abstraction. Each app has its own connection config and its own data access code — duplicated across the portfolio. This is the pain point the modernization story highlights.

| Service | Technology | Data Access | Tables Touched |
|---|---|---|---|
| ZavaLoan Portal | ASP.NET Web Forms | SqlDataSource + ADO.NET | Customers, Accounts, LoanApplications, LoanProducts |
| ZavaAccount Manager | .NET Framework WinForms/Web | Entity Framework 6 | Customers, Accounts, AccountTypes, Transactions |
| ZavaRisk Engine | WCF Service | ADO.NET (SqlCommand) | CreditScores, RiskAssessments, RiskFactors, LoanApplications |
| ZavaNotify | .NET Console App | ADO.NET (SqlCommand) | NotificationQueue, NotificationTemplates, NotificationLog |
| ZavaPay Gateway | Java Struts 1.x | JDBC (PreparedStatement) | Payments, PaymentMethods, PaymentBatches, Transactions |
| ZavaLedger | Java 17 | JDBC (PreparedStatement) | Accounts, Transactions, TransactionArchive, ExchangeRates |
| ZavaFraud Detector | Java Struts 2.x | JDBC (PreparedStatement) | FraudAlerts, FraudRules, FraudScores, Transactions |
| ZavaKYC Service | Java Servlets | JDBC (PreparedStatement) | KYCRecords, KYCDocuments, ComplianceChecks, ComplianceReports |
| ZavaStatement Generator | .NET Console App | ADO.NET | StatementRequests, StatementArchive, Transactions, Accounts |
| ZavaAlert Service | .NET Console App | ADO.NET | AccountAlerts, AlertRules, AlertHistory, Accounts |
| ZavaCurrency Service | Java Servlet | JDBC | ExchangeRates, CurrencyPairs |
| ZavaAudit Logger | .NET Console App | ADO.NET | AuditLog, AuditActions |
| ZavaBatch Processor | .NET Console App | ADO.NET | PaymentBatches, Transactions, TransactionArchive |
| ZavaReport Engine | .NET Console App | ADO.NET | All tables (read-only for reporting) |
| ZavaQueue Processor | .NET Console App | ADO.NET + MSMQ | NotificationQueue, PaymentBatches |
| ZavaAdmin Portal | ASP.NET Web Forms | SqlDataSource + ADO.NET | All tables (admin CRUD) |

---

## 2. Schema Design

All tables live in the `dbo` schema (era-appropriate — nobody used custom schemas in 2008).

### 2.1 Core Banking

```sql
-- The heart of the bank: who are our customers and what accounts do they have?

CREATE TABLE AccountTypes (
    AccountTypeID       INT IDENTITY(1,1) PRIMARY KEY,
    TypeName            NVARCHAR(50) NOT NULL,       -- 'Checking', 'Savings', 'Loan', 'CD', 'MoneyMarket'
    Description         NVARCHAR(255),
    InterestRate        DECIMAL(5,4) DEFAULT 0,       -- e.g., 0.0150 = 1.5%
    MinimumBalance      DECIMAL(18,2) DEFAULT 0,
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);

CREATE TABLE Customers (
    CustomerID          INT IDENTITY(1,1) PRIMARY KEY,
    FirstName           NVARCHAR(100) NOT NULL,
    LastName            NVARCHAR(100) NOT NULL,
    MiddleName          NVARCHAR(100),
    DateOfBirth         DATE NOT NULL,
    SSN                 NVARCHAR(11) NOT NULL,        -- stored as plaintext (legacy!)
    Email               NVARCHAR(255),
    Phone               NVARCHAR(20),
    AddressLine1        NVARCHAR(255),
    AddressLine2        NVARCHAR(255),
    City                NVARCHAR(100),
    State               NVARCHAR(2),
    ZipCode             NVARCHAR(10),
    Country             NVARCHAR(50) DEFAULT 'US',
    CustomerSince       DATETIME DEFAULT GETDATE(),
    Status              NVARCHAR(20) DEFAULT 'Active', -- Active, Suspended, Closed
    RiskRating          NVARCHAR(10) DEFAULT 'Medium', -- Low, Medium, High
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE(),
    CreatedBy           NVARCHAR(100),
    ModifiedBy          NVARCHAR(100)
);

CREATE TABLE Accounts (
    AccountID           INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    AccountTypeID       INT NOT NULL REFERENCES AccountTypes(AccountTypeID),
    AccountNumber       NVARCHAR(20) NOT NULL UNIQUE,  -- e.g., '1001-0001-2345'
    Balance             DECIMAL(18,2) DEFAULT 0,
    AvailableBalance    DECIMAL(18,2) DEFAULT 0,
    Status              NVARCHAR(20) DEFAULT 'Active', -- Active, Frozen, Closed, Overdrawn
    OpenDate            DATETIME DEFAULT GETDATE(),
    CloseDate           DATETIME NULL,
    LastActivityDate    DATETIME DEFAULT GETDATE(),
    OverdraftLimit      DECIMAL(18,2) DEFAULT 0,
    InterestAccrued     DECIMAL(18,2) DEFAULT 0,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);

CREATE INDEX IX_Accounts_CustomerID ON Accounts(CustomerID);
CREATE INDEX IX_Accounts_AccountNumber ON Accounts(AccountNumber);
```

### 2.2 Loans

```sql
CREATE TABLE LoanProducts (
    LoanProductID       INT IDENTITY(1,1) PRIMARY KEY,
    ProductName         NVARCHAR(100) NOT NULL,       -- 'Personal Loan', 'Mortgage', 'Auto Loan', 'Business Loan'
    ProductCode         NVARCHAR(20) NOT NULL UNIQUE,
    MinAmount           DECIMAL(18,2) NOT NULL,
    MaxAmount           DECIMAL(18,2) NOT NULL,
    MinTermMonths       INT NOT NULL,
    MaxTermMonths       INT NOT NULL,
    BaseInterestRate    DECIMAL(5,4) NOT NULL,         -- base APR
    RequiresCollateral  BIT DEFAULT 0,
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE LoanApplications (
    ApplicationID       INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    LoanProductID       INT NOT NULL REFERENCES LoanProducts(LoanProductID),
    RequestedAmount     DECIMAL(18,2) NOT NULL,
    ApprovedAmount      DECIMAL(18,2) NULL,
    InterestRate        DECIMAL(5,4) NULL,
    TermMonths          INT NOT NULL,
    Purpose             NVARCHAR(500),
    Status              NVARCHAR(30) DEFAULT 'Submitted', -- Submitted, UnderReview, Approved, Denied, Funded, Closed
    ApplicationDate     DATETIME DEFAULT GETDATE(),
    DecisionDate        DATETIME NULL,
    FundedDate          DATETIME NULL,
    DecisionNotes       NVARCHAR(MAX),
    AssignedOfficer     NVARCHAR(100),
    LoanAccountID       INT NULL REFERENCES Accounts(AccountID), -- linked account once funded
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);

CREATE TABLE LoanDecisions (
    DecisionID          INT IDENTITY(1,1) PRIMARY KEY,
    ApplicationID       INT NOT NULL REFERENCES LoanApplications(ApplicationID),
    DecisionType        NVARCHAR(20) NOT NULL,         -- 'Approve', 'Deny', 'Escalate', 'ConditionalApprove'
    DecisionBy          NVARCHAR(100),
    DecisionDate        DATETIME DEFAULT GETDATE(),
    Reason              NVARCHAR(MAX),
    CreditScoreAtTime   INT,
    RiskLevel           NVARCHAR(10),                  -- Low, Medium, High
    Conditions          NVARCHAR(MAX)                  -- JSON-ish text for conditional approvals
);

CREATE TABLE LoanPayments (
    PaymentID           INT IDENTITY(1,1) PRIMARY KEY,
    ApplicationID       INT NOT NULL REFERENCES LoanApplications(ApplicationID),
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    PaymentAmount       DECIMAL(18,2) NOT NULL,
    PrincipalAmount     DECIMAL(18,2) NOT NULL,
    InterestAmount      DECIMAL(18,2) NOT NULL,
    PaymentDate         DATETIME DEFAULT GETDATE(),
    DueDate             DATETIME NOT NULL,
    Status              NVARCHAR(20) DEFAULT 'Pending', -- Pending, Completed, Late, Missed, Reversed
    PaymentMethod       NVARCHAR(30),                   -- ACH, Wire, Check, Online
    ConfirmationNumber  NVARCHAR(50),
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE INDEX IX_LoanApplications_CustomerID ON LoanApplications(CustomerID);
CREATE INDEX IX_LoanPayments_ApplicationID ON LoanPayments(ApplicationID);
```

### 2.3 Transactions

```sql
CREATE TABLE TransactionTypes (
    TransactionTypeID   INT IDENTITY(1,1) PRIMARY KEY,
    TypeCode            NVARCHAR(10) NOT NULL UNIQUE,  -- 'DEP', 'WDR', 'TRF', 'FEE', 'INT', 'PMT', 'ADJ'
    TypeName            NVARCHAR(50) NOT NULL,
    Description         NVARCHAR(255),
    IsDebit             BIT NOT NULL,                  -- 1 = money out, 0 = money in
    IsActive            BIT DEFAULT 1
);

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
    Status              NVARCHAR(20) DEFAULT 'Pending', -- Pending, Posted, Reversed, Failed
    Channel             NVARCHAR(20),                   -- Online, ATM, Branch, Mobile, Wire
    CounterpartyAccount NVARCHAR(20) NULL,              -- for transfers
    CheckNumber         NVARCHAR(20) NULL,
    Memo                NVARCHAR(255),
    CreatedDate         DATETIME DEFAULT GETDATE()
);

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

CREATE INDEX IX_Transactions_AccountID ON Transactions(AccountID);
CREATE INDEX IX_Transactions_TransactionDate ON Transactions(TransactionDate);
CREATE INDEX IX_Transactions_ReferenceNumber ON Transactions(ReferenceNumber);
```

### 2.4 Payments

```sql
CREATE TABLE PaymentMethods (
    PaymentMethodID     INT IDENTITY(1,1) PRIMARY KEY,
    MethodName          NVARCHAR(50) NOT NULL,         -- 'ACH', 'Wire', 'Check', 'InternalTransfer', 'Debit'
    MethodCode          NVARCHAR(10) NOT NULL UNIQUE,
    ProcessingFee       DECIMAL(18,2) DEFAULT 0,
    MaxDailyLimit       DECIMAL(18,2),
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE Payments (
    PaymentID           INT IDENTITY(1,1) PRIMARY KEY,
    SourceAccountID     INT NOT NULL REFERENCES Accounts(AccountID),
    DestinationAccount  NVARCHAR(50) NOT NULL,         -- could be internal or external
    PaymentMethodID     INT NOT NULL REFERENCES PaymentMethods(PaymentMethodID),
    Amount              DECIMAL(18,2) NOT NULL,
    Currency            NVARCHAR(3) DEFAULT 'USD',
    Status              NVARCHAR(20) DEFAULT 'Initiated', -- Initiated, Processing, Completed, Failed, Reversed
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

CREATE TABLE PaymentBatches (
    BatchID             INT IDENTITY(1,1) PRIMARY KEY,
    BatchName           NVARCHAR(100),
    BatchType           NVARCHAR(30),                  -- 'ACHBatch', 'WireBatch', 'PayrollBatch'
    TotalAmount         DECIMAL(18,2),
    PaymentCount        INT DEFAULT 0,
    Status              NVARCHAR(20) DEFAULT 'Created', -- Created, Processing, Completed, PartialFailure, Failed
    SubmittedBy         NVARCHAR(100),
    SubmittedDate       DATETIME DEFAULT GETDATE(),
    ProcessedDate       DATETIME NULL,
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE INDEX IX_Payments_SourceAccountID ON Payments(SourceAccountID);
CREATE INDEX IX_Payments_Status ON Payments(Status);
```

### 2.5 KYC / Compliance

```sql
CREATE TABLE KYCRecords (
    KYCID               INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    VerificationLevel   NVARCHAR(20) DEFAULT 'Basic',  -- Basic, Enhanced, FullDueDiligence
    Status              NVARCHAR(20) DEFAULT 'Pending', -- Pending, Verified, Failed, Expired
    VerifiedDate        DATETIME NULL,
    ExpiryDate          DATETIME NULL,
    VerifiedBy          NVARCHAR(100),
    Notes               NVARCHAR(MAX),
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);

CREATE TABLE KYCDocuments (
    DocumentID          INT IDENTITY(1,1) PRIMARY KEY,
    KYCID               INT NOT NULL REFERENCES KYCRecords(KYCID),
    DocumentType        NVARCHAR(50) NOT NULL,         -- 'Passport', 'DriversLicense', 'UtilityBill', 'BankStatement'
    DocumentNumber      NVARCHAR(100),
    IssuedDate          DATETIME,
    ExpiryDate          DATETIME,
    FilePath            NVARCHAR(500),                 -- UNC path to scanned document (legacy file share)
    VerificationStatus  NVARCHAR(20) DEFAULT 'Pending',
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE ComplianceChecks (
    CheckID             INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    CheckType           NVARCHAR(50) NOT NULL,         -- 'OFAC', 'PEP', 'AML', 'SanctionsList'
    Result              NVARCHAR(20) NOT NULL,         -- 'Clear', 'Hit', 'PendingReview'
    Details             NVARCHAR(MAX),
    CheckedDate         DATETIME DEFAULT GETDATE(),
    CheckedBy           NVARCHAR(100),                 -- system or officer name
    ExternalRefID       NVARCHAR(100)                  -- third-party reference
);

CREATE TABLE ComplianceReports (
    ReportID            INT IDENTITY(1,1) PRIMARY KEY,
    ReportType          NVARCHAR(50) NOT NULL,         -- 'SAR', 'CTR', 'AnnualReview'
    CustomerID          INT NULL REFERENCES Customers(CustomerID),
    FilingDate          DATETIME DEFAULT GETDATE(),
    Status              NVARCHAR(20) DEFAULT 'Draft',  -- Draft, Filed, Acknowledged
    ReportData          NVARCHAR(MAX),                 -- XML blob (era-appropriate)
    FiledBy             NVARCHAR(100),
    RegulatoryBody      NVARCHAR(100),                 -- 'FinCEN', 'OCC'
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE INDEX IX_KYCRecords_CustomerID ON KYCRecords(CustomerID);
CREATE INDEX IX_ComplianceChecks_CustomerID ON ComplianceChecks(CustomerID);
```

### 2.6 Fraud

```sql
CREATE TABLE FraudRules (
    RuleID              INT IDENTITY(1,1) PRIMARY KEY,
    RuleName            NVARCHAR(100) NOT NULL,
    RuleDescription     NVARCHAR(500),
    RuleExpression      NVARCHAR(MAX),                 -- SQL-based rule expression
    Severity            NVARCHAR(10) NOT NULL,         -- Low, Medium, High, Critical
    IsActive            BIT DEFAULT 1,
    ThresholdAmount     DECIMAL(18,2) NULL,
    TimeWindowMinutes   INT NULL,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);

CREATE TABLE FraudAlerts (
    AlertID             INT IDENTITY(1,1) PRIMARY KEY,
    TransactionID       BIGINT NULL REFERENCES Transactions(TransactionID),
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    RuleID              INT NULL REFERENCES FraudRules(RuleID),
    AlertType           NVARCHAR(50) NOT NULL,         -- 'UnusualAmount', 'VelocityCheck', 'GeographicAnomaly', 'PatternMatch'
    Severity            NVARCHAR(10) NOT NULL,
    Status              NVARCHAR(20) DEFAULT 'New',    -- New, Investigating, Confirmed, FalsePositive, Resolved
    Description         NVARCHAR(MAX),
    AssignedTo          NVARCHAR(100),
    ResolvedDate        DATETIME NULL,
    ResolutionNotes     NVARCHAR(MAX),
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);

CREATE TABLE FraudScores (
    ScoreID             INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    TransactionID       BIGINT NULL REFERENCES Transactions(TransactionID),
    Score               DECIMAL(5,2) NOT NULL,         -- 0.00 to 100.00
    ModelVersion        NVARCHAR(20),                  -- 'RuleEngine_v2.1'
    Factors             NVARCHAR(MAX),                 -- pipe-delimited factor list (legacy)
    EvaluatedDate       DATETIME DEFAULT GETDATE()
);

CREATE INDEX IX_FraudAlerts_CustomerID ON FraudAlerts(CustomerID);
CREATE INDEX IX_FraudAlerts_Status ON FraudAlerts(Status);
CREATE INDEX IX_FraudScores_CustomerID ON FraudScores(CustomerID);
```

### 2.7 Risk

```sql
CREATE TABLE CreditScores (
    CreditScoreID       INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    Score               INT NOT NULL,                  -- 300-850
    ScoreSource         NVARCHAR(50),                  -- 'Experian', 'Equifax', 'TransUnion', 'Internal'
    ReportDate          DATETIME DEFAULT GETDATE(),
    ExpiryDate          DATETIME,
    RawReportData       NVARCHAR(MAX),                 -- XML blob from bureau
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE RiskFactors (
    FactorID            INT IDENTITY(1,1) PRIMARY KEY,
    FactorName          NVARCHAR(100) NOT NULL,
    FactorCode          NVARCHAR(20) NOT NULL UNIQUE,  -- 'DTI', 'LTV', 'EMP_HISTORY', 'COLL_VALUE'
    Weight              DECIMAL(5,2) DEFAULT 1.0,
    Category            NVARCHAR(50),                  -- 'Financial', 'Employment', 'Collateral', 'Behavioral'
    Description         NVARCHAR(500),
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE RiskAssessments (
    AssessmentID        INT IDENTITY(1,1) PRIMARY KEY,
    ApplicationID       INT NOT NULL REFERENCES LoanApplications(ApplicationID),
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    OverallRiskScore    DECIMAL(5,2) NOT NULL,         -- 0-100, lower is better
    RiskLevel           NVARCHAR(10) NOT NULL,         -- Low, Medium, High, Critical
    DebtToIncomeRatio   DECIMAL(5,2) NULL,
    LoanToValueRatio    DECIMAL(5,2) NULL,
    FactorBreakdown     NVARCHAR(MAX),                 -- pipe-delimited factor=score pairs
    Recommendation      NVARCHAR(20),                  -- 'Approve', 'Deny', 'ManualReview'
    AssessedBy          NVARCHAR(100) DEFAULT 'SYSTEM',
    AssessedDate        DATETIME DEFAULT GETDATE(),
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE INDEX IX_CreditScores_CustomerID ON CreditScores(CustomerID);
CREATE INDEX IX_RiskAssessments_ApplicationID ON RiskAssessments(ApplicationID);
```

### 2.8 Notifications

```sql
CREATE TABLE NotificationTemplates (
    TemplateID          INT IDENTITY(1,1) PRIMARY KEY,
    TemplateName        NVARCHAR(100) NOT NULL,
    TemplateCode        NVARCHAR(30) NOT NULL UNIQUE,  -- 'LOAN_APPROVED', 'PAYMENT_DUE', 'FRAUD_ALERT'
    Channel             NVARCHAR(20) NOT NULL,         -- 'Email', 'SMS', 'Letter'
    Subject             NVARCHAR(255),
    BodyTemplate        NVARCHAR(MAX),                 -- with {{placeholders}}
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE NotificationQueue (
    QueueID             INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    TemplateID          INT NOT NULL REFERENCES NotificationTemplates(TemplateID),
    Channel             NVARCHAR(20) NOT NULL,
    Recipient           NVARCHAR(255) NOT NULL,        -- email or phone
    Subject             NVARCHAR(255),
    Body                NVARCHAR(MAX),
    Status              NVARCHAR(20) DEFAULT 'Queued',  -- Queued, Sending, Sent, Failed, Cancelled
    Priority            INT DEFAULT 5,                  -- 1=highest, 10=lowest
    ScheduledDate       DATETIME DEFAULT GETDATE(),
    AttemptCount        INT DEFAULT 0,
    MaxAttempts         INT DEFAULT 3,
    LastAttemptDate     DATETIME NULL,
    ErrorMessage        NVARCHAR(500) NULL,
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE NotificationLog (
    LogID               INT IDENTITY(1,1) PRIMARY KEY,
    QueueID             INT NULL REFERENCES NotificationQueue(QueueID),
    CustomerID          INT NOT NULL,
    Channel             NVARCHAR(20),
    Recipient           NVARCHAR(255),
    Status              NVARCHAR(20),                  -- Sent, Failed, Bounced
    SentDate            DATETIME DEFAULT GETDATE(),
    ResponseCode        NVARCHAR(50),
    ErrorDetails        NVARCHAR(500)
);

CREATE INDEX IX_NotificationQueue_Status ON NotificationQueue(Status);
CREATE INDEX IX_NotificationQueue_ScheduledDate ON NotificationQueue(ScheduledDate);
```

### 2.9 File Staging

```sql
-- File-based integration: incoming file batches from ZavaFile Ingestion, ZavaACH Processor, ZavaCheck Scanner
-- Tracks file imports, check images, wire confirmations, and regulatory feeds

CREATE TABLE FileImports (
    ImportID            INT IDENTITY(1,1) PRIMARY KEY,
    FileName            NVARCHAR(255) NOT NULL,
    FileType            NVARCHAR(20) NOT NULL,          -- ACH, CHECK, WIRE, REGULATORY
    SourcePath          NVARCHAR(500) NOT NULL,         -- UNC path or SFTP path
    Status              NVARCHAR(20) DEFAULT 'PENDING', -- PENDING, PROCESSING, COMPLETED, FAILED
    RecordCount         INT DEFAULT 0,
    ErrorCount          INT DEFAULT 0,
    ImportedAt          DATETIME NOT NULL DEFAULT GETDATE(),
    CompletedAt         DATETIME NULL,
    ErrorDetails        NVARCHAR(MAX),
    ProcessedBy         NVARCHAR(100),                  -- system or worker name
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE CheckImages (
    ImageID             INT IDENTITY(1,1) PRIMARY KEY,
    CheckNumber         NVARCHAR(20) NOT NULL,
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    FrontImagePath      NVARCHAR(500) NOT NULL,         -- UNC path to front scan
    BackImagePath       NVARCHAR(500),                  -- UNC path to back scan
    ScanStatus          NVARCHAR(20) DEFAULT 'PENDING', -- PENDING, SCANNED, RECOGNIZED, FAILED
    ScannedAt           DATETIME NOT NULL DEFAULT GETDATE(),
    ProcessedAt         DATETIME NULL,
    CheckAmount         DECIMAL(18,2),
    CheckDate           DATETIME,
    PayeeName           NVARCHAR(200),
    MICR                NVARCHAR(100),                  -- magnetic ink character recognition (routing + account + check)
    QualityScore        INT,                            -- 0-100 scan quality
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE WireConfirmations (
    ConfirmationID      INT IDENTITY(1,1) PRIMARY KEY,
    TransactionID       BIGINT NOT NULL REFERENCES Transactions(TransactionID),
    ConfirmationNumber  NVARCHAR(50) NOT NULL UNIQUE,
    FilePath            NVARCHAR(500) NOT NULL,         -- UNC path to confirmation file
    ReceivedAt          DATETIME NOT NULL DEFAULT GETDATE(),
    Status              NVARCHAR(20) DEFAULT 'RECEIVED', -- RECEIVED, PROCESSED, REJECTED, ARCHIVED
    WireReference       NVARCHAR(100),
    BeneficiaryBank     NVARCHAR(100),
    BeneficiaryName     NVARCHAR(200),
    Amount              DECIMAL(18,2),
    Currency            NVARCHAR(3) DEFAULT 'USD',
    ExchangeRate        DECIMAL(18,6),
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE RegulatoryFeeds (
    FeedID              INT IDENTITY(1,1) PRIMARY KEY,
    FeedType            NVARCHAR(20) NOT NULL,          -- SAR (Suspicious Activity Report), CTR (Currency Transaction Report), OFAC
    FilePath            NVARCHAR(500) NOT NULL,
    ReportingPeriod     DATETIME NOT NULL,              -- start of reporting period
    Status              NVARCHAR(20) DEFAULT 'PENDING', -- PENDING, SUBMITTED, ACKNOWLEDGED, REJECTED, ARCHIVED
    SubmittedAt         DATETIME NULL,
    AcknowledgedAt      DATETIME NULL,
    AcknowledgmentRef   NVARCHAR(100),                  -- reference number from regulator
    RecordCount         INT DEFAULT 0,
    RejectionReason     NVARCHAR(500),
    RegulatoryAgency    NVARCHAR(100),                  -- e.g., 'FinCEN', 'Federal Reserve'
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE INDEX IX_FileImports_FileType ON FileImports(FileType);
CREATE INDEX IX_FileImports_Status ON FileImports(Status);
CREATE INDEX IX_FileImports_ImportedAt ON FileImports(ImportedAt);
CREATE INDEX IX_CheckImages_CheckNumber ON CheckImages(CheckNumber);
CREATE INDEX IX_CheckImages_AccountID ON CheckImages(AccountID);
CREATE INDEX IX_CheckImages_ScanStatus ON CheckImages(ScanStatus);
CREATE INDEX IX_WireConfirmations_TransactionID ON WireConfirmations(TransactionID);
CREATE INDEX IX_WireConfirmations_ConfirmationNumber ON WireConfirmations(ConfirmationNumber);
CREATE INDEX IX_RegulatoryFeeds_FeedType ON RegulatoryFeeds(FeedType);
CREATE INDEX IX_RegulatoryFeeds_Status ON RegulatoryFeeds(Status);
CREATE INDEX IX_RegulatoryFeeds_ReportingPeriod ON RegulatoryFeeds(ReportingPeriod);
```

### 2.10 Audit

```sql
CREATE TABLE AuditActions (
    ActionID            INT IDENTITY(1,1) PRIMARY KEY,
    ActionName          NVARCHAR(50) NOT NULL UNIQUE,  -- 'LOGIN', 'ACCOUNT_CREATE', 'TRANSFER', 'LOAN_DECISION'
    Description         NVARCHAR(255),
    Severity            NVARCHAR(10) DEFAULT 'Info'    -- Info, Warning, Critical
);

CREATE TABLE AuditLog (
    AuditID             BIGINT IDENTITY(1,1) PRIMARY KEY,
    ActionID            INT NOT NULL REFERENCES AuditActions(ActionID),
    UserName            NVARCHAR(100),
    IPAddress           NVARCHAR(45),
    TableName           NVARCHAR(128),
    RecordID            NVARCHAR(50),
    OldValues           NVARCHAR(MAX),                 -- XML or pipe-delimited (era-appropriate)
    NewValues           NVARCHAR(MAX),
    Description         NVARCHAR(500),
    Timestamp           DATETIME DEFAULT GETDATE(),
    SessionID           NVARCHAR(100),
    MachineName         NVARCHAR(100)
);

CREATE INDEX IX_AuditLog_Timestamp ON AuditLog(Timestamp);
CREATE INDEX IX_AuditLog_UserName ON AuditLog(UserName);
CREATE INDEX IX_AuditLog_TableName ON AuditLog(TableName);
```

### 2.11 Currency

```sql
CREATE TABLE CurrencyPairs (
    PairID              INT IDENTITY(1,1) PRIMARY KEY,
    BaseCurrency        NVARCHAR(3) NOT NULL,          -- 'USD', 'EUR', 'GBP'
    QuoteCurrency       NVARCHAR(3) NOT NULL,
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    UNIQUE(BaseCurrency, QuoteCurrency)
);

CREATE TABLE ExchangeRates (
    RateID              INT IDENTITY(1,1) PRIMARY KEY,
    PairID              INT NOT NULL REFERENCES CurrencyPairs(PairID),
    BidRate             DECIMAL(18,6) NOT NULL,
    AskRate             DECIMAL(18,6) NOT NULL,
    MidRate             DECIMAL(18,6) NOT NULL,
    EffectiveDate       DATETIME DEFAULT GETDATE(),
    ExpiryDate          DATETIME,
    Source              NVARCHAR(50) DEFAULT 'Reuters', -- feed source
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE INDEX IX_ExchangeRates_PairID ON ExchangeRates(PairID);
CREATE INDEX IX_ExchangeRates_EffectiveDate ON ExchangeRates(EffectiveDate);
```

### 2.12 Statements

```sql
CREATE TABLE StatementRequests (
    RequestID           INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    StatementType       NVARCHAR(20) NOT NULL,         -- 'Monthly', 'Quarterly', 'Annual', 'AdHoc'
    PeriodStart         DATETIME NOT NULL,
    PeriodEnd           DATETIME NOT NULL,
    Format              NVARCHAR(10) DEFAULT 'PDF',    -- PDF, CSV
    Status              NVARCHAR(20) DEFAULT 'Requested', -- Requested, Generating, Ready, Failed, Expired
    RequestedDate       DATETIME DEFAULT GETDATE(),
    CompletedDate       DATETIME NULL,
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE StatementArchive (
    ArchiveID           INT IDENTITY(1,1) PRIMARY KEY,
    RequestID           INT NOT NULL REFERENCES StatementRequests(RequestID),
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    FilePath            NVARCHAR(500),                 -- UNC path to generated file
    FileSize            INT,
    GeneratedDate       DATETIME DEFAULT GETDATE(),
    ExpiryDate          DATETIME,                      -- auto-cleanup date
    Checksum            NVARCHAR(64)                   -- MD5 hash
);

CREATE INDEX IX_StatementRequests_CustomerID ON StatementRequests(CustomerID);
CREATE INDEX IX_StatementRequests_AccountID ON StatementRequests(AccountID);
```

### 2.13 Alerts

```sql
CREATE TABLE AlertRules (
    RuleID              INT IDENTITY(1,1) PRIMARY KEY,
    RuleName            NVARCHAR(100) NOT NULL,
    RuleCode            NVARCHAR(30) NOT NULL UNIQUE,  -- 'LOW_BALANCE', 'LARGE_TXN', 'LOGIN_FAIL'
    DefaultThreshold    NVARCHAR(50),                  -- e.g., '100.00', '3'
    Category            NVARCHAR(30),                  -- 'Balance', 'Security', 'Transaction'
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE AccountAlerts (
    AccountAlertID      INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    RuleID              INT NOT NULL REFERENCES AlertRules(RuleID),
    Threshold           NVARCHAR(50),                  -- customer-defined override
    NotificationChannel NVARCHAR(20) DEFAULT 'Email',  -- Email, SMS
    IsEnabled           BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);

CREATE TABLE AlertHistory (
    AlertHistoryID      INT IDENTITY(1,1) PRIMARY KEY,
    AccountAlertID      INT NOT NULL REFERENCES AccountAlerts(AccountAlertID),
    TriggeredDate       DATETIME DEFAULT GETDATE(),
    TriggerValue        NVARCHAR(100),                 -- the value that triggered it
    NotificationSent    BIT DEFAULT 0,
    NotificationDate    DATETIME NULL,
    Details             NVARCHAR(500)
);

CREATE INDEX IX_AccountAlerts_CustomerID ON AccountAlerts(CustomerID);
CREATE INDEX IX_AccountAlerts_AccountID ON AccountAlerts(AccountID);
CREATE INDEX IX_AlertHistory_TriggeredDate ON AlertHistory(TriggeredDate);
```

### 2.14 Auth & Sessions

```sql
-- Authentication and session management for ZavaAuth Gateway
-- FormsAuthentication with SHA-1 password hashing (legacy — no bcrypt, no PBKDF2)
-- SessionTokens table is the cross-ecosystem SSO bridge: .NET and Java apps both validate tokens here

CREATE TABLE Users (
    UserID              INT IDENTITY(1,1) PRIMARY KEY,
    Username            NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash        NVARCHAR(128) NOT NULL,          -- SHA-1 hex digest (legacy!)
    Salt                NVARCHAR(64) NOT NULL,            -- per-user salt, concatenated before hashing
    Email               NVARCHAR(255) NOT NULL,
    FirstName           NVARCHAR(100) NOT NULL,
    LastName            NVARCHAR(100) NOT NULL,
    IsActive            BIT DEFAULT 1,
    FailedLoginAttempts INT DEFAULT 0,
    IsLockedOut         BIT DEFAULT 0,
    LastLoginDate       DATETIME NULL,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);

CREATE TABLE Roles (
    RoleID              INT IDENTITY(1,1) PRIMARY KEY,
    RoleName            NVARCHAR(50) NOT NULL UNIQUE,     -- Customer, Teller, LoanOfficer, FraudAnalyst, Admin
    Description         NVARCHAR(255),
    CreatedDate         DATETIME DEFAULT GETDATE()
);

CREATE TABLE UserRoles (
    UserID              INT NOT NULL REFERENCES Users(UserID),
    RoleID              INT NOT NULL REFERENCES Roles(RoleID),
    AssignedDate        DATETIME DEFAULT GETDATE(),
    AssignedBy          NVARCHAR(100),
    PRIMARY KEY (UserID, RoleID)
);

CREATE TABLE SessionTokens (
    TokenID             INT IDENTITY(1,1) PRIMARY KEY,
    UserID              INT NOT NULL REFERENCES Users(UserID),
    Token               NVARCHAR(64) NOT NULL UNIQUE,     -- GUID string — shared SSO token
    CreatedAt           DATETIME DEFAULT GETDATE(),
    ExpiresAt           DATETIME NOT NULL,
    SourceSystem        NVARCHAR(10) NOT NULL,             -- 'DotNet' or 'Java'
    IsActive            BIT DEFAULT 1,
    IPAddress           NVARCHAR(45),                      -- client IP at login
    UserAgent           NVARCHAR(500)                      -- browser/client string
);

CREATE INDEX IX_Users_Username ON Users(Username);
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_SessionTokens_Token ON SessionTokens(Token);
CREATE INDEX IX_SessionTokens_UserID ON SessionTokens(UserID);
CREATE INDEX IX_SessionTokens_ExpiresAt ON SessionTokens(ExpiresAt);
CREATE INDEX IX_UserRoles_RoleID ON UserRoles(RoleID);
```

---

## 3. Key Stored Procedures

All business logic lives in stored procedures — era-appropriate. Application code calls these procs directly. No ORM for critical paths.

### 3.1 Loan Processing

| Procedure | Purpose |
|---|---|
| `sp_ProcessLoanApplication` | Accepts a loan application, runs initial validation, creates the record, triggers risk assessment. Takes customer ID, product ID, amount, term, purpose. Returns application ID and initial status. |
| `sp_CalculateRisk` | Pulls credit score, calculates debt-to-income ratio, evaluates risk factors, produces an overall risk score and recommendation. Called by `sp_ProcessLoanApplication`. |
| `sp_MakeLoanDecision` | Records approve/deny/escalate decision on a loan application. Updates application status, creates LoanDecisions record, triggers notification queue entry. |
| `sp_FundLoan` | Creates the loan account, posts the disbursement transaction, updates loan application status to 'Funded'. Links the loan account back to the application. |
| `sp_ProcessLoanPayment` | Processes a loan payment — splits into principal and interest, updates balances, records the payment, checks if loan is paid off. |

### 3.2 Payment Processing

| Procedure | Purpose |
|---|---|
| `sp_ProcessPayment` | Core payment procedure. Validates source account balance, checks daily limits, creates the payment record, debits the source account, posts the transaction. Returns confirmation number. |
| `sp_BatchPayments` | Processes a batch of payments (payroll, ACH batch). Iterates through batch items, calls `sp_ProcessPayment` for each, tracks successes and failures, updates batch status. |
| `sp_ReversePayment` | Reverses a completed payment. Credits the source account, posts a reversal transaction, updates payment status. Requires authorization. |
| `sp_GetPaymentStatus` | Returns detailed payment status with processing history. Used by ZavaPay Gateway for status checks. |

### 3.3 Transaction Posting

| Procedure | Purpose |
|---|---|
| `sp_PostTransaction` | Posts a transaction to an account. Updates account balance, creates the transaction record, checks for overdraft, triggers fraud check for amounts over threshold. |
| `sp_TransferFunds` | Moves money between two accounts. Posts a debit to source and credit to destination in a single transaction. Validates balances and limits. |
| `sp_ArchiveTransactions` | Moves transactions older than a configurable threshold (default: 2 years) from `Transactions` to `TransactionArchive`. Run nightly by the batch processor. |
| `sp_ReconcileDaily` | End-of-day reconciliation. Sums all day's transactions by type, verifies account balances match, flags discrepancies for review. |

### 3.4 Fraud Checking

| Procedure | Purpose |
|---|---|
| `sp_CheckFraud` | Evaluates a transaction against all active fraud rules. Checks velocity (too many transactions in a time window), amount thresholds, geographic anomalies. Creates FraudAlerts for any hits. Returns a fraud score. |
| `sp_UpdateFraudScore` | Recalculates a customer's overall fraud score based on recent alerts, transaction patterns, and account age. Updates FraudScores table. |
| `sp_ResolveFraudAlert` | Marks a fraud alert as resolved (confirmed fraud or false positive). Updates status, records resolution notes, adjusts fraud score accordingly. |
| `sp_GetFraudDashboard` | Returns aggregated fraud metrics: alerts by severity, resolution rates, top rules triggered. Used by ZavaAdmin Portal. |

### 3.5 Report Generation

| Procedure | Purpose |
|---|---|
| `sp_GenerateStatement` | Generates an account statement for a date range. Pulls all transactions, calculates opening/closing balances, interest accrued. Creates StatementArchive record. |
| `sp_ComplianceReport` | Generates compliance reports (SAR, CTR). Pulls customer transactions over reporting thresholds, KYC status, compliance check results. Creates ComplianceReports record. |
| `sp_DailyBalanceReport` | Produces end-of-day balance report across all accounts. Used by ZavaReport Engine. |
| `sp_LoanPortfolioReport` | Aggregates loan portfolio metrics: total outstanding, delinquency rates, approval rates by product. |

### 3.6 KYC & Compliance

| Procedure | Purpose |
|---|---|
| `sp_RunKYCCheck` | Initiates KYC verification for a customer. Creates KYCRecord, validates documents, runs OFAC/PEP screening via ComplianceChecks. |
| `sp_UpdateKYCStatus` | Updates KYC verification status after document review. Marks as Verified, Failed, or Expired. |
| `sp_ScreenCustomer` | Runs a customer against sanctions lists and PEP databases. Creates ComplianceChecks records with results. |

### 3.7 Notification & Alerts

| Procedure | Purpose |
|---|---|
| `sp_QueueNotification` | Creates a notification queue entry. Resolves template, fills in placeholders, sets priority and schedule. |
| `sp_ProcessNotificationBatch` | Processes queued notifications in priority order. Attempts delivery, updates status, logs results. Called by ZavaQueue Processor. |
| `sp_EvaluateAlerts` | Checks all active account alerts against current account state. Triggers notifications for any threshold breaches. Run by ZavaAlert Service. |

### 3.8 Auth & Session Management

| Procedure | Purpose |
|---|---|
| `sp_ValidateUser` | Validates a login attempt. Takes username and password, looks up the user, concatenates salt + password, computes SHA-1 hash, compares to stored `PasswordHash`. Increments `FailedLoginAttempts` on failure, locks account after 5 consecutive failures. On success, resets fail count and updates `LastLoginDate`. Returns user ID, roles, and success/failure flag. |
| `sp_CreateSession` | Creates a new session token after successful login. Generates a GUID token, inserts into `SessionTokens` with `SourceSystem` ('DotNet' or 'Java'), sets `ExpiresAt` to 30 minutes from now. Returns the token for the caller to set as a cookie. Called by both ZavaAuth Gateway (.NET) and ZavaPay Gateway (Java). |
| `sp_ValidateSessionToken` | Validates an active session token. Checks that the token exists, `IsActive = 1`, and `ExpiresAt > GETDATE()`. Returns user ID, username, and roles if valid. Used by every app on every request for SSO validation across .NET and Java ecosystems. |
| `sp_ExpireSession` | Expires a session on logout. Sets `IsActive = 0` on the token record. Optionally expires all sessions for a user (force logout). |

---

## 4. Data Access Patterns

### 4.0 Data Access Ownership — Per-App, Not Shared

> **Important:** There is no shared data access library. Every app owns its own database access code inside its own folder. This means each .NET app has its own ADO.NET helper classes (or EF6 `.edmx`, or `SqlDataSource` controls), and each Java app has its own JDBC utility classes and connection pool config. The duplication is intentional — it's era-appropriate and represents a key modernization pain point.

Typical per-app data access layout:

**.NET example — `zava-risk-engine/` (WCF service):**
- `Web.config` — connection string lives here
- `DataAccess/DatabaseHelper.cs` — SqlConnection/SqlCommand wrapper
- `DataAccess/RiskDataProvider.cs` — calls stored procs for risk tables

**Java example — `zava-fraud-detector/` (Struts 2.x):**
- `src/main/resources/jdbc.properties` — connection string lives here
- `src/main/java/.../dao/DatabaseUtil.java` — JDBC connection factory
- `src/main/java/.../dao/FraudAlertDao.java` — PreparedStatement calls for fraud tables

### 4.1 .NET Services — ADO.NET (SqlCommand)

Used by: **ZavaRisk Engine**, **ZavaNotify**, **ZavaStatement Generator**, **ZavaAlert Service**, **ZavaAudit Logger**, **ZavaBatch Processor**, **ZavaReport Engine**, **ZavaQueue Processor**

Each of these apps has its own `DatabaseHelper.cs` (or similar) inside its app folder. No shared NuGet package or class library — just copy-pasted helper code with minor variations per app (era-appropriate).

```csharp
// Located in: zava-risk-engine/DataAccess/DatabaseHelper.cs (or equivalent per app)
// Typical pattern — raw ADO.NET, no abstraction, connection strings in web.config/app.config
using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ZavaBankDB"].ConnectionString))
{
    conn.Open();
    using (var cmd = new SqlCommand("sp_ProcessPayment", conn))
    {
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.AddWithValue("@AccountID", accountId);
        cmd.Parameters.AddWithValue("@Amount", amount);
        cmd.Parameters.AddWithValue("@PaymentMethodID", methodId);

        using (var reader = cmd.ExecuteReader())
        {
            // read results inline, no mapping layer
        }
    }
}
```

### 4.2 .NET Services — Entity Framework 6

Used by: **ZavaAccount Manager**

The `.edmx` file lives inside `zava-account-manager/` — generated from the database using Database-First. Lazy loading is on. No repository pattern. Context is created per-request in code-behind files.

```csharp
// Located in: zava-account-manager/Models/ZavaBankEntities.edmx (Database-First)
using (var context = new ZavaBankEntities())
{
    var customer = context.Customers
        .Include("Accounts")
        .Include("Accounts.AccountType")
        .FirstOrDefault(c => c.CustomerID == customerId);

    // Lazy loading enabled (N+1 queries everywhere — intentional tech debt)
}
```

### 4.3 .NET Services — SqlDataSource (Web Forms)

Used by: **ZavaLoan Portal**, **ZavaAdmin Portal**

The `SqlDataSource` controls are embedded directly in `.aspx` markup files inside each app's folder. Connection strings come from each app's own `Web.config`.

```aspx
<!-- Located in: zava-loan-portal/Pages/LoanHistory.aspx -->
<asp:SqlDataSource ID="dsLoanApplications" runat="server"
    ConnectionString="<%$ ConnectionStrings:ZavaBankDB %>"
    SelectCommand="SELECT la.*, c.FirstName, c.LastName, lp.ProductName
                   FROM LoanApplications la
                   JOIN Customers c ON la.CustomerID = c.CustomerID
                   JOIN LoanProducts lp ON la.LoanProductID = lp.LoanProductID
                   WHERE la.CustomerID = @CustomerID"
    SelectCommandType="Text">
    <SelectParameters>
        <asp:SessionParameter Name="CustomerID" SessionField="CustomerID" />
    </SelectParameters>
</asp:SqlDataSource>

<asp:GridView ID="gvLoans" runat="server" DataSourceID="dsLoanApplications"
    AutoGenerateColumns="False" AllowPaging="True" PageSize="10">
    <!-- columns defined in markup -->
</asp:GridView>
```

Some pages also use code-behind with `SqlCommand` for stored procedure calls (mixed pattern — typical of real legacy apps).

### 4.4 Java Services — JDBC (PreparedStatement)

Used by: **ZavaPay Gateway**, **ZavaLedger**, **ZavaFraud Detector**, **ZavaKYC Service**, **ZavaCurrency Service**

Each Java app has its own `DatabaseUtil.java` and DAO classes inside its app folder. Connection pooling via Apache Commons DBCP or Tomcat JDBC pool, configured per-app.

```java
// Located in: zava-fraud-detector/src/main/java/.../dao/DatabaseUtil.java (or equivalent per app)
// Typical pattern — manual JDBC, connections from a pool, no ORM
Connection conn = null;
PreparedStatement stmt = null;
ResultSet rs = null;
try {
    conn = dataSource.getConnection();
    stmt = conn.prepareStatement(
        "EXEC sp_CheckFraud @TransactionID = ?, @AccountID = ?, @Amount = ?");
    stmt.setLong(1, transactionId);
    stmt.setInt(2, accountId);
    stmt.setBigDecimal(3, amount);
    rs = stmt.executeQuery();

    while (rs.next()) {
        // manual result mapping into POJOs
    }
} catch (SQLException e) {
    logger.error("Fraud check failed for txn " + transactionId, e);
    throw new FraudCheckException(e);
} finally {
    // manual resource cleanup (pre-try-with-resources in Java 8 apps)
    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
    if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
}
```

Java apps use the Microsoft JDBC driver for SQL Server (`mssql-jdbc`).

### 4.5 Connection String Patterns

Every app has its own config file with the connection string — stored inside the app's folder. They all point to the same `ZavaBankDB` instance. Credentials are in config files (not secret stores — this is legacy).

**.NET (each app's own web.config / app.config):**
```xml
<!-- Located in: zava-loan-portal/Web.config, zava-risk-engine/Web.config, etc. -->
<connectionStrings>
  <add name="ZavaBankDB"
       connectionString="Server=sqlserver;Database=ZavaBankDB;User Id=zavaapp;Password=ZavaBank2024!;TrustServerCertificate=True;"
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

**Java (each app's own properties file):**
```properties
# Located in: zava-pay-gateway/src/main/resources/jdbc.properties, zava-fraud-detector/src/main/resources/jdbc.properties, etc.
jdbc.url=jdbc:sqlserver://sqlserver:1433;databaseName=ZavaBankDB;trustServerCertificate=true
jdbc.username=zavaapp
jdbc.password=ZavaBank2024!
jdbc.driverClassName=com.microsoft.sqlserver.jdbc.SQLServerDriver
```

**Docker Compose environment (overrides per-service):**
```yaml
# Each service in docker-compose.yml gets the same DB env vars
services:
  zava-loan-portal:
    environment:
      - DB_SERVER=sqlserver
      - DB_NAME=ZavaBankDB
      - DB_USER=zavaapp
      - DB_PASSWORD=ZavaBank2024!
  zava-pay-gateway:
    environment:
      - DB_SERVER=sqlserver
      - DB_NAME=ZavaBankDB
      - DB_USER=zavaapp
      - DB_PASSWORD=ZavaBank2024!
  # ... repeated for every app — no shared env file (era-appropriate)
```

---

## 5. Seed Data Strategy

The seed data makes the banking scenario feel real during demos. It should be rich enough that every screen in the application shows meaningful data.

### 5.1 Customers (50 seeded)

- Mix of individual and small-business customers
- Realistic names, addresses across multiple US states
- Varying `CustomerSince` dates (2005–2024) to show account age
- Risk ratings distributed: 60% Low, 30% Medium, 10% High
- SSNs in plaintext (intentional security anti-pattern for the modernization story)

### 5.2 Accounts (~120 seeded)

- Each customer has 1–4 accounts (checking, savings, some with loans)
- Balances ranging from $0.00 (overdrawn checking) to $250,000 (savings)
- Mix of Active, Frozen, and Closed statuses
- Account numbers in `XXXX-XXXX-XXXX` format

### 5.3 Transactions (~2,000 seeded)

- 6 months of transaction history per active account
- Realistic patterns: payroll deposits (biweekly), rent payments (monthly), grocery/retail (random)
- Mix of channels: Online, ATM, Branch, Mobile
- A few deliberately suspicious transactions (large cash deposits, rapid-fire small transfers) for fraud demo scenarios

### 5.4 Loan Applications (30 seeded)

- Mix of statuses: 10 Approved/Funded, 8 Denied, 5 Under Review, 4 Submitted, 3 Closed
- Products spread across Personal, Mortgage, Auto, Business
- Amounts from $5,000 to $500,000
- Linked risk assessments and credit scores

### 5.5 Payments (200 seeded)

- ACH, Wire, and internal transfers
- Most completed, a few failed (for error-handling demo)
- 2–3 payment batches (payroll runs)

### 5.6 Fraud (15 alerts seeded)

- 5 confirmed fraud cases, 5 false positives, 5 new/investigating
- Rules that triggered: large transaction, velocity check, geographic anomaly
- Linked to suspicious transactions in the transaction seed data

### 5.7 KYC/Compliance (50 records seeded)

- All customers have at least a Basic KYC record
- 10 customers with Enhanced verification
- 5 customers with expired KYC (triggers compliance workflow)
- 3 customers with OFAC/PEP hits (for compliance demo)

### 5.8 Notifications (~100 seeded)

- Mix of Sent, Queued, and Failed
- Templates for common events: welcome, payment due, loan approved, fraud alert
- Some failed notifications to show retry logic

### 5.9 Audit Log (~500 entries seeded)

- Login events, account creations, transfers, loan decisions
- Multiple users and IP addresses
- Timestamps spanning 6 months

### 5.10 Special Demo Scenarios

The seed data supports these specific demo moments:

| Scenario | Seed Data |
|---|---|
| **Customer applies for a loan** | Customer "Maria Rodriguez" has a pending loan application, good credit score, clean KYC |
| **Fraud detection in action** | Customer "James Chen" has suspicious transactions flagged by velocity check rule |
| **Compliance review** | Customer "Viktor Petrov" has a PEP hit requiring enhanced due diligence |
| **Overdrawn account** | Customer "Sarah Miller" has a checking account at -$45.00 with overdraft alerts |
| **Loan rejection story** | Customer "David Park" was denied — high DTI ratio, recent missed payments |
| **Successful loan lifecycle** | Customer "Emily Johnson" — full lifecycle: application → approval → funding → repayment |

### 5.11 Auth & Sessions (10 users, 5 roles seeded)

- **5 roles:** Customer, Teller, LoanOfficer, FraudAnalyst, Admin
- **10 test users** with known credentials (all passwords are SHA-1 hashed with per-user salt):

| Username | Password (plaintext) | Roles | Notes |
|---|---|---|---|
| `admin` | `Password1!` | Admin | Full access, used for admin portal demos |
| `teller.jones` | `Teller2024` | Teller | Branch teller, processes deposits/withdrawals |
| `loan.officer.kim` | `Loans2024` | LoanOfficer | Reviews and approves loan applications |
| `fraud.analyst.chen` | `Fraud2024` | FraudAnalyst | Investigates fraud alerts |
| `maria.rodriguez` | `Customer1` | Customer | Linked to customer "Maria Rodriguez" — pending loan |
| `james.chen` | `Customer2` | Customer | Linked to customer "James Chen" — fraud scenario |
| `sarah.miller` | `Customer3` | Customer | Linked to customer "Sarah Miller" — overdrawn account |
| `david.park` | `Customer4` | Customer | Linked to customer "David Park" — denied loan |
| `emily.johnson` | `Customer5` | Customer | Linked to customer "Emily Johnson" — full loan lifecycle |
| `viktor.petrov` | `Customer6` | Customer | Linked to customer "Viktor Petrov" — PEP/compliance scenario |

- Each user has 1–3 active session tokens (mix of DotNet and Java source systems)
- `admin` has sessions from both ecosystems to demonstrate cross-platform SSO
- 5 expired session tokens retained to show token lifecycle
- `david.park` account is locked out (5 failed login attempts) for lockout demo

---

## 6. SQL Server Container

### 6.1 Docker Image

```yaml
# docker-compose.yml (relevant section)
services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2019-latest
    container_name: zavabank-sqlserver
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_SA_PASSWORD=ZavaBank2024!
      - MSSQL_PID=Developer
    ports:
      - "1433:1433"
    volumes:
      - sqlserver-data:/var/opt/mssql
      - ./infrastructure/sql:/docker-entrypoint-initdb.d
    healthcheck:
      test: /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "ZavaBank2024!" -C -Q "SELECT 1" -b
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

volumes:
  sqlserver-data:
```

### 6.2 Initialization Scripts

The database initializes through a series of numbered SQL scripts in `infrastructure/sql/`, executed in order by an init container or entrypoint script:

**Scripts in `infrastructure/sql/` (executed in order):**

| Script | Purpose |
|---|---|
| `01-create-database.sql` | CREATE DATABASE ZavaBankDB, logins, users |
| `02-core-banking-tables.sql` | Customers, Accounts, AccountTypes |
| `03-loan-tables.sql` | LoanProducts, LoanApplications, LoanDecisions, LoanPayments |
| `04-transaction-tables.sql` | Transactions, TransactionTypes, TransactionArchive |
| `05-payment-tables.sql` | Payments, PaymentMethods, PaymentBatches |
| `06-kyc-compliance-tables.sql` | KYCRecords, KYCDocuments, ComplianceChecks, ComplianceReports |
| `07-fraud-tables.sql` | FraudAlerts, FraudRules, FraudScores |
| `08-risk-tables.sql` | CreditScores, RiskAssessments, RiskFactors |
| `09-notification-tables.sql` | NotificationQueue, NotificationTemplates, NotificationLog |
| `10-audit-tables.sql` | AuditLog, AuditActions |
| `11-currency-tables.sql` | ExchangeRates, CurrencyPairs |
| `12-statement-tables.sql` | StatementRequests, StatementArchive |
| `13-alert-tables.sql` | AccountAlerts, AlertRules, AlertHistory |
| `20-stored-procedures.sql` | All stored procedures |
| `30-views.sql` | Convenience views for reporting |
| `40-seed-reference-data.sql` | AccountTypes, TransactionTypes, LoanProducts, etc. |
| `50-seed-demo-data.sql` | Customers, accounts, transactions — the demo dataset |
| `init-db.sh` | Entrypoint script that waits for SQL Server and runs scripts |
| `README.md` | Documentation |

> **Note:** No SQL DDL or seed scripts live in individual app folders. Apps only contain their own connection configs and data access code. The `infrastructure/sql/` folder is the single source of truth for the database.

### 6.3 Init Entrypoint Script

```bash
#!/bin/bash
# init-db.sh — waits for SQL Server to be ready, then runs init scripts in order

echo "Waiting for SQL Server to start..."
for i in {1..60}; do
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C -Q "SELECT 1" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "SQL Server is ready."
        break
    fi
    sleep 2
done

echo "Running initialization scripts..."
for script in /docker-entrypoint-initdb.d/*.sql; do
    echo "Executing $script..."
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C -d master -i "$script"
done

echo "Database initialization complete."
```

### 6.4 Init Container in Docker Compose

Since the SQL Server image doesn't natively support init scripts like PostgreSQL, we use a sidecar init container:

```yaml
services:
  sqlserver-init:
    image: mcr.microsoft.com/mssql-tools:latest
    container_name: zavabank-sqlserver-init
    depends_on:
      sqlserver:
        condition: service_healthy
    volumes:
      - ./infrastructure/sql:/scripts
      - ./infrastructure/sql/init-db.sh:/init-db.sh
    entrypoint: ["/bin/bash", "/init-db.sh"]
    environment:
      - SA_PASSWORD=ZavaBank2024!
```

### 6.5 Key Views (for reporting and admin screens)

```sql
-- v_CustomerSummary: one-stop view for customer overview screens
CREATE VIEW v_CustomerSummary AS
SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, c.Status, c.RiskRating,
       COUNT(DISTINCT a.AccountID) AS AccountCount,
       SUM(a.Balance) AS TotalBalance,
       MAX(cs.Score) AS LatestCreditScore,
       k.Status AS KYCStatus
FROM Customers c
LEFT JOIN Accounts a ON c.CustomerID = a.CustomerID
LEFT JOIN CreditScores cs ON c.CustomerID = cs.CustomerID
LEFT JOIN KYCRecords k ON c.CustomerID = k.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email, c.Status, c.RiskRating, k.Status;

-- v_LoanPipeline: loan officer dashboard
CREATE VIEW v_LoanPipeline AS
SELECT la.ApplicationID, la.Status, la.RequestedAmount, la.ApprovedAmount,
       la.ApplicationDate, la.AssignedOfficer,
       c.FirstName + ' ' + c.LastName AS CustomerName,
       lp.ProductName, ra.RiskLevel, ra.OverallRiskScore
FROM LoanApplications la
JOIN Customers c ON la.CustomerID = c.CustomerID
JOIN LoanProducts lp ON la.LoanProductID = lp.LoanProductID
LEFT JOIN RiskAssessments ra ON la.ApplicationID = ra.ApplicationID;

-- v_RecentTransactions: used by multiple screens
CREATE VIEW v_RecentTransactions AS
SELECT t.TransactionID, t.AccountID, a.AccountNumber,
       tt.TypeName AS TransactionType, t.Amount, t.BalanceAfter,
       t.Description, t.TransactionDate, t.Status, t.Channel
FROM Transactions t
JOIN Accounts a ON t.AccountID = a.AccountID
JOIN TransactionTypes tt ON t.TransactionTypeID = tt.TransactionTypeID;

-- v_FraudDashboard: fraud analyst screen
CREATE VIEW v_FraudDashboard AS
SELECT fa.AlertID, fa.AlertType, fa.Severity, fa.Status,
       c.FirstName + ' ' + c.LastName AS CustomerName,
       a.AccountNumber, fa.Description, fa.CreatedDate,
       fr.RuleName, fs.Score AS FraudScore
FROM FraudAlerts fa
JOIN Customers c ON fa.CustomerID = c.CustomerID
JOIN Accounts a ON fa.AccountID = a.AccountID
LEFT JOIN FraudRules fr ON fa.RuleID = fr.RuleID
LEFT JOIN FraudScores fs ON fa.CustomerID = fs.CustomerID;

-- v_ActiveAlerts: alert service processing
CREATE VIEW v_ActiveAlerts AS
SELECT aa.AccountAlertID, aa.CustomerID, aa.AccountID, aa.Threshold,
       ar.RuleName, ar.RuleCode, ar.Category,
       a.Balance, a.AccountNumber,
       c.Email, c.Phone
FROM AccountAlerts aa
JOIN AlertRules ar ON aa.RuleID = ar.RuleID
JOIN Accounts a ON aa.AccountID = a.AccountID
JOIN Customers c ON aa.CustomerID = c.CustomerID
WHERE aa.IsEnabled = 1 AND ar.IsActive = 1;
```

---

## 7. Table Summary

| Domain | Tables | Row Estimate (Seed) |
|---|---|---|
| Core Banking | AccountTypes, Customers, Accounts | 5 + 50 + 120 |
| Loans | LoanProducts, LoanApplications, LoanDecisions, LoanPayments | 6 + 30 + 40 + 150 |
| Transactions | TransactionTypes, Transactions, TransactionArchive | 7 + 2000 + 500 |
| Payments | PaymentMethods, Payments, PaymentBatches | 5 + 200 + 3 |
| KYC/Compliance | KYCRecords, KYCDocuments, ComplianceChecks, ComplianceReports | 50 + 80 + 60 + 10 |
| Fraud | FraudRules, FraudAlerts, FraudScores | 10 + 15 + 50 |
| Risk | CreditScores, RiskFactors, RiskAssessments | 50 + 12 + 30 |
| Notifications | NotificationTemplates, NotificationQueue, NotificationLog | 12 + 100 + 80 |
| Audit | AuditActions, AuditLog | 15 + 500 |
| Currency | CurrencyPairs, ExchangeRates | 10 + 100 |
| Statements | StatementRequests, StatementArchive | 40 + 35 |
| Alerts | AlertRules, AccountAlerts, AlertHistory | 8 + 60 + 120 |
| Auth | Users, Roles, UserRoles, SessionTokens | 10 + 5 + 15 + 25 |
| **Total** | **42 tables** | **~4,660 rows** |

---

## 8. Intentional Legacy Anti-Patterns

These are by design — they're the "before" picture for the modernization demo:

1. **SSN stored in plaintext** — no encryption, no hashing
2. **Passwords in config files** — connection strings with credentials in `web.config` and `jdbc.properties`
3. **Shared database** — every service hits the same tables, no bounded contexts
4. **No schema separation** — everything in `dbo`
5. **God stored procedures** — `sp_ProcessLoanApplication` does validation, risk assessment, notification, and audit in one proc
6. **XML blobs in NVARCHAR(MAX)** — compliance reports, credit bureau data stored as untyped XML strings
7. **Pipe-delimited fields** — `FactorBreakdown` column stores `"DTI=0.35|LTV=0.80|EMP=5yr"` as a string
8. **No foreign key cascade rules** — all deletes require manual cleanup
9. **Mixed data access** — same app uses SqlDataSource in markup AND SqlCommand in code-behind
10. **N+1 query patterns** — EF6 with lazy loading enabled, no `.Include()` optimization
11. **Copy-pasted data access code** — every app has its own `DatabaseHelper.cs` or `DatabaseUtil.java` with nearly identical boilerplate, duplicated across 20+ app folders
12. **SHA-1 password hashing** — `Users.PasswordHash` uses SHA-1 with a simple salt concatenation, no key stretching (no bcrypt, no PBKDF2)
13. **Session tokens in the database** — cross-ecosystem SSO via a shared `SessionTokens` table polled on every request instead of a proper token service
