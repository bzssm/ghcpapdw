USE [ZavaBankDB];
GO

-- ============================================================
-- 43-seed-misc.sql
-- Seeds: KYCRecords, KYCDocuments, ComplianceChecks,
--        ComplianceReports, FraudRules, FraudAlerts, FraudScores,
--        NotificationTemplates, NotificationQueue, NotificationLog,
--        AuditActions, AuditLog, CurrencyPairs, ExchangeRates,
--        StatementRequests, StatementArchive, AlertRules,
--        AccountAlerts, AlertHistory, PaymentBatches, Payments,
--        FileImports, CheckImages, WireConfirmations, RegulatoryFeeds
-- ============================================================

-- ----------------------------------------------------------
-- KYCRecords (50 rows – one per customer)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [KYCRecords] ON;
GO

-- Named customers 1-6
INSERT INTO KYCRecords (KYCID, CustomerID, VerificationLevel, Status, VerifiedDate, ExpiryDate, VerifiedBy, Notes, CreatedDate, ModifiedDate)
VALUES (1, 1, N'Enhanced', N'Verified', '2024-06-15', '2026-06-15', N'Lisa Wong', N'Maria Rodriguez – dual citizenship verified, enhanced due diligence complete', '2024-06-15', '2024-06-15');
INSERT INTO KYCRecords (KYCID, CustomerID, VerificationLevel, Status, VerifiedDate, ExpiryDate, VerifiedBy, Notes, CreatedDate, ModifiedDate)
VALUES (2, 2, N'Enhanced', N'UnderReview', '2024-09-20', '2026-09-20', N'Lisa Wong', N'James Chen – unusual transaction patterns flagged, AML review pending', '2024-09-20', '2025-04-01');
INSERT INTO KYCRecords (KYCID, CustomerID, VerificationLevel, Status, VerifiedDate, ExpiryDate, VerifiedBy, Notes, CreatedDate, ModifiedDate)
VALUES (3, 3, N'Enhanced', N'Verified', '2024-03-10', '2025-09-10', N'Mark Stevens', N'Viktor Petrov – PEP hit confirmed, enhanced monitoring in place', '2024-03-10', '2025-01-15');
INSERT INTO KYCRecords (KYCID, CustomerID, VerificationLevel, Status, VerifiedDate, ExpiryDate, VerifiedBy, Notes, CreatedDate, ModifiedDate)
VALUES (4, 4, N'Basic', N'Verified', '2024-08-01', '2026-08-01', N'Lisa Wong', N'Sarah Miller – standard verification complete', '2024-08-01', '2024-08-01');
INSERT INTO KYCRecords (KYCID, CustomerID, VerificationLevel, Status, VerifiedDate, ExpiryDate, VerifiedBy, Notes, CreatedDate, ModifiedDate)
VALUES (5, 5, N'Basic', N'Verified', '2024-07-22', '2026-07-22', N'Lisa Wong', N'David Park – standard verification complete', '2024-07-22', '2024-07-22');
INSERT INTO KYCRecords (KYCID, CustomerID, VerificationLevel, Status, VerifiedDate, ExpiryDate, VerifiedBy, Notes, CreatedDate, ModifiedDate)
VALUES (6, 6, N'Basic', N'Verified', '2024-11-05', '2026-11-05', N'Mark Stevens', N'Emily Johnson – standard verification complete', '2024-11-05', '2024-11-05');

-- Regular customers 7-50
DECLARE @k INT = 7;
WHILE @k <= 50
BEGIN
    INSERT INTO KYCRecords (KYCID, CustomerID, VerificationLevel, Status, VerifiedDate, ExpiryDate, VerifiedBy, Notes, CreatedDate, ModifiedDate)
    VALUES (@k, @k, N'Basic', N'Verified',
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365 - 180, '2025-05-14'),
            DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365 + 365, '2025-05-14'),
            CASE WHEN @k % 2 = 0 THEN N'Lisa Wong' ELSE N'Mark Stevens' END,
            N'Standard KYC verification complete',
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365 - 180, '2025-05-14'),
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365 - 180, '2025-05-14'));
    SET @k = @k + 1;
END;

SET IDENTITY_INSERT [KYCRecords] OFF;
GO

-- ----------------------------------------------------------
-- KYCDocuments (~80 rows – 1-2 docs per KYC record)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [KYCDocuments] ON;
GO

-- Named customers – explicit documents
INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
VALUES (1,  1, N'Passport',         N'US-MR-98231',   '2020-03-15', '2030-03-15', N'/docs/kyc/1/passport.pdf',       N'Verified',  '2024-06-15');
INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
VALUES (2,  1, N'UtilityBill',      N'UB-2024-0601',  '2024-06-01', NULL,          N'/docs/kyc/1/utility.pdf',        N'Verified',  '2024-06-15');
INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
VALUES (3,  2, N'DriversLicense',   N'DL-CA-JC4421',  '2021-11-10', '2029-11-10', N'/docs/kyc/2/dl.pdf',             N'Verified',  '2024-09-20');
INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
VALUES (4,  2, N'BankStatement',    N'BS-2024-0901',  '2024-09-01', NULL,          N'/docs/kyc/2/bankstmt.pdf',       N'Verified',  '2024-09-20');
INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
VALUES (5,  3, N'Passport',         N'RU-VP-55102',   '2019-07-22', '2029-07-22', N'/docs/kyc/3/passport.pdf',       N'Verified',  '2024-03-10');
INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
VALUES (6,  3, N'AddressProof',     N'AP-VP-2024',    '2024-02-28', NULL,          N'/docs/kyc/3/address.pdf',        N'Verified',  '2024-03-10');
INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
VALUES (7,  4, N'DriversLicense',   N'DL-TX-SM7789',  '2022-04-18', '2030-04-18', N'/docs/kyc/4/dl.pdf',             N'Verified',  '2024-08-01');
INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
VALUES (8,  5, N'Passport',         N'US-DP-33210',   '2021-01-05', '2031-01-05', N'/docs/kyc/5/passport.pdf',       N'Verified',  '2024-07-22');
INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
VALUES (9,  5, N'SSNVerification',  N'SSN-V-DP-2024', '2024-07-22', NULL,          N'/docs/kyc/5/ssn.pdf',            N'Verified',  '2024-07-22');
INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
VALUES (10, 6, N'DriversLicense',   N'DL-WA-EJ1155',  '2023-02-14', '2031-02-14', N'/docs/kyc/6/dl.pdf',             N'Verified',  '2024-11-05');
INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
VALUES (11, 6, N'UtilityBill',      N'UB-2024-1001',  '2024-10-01', NULL,          N'/docs/kyc/6/utility.pdf',        N'Verified',  '2024-11-05');

-- Bulk documents for customers 7-50
DECLARE @d INT = 12;
DECLARE @kk INT = 7;
WHILE @kk <= 50
BEGIN
    INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
    VALUES (@d, @kk,
            CASE @kk % 3 WHEN 0 THEN N'Passport' WHEN 1 THEN N'DriversLicense' ELSE N'StateID' END,
            N'DOC-' + RIGHT('000' + CAST(@kk AS VARCHAR), 3),
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 1000 - 365, '2025-05-14'),
            DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 2000 + 365, '2025-05-14'),
            N'/docs/kyc/' + CAST(@kk AS NVARCHAR) + N'/doc1.pdf',
            N'Verified',
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365 - 180, '2025-05-14'));
    SET @d = @d + 1;

    -- Second document for ~60% of customers
    IF @kk % 5 <> 0
    BEGIN
        INSERT INTO KYCDocuments (DocumentID, KYCID, DocumentType, DocumentNumber, IssuedDate, ExpiryDate, FilePath, VerificationStatus, CreatedDate)
        VALUES (@d, @kk,
                N'UtilityBill',
                N'UB-' + RIGHT('000' + CAST(@kk AS VARCHAR), 3),
                DATEADD(MONTH, -ABS(CHECKSUM(NEWID())) % 6, '2025-05-14'),
                NULL,
                N'/docs/kyc/' + CAST(@kk AS NVARCHAR) + N'/doc2.pdf',
                N'Verified',
                DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365 - 180, '2025-05-14'));
        SET @d = @d + 1;
    END;

    SET @kk = @kk + 1;
END;

SET IDENTITY_INSERT [KYCDocuments] OFF;
GO

-- ----------------------------------------------------------
-- ComplianceChecks (~60 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [ComplianceChecks] ON;
GO

-- Viktor Petrov – PEP hit
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (1, 3, N'PEP Screening', N'Hit', N'Match found: Viktor Petrov – associate of government officials in Eastern Europe. Enhanced due diligence required.', '2024-03-10', N'ComplianceBot', N'PEP-2024-00312');
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (2, 3, N'Sanctions Check', N'Clear', N'No OFAC/EU sanctions match found', '2024-03-10', N'ComplianceBot', N'SAN-2024-00312');
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (3, 3, N'Enhanced Due Diligence', N'Completed', N'EDD completed: source of wealth verified, ongoing monitoring established', '2024-04-05', N'Mark Stevens', N'EDD-2024-00103');

-- James Chen – AML pending
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (4, 2, N'AML Review', N'Pending', N'Multiple structured deposits detected below $10k threshold – potential structuring', '2025-04-01', N'Lisa Wong', N'AML-2025-00218');
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (5, 2, N'PEP Screening', N'Clear', N'No PEP matches found', '2024-09-20', N'ComplianceBot', N'PEP-2024-00910');
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (6, 2, N'Sanctions Check', N'Clear', N'No OFAC/EU sanctions match found', '2024-09-20', N'ComplianceBot', N'SAN-2024-00910');

-- Maria Rodriguez
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (7, 1, N'PEP Screening', N'Clear', N'No PEP matches found', '2024-06-15', N'ComplianceBot', N'PEP-2024-00615');
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (8, 1, N'Sanctions Check', N'Clear', N'No OFAC/EU sanctions match found', '2024-06-15', N'ComplianceBot', N'SAN-2024-00615');
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (9, 1, N'AML Review', N'Clear', N'No suspicious activity detected', '2024-06-20', N'Lisa Wong', N'AML-2024-00615');

-- Sarah Miller
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (10, 4, N'PEP Screening', N'Clear', N'No PEP matches found', '2024-08-01', N'ComplianceBot', N'PEP-2024-00801');
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (11, 4, N'Sanctions Check', N'Clear', N'No OFAC/EU sanctions match found', '2024-08-01', N'ComplianceBot', N'SAN-2024-00801');

-- David Park
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (12, 5, N'PEP Screening', N'Clear', N'No PEP matches found', '2024-07-22', N'ComplianceBot', N'PEP-2024-00722');
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (13, 5, N'Sanctions Check', N'Clear', N'No OFAC/EU sanctions match found', '2024-07-22', N'ComplianceBot', N'SAN-2024-00722');

-- Emily Johnson
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (14, 6, N'PEP Screening', N'Clear', N'No PEP matches found', '2024-11-05', N'ComplianceBot', N'PEP-2024-01105');
INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
VALUES (15, 6, N'Sanctions Check', N'Clear', N'No OFAC/EU sanctions match found', '2024-11-05', N'ComplianceBot', N'SAN-2024-01105');

-- Bulk compliance checks for customers 7-50
DECLARE @cc INT = 16;
DECLARE @cust INT = 7;
WHILE @cust <= 50
BEGIN
    INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
    VALUES (@cc, @cust, N'PEP Screening', N'Clear', N'No PEP matches found',
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365 - 90, '2025-05-14'),
            N'ComplianceBot',
            N'PEP-' + RIGHT('0000' + CAST(@cc AS VARCHAR), 4));
    SET @cc = @cc + 1;

    INSERT INTO ComplianceChecks (CheckID, CustomerID, CheckType, Result, Details, CheckedDate, CheckedBy, ExternalRefID)
    VALUES (@cc, @cust, N'Sanctions Check', N'Clear', N'No OFAC/EU sanctions match found',
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365 - 90, '2025-05-14'),
            N'ComplianceBot',
            N'SAN-' + RIGHT('0000' + CAST(@cc AS VARCHAR), 4));
    SET @cc = @cc + 1;

    SET @cust = @cust + 1;
