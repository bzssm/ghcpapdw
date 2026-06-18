# Database Schema — Zava Bank (ZavaBankDB)

Entity-relationship diagram of the shared SQL Server database. All 23 application nodes connect to this single instance. Tables are organized into 14 domain groups, all in the `dbo` schema.

## Core Banking and Loans

```mermaid
---
config:
  theme: dark
  themeVariables:
    primaryColor: "#1e3a5f"
    primaryTextColor: "#ffffff"
    lineColor: "#4a7bb5"
---
erDiagram
    Customers {
        int CustomerID PK
        nvarchar FirstName
        nvarchar LastName
        date DateOfBirth
        nvarchar SSN
        nvarchar Email
        nvarchar Status
        nvarchar RiskRating
    }

    AccountTypes {
        int AccountTypeID PK
        nvarchar TypeName
        decimal InterestRate
        decimal MinimumBalance
    }

    Accounts {
        int AccountID PK
        int CustomerID FK
        int AccountTypeID FK
        nvarchar AccountNumber
        decimal Balance
        nvarchar Status
    }

    LoanProducts {
        int LoanProductID PK
        nvarchar ProductName
        decimal MinAmount
        decimal MaxAmount
        decimal BaseInterestRate
    }

    LoanApplications {
        int ApplicationID PK
        int CustomerID FK
        int LoanProductID FK
        decimal RequestedAmount
        decimal ApprovedAmount
        nvarchar Status
        int LoanAccountID FK
    }

    LoanDecisions {
        int DecisionID PK
        int ApplicationID FK
        nvarchar DecisionType
        nvarchar RiskLevel
    }

    LoanPayments {
        int PaymentID PK
        int ApplicationID FK
        int AccountID FK
        decimal PaymentAmount
        nvarchar Status
    }

    Customers ||--o{ Accounts : "has"
    AccountTypes ||--o{ Accounts : "type"
    Customers ||--o{ LoanApplications : "applies"
    LoanProducts ||--o{ LoanApplications : "product"
    LoanApplications ||--o{ LoanDecisions : "decisions"
    LoanApplications ||--o{ LoanPayments : "payments"
    Accounts ||--o{ LoanPayments : "from account"
    Accounts ||--o| LoanApplications : "funded into"
```

## Transactions, Payments, and Risk

```mermaid
---
config:
  theme: dark
  themeVariables:
    primaryColor: "#1e3a5f"
    primaryTextColor: "#ffffff"
    lineColor: "#4a7bb5"
---
erDiagram
    TransactionTypes {
        int TransactionTypeID PK
        nvarchar TypeCode
        nvarchar TypeName
        bit IsDebit
    }

    Transactions {
        bigint TransactionID PK
        int AccountID FK
        int TransactionTypeID FK
        decimal Amount
        decimal BalanceAfter
        nvarchar Status
        nvarchar Channel
    }

    Payments {
        int PaymentID PK
        int SourceAccountID FK
        int PaymentMethodID FK
        decimal Amount
        nvarchar Currency
        nvarchar Status
    }

    PaymentMethods {
        int PaymentMethodID PK
        nvarchar MethodName
        nvarchar MethodCode
        decimal ProcessingFee
    }

    PaymentBatches {
        int BatchID PK
        nvarchar BatchType
        decimal TotalAmount
        int PaymentCount
        nvarchar Status
    }

    CreditScores {
        int CreditScoreID PK
        int CustomerID FK
        int Score
        nvarchar ScoreSource
    }

    RiskAssessments {
        int AssessmentID PK
        int ApplicationID FK
        int CustomerID FK
        decimal OverallRiskScore
        nvarchar RiskLevel
        nvarchar Recommendation
    }

    RiskFactors {
        int FactorID PK
        nvarchar FactorName
        nvarchar FactorCode
        decimal Weight
    }

    Accounts ||--o{ Transactions : "has"
    TransactionTypes ||--o{ Transactions : "type"
    Accounts ||--o{ Payments : "source"
    PaymentMethods ||--o{ Payments : "method"
    Customers ||--o{ CreditScores : "scores"
    LoanApplications ||--o{ RiskAssessments : "assessed"
    Customers ||--o{ RiskAssessments : "risk"
```

