-- Performance Indexes for ZavaBankDB
-- Section 4 of database-topology.md

USE [ZavaBankDB];
GO

-- Core Banking
CREATE INDEX IX_Accounts_CustomerID ON Accounts(CustomerID);
GO
CREATE INDEX IX_Accounts_AccountNumber ON Accounts(AccountNumber);
GO

-- Transactions
CREATE INDEX IX_Transactions_AccountID ON Transactions(AccountID);
GO
CREATE INDEX IX_Transactions_TransactionDate ON Transactions(TransactionDate);
GO
CREATE INDEX IX_Transactions_ReferenceNumber ON Transactions(ReferenceNumber);
GO

-- Loans
CREATE INDEX IX_LoanApplications_CustomerID ON LoanApplications(CustomerID);
GO
CREATE INDEX IX_LoanPayments_ApplicationID ON LoanPayments(ApplicationID);
GO

-- Payments
CREATE INDEX IX_Payments_SourceAccountID ON Payments(SourceAccountID);
GO
CREATE INDEX IX_Payments_Status ON Payments(Status);
GO

-- KYC/Compliance
CREATE INDEX IX_KYCRecords_CustomerID ON KYCRecords(CustomerID);
GO
CREATE INDEX IX_ComplianceChecks_CustomerID ON ComplianceChecks(CustomerID);
GO

-- Fraud
CREATE INDEX IX_FraudAlerts_CustomerID ON FraudAlerts(CustomerID);
GO
CREATE INDEX IX_FraudAlerts_Status ON FraudAlerts(Status);
GO
CREATE INDEX IX_FraudScores_CustomerID ON FraudScores(CustomerID);
GO

-- Risk
CREATE INDEX IX_CreditScores_CustomerID ON CreditScores(CustomerID);
GO
CREATE INDEX IX_RiskAssessments_ApplicationID ON RiskAssessments(ApplicationID);
GO

-- Notifications
CREATE INDEX IX_NotificationQueue_Status ON NotificationQueue(Status);
GO
CREATE INDEX IX_NotificationQueue_ScheduledDate ON NotificationQueue(ScheduledDate);
GO

-- Audit
CREATE INDEX IX_AuditLog_Timestamp ON AuditLog(Timestamp);
GO
CREATE INDEX IX_AuditLog_UserName ON AuditLog(UserName);
GO
CREATE INDEX IX_AuditLog_TableName ON AuditLog(TableName);
GO

-- Currency
CREATE INDEX IX_ExchangeRates_PairID ON ExchangeRates(PairID);
GO
CREATE INDEX IX_ExchangeRates_EffectiveDate ON ExchangeRates(EffectiveDate);
GO

-- Statements
CREATE INDEX IX_StatementRequests_CustomerID ON StatementRequests(CustomerID);
GO
CREATE INDEX IX_StatementRequests_AccountID ON StatementRequests(AccountID);
GO

-- Alerts
CREATE INDEX IX_AccountAlerts_CustomerID ON AccountAlerts(CustomerID);
GO
CREATE INDEX IX_AccountAlerts_AccountID ON AccountAlerts(AccountID);
GO
CREATE INDEX IX_AlertHistory_TriggeredDate ON AlertHistory(TriggeredDate);
GO

-- File Staging
CREATE INDEX IX_FileImports_FileType ON FileImports(FileType);
GO
CREATE INDEX IX_FileImports_Status ON FileImports(Status);
GO
CREATE INDEX IX_FileImports_ImportedAt ON FileImports(ImportedAt);
GO
CREATE INDEX IX_CheckImages_CheckNumber ON CheckImages(CheckNumber);
GO
CREATE INDEX IX_CheckImages_AccountID ON CheckImages(AccountID);
GO
CREATE INDEX IX_CheckImages_ScanStatus ON CheckImages(ScanStatus);
GO
CREATE INDEX IX_WireConfirmations_TransactionID ON WireConfirmations(TransactionID);
GO
CREATE INDEX IX_WireConfirmations_ConfirmationNumber ON WireConfirmations(ConfirmationNumber);
GO
CREATE INDEX IX_RegulatoryFeeds_FeedType ON RegulatoryFeeds(FeedType);
GO
CREATE INDEX IX_RegulatoryFeeds_Status ON RegulatoryFeeds(Status);
GO
CREATE INDEX IX_RegulatoryFeeds_ReportingPeriod ON RegulatoryFeeds(ReportingPeriod);
GO

-- Auth
CREATE INDEX IX_Users_Username ON Users(Username);
GO
CREATE INDEX IX_Users_Email ON Users(Email);
GO
CREATE INDEX IX_SessionTokens_Token ON SessionTokens(Token);
GO
CREATE INDEX IX_SessionTokens_UserID ON SessionTokens(UserID);
GO
CREATE INDEX IX_SessionTokens_ExpiresAt ON SessionTokens(ExpiresAt);
GO
CREATE INDEX IX_UserRoles_RoleID ON UserRoles(RoleID);
GO

PRINT 'All indexes created successfully.';
GO
