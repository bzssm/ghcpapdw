-- Verification Script for ZavaBankDB
-- Validates that all tables exist and contain expected seed data
-- Generated: 2026-05-14

USE [ZavaBankDB];
GO

PRINT '========================================';
PRINT 'ZavaBankDB Verification Report';
PRINT '========================================';
PRINT '';

-- Core Banking
SELECT 'AccountTypes' AS TableName, COUNT(*) AS RowCount FROM AccountTypes;
SELECT 'Customers' AS TableName, COUNT(*) AS RowCount FROM Customers;
SELECT 'Accounts' AS TableName, COUNT(*) AS RowCount FROM Accounts;

-- Transactions
SELECT 'TransactionTypes' AS TableName, COUNT(*) AS RowCount FROM TransactionTypes;
SELECT 'Transactions' AS TableName, COUNT(*) AS RowCount FROM Transactions;
SELECT 'TransactionArchive' AS TableName, COUNT(*) AS RowCount FROM TransactionArchive;

-- Loans
SELECT 'LoanProducts' AS TableName, COUNT(*) AS RowCount FROM LoanProducts;
SELECT 'LoanApplications' AS TableName, COUNT(*) AS RowCount FROM LoanApplications;
SELECT 'LoanDecisions' AS TableName, COUNT(*) AS RowCount FROM LoanDecisions;
SELECT 'LoanPayments' AS TableName, COUNT(*) AS RowCount FROM LoanPayments;

-- Payments
SELECT 'PaymentMethods' AS TableName, COUNT(*) AS RowCount FROM PaymentMethods;
SELECT 'Payments' AS TableName, COUNT(*) AS RowCount FROM Payments;
SELECT 'PaymentBatches' AS TableName, COUNT(*) AS RowCount FROM PaymentBatches;

-- KYC/Compliance
SELECT 'KYCRecords' AS TableName, COUNT(*) AS RowCount FROM KYCRecords;
SELECT 'KYCDocuments' AS TableName, COUNT(*) AS RowCount FROM KYCDocuments;
SELECT 'ComplianceChecks' AS TableName, COUNT(*) AS RowCount FROM ComplianceChecks;
SELECT 'ComplianceReports' AS TableName, COUNT(*) AS RowCount FROM ComplianceReports;

-- Fraud
SELECT 'FraudRules' AS TableName, COUNT(*) AS RowCount FROM FraudRules;
SELECT 'FraudAlerts' AS TableName, COUNT(*) AS RowCount FROM FraudAlerts;
SELECT 'FraudScores' AS TableName, COUNT(*) AS RowCount FROM FraudScores;

-- Risk
SELECT 'CreditScores' AS TableName, COUNT(*) AS RowCount FROM CreditScores;
SELECT 'RiskFactors' AS TableName, COUNT(*) AS RowCount FROM RiskFactors;
SELECT 'RiskAssessments' AS TableName, COUNT(*) AS RowCount FROM RiskAssessments;

-- Notifications
SELECT 'NotificationTemplates' AS TableName, COUNT(*) AS RowCount FROM NotificationTemplates;
SELECT 'NotificationQueue' AS TableName, COUNT(*) AS RowCount FROM NotificationQueue;
SELECT 'NotificationLog' AS TableName, COUNT(*) AS RowCount FROM NotificationLog;

-- File Staging
SELECT 'FileImports' AS TableName, COUNT(*) AS RowCount FROM FileImports;
SELECT 'CheckImages' AS TableName, COUNT(*) AS RowCount FROM CheckImages;
SELECT 'WireConfirmations' AS TableName, COUNT(*) AS RowCount FROM WireConfirmations;
SELECT 'RegulatoryFeeds' AS TableName, COUNT(*) AS RowCount FROM RegulatoryFeeds;

-- Audit
SELECT 'AuditActions' AS TableName, COUNT(*) AS RowCount FROM AuditActions;
SELECT 'AuditLog' AS TableName, COUNT(*) AS RowCount FROM AuditLog;

-- Currency
SELECT 'CurrencyPairs' AS TableName, COUNT(*) AS RowCount FROM CurrencyPairs;
SELECT 'ExchangeRates' AS TableName, COUNT(*) AS RowCount FROM ExchangeRates;

-- Statements
SELECT 'StatementRequests' AS TableName, COUNT(*) AS RowCount FROM StatementRequests;
SELECT 'StatementArchive' AS TableName, COUNT(*) AS RowCount FROM StatementArchive;

-- Alerts
SELECT 'AlertRules' AS TableName, COUNT(*) AS RowCount FROM AlertRules;
SELECT 'AccountAlerts' AS TableName, COUNT(*) AS RowCount FROM AccountAlerts;
SELECT 'AlertHistory' AS TableName, COUNT(*) AS RowCount FROM AlertHistory;

-- Auth
SELECT 'Users' AS TableName, COUNT(*) AS RowCount FROM Users;
SELECT 'Roles' AS TableName, COUNT(*) AS RowCount FROM Roles;
SELECT 'UserRoles' AS TableName, COUNT(*) AS RowCount FROM UserRoles;
SELECT 'SessionTokens' AS TableName, COUNT(*) AS RowCount FROM SessionTokens;

PRINT '';
PRINT '========================================';
PRINT 'Demo Scenario Verification';
PRINT '========================================';

-- Maria Rodriguez: pending loan
SELECT 'Maria Rodriguez - Pending Loan' AS Scenario,
       la.ApplicationID, la.Status, la.RequestedAmount
FROM LoanApplications la JOIN Customers c ON la.CustomerID = c.CustomerID
WHERE c.FirstName = 'Maria' AND c.LastName = 'Rodriguez' AND la.Status IN ('Submitted', 'UnderReview');

-- James Chen: fraud alerts
SELECT 'James Chen - Fraud Alerts' AS Scenario, COUNT(*) AS AlertCount
FROM FraudAlerts fa JOIN Customers c ON fa.CustomerID = c.CustomerID
WHERE c.FirstName = 'James' AND c.LastName = 'Chen';

-- Viktor Petrov: PEP hit
SELECT 'Viktor Petrov - PEP Check' AS Scenario, cc.Result
FROM ComplianceChecks cc JOIN Customers c ON cc.CustomerID = c.CustomerID
WHERE c.FirstName = 'Viktor' AND c.LastName = 'Petrov' AND cc.CheckType = 'PEP';

-- Sarah Miller: overdrawn
SELECT 'Sarah Miller - Overdrawn Account' AS Scenario, a.AccountNumber, a.Balance
FROM Accounts a JOIN Customers c ON a.CustomerID = c.CustomerID
WHERE c.FirstName = 'Sarah' AND c.LastName = 'Miller' AND a.Balance < 0;

-- David Park: denied loan
SELECT 'David Park - Denied Loan' AS Scenario, la.Status, la.RequestedAmount
FROM LoanApplications la JOIN Customers c ON la.CustomerID = c.CustomerID
WHERE c.FirstName = 'David' AND c.LastName = 'Park' AND la.Status = 'Denied';

-- Emily Johnson: funded loan
SELECT 'Emily Johnson - Funded Loan' AS Scenario, la.Status, la.ApprovedAmount
FROM LoanApplications la JOIN Customers c ON la.CustomerID = c.CustomerID
WHERE c.FirstName = 'Emily' AND c.LastName = 'Johnson' AND la.Status IN ('Funded', 'Closed');

-- David Park: locked out
SELECT 'David Park - Locked Out' AS Scenario, u.IsLockedOut, u.FailedLoginAttempts
FROM Users u WHERE u.Username = 'david.park';

PRINT '';
PRINT 'Verification complete.';
GO