## KYC, Fraud, and Compliance

```mermaid
---
config:
  theme: dark
  themeVariables:
    primaryColor: "#1e3a5f"
    primaryTextColor: "#ffffff"
    lineColor: "#4a7bb5"
---
erDiagram
    KYCRecords {
        int KYCID PK
        int CustomerID FK
        nvarchar VerificationLevel
        nvarchar Status
    }

    KYCDocuments {
        int DocumentID PK
        int KYCID FK
        nvarchar DocumentType
        nvarchar VerificationStatus
    }

    ComplianceChecks {
        int CheckID PK
        int CustomerID FK
        nvarchar CheckType
        nvarchar Result
    }

    ComplianceReports {
        int ReportID PK
        int CustomerID FK
        nvarchar ReportType
        nvarchar Status
    }

    FraudRules {
        int RuleID PK
        nvarchar RuleName
        nvarchar Severity
        decimal ThresholdAmount
    }

    FraudAlerts {
        int AlertID PK
        bigint TransactionID FK
        int CustomerID FK
        int AccountID FK
        int RuleID FK
        nvarchar Severity
        nvarchar Status
    }

    FraudScores {
        int ScoreID PK
        int CustomerID FK
        bigint TransactionID FK
        decimal Score
    }

    Customers ||--o{ KYCRecords : "identity"
    KYCRecords ||--o{ KYCDocuments : "documents"
    Customers ||--o{ ComplianceChecks : "checks"
    Customers ||--o{ ComplianceReports : "reports"
    FraudRules ||--o{ FraudAlerts : "triggered by"
    Customers ||--o{ FraudAlerts : "flagged"
    Transactions ||--o{ FraudAlerts : "on"
    Customers ||--o{ FraudScores : "scored"
```

## Auth, Notifications, Alerts, and Audit

```mermaid
---
config:
  theme: dark
  themeVariables:
    primaryColor: "#1e3a5f"
    primaryTextColor: "#ffffff"
    lineColor: "#4a7bb5"
---
erDiagram
    Users {
        int UserID PK
        nvarchar Username
        nvarchar PasswordHash
        nvarchar Email
        bit IsActive
    }

    Roles {
        int RoleID PK
        nvarchar RoleName
    }

    UserRoles {
        int UserID FK
        int RoleID FK
    }

    SessionTokens {
        int TokenID PK
        int UserID FK
        nvarchar Token
        datetime ExpiresAt
        nvarchar SourceSystem
    }

    NotificationTemplates {
        int TemplateID PK
        nvarchar TemplateName
        nvarchar Channel
    }

    NotificationQueue {
        int QueueID PK
        int CustomerID FK
        int TemplateID FK
        nvarchar Status
        int Priority
    }

    AlertRules {
        int RuleID PK
        nvarchar RuleName
        nvarchar RuleCode
        nvarchar Category
    }

    AccountAlerts {
        int AccountAlertID PK
        int CustomerID FK
        int AccountID FK
        int RuleID FK
    }

    AuditLog {
        bigint AuditID PK
        int ActionID FK
        nvarchar UserName
        nvarchar TableName
        datetime Timestamp
    }

    AuditActions {
        int ActionID PK
        nvarchar ActionName
        nvarchar Severity
    }

    Users ||--o{ UserRoles : "assigned"
    Roles ||--o{ UserRoles : "members"
    Users ||--o{ SessionTokens : "sessions"
    NotificationTemplates ||--o{ NotificationQueue : "template"
    Customers ||--o{ NotificationQueue : "recipient"
    AlertRules ||--o{ AccountAlerts : "rule"
    Customers ||--o{ AccountAlerts : "subscribed"
    AuditActions ||--o{ AuditLog : "action type"
```
