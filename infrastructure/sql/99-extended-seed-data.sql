USE [ZavaBankDB];
GO

PRINT 'Loading extended demo seed data...';
GO

DECLARE @SeedNow DATETIME = '2026-05-14T08:22:11';

IF OBJECT_ID('dbo.Documents', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Documents (
        DocumentID BIGINT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT NOT NULL,
        DocumentType NVARCHAR(80) NOT NULL,
        FileName NVARCHAR(255) NOT NULL,
        ContentType NVARCHAR(150) NULL,
        DocumentData VARBINARY(MAX) NOT NULL,
        UploadedDate DATETIME NOT NULL DEFAULT GETDATE()
    );
END;
GO

DECLARE @SeedNow DATETIME = '2026-05-14T08:22:11';

;WITH CustomerSeed AS (
    SELECT *
    FROM (VALUES
        (N'Avery',    N'Bennett',  N'1989-02-14', N'411-22-1001', N'extended.demo01@zavabank.com', N'206-555-1201', N'410 Pine St',               NULL,         N'Seattle',      N'WA', N'98101', N'2017-03-01', N'Active', N'Low'),
        (N'Noah',     N'Campbell', N'1984-07-03', N'411-22-1002', N'extended.demo02@zavabank.com', N'303-555-1202', N'900 Broadway',             N'Unit 9',    N'Denver',       N'CO', N'80203', N'2016-08-20', N'Active', N'Low'),
        (N'Mia',      N'Edwards',  N'1993-11-09', N'411-22-1003', N'extended.demo03@zavabank.com', N'615-555-1203', N'110 2nd Ave S',            NULL,         N'Nashville',    N'TN', N'37201', N'2021-04-14', N'Active', N'Low'),
        (N'Liam',     N'Foster',   N'1979-01-26', N'411-22-1004', N'extended.demo04@zavabank.com', N'214-555-1204', N'2401 Cedar Springs Rd',   NULL,         N'Dallas',       N'TX', N'75201', N'2012-12-03', N'Active', N'Medium'),
        (N'Olivia',   N'Green',    N'1987-05-18', N'411-22-1005', N'extended.demo05@zavabank.com', N'617-555-1205', N'30 Newbury St',            NULL,         N'Boston',       N'MA', N'02116', N'2018-01-11', N'Active', N'Low'),
        (N'Ethan',    N'Hayes',    N'1991-09-30', N'411-22-1006', N'extended.demo06@zavabank.com', N'602-555-1206', N'40 W Jefferson St',       N'Ste 500',   N'Phoenix',      N'AZ', N'85003', N'2019-09-25', N'Active', N'Low'),
        (N'Sophia',   N'Irwin',    N'1982-04-21', N'411-22-1007', N'extended.demo07@zavabank.com', N'404-555-1207', N'120 Peachtree St NW',     NULL,         N'Atlanta',      N'GA', N'30303', N'2014-06-10', N'Active', N'Medium'),
        (N'Lucas',    N'James',    N'1976-08-12', N'411-22-1008', N'extended.demo08@zavabank.com', N'312-555-1208', N'233 N Michigan Ave',      NULL,         N'Chicago',      N'IL', N'60601', N'2011-05-29', N'Active', N'Medium'),
        (N'Emma',     N'Knight',   N'1995-03-07', N'411-22-1009', N'extended.demo09@zavabank.com', N'503-555-1209', N'121 SW Salmon St',        NULL,         N'Portland',     N'OR', N'97204', N'2022-02-18', N'Active', N'Low'),
        (N'Jackson',  N'Lopez',    N'1980-10-16', N'411-22-1010', N'extended.demo10@zavabank.com', N'702-555-1210', N'300 S 4th St',            NULL,         N'Las Vegas',    N'NV', N'89101', N'2010-10-10', N'Active', N'Medium'),
        (N'Amelia',   N'Moore',    N'1988-12-28', N'411-22-1011', N'extended.demo11@zavabank.com', N'713-555-1211', N'1000 Main St',            NULL,         N'Houston',      N'TX', N'77002', N'2016-01-19', N'Active', N'Low'),
        (N'Logan',    N'Nguyen',   N'1992-06-15', N'411-22-1012', N'extended.demo12@zavabank.com', N'408-555-1212', N'1 W Santa Clara St',      NULL,         N'San Jose',     N'CA', N'95113', N'2019-11-04', N'Active', N'Low'),
        (N'Harper',   N'Owens',    N'1985-02-02', N'411-22-1013', N'extended.demo13@zavabank.com', N'305-555-1213', N'701 Brickell Ave',        NULL,         N'Miami',        N'FL', N'33131', N'2015-07-07', N'Active', N'Low'),
        (N'Mason',    N'Parker',   N'1974-11-23', N'411-22-1014', N'extended.demo14@zavabank.com', N'414-555-1214', N'250 E Wisconsin Ave',     NULL,         N'Milwaukee',    N'WI', N'53202', N'2009-09-09', N'Active', N'Medium'),
        (N'Evelyn',   N'Quinn',    N'1996-01-05', N'411-22-1015', N'extended.demo15@zavabank.com', N'704-555-1215', N'210 S Tryon St',          NULL,         N'Charlotte',    N'NC', N'28202', N'2023-01-05', N'Active', N'Low'),
        (N'Elijah',   N'Reed',     N'1983-09-19', N'411-22-1016', N'extended.demo16@zavabank.com', N'216-555-1216', N'1111 Superior Ave',       NULL,         N'Cleveland',    N'OH', N'44114', N'2013-03-27', N'Active', N'Medium'),
        (N'Abigail',  N'Simmons',  N'1990-04-29', N'411-22-1017', N'extended.demo17@zavabank.com', N'801-555-1217', N'95 S State St',           NULL,         N'Salt Lake City',N'UT', N'84111', N'2018-12-12', N'Active', N'Low'),
        (N'Benjamin', N'Turner',   N'1977-07-21', N'411-22-1018', N'extended.demo18@zavabank.com', N'504-555-1218', N'909 Poydras St',          NULL,         N'New Orleans',  N'LA', N'70112', N'2011-02-02', N'Active', N'Medium'),
        (N'Aurora',   N'Underwood',N'1986-03-11', N'411-22-1019', N'extended.demo19@zavabank.com', N'412-555-1219', N'625 Liberty Ave',         NULL,         N'Pittsburgh',   N'PA', N'15222', N'2017-05-15', N'Active', N'Low'),
        (N'Grayson',  N'Vega',     N'1994-08-08', N'411-22-1020', N'extended.demo20@zavabank.com', N'410-555-1220', N'100 Light St',            NULL,         N'Baltimore',    N'MD', N'21202', N'2021-07-21', N'Active', N'Low')
    ) AS s(FirstName, LastName, DateOfBirth, SSN, Email, Phone, AddressLine1, AddressLine2, City, State, ZipCode, CustomerSince, Status, RiskRating)
)
INSERT INTO Customers (
    FirstName, LastName, MiddleName, DateOfBirth, SSN, Email, Phone, AddressLine1, AddressLine2, City, State, ZipCode, Country,
    CustomerSince, Status, RiskRating, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy
)
SELECT
    s.FirstName, s.LastName, NULL, CAST(s.DateOfBirth AS DATE), s.SSN, s.Email, s.Phone, s.AddressLine1, s.AddressLine2, s.City, s.State, s.ZipCode, N'US',
    CAST(s.CustomerSince AS DATETIME), s.Status, s.RiskRating, @SeedNow, @SeedNow, N'99-extended-seed-data', N'99-extended-seed-data'
FROM CustomerSeed s
WHERE NOT EXISTS (
    SELECT 1
    FROM Customers c
    WHERE c.Email = s.Email
);
GO

DECLARE @SeedNow DATETIME = '2026-05-14T08:22:11';

;WITH ExtendedCustomers AS (
    SELECT
        c.CustomerID,
        c.Email,
        ROW_NUMBER() OVER (ORDER BY c.Email) AS rn
    FROM Customers c
    WHERE c.Email LIKE 'extended.demo%@zavabank.com'
),
AccountSeed AS (
    SELECT
        ec.CustomerID,
        ec.rn,
        N'Checking' AS AccountTypeName,
        N'2002-' + RIGHT('0000' + CAST(ec.rn AS NVARCHAR(4)), 4) + N'-0001' AS AccountNumber,
        CAST(1800.00 + (ec.rn * 210.00) AS DECIMAL(18,2)) AS Balance,
        CAST(1800.00 + (ec.rn * 210.00) AS DECIMAL(18,2)) AS AvailableBalance,
        N'Active' AS Status,
        CAST(450 + (ec.rn * 15) AS DECIMAL(18,2)) AS OverdraftLimit,
        CAST(0.00 AS DECIMAL(18,2)) AS InterestAccrued
    FROM ExtendedCustomers ec

    UNION ALL

    SELECT
        ec.CustomerID,
        ec.rn,
        N'Savings',
        N'2002-' + RIGHT('0000' + CAST(ec.rn AS NVARCHAR(4)), 4) + N'-0002',
        CAST(4200.00 + (ec.rn * 390.00) AS DECIMAL(18,2)),
        CAST(4200.00 + (ec.rn * 390.00) AS DECIMAL(18,2)),
        N'Active',
        CAST(0.00 AS DECIMAL(18,2)),
        CAST(8.00 + ec.rn AS DECIMAL(18,2))
    FROM ExtendedCustomers ec

    UNION ALL

    SELECT
        ec.CustomerID,
        ec.rn,
        N'Loan',
        N'2002-' + RIGHT('0000' + CAST(ec.rn AS NVARCHAR(4)), 4) + N'-0003',
        CAST(12000.00 + (ec.rn * 1250.00) AS DECIMAL(18,2)),
        CAST(0.00 AS DECIMAL(18,2)),
        N'Active',
        CAST(0.00 AS DECIMAL(18,2)),
        CAST(0.00 AS DECIMAL(18,2))
    FROM ExtendedCustomers ec
    WHERE ec.rn % 2 = 0

    UNION ALL

    SELECT
        ec.CustomerID,
        ec.rn,
        N'CD',
        N'2002-' + RIGHT('0000' + CAST(ec.rn AS NVARCHAR(4)), 4) + N'-0004',
        CAST(10000.00 + (ec.rn * 1500.00) AS DECIMAL(18,2)),
        CAST(10000.00 + (ec.rn * 1500.00) AS DECIMAL(18,2)),
        N'Active',
        CAST(0.00 AS DECIMAL(18,2)),
        CAST(40.00 + (ec.rn * 2.50) AS DECIMAL(18,2))
    FROM ExtendedCustomers ec
    WHERE ec.rn IN (1,4,7,10,13,16,19)
)
INSERT INTO Accounts (
    CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate
)
SELECT
    a.CustomerID,
    atp.AccountTypeID,
    a.AccountNumber,
    a.Balance,
    a.AvailableBalance,
    a.Status,
    DATEADD(DAY, -(700 + a.rn * 20), @SeedNow),
    NULL,
    DATEADD(DAY, -(a.rn % 12), @SeedNow),
    a.OverdraftLimit,
    a.InterestAccrued,
    @SeedNow,
    @SeedNow
FROM AccountSeed a
INNER JOIN AccountTypes atp
    ON atp.TypeName = a.AccountTypeName
WHERE NOT EXISTS (
    SELECT 1
    FROM Accounts x
    WHERE x.AccountNumber = a.AccountNumber
);
GO

DECLARE @SeedNow DATETIME = '2026-05-14T08:22:11';

;WITH ExtendedAccounts AS (
    SELECT
        a.AccountID,
        a.CustomerID,
        a.AccountNumber,
        a.Balance,
        atp.TypeName,
        ROW_NUMBER() OVER (ORDER BY a.AccountNumber) AS rn
    FROM Accounts a
    INNER JOIN AccountTypes atp
        ON atp.AccountTypeID = a.AccountTypeID
    WHERE a.AccountNumber LIKE '2002-%'
),
CheckingTx AS (
    SELECT
        ea.AccountID,
        ea.CustomerID,
        ea.AccountNumber,
        tx.SeqNo,
        tx.TransactionTypeID,
        tx.Amount,
        tx.Description,
        tx.Channel,
        tx.OffsetDays
    FROM ExtendedAccounts ea
    CROSS APPLY (VALUES
        (1, 1, CAST(2100.00 + (ea.rn * 45.00) AS DECIMAL(18,2)), N'Payroll Deposit - Zava Manufacturing', N'Online', -84),
        (2, 6, CAST(580.00 + (ea.rn * 6.00)  AS DECIMAL(18,2)), N'Mortgage Payment - First National',     N'Online', -77),
        (3, 2, CAST(95.00 + (ea.rn * 2.00)   AS DECIMAL(18,2)), N'ATM Withdrawal',                          N'ATM',    -70),
        (4, 3, CAST(CASE WHEN ea.rn % 5 = 0 THEN 24000.00 ELSE 320.00 + (ea.rn * 7.00) END AS DECIMAL(18,2)), N'Transfer to Savings', N'Online', -56),
        (5, 1, CAST(2100.00 + (ea.rn * 45.00) AS DECIMAL(18,2)), N'Payroll Deposit - Zava Manufacturing', N'Online', -42),
        (6, 6, CAST(160.00 + (ea.rn * 3.00)  AS DECIMAL(18,2)), N'Utility Payment Bundle',                  N'Online', -28),
        (7, 2, CAST(45.00 + (ea.rn * 1.50)   AS DECIMAL(18,2)), N'Point of Sale Purchase',                  N'Mobile', -14),
        (8, 1, CAST(2100.00 + (ea.rn * 45.00) AS DECIMAL(18,2)), N'Payroll Deposit - Zava Manufacturing', N'Online', -3)
    ) tx(SeqNo, TransactionTypeID, Amount, Description, Channel, OffsetDays)
    WHERE ea.TypeName = N'Checking'
),
SavingsTx AS (
    SELECT
        ea.AccountID,
        ea.CustomerID,
        ea.AccountNumber,
        tx.SeqNo,
        tx.TransactionTypeID,
        tx.Amount,
        tx.Description,
        tx.Channel,
        tx.OffsetDays
    FROM ExtendedAccounts ea
    CROSS APPLY (VALUES
        (1, 1, CAST(300.00 + (ea.rn * 5.00) AS DECIMAL(18,2)),  N'Automated Transfer In', N'Online', -55),
        (2, 5, CAST(12.00 + (ea.rn * 0.30) AS DECIMAL(18,2)),   N'Monthly Interest Credit',N'Online', -27),
        (3, 3, CAST(110.00 + (ea.rn * 1.20) AS DECIMAL(18,2)),  N'Transfer to Checking',   N'Online', -8)
    ) tx(SeqNo, TransactionTypeID, Amount, Description, Channel, OffsetDays)
    WHERE ea.TypeName = N'Savings'
),
LoanTx AS (
    SELECT
        ea.AccountID,
        ea.CustomerID,
        ea.AccountNumber,
        tx.SeqNo,
        tx.TransactionTypeID,
        tx.Amount,
        tx.Description,
        tx.Channel,
        tx.OffsetDays
    FROM ExtendedAccounts ea
    CROSS APPLY (VALUES
        (1, 6, CAST(460.00 + (ea.rn * 3.50) AS DECIMAL(18,2)), N'Auto Loan Payment', N'ACH', -32),
        (2, 6, CAST(460.00 + (ea.rn * 3.50) AS DECIMAL(18,2)), N'Auto Loan Payment', N'ACH', -2)
    ) tx(SeqNo, TransactionTypeID, Amount, Description, Channel, OffsetDays)
    WHERE ea.TypeName = N'Loan'
),
AllTx AS (
    SELECT * FROM CheckingTx
    UNION ALL
    SELECT * FROM SavingsTx
    UNION ALL
    SELECT * FROM LoanTx
)
INSERT INTO Transactions (
    AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel, CounterpartyAccount, Memo, CreatedDate
)
SELECT
    t.AccountID,
    t.TransactionTypeID,
    t.Amount,
    CAST(CASE WHEN t.TransactionTypeID IN (1,5,7) THEN ea.Balance + (t.SeqNo * 55.00) ELSE ea.Balance - (t.SeqNo * 35.00) END AS DECIMAL(18,2)) AS BalanceAfter,
    t.Description,
    N'EXT-' + REPLACE(t.AccountNumber, N'-', N'') + N'-' +
        CASE
            WHEN ea.TypeName = N'Checking' THEN N'C'
            WHEN ea.TypeName = N'Savings' THEN N'S'
            ELSE N'L'
        END +
        RIGHT(N'00' + CAST(t.SeqNo AS NVARCHAR(2)), 2) AS ReferenceNumber,
    DATEADD(DAY, t.OffsetDays, @SeedNow) AS TransactionDate,
    DATEADD(DAY, t.OffsetDays, @SeedNow) AS PostDate,
    N'Posted' AS Status,
    t.Channel,
    CASE WHEN t.TransactionTypeID = 3 THEN N'INT-' + RIGHT(REPLACE(t.AccountNumber, N'-', N''), 6) ELSE NULL END AS CounterpartyAccount,
    CASE
        WHEN t.TransactionTypeID = 1 THEN N'Recurring payroll demo data'
        WHEN t.TransactionTypeID = 6 THEN N'Recurring payment demo data'
        ELSE NULL
    END AS Memo,
    DATEADD(DAY, t.OffsetDays, @SeedNow) AS CreatedDate
FROM AllTx t
INNER JOIN ExtendedAccounts ea
    ON ea.AccountID = t.AccountID
WHERE NOT EXISTS (
    SELECT 1
    FROM Transactions x
    WHERE x.ReferenceNumber =
        N'EXT-' + REPLACE(t.AccountNumber, N'-', N'') + N'-' +
        CASE
            WHEN ea.TypeName = N'Checking' THEN N'C'
            WHEN ea.TypeName = N'Savings' THEN N'S'
            ELSE N'L'
        END +
        RIGHT(N'00' + CAST(t.SeqNo AS NVARCHAR(2)), 2)
);
GO

DECLARE @SeedNow DATETIME = '2026-05-14T08:22:11';

;WITH LoanAppSeed AS (
    SELECT *
    FROM (VALUES
        (N'extended.demo01@zavabank.com', N'PERS', 18000.00, NULL,     NULL,   48, N'Kitchen remodel',               N'Submitted', CAST('2026-05-12' AS DATETIME), NULL,         NULL,         NULL,                                                     N'loan.officer.kim', NULL),
        (N'extended.demo04@zavabank.com', N'AUTO', 42000.00, 40000.00, 0.0699, 72, N'EV purchase',                   N'Approved',  CAST('2026-05-05' AS DATETIME), CAST('2026-05-10' AS DATETIME), NULL, N'Approved with proof of insurance required.',          N'loan.officer.kim', NULL),
        (N'extended.demo08@zavabank.com', N'PERS', 12000.00, NULL,     NULL,   36, N'Debt consolidation',            N'Denied',    CAST('2026-05-03' AS DATETIME), CAST('2026-05-09' AS DATETIME), NULL, N'Denied due to high revolving utilization.',            N'loan.officer.kim', NULL),
        (N'extended.demo12@zavabank.com', N'BUSI', 95000.00, NULL,     NULL,   60, N'Fleet expansion',               N'InReview',  CAST('2026-05-11' AS DATETIME), NULL,         NULL,         N'Requires updated P&L and tax transcript.',             N'admin',            NULL),
        (N'extended.demo16@zavabank.com', N'HEQY', 76000.00, 76000.00, 0.0615, 180,N'Home office addition',          N'Funded',    CAST('2026-04-10' AS DATETIME), CAST('2026-04-18' AS DATETIME), CAST('2026-04-22' AS DATETIME), N'Funded after collateral verification.', N'loan.officer.kim', N'2002-0016-0003'),
        (N'extended.demo19@zavabank.com', N'STUD', 28000.00, 28000.00, 0.0525, 120,N'Graduate degree tuition',       N'Approved',  CAST('2026-04-28' AS DATETIME), CAST('2026-05-06' AS DATETIME), NULL, N'Approved pending school enrollment confirmation.',     N'loan.officer.kim', NULL)
    ) s(CustomerEmail, LoanProductCode, RequestedAmount, ApprovedAmount, InterestRate, TermMonths, Purpose, Status, ApplicationDate, DecisionDate, FundedDate, DecisionNotes, AssignedOfficer, LoanAccountNumber)
)
INSERT INTO LoanApplications (
    CustomerID, LoanProductID, RequestedAmount, ApprovedAmount, InterestRate, TermMonths, Purpose, Status, ApplicationDate, DecisionDate, FundedDate, DecisionNotes, AssignedOfficer, LoanAccountID, CreatedDate, ModifiedDate
)
SELECT
    c.CustomerID,
    lp.LoanProductID,
    s.RequestedAmount,
    s.ApprovedAmount,
    s.InterestRate,
    s.TermMonths,
    s.Purpose,
    s.Status,
    s.ApplicationDate,
    s.DecisionDate,
    s.FundedDate,
    s.DecisionNotes,
    s.AssignedOfficer,
    la.AccountID,
    @SeedNow,
    @SeedNow
FROM LoanAppSeed s
INNER JOIN Customers c
    ON c.Email = s.CustomerEmail
INNER JOIN LoanProducts lp
    ON lp.ProductCode = s.LoanProductCode
LEFT JOIN Accounts la
    ON la.AccountNumber = s.LoanAccountNumber
WHERE NOT EXISTS (
    SELECT 1
    FROM LoanApplications x
    WHERE x.CustomerID = c.CustomerID
      AND x.Purpose = s.Purpose
      AND x.ApplicationDate = s.ApplicationDate
);
GO

DECLARE @SeedNow DATETIME = '2026-05-14T08:22:11';

IF NOT EXISTS (SELECT 1 FROM FraudRules WHERE RuleName = N'High Amount Velocity')
BEGIN
    INSERT INTO FraudRules (RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
    VALUES (N'High Amount Velocity', N'Flags deposits, transfers, or withdrawals above configured threshold in short time windows.', N'Amount > 10000 AND TimeWindowMinutes <= 60', N'High', 1, 10000.00, 60, @SeedNow, @SeedNow);
END;

IF NOT EXISTS (SELECT 1 FROM FraudRules WHERE RuleName = N'Unusual Geo Location')
BEGIN
    INSERT INTO FraudRules (RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
    VALUES (N'Unusual Geo Location', N'Flags transactions posted from new geographic regions for customer profile.', N'GeoLocationNotInProfile = 1', N'Medium', 1, NULL, 180, @SeedNow, @SeedNow);
END;

IF NOT EXISTS (SELECT 1 FROM FraudRules WHERE RuleName = N'Rapid Successive Transactions')
BEGIN
    INSERT INTO FraudRules (RuleName, RuleDescription, RuleExpression, Severity, IsActive, ThresholdAmount, TimeWindowMinutes, CreatedDate, ModifiedDate)
    VALUES (N'Rapid Successive Transactions', N'Flags more than 5 transactions in 10 minutes on same account.', N'TransactionCount >= 5 AND TimeWindowMinutes <= 10', N'High', 1, 500.00, 10, @SeedNow, @SeedNow);
END;
GO

DECLARE @SeedNow DATETIME = '2026-05-14T08:22:11';

IF NOT EXISTS (SELECT 1 FROM AlertRules WHERE RuleCode = N'FRD_HIGH_AMT')
BEGIN
    INSERT INTO AlertRules (RuleName, RuleCode, DefaultThreshold, Category, IsActive, CreatedDate)
    VALUES (N'Fraud High Amount', N'FRD_HIGH_AMT', N'10000.00', N'Fraud', 1, @SeedNow);
END;

IF NOT EXISTS (SELECT 1 FROM AlertRules WHERE RuleCode = N'FRD_GEO')
BEGIN
    INSERT INTO AlertRules (RuleName, RuleCode, DefaultThreshold, Category, IsActive, CreatedDate)
    VALUES (N'Fraud Unusual Location', N'FRD_GEO', N'GeoMismatch', N'Fraud', 1, @SeedNow);
END;

IF NOT EXISTS (SELECT 1 FROM AlertRules WHERE RuleCode = N'FRD_RAPID_TXN')
BEGIN
    INSERT INTO AlertRules (RuleName, RuleCode, DefaultThreshold, Category, IsActive, CreatedDate)
    VALUES (N'Fraud Rapid Transactions', N'FRD_RAPID_TXN', N'5 in 10m', N'Fraud', 1, @SeedNow);
END;
GO

DECLARE @SeedNow DATETIME = '2026-05-14T08:22:11';
DECLARE @RuleHigh INT = (SELECT TOP 1 RuleID FROM FraudRules WHERE RuleName = N'High Amount Velocity' ORDER BY RuleID DESC);
DECLARE @RuleGeo INT = (SELECT TOP 1 RuleID FROM FraudRules WHERE RuleName = N'Unusual Geo Location' ORDER BY RuleID DESC);
DECLARE @RuleRapid INT = (SELECT TOP 1 RuleID FROM FraudRules WHERE RuleName = N'Rapid Successive Transactions' ORDER BY RuleID DESC);

;WITH AlertSeed AS (
    SELECT *
    FROM (VALUES
        (N'EXT-200200050001-C04', N'extended.demo05@zavabank.com', N'2002-0005-0001', @RuleHigh,  N'HighAmount',        N'Pending',   N'Large transfer outlier detected above threshold.',         NULL,                NULL,                  NULL),
        (N'EXT-200200070001-C07', N'extended.demo07@zavabank.com', N'2002-0007-0001', @RuleGeo,   N'UnusualLocation',   N'Escalated', N'Mobile withdrawal originated from new region.',             N'fraud.analyst.chen', NULL,                  NULL),
        (N'EXT-200200100001-C08', N'extended.demo10@zavabank.com', N'2002-0010-0001', @RuleRapid, N'RapidTransactions', N'Cleared',   N'Rapid posting sequence reviewed and verified as payroll run.', N'fraud.analyst.chen', CAST('2026-05-13T16:45:00' AS DATETIME), N'Employer file release confirmed.'),
        (N'EXT-200200160001-C04', N'extended.demo16@zavabank.com', N'2002-0016-0001', @RuleHigh,  N'HighAmount',        N'Pending',   N'High amount transfer requires enhanced due diligence.',      N'fraud.analyst.chen', NULL,                  NULL),
        (N'EXT-200200190001-C07', N'extended.demo19@zavabank.com', N'2002-0019-0001', @RuleGeo,   N'UnusualLocation',   N'Escalated', N'Cross-state card-present anomaly detected.',                 N'fraud.analyst.chen', NULL,                  NULL)
    ) s(ReferenceNumber, CustomerEmail, AccountNumber, RuleID, AlertType, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes)
)
INSERT INTO FraudAlerts (
    TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Status, Description, AssignedTo, ResolvedDate, ResolutionNotes, CreatedDate, ModifiedDate
)
SELECT
    t.TransactionID,
    c.CustomerID,
    a.AccountID,
    s.RuleID,
    s.AlertType,
    CASE WHEN s.Status IN (N'Escalated', N'Pending') THEN N'High' ELSE N'Medium' END,
    s.Status,
    s.Description,
    s.AssignedTo,
    s.ResolvedDate,
    s.ResolutionNotes,
    @SeedNow,
    @SeedNow
FROM AlertSeed s
INNER JOIN Customers c
    ON c.Email = s.CustomerEmail
INNER JOIN Accounts a
    ON a.AccountNumber = s.AccountNumber
LEFT JOIN Transactions t
    ON t.ReferenceNumber = s.ReferenceNumber
WHERE NOT EXISTS (
    SELECT 1
    FROM FraudAlerts fa
    WHERE fa.AlertType = s.AlertType
      AND fa.CustomerID = c.CustomerID
      AND fa.AccountID = a.AccountID
      AND fa.Description = s.Description
);
GO

DECLARE @SeedNow DATETIME = '2026-05-14T08:22:11';

;WITH ComplianceSeed AS (
    SELECT *
    FROM (VALUES
        (N'CTR', N'extended.demo04@zavabank.com', CAST('2026-05-09T11:00:00' AS DATETIME), N'Filed',  N'{"cashIn":15250.00,"branch":"Dallas Downtown","txnCount":2}', N'compliance.bot', N'FinCEN'),
        (N'CTR', N'extended.demo08@zavabank.com', CAST('2026-05-10T14:30:00' AS DATETIME), N'Filed',  N'{"cashIn":11875.00,"branch":"Chicago Loop","txnCount":3}',     N'compliance.bot', N'FinCEN'),
        (N'SAR', N'extended.demo07@zavabank.com', CAST('2026-05-11T09:10:00' AS DATETIME), N'Review', N'{"reason":"unusual location + velocity","risk":"high"}',       N'fraud.analyst.chen', N'FinCEN'),
        (N'SAR', N'extended.demo16@zavabank.com', CAST('2026-05-12T13:25:00' AS DATETIME), N'Filed',  N'{"reason":"large outbound wires","risk":"medium"}',             N'compliance.bot', N'FinCEN'),
        (N'CTR', N'extended.demo19@zavabank.com', CAST('2026-05-13T16:40:00' AS DATETIME), N'Filed',  N'{"cashOut":12400.00,"branch":"Pittsburgh Center","txnCount":1}', N'compliance.bot', N'FinCEN'),
        (N'SAR', N'extended.demo05@zavabank.com', CAST('2026-05-14T07:55:00' AS DATETIME), N'Draft',  N'{"reason":"high amount transfer pattern","risk":"medium"}',     N'fraud.analyst.chen', N'FinCEN')
    ) s(ReportType, CustomerEmail, FilingDate, Status, ReportData, FiledBy, RegulatoryBody)
)
INSERT INTO ComplianceReports (
    ReportType, CustomerID, FilingDate, Status, ReportData, FiledBy, RegulatoryBody, CreatedDate
)
SELECT
    s.ReportType,
    c.CustomerID,
    s.FilingDate,
    s.Status,
    s.ReportData,
    s.FiledBy,
    s.RegulatoryBody,
    @SeedNow
FROM ComplianceSeed s
INNER JOIN Customers c
    ON c.Email = s.CustomerEmail
WHERE NOT EXISTS (
    SELECT 1
    FROM ComplianceReports cr
    WHERE cr.ReportType = s.ReportType
      AND cr.CustomerID = c.CustomerID
      AND cr.FilingDate = s.FilingDate
);
GO

DECLARE @SeedNow DATETIME = '2026-05-14T08:22:11';

;WITH DocumentSeed AS (
    SELECT *
    FROM (VALUES
        (N'extended.demo01@zavabank.com', N'LoanAgreement', N'loan-agreement-demo01.pdf', N'application/pdf', N'Loan agreement payload for demo customer 01'),
        (N'extended.demo04@zavabank.com', N'DriverLicense', N'id-copy-demo04.png',        N'image/png',      N'Driver license scan payload for demo customer 04'),
        (N'extended.demo07@zavabank.com', N'TaxForm',       N'w2-demo07-2025.pdf',         N'application/pdf', N'W-2 tax form payload for demo customer 07'),
        (N'extended.demo10@zavabank.com', N'LoanAgreement', N'auto-loan-demo10.pdf',       N'application/pdf', N'Auto loan agreement payload for demo customer 10'),
        (N'extended.demo12@zavabank.com', N'BusinessPlan',  N'business-plan-demo12.pdf',   N'application/pdf', N'Business plan payload for demo customer 12'),
        (N'extended.demo16@zavabank.com', N'PropertyDeed',  N'property-deed-demo16.pdf',   N'application/pdf', N'Property deed payload for demo customer 16'),
        (N'extended.demo19@zavabank.com', N'TaxForm',       N'1040-demo19-2025.pdf',       N'application/pdf', N'1040 tax return payload for demo customer 19'),
        (N'extended.demo20@zavabank.com', N'Passport',      N'passport-demo20.jpg',        N'image/jpeg',      N'Passport scan payload for demo customer 20')
    ) s(CustomerEmail, DocumentType, FileName, ContentType, DocumentPayload)
)
INSERT INTO Documents (
    CustomerID, DocumentType, FileName, ContentType, DocumentData, UploadedDate
)
SELECT
    c.CustomerID,
    s.DocumentType,
    s.FileName,
    s.ContentType,
    CONVERT(VARBINARY(MAX), s.DocumentPayload),
    @SeedNow
FROM DocumentSeed s
INNER JOIN Customers c
    ON c.Email = s.CustomerEmail
WHERE NOT EXISTS (
    SELECT 1
    FROM Documents d
    WHERE d.CustomerID = c.CustomerID
      AND d.FileName = s.FileName
);
GO

PRINT 'Extended demo seed data loaded successfully.';
GO