END;

SET IDENTITY_INSERT [ComplianceChecks] OFF;
GO

-- ----------------------------------------------------------
-- ComplianceReports (10 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [ComplianceReports] ON;
GO

INSERT INTO ComplianceReports (ReportID, ReportType, CustomerID, FilingDate, Status, ReportData, FiledBy, RegulatoryBody, CreatedDate)
VALUES (1, N'SAR', 3, '2024-04-15', N'Filed', N'Suspicious activity report for Viktor Petrov – PEP match with international wire transfers', N'Mark Stevens', N'FinCEN', '2024-04-15');
INSERT INTO ComplianceReports (ReportID, ReportType, CustomerID, FilingDate, Status, ReportData, FiledBy, RegulatoryBody, CreatedDate)
VALUES (2, N'SAR', 2, '2025-04-10', N'Draft', N'Suspicious activity report for James Chen – potential structuring of deposits below $10k threshold', N'Lisa Wong', N'FinCEN', '2025-04-10');
INSERT INTO ComplianceReports (ReportID, ReportType, CustomerID, FilingDate, Status, ReportData, FiledBy, RegulatoryBody, CreatedDate)
VALUES (3, N'CTR', 1, '2024-07-02', N'Filed', N'Currency transaction report for Maria Rodriguez – $15,000 cash deposit', N'Lisa Wong', N'FinCEN', '2024-07-02');
INSERT INTO ComplianceReports (ReportID, ReportType, CustomerID, FilingDate, Status, ReportData, FiledBy, RegulatoryBody, CreatedDate)
VALUES (4, N'CTR', 3, '2024-05-20', N'Filed', N'Currency transaction report for Viktor Petrov – $25,000 wire transfer', N'Mark Stevens', N'FinCEN', '2024-05-20');
INSERT INTO ComplianceReports (ReportID, ReportType, CustomerID, FilingDate, Status, ReportData, FiledBy, RegulatoryBody, CreatedDate)
VALUES (5, N'AnnualReview', NULL, '2025-01-15', N'Completed', N'Annual BSA/AML compliance review – all policies current, 3 SARs filed in period', N'Mark Stevens', N'OCC', '2025-01-15');
INSERT INTO ComplianceReports (ReportID, ReportType, CustomerID, FilingDate, Status, ReportData, FiledBy, RegulatoryBody, CreatedDate)
VALUES (6, N'CTR', 5, '2024-12-10', N'Filed', N'Currency transaction report for David Park – $12,500 cash deposit', N'Lisa Wong', N'FinCEN', '2024-12-10');
INSERT INTO ComplianceReports (ReportID, ReportType, CustomerID, FilingDate, Status, ReportData, FiledBy, RegulatoryBody, CreatedDate)
VALUES (7, N'AnnualReview', NULL, '2024-01-20', N'Completed', N'2023 Annual BSA/AML compliance review', N'Mark Stevens', N'OCC', '2024-01-20');
INSERT INTO ComplianceReports (ReportID, ReportType, CustomerID, FilingDate, Status, ReportData, FiledBy, RegulatoryBody, CreatedDate)
VALUES (8, N'RiskAssessment', NULL, '2025-03-01', N'Completed', N'Enterprise-wide risk assessment – medium risk rating maintained', N'Mark Stevens', N'OCC', '2025-03-01');
INSERT INTO ComplianceReports (ReportID, ReportType, CustomerID, FilingDate, Status, ReportData, FiledBy, RegulatoryBody, CreatedDate)
VALUES (9, N'SAR', 3, '2025-02-28', N'Filed', N'Follow-up SAR for Viktor Petrov – continued PEP-related transactions', N'Mark Stevens', N'FinCEN', '2025-02-28');
INSERT INTO ComplianceReports (ReportID, ReportType, CustomerID, FilingDate, Status, ReportData, FiledBy, RegulatoryBody, CreatedDate)
VALUES (10, N'AuditReport', NULL, '2024-06-30', N'Completed', N'Internal audit of KYC procedures – minor findings remediated', N'External Auditors', N'Internal', '2024-06-30');

SET IDENTITY_INSERT [ComplianceReports] OFF;
GO

-- ----------------------------------------------------------
-- FraudRules (10 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [FraudRules] ON;
GO

INSERT INTO FraudRules (RuleID, RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
VALUES (1,  N'Large Transaction',          N'Single transaction exceeds threshold',                    N'Amount > @Threshold',                         N'High',     1, 10000.00,  NULL, '2024-01-01', '2024-01-01');
INSERT INTO FraudRules (RuleID, RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
VALUES (2,  N'Rapid Succession',           N'Multiple transactions in short time window',              N'COUNT(TxnInWindow) > 5',                      N'Medium',   1, NULL,      30,   '2024-01-01', '2024-01-01');
INSERT INTO FraudRules (RuleID, RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
VALUES (3,  N'Structuring Detection',      N'Multiple deposits just below $10,000 reporting threshold',N'SUM(Deposits) BETWEEN 8000 AND 9999 PER DAY', N'Critical', 1, 9999.00,   1440, '2024-01-01', '2024-01-01');
INSERT INTO FraudRules (RuleID, RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
VALUES (4,  N'International Wire High',    N'International wire transfer exceeds threshold',           N'WireAmount > @Threshold AND Type=INTL',       N'High',     1, 25000.00,  NULL, '2024-01-01', '2024-01-01');
INSERT INTO FraudRules (RuleID, RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
VALUES (5,  N'Velocity Check',             N'Spending velocity exceeds normal pattern',                N'DailySpend > 3 * AvgDailySpend',              N'Medium',   1, NULL,      1440, '2024-01-01', '2024-01-01');
INSERT INTO FraudRules (RuleID, RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
VALUES (6,  N'Geo Anomaly',               N'Transaction from unusual geographic location',            N'TxnLocation NOT IN CustomerProfile',          N'Medium',   1, NULL,      NULL, '2024-01-01', '2024-01-01');
INSERT INTO FraudRules (RuleID, RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
VALUES (7,  N'New Account High Value',     N'High-value transaction on account less than 30 days old', N'AccountAge < 30 AND Amount > @Threshold',     N'High',     1, 5000.00,   NULL, '2024-01-01', '2024-01-01');
INSERT INTO FraudRules (RuleID, RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
VALUES (8,  N'Dormant Account Activity',   N'Activity on account dormant for >90 days',               N'LastTxnDate > 90 days ago',                   N'Medium',   1, NULL,      NULL, '2024-01-01', '2024-01-01');
INSERT INTO FraudRules (RuleID, RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
VALUES (9,  N'Round Amount Pattern',       N'Repeated round-dollar transactions',                     N'Amount MOD 100 = 0 AND COUNT > 3',            N'Low',      1, NULL,      1440, '2024-01-01', '2024-01-01');
INSERT INTO FraudRules (RuleID, RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
VALUES (10, N'Cross-Border Mismatch',      N'Wire destination country does not match customer profile',N'DestCountry NOT IN ProfileCountries',          N'High',     1, NULL,      NULL, '2024-01-01', '2024-01-01');

SET IDENTITY_INSERT [FraudRules] OFF;
GO

-- ----------------------------------------------------------
-- FraudAlerts (15 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [FraudAlerts] ON;
GO

-- James Chen alerts (CustomerID=2, AccountID=3 checking, 4 savings)
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (1, NULL, 2, 3, 3, N'Structuring', N'Critical', N'Open', N'Three deposits of $9,500, $9,800, and $9,700 within 48 hours – potential structuring', N'Lisa Wong', NULL, NULL, '2025-03-28', '2025-03-28');
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (2, NULL, 2, 3, 1, N'LargeTransaction', N'High', N'Investigating', N'$15,000 wire transfer to unrecognized beneficiary', N'Lisa Wong', NULL, NULL, '2025-04-02', '2025-04-05');
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (3, NULL, 2, 4, 2, N'RapidSuccession', N'Medium', N'Resolved', N'6 ATM withdrawals in 25 minutes from different locations', N'Lisa Wong', '2025-02-20', N'Customer confirmed legitimate travel withdrawals', '2025-02-18', '2025-02-20');
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (4, NULL, 2, 3, 5, N'Velocity', N'Medium', N'Open', N'Daily spending 4.2x average – unusual pattern', N'Lisa Wong', NULL, NULL, '2025-04-08', '2025-04-08');

-- Viktor Petrov alerts (CustomerID=3, AccountID=5 checking, 6 savings)
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (5, NULL, 3, 5, 4, N'InternationalWire', N'High', N'Resolved', N'$35,000 international wire to Moscow – PEP customer', N'Mark Stevens', '2024-06-15', N'Wire verified through EDD process', '2024-06-10', '2024-06-15');
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (6, NULL, 3, 5, 10, N'CrossBorder', N'High', N'Investigating', N'Wire to Cyprus not matching customer profile countries', N'Mark Stevens', NULL, NULL, '2025-03-15', '2025-03-20');

-- Other customers
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (7,  NULL, 1, 1, 1, N'LargeTransaction', N'High', N'Resolved', N'$15,000 deposit flagged – CTR filed', N'Lisa Wong', '2024-07-05', N'Legitimate business income verified', '2024-07-01', '2024-07-05');
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (8,  NULL, 5, 9, 6, N'GeoAnomaly', N'Medium', N'Resolved', N'POS transaction from overseas – customer notified', N'Lisa Wong', '2024-12-05', N'Customer confirmed vacation travel', '2024-12-01', '2024-12-05');
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (9,  NULL, 4, 7, 8, N'DormantAccount', N'Medium', N'Resolved', N'Activity after 95 days of dormancy', N'Mark Stevens', '2025-01-10', N'Customer resumed normal usage', '2025-01-05', '2025-01-10');
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (10, NULL, 6, 11, 9, N'RoundAmount', N'Low', N'Dismissed', N'Three $500 transfers in one day – customer regularly sends rent', N'Lisa Wong', '2025-02-01', N'Normal recurring pattern', '2025-01-28', '2025-02-01');
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (11, NULL, 7,  14, 7, N'NewAccountHighValue', N'High', N'Resolved', N'$8,000 deposit on 2-week-old account', N'Mark Stevens', '2025-03-05', N'Employment bonus verified', '2025-02-28', '2025-03-05');
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (12, NULL, 10, 20, 2, N'RapidSuccession', N'Medium', N'Resolved', N'5 transactions in 10 minutes', N'Lisa Wong', '2025-01-22', N'Online shopping spree confirmed', '2025-01-20', '2025-01-22');
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (13, NULL, 15, 30, 6, N'GeoAnomaly', N'Medium', N'Open', N'ATM withdrawal in Eastern Europe – unusual for profile', N'Mark Stevens', NULL, NULL, '2025-04-20', '2025-04-20');
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (14, NULL, 20, 40, 1, N'LargeTransaction', N'High', N'Resolved', N'$12,000 check deposit', N'Lisa Wong', '2025-03-18', N'Insurance payout verified', '2025-03-15', '2025-03-18');
INSERT INTO FraudAlerts (AlertID, TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate)
VALUES (15, NULL, 25, 50, 5, N'Velocity', N'Medium', N'Dismissed', N'Spending spike – holiday season', N'Mark Stevens', '2024-12-28', N'Seasonal pattern confirmed', '2024-12-26', '2024-12-28');

SET IDENTITY_INSERT [FraudAlerts] OFF;
GO

-- ----------------------------------------------------------
-- FraudScores (~50 rows – one per customer)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [FraudScores] ON;
GO

-- Named customers with specific scores
INSERT INTO FraudScores (ScoreID, CustomerID, TransactionID, Score, ModelVersion, Factors, EvaluatedDate)
VALUES (1, 1, NULL, 12.00, N'v2.3', N'{"history":"clean","txn_pattern":"normal","kyc":"enhanced_verified"}', '2025-04-15');
INSERT INTO FraudScores (ScoreID, CustomerID, TransactionID, Score, ModelVersion, Factors, EvaluatedDate)
VALUES (2, 2, NULL, 82.50, N'v2.3', N'{"structuring_signals":"high","velocity":"elevated","aml_review":"pending"}', '2025-04-15');
INSERT INTO FraudScores (ScoreID, CustomerID, TransactionID, Score, ModelVersion, Factors, EvaluatedDate)
VALUES (3, 3, NULL, 65.00, N'v2.3', N'{"pep_match":"confirmed","intl_wires":"high","geo_risk":"elevated"}', '2025-04-15');
INSERT INTO FraudScores (ScoreID, CustomerID, TransactionID, Score, ModelVersion, Factors, EvaluatedDate)
VALUES (4, 4, NULL, 8.50,  N'v2.3', N'{"history":"clean","txn_pattern":"normal","kyc":"basic_verified"}', '2025-04-15');
INSERT INTO FraudScores (ScoreID, CustomerID, TransactionID, Score, ModelVersion, Factors, EvaluatedDate)
VALUES (5, 5, NULL, 15.00, N'v2.3', N'{"history":"clean","geo_anomaly":"resolved","kyc":"basic_verified"}', '2025-04-15');
INSERT INTO FraudScores (ScoreID, CustomerID, TransactionID, Score, ModelVersion, Factors, EvaluatedDate)
VALUES (6, 6, NULL, 5.20,  N'v2.3', N'{"history":"clean","txn_pattern":"normal","kyc":"basic_verified"}', '2025-04-15');

-- Bulk scores for customers 7-50
DECLARE @fs INT = 7;
WHILE @fs <= 50
BEGIN
    INSERT INTO FraudScores (ScoreID, CustomerID, TransactionID, Score, ModelVersion, Factors, EvaluatedDate)
    VALUES (@fs, @fs, NULL,
            CAST(ABS(CHECKSUM(NEWID())) % 30 + 2 AS DECIMAL(5,2)),
            N'v2.3',
            N'{"history":"clean","txn_pattern":"normal"}',
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 30, '2025-05-14'));
    SET @fs = @fs + 1;
END;

SET IDENTITY_INSERT [FraudScores] OFF;
GO

-- ----------------------------------------------------------
-- NotificationTemplates (12 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [NotificationTemplates] ON;
GO

INSERT INTO NotificationTemplates (TemplateID, TemplateName, TemplateCode, Channel, Subject, BodyTemplate, IsActive, CreatedDate)
VALUES (1,  N'Welcome Email',            N'WELCOME_EMAIL',        N'Email', N'Welcome to ZavaBank!',             N'Dear {{CustomerName}}, Welcome to ZavaBank. Your account is now active.', 1, '2024-01-01');
INSERT INTO NotificationTemplates (TemplateID, TemplateName, TemplateCode, Channel, Subject, BodyTemplate, IsActive, CreatedDate)
VALUES (2,  N'Transaction Alert Email',  N'TXN_ALERT_EMAIL',      N'Email', N'Transaction Alert',                N'A {{TransactionType}} of {{Amount}} was posted to your account {{AccountNumber}}.', 1, '2024-01-01');
INSERT INTO NotificationTemplates (TemplateID, TemplateName, TemplateCode, Channel, Subject, BodyTemplate, IsActive, CreatedDate)
VALUES (3,  N'Transaction Alert SMS',    N'TXN_ALERT_SMS',        N'SMS',   NULL,                                N'ZavaBank: {{TransactionType}} of {{Amount}} on acct ending {{Last4}}.', 1, '2024-01-01');
INSERT INTO NotificationTemplates (TemplateID, TemplateName, TemplateCode, Channel, Subject, BodyTemplate, IsActive, CreatedDate)
VALUES (4,  N'Low Balance Alert',        N'LOW_BAL_EMAIL',        N'Email', N'Low Balance Alert',                N'Your account {{AccountNumber}} balance is {{Balance}}, below your threshold of {{Threshold}}.', 1, '2024-01-01');
INSERT INTO NotificationTemplates (TemplateID, TemplateName, TemplateCode, Channel, Subject, BodyTemplate, IsActive, CreatedDate)
VALUES (5,  N'Low Balance SMS',          N'LOW_BAL_SMS',          N'SMS',   NULL,                                N'ZavaBank: Low balance alert. Acct ending {{Last4}} balance is {{Balance}}.', 1, '2024-01-01');
INSERT INTO NotificationTemplates (TemplateID, TemplateName, TemplateCode, Channel, Subject, BodyTemplate, IsActive, CreatedDate)
VALUES (6,  N'Fraud Alert Email',        N'FRAUD_ALERT_EMAIL',    N'Email', N'Security Alert – Action Required', N'We detected unusual activity on your account. Please review transaction {{TransactionID}}.', 1, '2024-01-01');
INSERT INTO NotificationTemplates (TemplateID, TemplateName, TemplateCode, Channel, Subject, BodyTemplate, IsActive, CreatedDate)
VALUES (7,  N'Fraud Alert SMS',          N'FRAUD_ALERT_SMS',      N'SMS',   NULL,                                N'ZavaBank SECURITY: Unusual activity detected. Call 1-800-ZAVA immediately.', 1, '2024-01-01');
INSERT INTO NotificationTemplates (TemplateID, TemplateName, TemplateCode, Channel, Subject, BodyTemplate, IsActive, CreatedDate)
VALUES (8,  N'Payment Confirmation',     N'PMT_CONFIRM_EMAIL',    N'Email', N'Payment Confirmed',                N'Your payment of {{Amount}} to {{PayeeName}} has been processed. Ref: {{ReferenceNumber}}.', 1, '2024-01-01');
INSERT INTO NotificationTemplates (TemplateID, TemplateName, TemplateCode, Channel, Subject, BodyTemplate, IsActive, CreatedDate)
VALUES (9,  N'Statement Ready',          N'STMT_READY_EMAIL',     N'Email', N'Your Statement is Ready',          N'Your {{StatementType}} statement for {{Period}} is now available for download.', 1, '2024-01-01');
INSERT INTO NotificationTemplates (TemplateID, TemplateName, TemplateCode, Channel, Subject, BodyTemplate, IsActive, CreatedDate)
VALUES (10, N'KYC Reminder',            N'KYC_REMINDER_EMAIL',   N'Email', N'Document Verification Required',   N'Please update your KYC documents. Current verification expires on {{ExpiryDate}}.', 1, '2024-01-01');
INSERT INTO NotificationTemplates (TemplateID, TemplateName, TemplateCode, Channel, Subject, BodyTemplate, IsActive, CreatedDate)
VALUES (11, N'Overdraft Notice',         N'OVERDRAFT_EMAIL',      N'Email', N'Overdraft Notice',                 N'Your account {{AccountNumber}} has been overdrawn by {{OverdraftAmount}}. Please deposit funds.', 1, '2024-01-01');
INSERT INTO NotificationTemplates (TemplateID, TemplateName, TemplateCode, Channel, Subject, BodyTemplate, IsActive, CreatedDate)
VALUES (12, N'Loan Payment Reminder',    N'LOAN_PMT_EMAIL',       N'Email', N'Loan Payment Due',                 N'Your loan payment of {{Amount}} is due on {{DueDate}}. Loan #{{LoanNumber}}.', 1, '2024-01-01');

SET IDENTITY_INSERT [NotificationTemplates] OFF;
GO

-- ----------------------------------------------------------
-- NotificationQueue (~100 rows via WHILE loop)
-- ----------------------------------------------------------
DECLARE @nq INT = 1;
DECLARE @nqCust INT;
DECLARE @nqTemplate INT;
DECLARE @nqChannel NVARCHAR(20);
DECLARE @nqStatus NVARCHAR(20);

WHILE @nq <= 100
BEGIN
    SET @nqCust = CASE
        WHEN @nq <= 10 THEN (@nq % 6) + 1
        ELSE ((@nq - 1) % 50) + 1
    END;

    SET @nqTemplate = ((@nq - 1) % 12) + 1;

    SET @nqChannel = CASE WHEN @nqTemplate IN (3, 5, 7) THEN N'SMS' ELSE N'Email' END;

    SET @nqStatus = CASE
        WHEN @nq % 10 = 0 THEN N'Failed'
        WHEN @nq % 5 = 0  THEN N'Queued'
        WHEN @nq % 3 = 0  THEN N'Processing'
        ELSE N'Sent'
    END;

    INSERT INTO NotificationQueue (CustomerID, TemplateID, Channel, Recipient, Subject, Body, Status, Priority, ScheduledDate, AttemptCount, MaxAttempts, LastAttemptDate, ErrorMessage, CreatedDate)
    VALUES (@nqCust, @nqTemplate, @nqChannel,
            CASE WHEN @nqChannel = N'SMS' THEN N'+1555' + RIGHT('0000000' + CAST(1000000 + @nqCust AS VARCHAR), 7) ELSE N'customer' + CAST(@nqCust AS NVARCHAR) + N'@example.com' END,
            CASE WHEN @nqChannel = N'SMS' THEN NULL ELSE N'ZavaBank Notification' END,
            N'Notification body for queue item ' + CAST(@nq AS NVARCHAR),
            @nqStatus,
            CASE WHEN @nqTemplate IN (6, 7) THEN 1 WHEN @nqTemplate IN (4, 5, 11) THEN 3 ELSE 5 END,
            DATEADD(HOUR, -@nq * 2, '2025-05-14'),
            CASE WHEN @nqStatus = N'Failed' THEN 3 WHEN @nqStatus = N'Sent' THEN 1 ELSE 0 END,
            3,
            CASE WHEN @nqStatus IN (N'Sent', N'Failed') THEN DATEADD(HOUR, -@nq * 2 + 1, '2025-05-14') ELSE NULL END,
            CASE WHEN @nqStatus = N'Failed' THEN N'SMTP connection timeout after 30s' ELSE NULL END,
            DATEADD(HOUR, -@nq * 2, '2025-05-14'));

    SET @nq = @nq + 1;
END;
GO

-- ----------------------------------------------------------
-- NotificationLog (~80 rows via WHILE loop)
-- ----------------------------------------------------------
DECLARE @nl INT = 1;
DECLARE @nlCust INT;
DECLARE @nlStatus NVARCHAR(20);

WHILE @nl <= 80
BEGIN
    SET @nlCust = ((@nl - 1) % 50) + 1;

    SET @nlStatus = CASE
        WHEN @nl % 12 = 0 THEN N'Failed'
        WHEN @nl % 8 = 0  THEN N'Bounced'
        ELSE N'Delivered'
    END;

    INSERT INTO NotificationLog (QueueID, CustomerID, Channel, Recipient, Status, SentDate, ResponseCode, ErrorDetails)
    VALUES (
        CASE WHEN @nl <= 100 THEN @nl ELSE NULL END,
        @nlCust,
        CASE WHEN @nl % 4 = 0 THEN N'SMS' ELSE N'Email' END,
        CASE WHEN @nl % 4 = 0 THEN N'+1555' + RIGHT('0000000' + CAST(1000000 + @nlCust AS VARCHAR), 7)
             ELSE N'customer' + CAST(@nlCust AS NVARCHAR) + N'@example.com' END,
        @nlStatus,
        DATEADD(HOUR, -@nl * 3, '2025-05-14'),
        CASE @nlStatus WHEN N'Delivered' THEN N'250 OK' WHEN N'Failed' THEN N'550 Mailbox unavailable' ELSE N'452 Too many recipients' END,
        CASE WHEN @nlStatus <> N'Delivered' THEN N'Delivery failure for notification log entry ' + CAST(@nl AS NVARCHAR) ELSE NULL END);

    SET @nl = @nl + 1;
END;
GO

-- ----------------------------------------------------------
-- AuditActions (15 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [AuditActions] ON;
GO

INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (1,  N'Login',              N'User logged in',                           N'Info');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (2,  N'Logout',             N'User logged out',                          N'Info');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (3,  N'FailedLogin',        N'Failed login attempt',                     N'Warning');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (4,  N'PasswordChange',     N'Password was changed',                     N'Info');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (5,  N'AccountCreated',     N'New account created',                      N'Info');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (6,  N'AccountModified',    N'Account details modified',                 N'Info');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (7,  N'TransferInitiated',  N'Fund transfer initiated',                  N'Info');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (8,  N'TransferCompleted',  N'Fund transfer completed',                  N'Info');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (9,  N'FraudAlertCreated',  N'Fraud alert was generated',                N'Warning');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (10, N'FraudAlertResolved', N'Fraud alert was resolved',                 N'Info');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (11, N'KYCUpdated',         N'KYC record was updated',                   N'Info');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (12, N'ComplianceFiled',    N'Compliance report was filed',              N'Info');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (13, N'PermissionChanged',  N'User permissions were changed',            N'Critical');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (14, N'DataExported',       N'Customer data was exported',               N'Warning');
INSERT INTO AuditActions (ActionID, ActionName, Description, Severity) VALUES (15, N'SystemConfig',       N'System configuration was changed',         N'Critical');

SET IDENTITY_INSERT [AuditActions] OFF;
GO

-- ----------------------------------------------------------
-- AuditLog (~500 rows via WHILE loop)
-- ----------------------------------------------------------
DECLARE @al INT = 1;
DECLARE @alAction INT;
DECLARE @alUser NVARCHAR(100);
DECLARE @alTable NVARCHAR(128);

WHILE @al <= 500
BEGIN
    SET @alAction = CASE
        WHEN @al % 20 = 0 THEN 3   -- FailedLogin
        WHEN @al % 15 = 0 THEN 9   -- FraudAlertCreated
        WHEN @al % 12 = 0 THEN 7   -- TransferInitiated
        WHEN @al % 10 = 0 THEN 8   -- TransferCompleted
        WHEN @al % 7 = 0  THEN 4   -- PasswordChange
        WHEN @al % 5 = 0  THEN 6   -- AccountModified
        WHEN @al % 3 = 0  THEN 2   -- Logout
        ELSE 1                       -- Login
    END;

    SET @alUser = CASE @al % 8
        WHEN 0 THEN N'maria.rodriguez'
        WHEN 1 THEN N'james.chen'
        WHEN 2 THEN N'viktor.petrov'
        WHEN 3 THEN N'sarah.miller'
        WHEN 4 THEN N'david.park'
        WHEN 5 THEN N'emily.johnson'
        WHEN 6 THEN N'admin.system'
        WHEN 7 THEN N'teller.branch01'
    END;

    SET @alTable = CASE @alAction
        WHEN 1  THEN N'UserSessions'
        WHEN 2  THEN N'UserSessions'
        WHEN 3  THEN N'UserSessions'
        WHEN 4  THEN N'Users'
        WHEN 5  THEN N'Accounts'
        WHEN 6  THEN N'Accounts'
        WHEN 7  THEN N'Transactions'
        WHEN 8  THEN N'Transactions'
        WHEN 9  THEN N'FraudAlerts'
        WHEN 10 THEN N'FraudAlerts'
        WHEN 11 THEN N'KYCRecords'
        WHEN 12 THEN N'ComplianceReports'
        WHEN 13 THEN N'Users'
        WHEN 14 THEN N'Customers'
        WHEN 15 THEN N'SystemConfig'
        ELSE N'General'
    END;

    INSERT INTO AuditLog (ActionID, UserName, IPAddress, TableName, RecordID, OldValues, NewValues, Description, [Timestamp], SessionID, MachineName)
    VALUES (@alAction, @alUser,
            N'10.0.' + CAST((@al % 5) + 1 AS NVARCHAR) + N'.' + CAST((@al % 254) + 1 AS NVARCHAR),
            @alTable,
            CAST(((@al - 1) % 50) + 1 AS NVARCHAR),
            CASE WHEN @alAction IN (4, 6) THEN N'{"previous":"value_' + CAST(@al AS NVARCHAR) + N'"}' ELSE NULL END,
            CASE WHEN @alAction IN (4, 5, 6) THEN N'{"updated":"value_' + CAST(@al AS NVARCHAR) + N'"}' ELSE NULL END,
            N'Audit entry ' + CAST(@al AS NVARCHAR) + N' – ' + @alTable,
            DATEADD(MINUTE, -@al * 15, '2025-05-14 17:00:00'),
            N'SID-' + RIGHT('00000' + CAST(ABS(CHECKSUM(NEWID())) % 99999 AS VARCHAR), 5),
            CASE @al % 3 WHEN 0 THEN N'WEB-SVR-01' WHEN 1 THEN N'WEB-SVR-02' ELSE N'APP-SVR-01' END);

    SET @al = @al + 1;
END;
GO

-- ----------------------------------------------------------
-- CurrencyPairs (10 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [CurrencyPairs] ON;
GO

INSERT INTO CurrencyPairs (PairID, BaseCurrency, QuoteCurrency, IsActive, CreatedDate) VALUES (1,  N'USD', N'EUR', 1, '2024-01-01');
INSERT INTO CurrencyPairs (PairID, BaseCurrency, QuoteCurrency, IsActive, CreatedDate) VALUES (2,  N'USD', N'GBP', 1, '2024-01-01');
INSERT INTO CurrencyPairs (PairID, BaseCurrency, QuoteCurrency, IsActive, CreatedDate) VALUES (3,  N'USD', N'JPY', 1, '2024-01-01');
INSERT INTO CurrencyPairs (PairID, BaseCurrency, QuoteCurrency, IsActive, CreatedDate) VALUES (4,  N'USD', N'CAD', 1, '2024-01-01');
INSERT INTO CurrencyPairs (PairID, BaseCurrency, QuoteCurrency, IsActive, CreatedDate) VALUES (5,  N'USD', N'CHF', 1, '2024-01-01');
INSERT INTO CurrencyPairs (PairID, BaseCurrency, QuoteCurrency, IsActive, CreatedDate) VALUES (6,  N'USD', N'CNY', 1, '2024-01-01');
INSERT INTO CurrencyPairs (PairID, BaseCurrency, QuoteCurrency, IsActive, CreatedDate) VALUES (7,  N'USD', N'RUB', 1, '2024-01-01');
INSERT INTO CurrencyPairs (PairID, BaseCurrency, QuoteCurrency, IsActive, CreatedDate) VALUES (8,  N'EUR', N'GBP', 1, '2024-01-01');
INSERT INTO CurrencyPairs (PairID, BaseCurrency, QuoteCurrency, IsActive, CreatedDate) VALUES (9,  N'EUR', N'JPY', 1, '2024-01-01');
INSERT INTO CurrencyPairs (PairID, BaseCurrency, QuoteCurrency, IsActive, CreatedDate) VALUES (10, N'GBP', N'JPY', 1, '2024-01-01');

SET IDENTITY_INSERT [CurrencyPairs] OFF;
GO

-- ----------------------------------------------------------
-- ExchangeRates (~100 rows – 10 pairs × 10 business days)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [ExchangeRates] ON;
GO

DECLARE @er INT = 1;
DECLARE @pair INT = 1;
DECLARE @dayOff INT;
DECLARE @baseRate DECIMAL(18,6);
DECLARE @jitter DECIMAL(18,6);

WHILE @pair <= 10
BEGIN
    SET @baseRate = CASE @pair
        WHEN 1  THEN 0.920000  -- USD/EUR
        WHEN 2  THEN 0.790000  -- USD/GBP
        WHEN 3  THEN 155.50000 -- USD/JPY
        WHEN 4  THEN 1.370000  -- USD/CAD
        WHEN 5  THEN 0.880000  -- USD/CHF
        WHEN 6  THEN 7.240000  -- USD/CNY
        WHEN 7  THEN 91.50000  -- USD/RUB
        WHEN 8  THEN 0.858000  -- EUR/GBP
        WHEN 9  THEN 168.80000 -- EUR/JPY
        WHEN 10 THEN 196.20000 -- GBP/JPY
    END;

    SET @dayOff = 0;
    WHILE @dayOff < 10
    BEGIN
        SET @jitter = CAST((ABS(CHECKSUM(NEWID())) % 1000 - 500) AS DECIMAL(18,6)) / 100000.0;

        INSERT INTO ExchangeRates (RateID, PairID, BidRate, AskRate, MidRate, EffectiveDate, ExpiryDate, Source, CreatedDate)
        VALUES (@er, @pair,
                @baseRate + @jitter - 0.001,
                @baseRate + @jitter + 0.001,
                @baseRate + @jitter,
                DATEADD(DAY, -@dayOff * 1, DATEADD(DAY, -(DATEPART(WEEKDAY, '2025-05-14') - 2), '2025-05-14')),
                DATEADD(DAY, -@dayOff * 1 + 1, DATEADD(DAY, -(DATEPART(WEEKDAY, '2025-05-14') - 2), '2025-05-14')),
                N'Reuters',
                DATEADD(DAY, -@dayOff * 1, DATEADD(DAY, -(DATEPART(WEEKDAY, '2025-05-14') - 2), '2025-05-14')));

        SET @er = @er + 1;
        SET @dayOff = @dayOff + 1;
    END;

    SET @pair = @pair + 1;
END;

SET IDENTITY_INSERT [ExchangeRates] OFF;
GO

-- ----------------------------------------------------------
-- StatementRequests (~40 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [StatementRequests] ON;
GO

DECLARE @sr INT = 1;
DECLARE @srCust INT;
DECLARE @srAcct INT;
DECLARE @srStatus NVARCHAR(20);
DECLARE @srType NVARCHAR(20);

WHILE @sr <= 40
BEGIN
    SET @srCust = CASE
        WHEN @sr <= 6 THEN @sr
        ELSE ((@sr - 1) % 50) + 1
    END;

    SET @srAcct = CASE
        WHEN @srCust <= 6 THEN (@srCust - 1) * 2 + 1
        ELSE 13 + (@srCust - 6)
    END;

    SET @srType = CASE @sr % 3 WHEN 0 THEN N'Annual' WHEN 1 THEN N'Monthly' ELSE N'Quarterly' END;

    SET @srStatus = CASE
        WHEN @sr % 8 = 0 THEN N'Requested'
        WHEN @sr % 5 = 0 THEN N'Processing'
        ELSE N'Completed'
    END;

    INSERT INTO StatementRequests (RequestID, CustomerID, AccountID, StatementType, PeriodStart, PeriodEnd, Format, Status, RequestedDate, CompletedDate, CreatedDate)
    VALUES (@sr, @srCust, @srAcct, @srType,
            DATEADD(MONTH, -(@sr % 12) - 1, '2025-05-01'),
            DATEADD(MONTH, -(@sr % 12), '2025-05-01'),
            CASE WHEN @sr % 4 = 0 THEN N'CSV' ELSE N'PDF' END,
            @srStatus,
            DATEADD(DAY, -@sr * 3, '2025-05-14'),
            CASE WHEN @srStatus = N'Completed' THEN DATEADD(DAY, -@sr * 3 + 1, '2025-05-14') ELSE NULL END,
            DATEADD(DAY, -@sr * 3, '2025-05-14'));

    SET @sr = @sr + 1;
END;

SET IDENTITY_INSERT [StatementRequests] OFF;
GO

-- ----------------------------------------------------------
-- StatementArchive (~35 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [StatementArchive] ON;
GO

DECLARE @sa INT = 1;
DECLARE @saReq INT;

WHILE @sa <= 35
BEGIN
    SET @saReq = @sa;

    INSERT INTO StatementArchive (ArchiveID, RequestID, AccountID, FilePath, FileSize, GeneratedDate, ExpiryDate, Checksum)
    VALUES (@sa, @saReq,
            CASE
                WHEN @sa <= 6 THEN (@sa - 1) * 2 + 1
                ELSE 13 + ((@sa - 6) % 44)
            END,
            N'/statements/archive/' + CAST(@sa AS NVARCHAR) + N'/statement.pdf',
            25000 + (ABS(CHECKSUM(NEWID())) % 75000),
            DATEADD(DAY, -@sa * 3 + 1, '2025-05-14'),
            DATEADD(YEAR, 1, DATEADD(DAY, -@sa * 3 + 1, '2025-05-14')),
            N'SHA256-' + RIGHT(CONVERT(NVARCHAR(50), NEWID()), 32));

    SET @sa = @sa + 1;
END;

SET IDENTITY_INSERT [StatementArchive] OFF;
GO

-- ----------------------------------------------------------
-- AlertRules (8 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [AlertRules] ON;
GO

INSERT INTO AlertRules (RuleID, RuleName, RuleCode, DefaultThreshold, Category, IsActive, CreatedDate) VALUES (1, N'Low Balance',            N'LOW_BAL',     N'100.00',   N'Balance',     1, '2024-01-01');
INSERT INTO AlertRules (RuleID, RuleName, RuleCode, DefaultThreshold, Category, IsActive, CreatedDate) VALUES (2, N'Large Transaction',      N'LARGE_TXN',   N'5000.00',  N'Transaction', 1, '2024-01-01');
INSERT INTO AlertRules (RuleID, RuleName, RuleCode, DefaultThreshold, Category, IsActive, CreatedDate) VALUES (3, N'Overdraft',              N'OVERDRAFT',   N'0.00',     N'Balance',     1, '2024-01-01');
INSERT INTO AlertRules (RuleID, RuleName, RuleCode, DefaultThreshold, Category, IsActive, CreatedDate) VALUES (4, N'Direct Deposit Received', N'DD_RECEIVED', N'0.00',     N'Transaction', 1, '2024-01-01');
INSERT INTO AlertRules (RuleID, RuleName, RuleCode, DefaultThreshold, Category, IsActive, CreatedDate) VALUES (5, N'International Wire',     N'INTL_WIRE',   N'1000.00',  N'Transaction', 1, '2024-01-01');
INSERT INTO AlertRules (RuleID, RuleName, RuleCode, DefaultThreshold, Category, IsActive, CreatedDate) VALUES (6, N'Daily Spending Limit',   N'DAILY_SPEND', N'2000.00',  N'Spending',    1, '2024-01-01');
INSERT INTO AlertRules (RuleID, RuleName, RuleCode, DefaultThreshold, Category, IsActive, CreatedDate) VALUES (7, N'Login from New Device',  N'NEW_DEVICE',  N'N/A',      N'Security',    1, '2024-01-01');
INSERT INTO AlertRules (RuleID, RuleName, RuleCode, DefaultThreshold, Category, IsActive, CreatedDate) VALUES (8, N'Password Expiring',      N'PWD_EXPIRY',  N'7 days',   N'Security',    1, '2024-01-01');

SET IDENTITY_INSERT [AlertRules] OFF;
GO

-- ----------------------------------------------------------
-- AccountAlerts (~60 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [AccountAlerts] ON;
GO

-- Sarah Miller overdraft alert on AccountID 7 (checking)
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (1, 4, 7, 3, N'0.00', N'Email', 1, '2024-08-01', '2024-08-01');
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (2, 4, 7, 1, N'200.00', N'Email', 1, '2024-08-01', '2024-08-01');
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (3, 4, 8, 2, N'3000.00', N'SMS', 1, '2024-08-01', '2024-08-01');

-- Maria Rodriguez
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (4, 1, 1, 1, N'500.00', N'Email', 1, '2024-06-15', '2024-06-15');
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (5, 1, 1, 2, N'5000.00', N'Email', 1, '2024-06-15', '2024-06-15');
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (6, 1, 2, 4, N'0.00', N'SMS', 1, '2024-06-15', '2024-06-15');

-- James Chen
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (7, 2, 3, 1, N'1000.00', N'Email', 1, '2024-09-20', '2024-09-20');
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (8, 2, 3, 2, N'10000.00', N'Email', 1, '2024-09-20', '2024-09-20');
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (9, 2, 4, 6, N'5000.00', N'SMS', 1, '2024-09-20', '2024-09-20');

-- Viktor Petrov
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (10, 3, 5, 2, N'15000.00', N'Email', 1, '2024-03-10', '2024-03-10');
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (11, 3, 5, 5, N'5000.00', N'Email', 1, '2024-03-10', '2024-03-10');
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (12, 3, 6, 1, N'2000.00', N'SMS', 1, '2024-03-10', '2024-03-10');

-- David Park
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (13, 5, 9, 1, N'300.00', N'Email', 1, '2024-07-22', '2024-07-22');
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (14, 5, 10, 2, N'5000.00', N'SMS', 1, '2024-07-22', '2024-07-22');

-- Emily Johnson
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (15, 6, 11, 1, N'250.00', N'Email', 1, '2024-11-05', '2024-11-05');
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (16, 6, 11, 2, N'3000.00', N'Email', 1, '2024-11-05', '2024-11-05');
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (17, 6, 12, 4, N'0.00', N'SMS', 1, '2024-11-05', '2024-11-05');
INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
VALUES (18, 6, 13, 2, N'1000.00', N'Email', 1, '2024-11-05', '2024-11-05');

-- Bulk alerts for customers 7-30
DECLARE @aa INT = 19;
DECLARE @aaCust INT = 7;
WHILE @aaCust <= 30
BEGIN
    INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
    VALUES (@aa, @aaCust, 13 + (@aaCust - 6),
            CASE @aaCust % 4 WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 ELSE 4 END,
            CASE @aaCust % 4 WHEN 0 THEN N'500.00' WHEN 1 THEN N'5000.00' WHEN 2 THEN N'0.00' ELSE N'0.00' END,
            CASE WHEN @aaCust % 3 = 0 THEN N'SMS' ELSE N'Email' END,
            1,
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365 - 90, '2025-05-14'),
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365 - 90, '2025-05-14'));
    SET @aa = @aa + 1;

    -- Second alert for half of customers
    IF @aaCust % 2 = 0
    BEGIN
        INSERT INTO AccountAlerts (AccountAlertID, CustomerID, AccountID, RuleID, Threshold, NotificationChannel, IsEnabled, CreatedDate, ModifiedDate)
        VALUES (@aa, @aaCust, 13 + (@aaCust - 6),
                CASE @aaCust % 3 WHEN 0 THEN 6 WHEN 1 THEN 7 ELSE 8 END,
                CASE @aaCust % 3 WHEN 0 THEN N'2000.00' WHEN 1 THEN N'N/A' ELSE N'7 days' END,
                N'Email', 1,
                DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365 - 90, '2025-05-14'),
                DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365 - 90, '2025-05-14'));
        SET @aa = @aa + 1;
    END;

    SET @aaCust = @aaCust + 1;
END;

SET IDENTITY_INSERT [AccountAlerts] OFF;
GO

-- ----------------------------------------------------------
-- AlertHistory (~120 rows via WHILE loop)
-- Sarah Miller overdraft entries included
-- ----------------------------------------------------------
DECLARE @ah INT = 1;
DECLARE @ahAlertID INT;

-- First: 5 explicit Sarah Miller overdraft alerts (AccountAlertID=1)
WHILE @ah <= 5
BEGIN
    INSERT INTO AlertHistory (AccountAlertID, TriggeredDate, TriggerValue, NotificationSent, NotificationDate, Details)
    VALUES (1,
            DATEADD(DAY, -@ah * 7, '2025-05-14'),
            N'-' + CAST((@ah * 35) + 12 AS NVARCHAR) + N'.50',
            1,
            DATEADD(DAY, -@ah * 7, '2025-05-14'),
            N'Overdraft of $' + CAST((@ah * 35) + 12 AS NVARCHAR) + N'.50 on Sarah Miller checking account');
    SET @ah = @ah + 1;
END;

-- Remaining ~115 entries across various alerts
WHILE @ah <= 120
BEGIN
    SET @ahAlertID = CASE
        WHEN @ah % 20 = 0 THEN 1   -- Sarah overdraft
        WHEN @ah % 10 = 0 THEN 10  -- Viktor large txn
        WHEN @ah % 7 = 0  THEN 7   -- James low balance
        WHEN @ah % 5 = 0  THEN 4   -- Maria low balance
        ELSE ((@ah - 1) % 18) + 1
    END;

    -- Clamp to valid range
    IF @ahAlertID > 60 SET @ahAlertID = ((@ah - 1) % 18) + 1;

    INSERT INTO AlertHistory (AccountAlertID, TriggeredDate, TriggerValue, NotificationSent, NotificationDate, Details)
    VALUES (@ahAlertID,
            DATEADD(HOUR, -@ah * 6, '2025-05-14 17:00:00'),
            CASE
                WHEN @ahAlertID IN (1, 2, 12) THEN CAST(ABS(CHECKSUM(NEWID())) % 500 AS NVARCHAR)
                WHEN @ahAlertID IN (3, 5, 10, 11) THEN CAST(ABS(CHECKSUM(NEWID())) % 20000 + 1000 AS NVARCHAR) + N'.00'
                ELSE N'triggered'
            END,
            CASE WHEN @ah % 6 = 0 THEN 0 ELSE 1 END,
            CASE WHEN @ah % 6 = 0 THEN NULL ELSE DATEADD(HOUR, -@ah * 6 + 1, '2025-05-14 17:00:00') END,
            N'Alert triggered – history entry ' + CAST(@ah AS NVARCHAR));

    SET @ah = @ah + 1;
END;
GO

-- ----------------------------------------------------------
-- PaymentBatches (3 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [PaymentBatches] ON;
GO

INSERT INTO PaymentBatches (BatchID, BatchName, BatchType, TotalAmount, PaymentCount, Status, SubmittedBy, SubmittedDate, ProcessedDate, CreatedDate)
VALUES (1, N'Payroll-2025-04', N'Payroll',   125000.00, 50, N'Processed', N'hr.system',    '2025-04-01 08:00:00', '2025-04-01 10:30:00', '2025-04-01');
INSERT INTO PaymentBatches (BatchID, BatchName, BatchType, TotalAmount, PaymentCount, Status, SubmittedBy, SubmittedDate, ProcessedDate, CreatedDate)
VALUES (2, N'Vendor-2025-04',  N'VendorPay', 45000.00,  15, N'Processed', N'ap.department', '2025-04-15 09:00:00', '2025-04-15 11:00:00', '2025-04-15');
INSERT INTO PaymentBatches (BatchID, BatchName, BatchType, TotalAmount, PaymentCount, Status, SubmittedBy, SubmittedDate, ProcessedDate, CreatedDate)
VALUES (3, N'Payroll-2025-05', N'Payroll',   128500.00, 52, N'Processing', N'hr.system',   '2025-05-01 08:00:00', NULL, '2025-05-01');

SET IDENTITY_INSERT [PaymentBatches] OFF;
GO

-- ----------------------------------------------------------
-- Payments (~200 rows via WHILE loop)
-- ----------------------------------------------------------
DECLARE @pm INT = 1;
DECLARE @pmAcct INT;
DECLARE @pmMethod INT;
DECLARE @pmAmt DECIMAL(18,2);
DECLARE @pmStatus NVARCHAR(20);

WHILE @pm <= 200
BEGIN
    SET @pmAcct = ((@pm - 1) % 50) + 1;

    SET @pmMethod = CASE
        WHEN @pm % 5 = 0 THEN 4  -- Wire
        WHEN @pm % 3 = 0 THEN 2  -- ACH
        WHEN @pm % 2 = 0 THEN 3  -- BillPay
        ELSE 1                     -- Check
    END;

    SET @pmAmt = CAST((ABS(CHECKSUM(NEWID())) % 50000 + 100) AS DECIMAL(18,2)) / 10.0;

    SET @pmStatus = CASE
        WHEN @pm % 20 = 0 THEN N'Failed'
        WHEN @pm % 10 = 0 THEN N'Initiated'
        WHEN @pm % 7 = 0  THEN N'Pending'
        ELSE N'Completed'
    END;

    INSERT INTO Payments (SourceAccountID, DestinationAccount, PaymentMethodID, Amount, Currency, Status, ScheduledDate, ProcessedDate, ReferenceNumber, PayeeName, PayeeRoutingNumber, Memo, RetryCount, FailureReason, CreatedDate, ModifiedDate)
    VALUES (@pmAcct,
            N'EXT-' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS VARCHAR), 6),
            @pmMethod,
            @pmAmt,
            CASE WHEN @pm % 12 = 0 THEN N'EUR' WHEN @pm % 15 = 0 THEN N'GBP' ELSE N'USD' END,
            @pmStatus,
            DATEADD(DAY, -(@pm % 60), '2025-05-14'),
            CASE WHEN @pmStatus IN (N'Completed', N'Failed') THEN DATEADD(DAY, -(@pm % 60) + 1, '2025-05-14') ELSE NULL END,
            N'PMT-' + RIGHT('00000000' + CAST(20250000 + @pm AS VARCHAR), 8),
            N'Payee ' + CAST(@pm AS NVARCHAR),
            CASE WHEN @pmMethod IN (2, 4) THEN N'0210' + RIGHT('00000' + CAST(ABS(CHECKSUM(NEWID())) % 99999 AS VARCHAR), 5) ELSE NULL END,
            N'Payment memo ' + CAST(@pm AS NVARCHAR),
            CASE WHEN @pmStatus = N'Failed' THEN 3 ELSE 0 END,
            CASE WHEN @pmStatus = N'Failed' THEN N'Insufficient funds or invalid routing number' ELSE NULL END,
            DATEADD(DAY, -(@pm % 60), '2025-05-14'),
            DATEADD(DAY, -(@pm % 60) + 1, '2025-05-14'));

    SET @pm = @pm + 1;
END;
GO

-- ----------------------------------------------------------
-- FileImports (~20 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [FileImports] ON;
GO

INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (1,  N'customers_20250401.csv',       N'CSV',  N'/imports/customers/',    N'COMPLETED', 150, 0,  '2025-04-01 06:00:00', '2025-04-01 06:15:00', NULL, N'batch.processor', '2025-04-01');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (2,  N'transactions_20250401.csv',    N'CSV',  N'/imports/transactions/', N'COMPLETED', 5200, 3, '2025-04-01 07:00:00', '2025-04-01 07:45:00', N'3 records with invalid account IDs skipped', N'batch.processor', '2025-04-01');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (3,  N'ach_batch_20250415.txt',       N'TXT',  N'/imports/ach/',          N'COMPLETED', 320, 0,  '2025-04-15 08:00:00', '2025-04-15 08:30:00', NULL, N'ach.processor', '2025-04-15');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (4,  N'wire_confirms_20250420.xml',   N'XML',  N'/imports/wires/',        N'COMPLETED', 12, 0,   '2025-04-20 09:00:00', '2025-04-20 09:10:00', NULL, N'wire.processor', '2025-04-20');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (5,  N'ofac_sanctions_20250501.xml',  N'XML',  N'/imports/regulatory/',   N'COMPLETED', 8500, 0, '2025-05-01 05:00:00', '2025-05-01 05:30:00', NULL, N'compliance.bot', '2025-05-01');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (6,  N'check_images_20250502.zip',    N'ZIP',  N'/imports/checks/',       N'COMPLETED', 45, 1,   '2025-05-02 06:00:00', '2025-05-02 06:20:00', N'1 image failed quality check', N'check.processor', '2025-05-02');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (7,  N'pep_list_20250505.csv',        N'CSV',  N'/imports/regulatory/',   N'COMPLETED', 12300, 0,'2025-05-05 05:00:00', '2025-05-05 05:45:00', NULL, N'compliance.bot', '2025-05-05');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (8,  N'transactions_20250505.csv',    N'CSV',  N'/imports/transactions/', N'COMPLETED', 4800, 1, '2025-05-05 07:00:00', '2025-05-05 07:40:00', N'1 duplicate transaction ID', N'batch.processor', '2025-05-05');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (9,  N'rates_feed_20250510.json',     N'JSON', N'/imports/rates/',        N'COMPLETED', 50, 0,   '2025-05-10 06:00:00', '2025-05-10 06:05:00', NULL, N'rate.processor', '2025-05-10');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (10, N'ach_returns_20250510.txt',     N'TXT',  N'/imports/ach/',          N'COMPLETED', 8, 0,    '2025-05-10 08:00:00', '2025-05-10 08:10:00', NULL, N'ach.processor', '2025-05-10');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (11, N'loan_payments_20250512.csv',   N'CSV',  N'/imports/loans/',        N'COMPLETED', 200, 2,  '2025-05-12 07:00:00', '2025-05-12 07:25:00', N'2 records with mismatched loan IDs', N'loan.processor', '2025-05-12');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (12, N'transactions_20250512.csv',    N'CSV',  N'/imports/transactions/', N'FAILED',    0, 0,    '2025-05-12 07:00:00', NULL, N'File format validation failed – unexpected header row', N'batch.processor', '2025-05-12');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (13, N'wire_confirms_20250513.xml',   N'XML',  N'/imports/wires/',        N'COMPLETED', 6, 0,    '2025-05-13 09:00:00', '2025-05-13 09:08:00', NULL, N'wire.processor', '2025-05-13');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (14, N'customers_20250514.csv',       N'CSV',  N'/imports/customers/',    N'PROCESSING', 0, 0,   '2025-05-14 06:00:00', NULL, NULL, N'batch.processor', '2025-05-14');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (15, N'transactions_20250514.csv',    N'CSV',  N'/imports/transactions/', N'PENDING',   0, 0,    '2025-05-14 07:00:00', NULL, NULL, N'batch.processor', '2025-05-14');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (16, N'ach_batch_20250514.txt',       N'TXT',  N'/imports/ach/',          N'PENDING',   0, 0,    '2025-05-14 08:00:00', NULL, NULL, N'ach.processor', '2025-05-14');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (17, N'check_images_20250514.zip',    N'ZIP',  N'/imports/checks/',       N'PENDING',   0, 0,    '2025-05-14 06:30:00', NULL, NULL, N'check.processor', '2025-05-14');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (18, N'eu_sanctions_20250514.xml',    N'XML',  N'/imports/regulatory/',   N'PENDING',   0, 0,    '2025-05-14 05:00:00', NULL, NULL, N'compliance.bot', '2025-05-14');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (19, N'rates_feed_20250514.json',     N'JSON', N'/imports/rates/',        N'COMPLETED', 50, 0,   '2025-05-14 06:00:00', '2025-05-14 06:03:00', NULL, N'rate.processor', '2025-05-14');
INSERT INTO FileImports (ImportID, FileName, FileType, SourcePath, Status, RecordCount, ErrorCount, ImportedAt, CompletedAt, ErrorDetails, ProcessedBy, CreatedDate)
VALUES (20, N'adverse_media_20250514.csv',   N'CSV',  N'/imports/regulatory/',   N'PENDING',   0, 0,    '2025-05-14 05:30:00', NULL, NULL, N'compliance.bot', '2025-05-14');

SET IDENTITY_INSERT [FileImports] OFF;
GO

-- ----------------------------------------------------------
-- CheckImages (~15 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [CheckImages] ON;
GO

INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (1,  N'1001', 1,  N'/checks/img/1001_front.tiff', N'/checks/img/1001_back.tiff', N'PROCESSED', '2025-03-01 10:00:00', '2025-03-01 10:05:00', 1250.00, '2025-02-28', N'Home Depot',        N'T021000089T 0001234567O 1001', 95, '2025-03-01');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (2,  N'1002', 1,  N'/checks/img/1002_front.tiff', N'/checks/img/1002_back.tiff', N'PROCESSED', '2025-03-05 11:00:00', '2025-03-05 11:04:00', 450.00,  '2025-03-04', N'City Utilities',    N'T021000089T 0001234567O 1002', 92, '2025-03-05');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (3,  N'2001', 3,  N'/checks/img/2001_front.tiff', N'/checks/img/2001_back.tiff', N'PROCESSED', '2025-03-10 09:00:00', '2025-03-10 09:06:00', 9500.00, '2025-03-09', N'Chen Enterprises',  N'T021000089T 0003456789O 2001', 88, '2025-03-10');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (4,  N'2002', 3,  N'/checks/img/2002_front.tiff', N'/checks/img/2002_back.tiff', N'PROCESSED', '2025-03-15 14:00:00', '2025-03-15 14:05:00', 9800.00, '2025-03-14', N'ABC Imports LLC',   N'T021000089T 0003456789O 2002', 90, '2025-03-15');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (5,  N'3001', 5,  N'/checks/img/3001_front.tiff', N'/checks/img/3001_back.tiff', N'PROCESSED', '2025-02-20 10:30:00', '2025-02-20 10:35:00', 15000.00,'2025-02-19', N'Petrov Holdings',   N'T021000089T 0005678901O 3001', 91, '2025-02-20');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (6,  N'4001', 7,  N'/checks/img/4001_front.tiff', N'/checks/img/4001_back.tiff', N'PROCESSED', '2025-04-01 08:00:00', '2025-04-01 08:04:00', 850.00,  '2025-03-31', N'State Farm Insurance', N'T021000089T 0007890123O 4001', 94, '2025-04-01');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (7,  N'5001', 9,  N'/checks/img/5001_front.tiff', N'/checks/img/5001_back.tiff', N'PROCESSED', '2025-04-10 09:00:00', '2025-04-10 09:03:00', 2200.00, '2025-04-09', N'Park & Associates', N'T021000089T 0009012345O 5001', 96, '2025-04-10');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (8,  N'6001', 11, N'/checks/img/6001_front.tiff', N'/checks/img/6001_back.tiff', N'PROCESSED', '2025-04-15 13:00:00', '2025-04-15 13:05:00', 500.00,  '2025-04-14', N'Rent Payment',      N'T021000089T 0001112233O 6001', 93, '2025-04-15');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (9,  N'6002', 11, N'/checks/img/6002_front.tiff', N'/checks/img/6002_back.tiff', N'PROCESSED', '2025-04-20 10:00:00', '2025-04-20 10:04:00', 500.00,  '2025-04-19', N'Rent Payment',      N'T021000089T 0001112233O 6002', 91, '2025-04-20');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (10, N'7001', 14, N'/checks/img/7001_front.tiff', N'/checks/img/7001_back.tiff', N'PROCESSED', '2025-04-25 11:00:00', '2025-04-25 11:06:00', 3500.00, '2025-04-24', N'Contractor Payment',N'T021000089T 0001400001O 7001', 87, '2025-04-25');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (11, N'7002', 20, N'/checks/img/7002_front.tiff', N'/checks/img/7002_back.tiff', N'PROCESSED', '2025-05-01 09:00:00', '2025-05-01 09:05:00', 12000.00,'2025-04-30', N'Insurance Payout',  N'T021000089T 0002000001O 7002', 89, '2025-05-01');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (12, N'8001', 25, N'/checks/img/8001_front.tiff', N'/checks/img/8001_back.tiff', N'PENDING',   '2025-05-10 14:00:00', NULL,                  750.00,  '2025-05-09', N'Medical Bill',      N'T021000089T 0002500001O 8001', NULL, '2025-05-10');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (13, N'8002', 30, N'/checks/img/8002_front.tiff', N'/checks/img/8002_back.tiff', N'REJECTED',  '2025-05-12 10:00:00', '2025-05-12 10:08:00', 200.00,  '2025-05-11', N'Cash',              N'T021000089T 0003000001O 8002', 42, '2025-05-12');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (14, N'9001', 35, N'/checks/img/9001_front.tiff', N'/checks/img/9001_back.tiff', N'PENDING',   '2025-05-13 15:00:00', NULL,                  1800.00, '2025-05-12', N'Tuition Payment',   N'T021000089T 0003500001O 9001', NULL, '2025-05-13');
INSERT INTO CheckImages (ImageID, CheckNumber, AccountID, FrontImagePath, BackImagePath, ScanStatus, ScannedAt, ProcessedAt, CheckAmount, CheckDate, PayeeName, MICR, QualityScore, CreatedDate)
VALUES (15, N'9002', 40, N'/checks/img/9002_front.tiff', N'/checks/img/9002_back.tiff', N'PENDING',   '2025-05-14 08:00:00', NULL,                  675.00,  '2025-05-13', N'Auto Repair',       N'T021000089T 0004000001O 9002', NULL, '2025-05-14');

SET IDENTITY_INSERT [CheckImages] OFF;
GO

-- ----------------------------------------------------------
-- WireConfirmations (~10 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [WireConfirmations] ON;
GO

INSERT INTO WireConfirmations (ConfirmationID, TransactionID, ConfirmationNumber, FilePath, ReceivedAt, Status, WireReference, BeneficiaryBank, BeneficiaryName, Amount, Currency, ExchangeRate, CreatedDate)
VALUES (1,  1,  N'WC-2025-000001', N'/wires/confirm/WC-2025-000001.pdf', '2025-01-15 14:00:00', N'CONFIRMED', N'FWT-20250115-001', N'Sberbank',          N'Petrov Holdings LLC',   35000.00, N'USD', NULL,      '2025-01-15');
INSERT INTO WireConfirmations (ConfirmationID, TransactionID, ConfirmationNumber, FilePath, ReceivedAt, Status, WireReference, BeneficiaryBank, BeneficiaryName, Amount, Currency, ExchangeRate, CreatedDate)
VALUES (2,  2,  N'WC-2025-000002', N'/wires/confirm/WC-2025-000002.pdf', '2025-02-10 10:00:00', N'CONFIRMED', N'FWT-20250210-001', N'Bank of Cyprus',    N'Cyprus Trading Co',     18000.00, N'EUR', 0.920000,  '2025-02-10');
INSERT INTO WireConfirmations (ConfirmationID, TransactionID, ConfirmationNumber, FilePath, ReceivedAt, Status, WireReference, BeneficiaryBank, BeneficiaryName, Amount, Currency, ExchangeRate, CreatedDate)
VALUES (3,  3,  N'WC-2025-000003', N'/wires/confirm/WC-2025-000003.pdf', '2025-02-28 11:00:00', N'CONFIRMED', N'FWT-20250228-001', N'HSBC',              N'Chen Import/Export',    15000.00, N'USD', NULL,      '2025-02-28');
INSERT INTO WireConfirmations (ConfirmationID, TransactionID, ConfirmationNumber, FilePath, ReceivedAt, Status, WireReference, BeneficiaryBank, BeneficiaryName, Amount, Currency, ExchangeRate, CreatedDate)
VALUES (4,  4,  N'WC-2025-000004', N'/wires/confirm/WC-2025-000004.pdf', '2025-03-05 15:00:00', N'CONFIRMED', N'FWT-20250305-001', N'Deutsche Bank',     N'Supplier GmbH',          8500.00, N'EUR', 0.921500,  '2025-03-05');
INSERT INTO WireConfirmations (ConfirmationID, TransactionID, ConfirmationNumber, FilePath, ReceivedAt, Status, WireReference, BeneficiaryBank, BeneficiaryName, Amount, Currency, ExchangeRate, CreatedDate)
VALUES (5,  5,  N'WC-2025-000005', N'/wires/confirm/WC-2025-000005.pdf', '2025-03-20 09:00:00', N'CONFIRMED', N'FWT-20250320-001', N'Barclays',          N'UK Services Ltd',        5200.00, N'GBP', 0.790000,  '2025-03-20');
INSERT INTO WireConfirmations (ConfirmationID, TransactionID, ConfirmationNumber, FilePath, ReceivedAt, Status, WireReference, BeneficiaryBank, BeneficiaryName, Amount, Currency, ExchangeRate, CreatedDate)
VALUES (6,  6,  N'WC-2025-000006', N'/wires/confirm/WC-2025-000006.pdf', '2025-04-02 13:00:00', N'CONFIRMED', N'FWT-20250402-001', N'JP Morgan Chase',   N'Rodriguez Consulting',  10000.00, N'USD', NULL,      '2025-04-02');
INSERT INTO WireConfirmations (ConfirmationID, TransactionID, ConfirmationNumber, FilePath, ReceivedAt, Status, WireReference, BeneficiaryBank, BeneficiaryName, Amount, Currency, ExchangeRate, CreatedDate)
VALUES (7,  7,  N'WC-2025-000007', N'/wires/confirm/WC-2025-000007.pdf', '2025-04-15 10:00:00', N'RECEIVED',  N'FWT-20250415-001', N'Mizuho Bank',       N'Tokyo Tech Partners',    7500.00, N'JPY', 155.50000, '2025-04-15');
INSERT INTO WireConfirmations (ConfirmationID, TransactionID, ConfirmationNumber, FilePath, ReceivedAt, Status, WireReference, BeneficiaryBank, BeneficiaryName, Amount, Currency, ExchangeRate, CreatedDate)
VALUES (8,  8,  N'WC-2025-000008', N'/wires/confirm/WC-2025-000008.pdf', '2025-04-28 16:00:00', N'CONFIRMED', N'FWT-20250428-001', N'Bank of China',     N'Shanghai Imports',      22000.00, N'CNY', 7.240000,  '2025-04-28');
INSERT INTO WireConfirmations (ConfirmationID, TransactionID, ConfirmationNumber, FilePath, ReceivedAt, Status, WireReference, BeneficiaryBank, BeneficiaryName, Amount, Currency, ExchangeRate, CreatedDate)
VALUES (9,  9,  N'WC-2025-000009', N'/wires/confirm/WC-2025-000009.pdf', '2025-05-05 11:00:00', N'PENDING',   N'FWT-20250505-001', N'Royal Bank of Canada', N'Canada Services Inc', 12000.00, N'CAD', 1.370000,  '2025-05-05');
INSERT INTO WireConfirmations (ConfirmationID, TransactionID, ConfirmationNumber, FilePath, ReceivedAt, Status, WireReference, BeneficiaryBank, BeneficiaryName, Amount, Currency, ExchangeRate, CreatedDate)
VALUES (10, 10, N'WC-2025-000010', N'/wires/confirm/WC-2025-000010.pdf', '2025-05-12 14:00:00', N'RECEIVED',  N'FWT-20250512-001', N'Credit Suisse',     N'Swiss Consulting AG',    6800.00, N'CHF', 0.880000,  '2025-05-12');

SET IDENTITY_INSERT [WireConfirmations] OFF;
GO

-- ----------------------------------------------------------
-- RegulatoryFeeds (~8 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [RegulatoryFeeds] ON;
GO

INSERT INTO RegulatoryFeeds (FeedID, FeedType, FilePath, ReportingPeriod, Status, SubmittedAt, AcknowledgedAt, AcknowledgmentRef, RecordCount, RejectionReason, RegulatoryAgency, CreatedDate)
VALUES (1, N'OFAC',  N'/regulatory/ofac_20250501.xml',    '2025-05-01', N'ACKNOWLEDGED', '2025-05-01 06:00:00', '2025-05-01 06:30:00', N'OFAC-ACK-20250501-001', 8500,  NULL, N'OFAC',    '2025-05-01');
INSERT INTO RegulatoryFeeds (FeedID, FeedType, FilePath, ReportingPeriod, Status, SubmittedAt, AcknowledgedAt, AcknowledgmentRef, RecordCount, RejectionReason, RegulatoryAgency, CreatedDate)
VALUES (2, N'CTR',   N'/regulatory/ctr_20250430.xml',     '2025-04-30', N'ACKNOWLEDGED', '2025-04-30 17:00:00', '2025-05-01 09:00:00', N'CTR-ACK-20250430-001',  12,    NULL, N'FinCEN',  '2025-04-30');
INSERT INTO RegulatoryFeeds (FeedID, FeedType, FilePath, ReportingPeriod, Status, SubmittedAt, AcknowledgedAt, AcknowledgmentRef, RecordCount, RejectionReason, RegulatoryAgency, CreatedDate)
VALUES (3, N'SAR',   N'/regulatory/sar_20250415.xml',     '2025-04-15', N'ACKNOWLEDGED', '2025-04-15 17:00:00', '2025-04-16 10:00:00', N'SAR-ACK-20250415-001',  3,     NULL, N'FinCEN',  '2025-04-15');
INSERT INTO RegulatoryFeeds (FeedID, FeedType, FilePath, ReportingPeriod, Status, SubmittedAt, AcknowledgedAt, AcknowledgmentRef, RecordCount, RejectionReason, RegulatoryAgency, CreatedDate)
VALUES (4, N'CRA',   N'/regulatory/cra_20250331.xml',     '2025-03-31', N'ACKNOWLEDGED', '2025-03-31 18:00:00', '2025-04-02 14:00:00', N'CRA-ACK-20250331-001',  1500,  NULL, N'FFIEC',   '2025-03-31');
INSERT INTO RegulatoryFeeds (FeedID, FeedType, FilePath, ReportingPeriod, Status, SubmittedAt, AcknowledgedAt, AcknowledgmentRef, RecordCount, RejectionReason, RegulatoryAgency, CreatedDate)
VALUES (5, N'OFAC',  N'/regulatory/ofac_20250514.xml',    '2025-05-14', N'PENDING',      NULL, NULL, NULL, 8600, NULL, N'OFAC', '2025-05-14');
INSERT INTO RegulatoryFeeds (FeedID, FeedType, FilePath, ReportingPeriod, Status, SubmittedAt, AcknowledgedAt, AcknowledgmentRef, RecordCount, RejectionReason, RegulatoryAgency, CreatedDate)
VALUES (6, N'PEP',   N'/regulatory/pep_20250505.csv',     '2025-05-05', N'ACKNOWLEDGED', '2025-05-05 06:00:00', '2025-05-05 07:00:00', N'PEP-ACK-20250505-001',  12300, NULL, N'Dow Jones', '2025-05-05');
INSERT INTO RegulatoryFeeds (FeedID, FeedType, FilePath, ReportingPeriod, Status, SubmittedAt, AcknowledgedAt, AcknowledgmentRef, RecordCount, RejectionReason, RegulatoryAgency, CreatedDate)
VALUES (7, N'CTR',   N'/regulatory/ctr_20250331.xml',     '2025-03-31', N'REJECTED',     '2025-03-31 17:00:00', NULL, NULL, 15, N'Invalid CTR format in records 8-10 – missing TIN fields', N'FinCEN', '2025-03-31');
INSERT INTO RegulatoryFeeds (FeedID, FeedType, FilePath, ReportingPeriod, Status, SubmittedAt, AcknowledgedAt, AcknowledgmentRef, RecordCount, RejectionReason, RegulatoryAgency, CreatedDate)
VALUES (8, N'ADVERSE', N'/regulatory/adverse_20250514.csv', '2025-05-14', N'PENDING',     NULL, NULL, NULL, 0, NULL, N'LexisNexis', '2025-05-14');

SET IDENTITY_INSERT [RegulatoryFeeds] OFF;
GO

-- ============================================================
PRINT 'Miscellaneous seed data loaded successfully.';
GO
