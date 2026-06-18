USE [ZavaBankDB];
GO

-- ============================================================
-- Seed RiskFactors (12 rows)
-- ============================================================
SET IDENTITY_INSERT [dbo].[RiskFactors] ON;

INSERT INTO [dbo].[RiskFactors] (FactorID, FactorName, FactorCode, Weight, Category, [Description], IsActive, CreatedDate)
VALUES
(1,  N'Debt-to-Income Ratio',  N'DTI',          2.50, N'Financial',  N'Ratio of monthly debt to monthly income',   1, '2024-01-01'),
(2,  N'Loan-to-Value Ratio',   N'LTV',          2.00, N'Financial',  N'Ratio of loan amount to collateral value',  1, '2024-01-01'),
(3,  N'Credit Score',           N'CREDIT_SCORE', 3.00, N'Financial',  N'Bureau credit score impact',                1, '2024-01-01'),
(4,  N'Employment History',     N'EMP_HISTORY',  1.50, N'Employment', N'Length and stability of employment',         1, '2024-01-01'),
(5,  N'Employment Status',      N'EMP_STATUS',   1.75, N'Employment', N'Current employment type',                   1, '2024-01-01'),
(6,  N'Collateral Value',       N'COLL_VALUE',   2.00, N'Collateral', N'Appraised value of collateral',             1, '2024-01-01'),
(7,  N'Payment History',        N'PAY_HISTORY',  2.50, N'Behavioral', N'History of on-time payments',               1, '2024-01-01'),
(8,  N'Account Age',            N'ACCT_AGE',     1.00, N'Behavioral', N'Length of banking relationship',            1, '2024-01-01'),
(9,  N'Existing Debt',          N'EXIST_DEBT',   1.75, N'Financial',  N'Total existing debt obligations',           1, '2024-01-01'),
(10, N'Income Verification',    N'INC_VERIFY',   2.00, N'Employment', N'Verified income documentation',             1, '2024-01-01'),
(11, N'Asset Reserves',         N'ASSET_RES',    1.25, N'Financial',  N'Liquid assets after closing',               1, '2024-01-01'),
(12, N'Residency Stability',    N'RES_STAB',     0.75, N'Behavioral', N'Length at current address',                 1, '2024-01-01');

SET IDENTITY_INSERT [dbo].[RiskFactors] OFF;
GO

-- ============================================================
-- Seed CreditScores (50 rows)
-- ============================================================
SET IDENTITY_INSERT [dbo].[CreditScores] ON;

INSERT INTO [dbo].[CreditScores] (CreditScoreID, CustomerID, Score, ScoreSource, ReportDate, ExpiryDate, RawReportData, CreatedDate)
VALUES
-- Special demo customers
(1,  1,  762, N'Experian',    '2026-03-10', '2026-06-08', N'<CreditReport><Score>762</Score><Source>Experian</Source></CreditReport>',    '2026-03-10'),
(2,  2,  710, N'TransUnion',  '2026-02-15', '2026-05-16', N'<CreditReport><Score>710</Score><Source>TransUnion</Source></CreditReport>',  '2026-02-15'),
(3,  3,  695, N'Equifax',     '2026-04-01', '2026-06-30', N'<CreditReport><Score>695</Score><Source>Equifax</Source></CreditReport>',     '2026-04-01'),
(4,  4,  680, N'Experian',    '2026-01-20', '2026-04-20', N'<CreditReport><Score>680</Score><Source>Experian</Source></CreditReport>',    '2026-01-20'),
(5,  5,  595, N'TransUnion',  '2026-03-05', '2026-06-03', N'<CreditReport><Score>595</Score><Source>TransUnion</Source></CreditReport>',  '2026-03-05'),
(6,  6,  755, N'Equifax',     '2024-12-15', '2025-03-15', N'<CreditReport><Score>755</Score><Source>Equifax</Source></CreditReport>',     '2024-12-15'),
-- Regular customers 7-50
(7,  7,  780, N'Experian',    '2026-01-10', '2026-04-10', NULL, '2026-01-10'),
(8,  8,  720, N'TransUnion',  '2026-02-20', '2026-05-21', NULL, '2026-02-20'),
(9,  9,  650, N'Equifax',     '2026-03-15', '2026-06-13', NULL, '2026-03-15'),
(10, 10, 810, N'Experian',    '2026-04-05', '2026-07-04', NULL, '2026-04-05'),
(11, 11, 690, N'Internal',    '2026-01-25', '2026-04-25', NULL, '2026-01-25'),
(12, 12, 735, N'TransUnion',  '2026-02-10', '2026-05-11', NULL, '2026-02-10'),
(13, 13, 620, N'Equifax',     '2026-03-20', '2026-06-18', NULL, '2026-03-20'),
(14, 14, 770, N'Experian',    '2026-04-12', '2026-07-11', NULL, '2026-04-12'),
(15, 15, 705, N'Internal',    '2026-01-05', '2026-04-05', NULL, '2026-01-05'),
(16, 16, 640, N'TransUnion',  '2026-02-28', '2026-05-29', NULL, '2026-02-28'),
(17, 17, 795, N'Equifax',     '2026-03-08', '2026-06-06', NULL, '2026-03-08'),
(18, 18, 580, N'Experian',    '2026-04-18', '2026-07-17', NULL, '2026-04-18'),
(19, 19, 750, N'Internal',    '2026-01-15', '2026-04-15', NULL, '2026-01-15'),
(20, 20, 715, N'TransUnion',  '2026-02-05', '2026-05-06', NULL, '2026-02-05'),
(21, 21, 660, N'Equifax',     '2026-03-25', '2026-06-23', NULL, '2026-03-25'),
(22, 22, 820, N'Experian',    '2026-04-01', '2026-06-30', NULL, '2026-04-01'),
(23, 23, 700, N'TransUnion',  '2026-01-20', '2026-04-20', NULL, '2026-01-20'),
(24, 24, 675, N'Internal',    '2026-02-12', '2026-05-13', NULL, '2026-02-12'),
(25, 25, 745, N'Equifax',     '2026-03-03', '2026-06-01', NULL, '2026-03-03'),
(26, 26, 610, N'Experian',    '2026-04-22', '2026-07-21', NULL, '2026-04-22'),
(27, 27, 785, N'TransUnion',  '2026-01-30', '2026-04-30', NULL, '2026-01-30'),
(28, 28, 730, N'Equifax',     '2026-02-18', '2026-05-19', NULL, '2026-02-18'),
(29, 29, 655, N'Internal',    '2026-03-12', '2026-06-10', NULL, '2026-03-12'),
(30, 30, 800, N'Experian',    '2026-04-08', '2026-07-07', NULL, '2026-04-08'),
(31, 31, 725, N'TransUnion',  '2026-01-08', '2026-04-08', NULL, '2026-01-08'),
(32, 32, 670, N'Equifax',     '2026-02-22', '2026-05-23', NULL, '2026-02-22'),
(33, 33, 760, N'Experian',    '2026-03-18', '2026-06-16', NULL, '2026-03-18'),
(34, 34, 590, N'Internal',    '2026-04-15', '2026-07-14', NULL, '2026-04-15'),
(35, 35, 740, N'TransUnion',  '2026-01-12', '2026-04-12', NULL, '2026-01-12'),
(36, 36, 815, N'Equifax',     '2026-02-08', '2026-05-09', NULL, '2026-02-08'),
(37, 37, 685, N'Experian',    '2026-03-28', '2026-06-26', NULL, '2026-03-28'),
(38, 38, 710, N'Internal',    '2026-04-10', '2026-07-09', NULL, '2026-04-10'),
(39, 39, 635, N'TransUnion',  '2026-01-18', '2026-04-18', NULL, '2026-01-18'),
(40, 40, 775, N'Equifax',     '2026-02-25', '2026-05-26', NULL, '2026-02-25'),
(41, 41, 720, N'Experian',    '2026-03-05', '2026-06-03', NULL, '2026-03-05'),
(42, 42, 645, N'Internal',    '2026-04-20', '2026-07-19', NULL, '2026-04-20'),
(43, 43, 790, N'TransUnion',  '2026-01-22', '2026-04-22', NULL, '2026-01-22'),
(44, 44, 665, N'Equifax',     '2026-02-14', '2026-05-15', NULL, '2026-02-14'),
(45, 45, 755, N'Experian',    '2026-03-22', '2026-06-20', NULL, '2026-03-22'),
(46, 46, 600, N'TransUnion',  '2026-04-02', '2026-07-01', NULL, '2026-04-02'),
(47, 47, 805, N'Equifax',     '2026-01-28', '2026-04-28', NULL, '2026-01-28'),
(48, 48, 680, N'Internal',    '2026-02-16', '2026-05-17', NULL, '2026-02-16'),
(49, 49, 740, N'Experian',    '2026-03-30', '2026-06-28', NULL, '2026-03-30'),
(50, 50, 625, N'TransUnion',  '2026-04-25', '2026-07-24', NULL, '2026-04-25');

SET IDENTITY_INSERT [dbo].[CreditScores] OFF;
GO

-- ============================================================
-- Seed LoanApplications (30 rows)
-- ============================================================
SET IDENTITY_INSERT [dbo].[LoanApplications] ON;

INSERT INTO [dbo].[LoanApplications]
    (ApplicationID, CustomerID, LoanProductID, RequestedAmount, ApprovedAmount, InterestRate, TermMonths, Purpose, [Status], ApplicationDate, DecisionDate, FundedDate, DecisionNotes, AssignedOfficer, LoanAccountID, CreatedDate, ModifiedDate)
VALUES
-- Special demo applications
(1,  1, 1, 15000.00,  NULL,      NULL,   36, N'Home improvement',     N'UnderReview', '2026-05-01', NULL,         NULL,         NULL, N'loan.officer.kim', NULL, '2026-05-01', '2026-05-01'),
(2,  5, 1, 25000.00,  NULL,      NULL,   48, N'Debt consolidation',   N'Denied',      '2026-03-15', '2026-03-22', NULL,         N'Application denied due to high DTI and low credit score.', N'loan.officer.kim', NULL, '2026-03-15', '2026-03-22'),
(3,  6, 1, 25000.00,  25000.00,  0.0899, 60, N'Home renovation',      N'Funded',      '2025-01-02', '2025-01-10', '2025-01-15', N'Approved and funded. Strong credit profile.', N'loan.officer.kim', 13,   '2025-01-02', '2025-01-15'),
(4,  2, 3, 35000.00,  32000.00,  0.0549, 60, N'New vehicle purchase',  N'Approved',    '2026-04-20', '2026-04-28', NULL,         N'Approved with condition met.', N'loan.officer.kim', NULL, '2026-04-20', '2026-04-28'),
(5,  3, 4, 200000.00, NULL,      NULL,   60, N'Business expansion',    N'UnderReview', '2026-05-05', NULL,         NULL,         NULL, N'loan.officer.kim', NULL, '2026-05-05', '2026-05-05'),

-- Regular applications (6-30)
(6,  7,  2, 350000.00, 340000.00, 0.0625, 360, N'Primary residence purchase',    N'Funded',      '2025-03-10', '2025-03-20', '2025-04-01', N'Funded mortgage.', N'loan.officer.kim', NULL, '2025-03-10', '2025-04-01'),
(7,  8,  3, 28000.00,  28000.00,  0.0499, 60,  N'Used vehicle purchase',         N'Funded',      '2025-06-15', '2025-06-22', '2025-07-01', N'Auto loan funded.', N'loan.officer.kim', NULL, '2025-06-15', '2025-07-01'),
(8,  9,  1, 10000.00,  NULL,      NULL,   24,  N'Medical expenses',              N'Denied',      '2026-01-05', '2026-01-12', NULL,         N'Credit score below minimum threshold.', N'loan.officer.kim', NULL, '2026-01-05', '2026-01-12'),
(9,  10, 2, 450000.00, 450000.00, 0.0575, 360, N'Investment property',           N'Funded',      '2025-04-20', '2025-05-01', '2025-05-15', N'Excellent credit profile.', N'admin', NULL, '2025-04-20', '2025-05-15'),
(10, 11, 5, 50000.00,  45000.00,  0.0699, 180, N'Home equity line',              N'Approved',    '2026-02-10', '2026-02-20', NULL,         N'Approved at reduced amount.', N'loan.officer.kim', NULL, '2026-02-10', '2026-02-20'),
(11, 12, 1, 8000.00,   8000.00,   0.1099, 24,  N'Vacation travel',              N'Funded',      '2025-08-01', '2025-08-05', '2025-08-10', N'Funded personal loan.', N'loan.officer.kim', NULL, '2025-08-01', '2025-08-10'),
(12, 13, 6, 30000.00,  NULL,      NULL,   120, N'Graduate tuition',              N'Denied',      '2026-01-20', '2026-01-28', NULL,         N'Insufficient credit history.', N'admin', NULL, '2026-01-20', '2026-01-28'),
(13, 14, 3, 42000.00,  42000.00,  0.0449, 72,  N'New vehicle purchase',         N'Funded',      '2025-09-10', '2025-09-18', '2025-10-01', N'Strong applicant.', N'loan.officer.kim', NULL, '2025-09-10', '2025-10-01'),
(14, 15, 4, 150000.00, 120000.00, 0.0799, 60,  N'Restaurant startup',           N'Approved',    '2026-03-01', '2026-03-15', NULL,         N'Approved at reduced amount due to limited business history.', N'loan.officer.kim', NULL, '2026-03-01', '2026-03-15'),
(15, 16, 1, 12000.00,  NULL,      NULL,   36,  N'Debt consolidation',           N'Denied',      '2026-02-05', '2026-02-12', NULL,         N'High existing debt load.', N'loan.officer.kim', NULL, '2026-02-05', '2026-02-12'),
(16, 17, 2, 500000.00, 500000.00, 0.0550, 360, N'Luxury home purchase',         N'Funded',      '2025-05-01', '2025-05-12', '2025-06-01', N'Premium client.', N'admin', NULL, '2025-05-01', '2025-06-01'),
(17, 18, 1, 5000.00,   NULL,      NULL,   12,  N'Emergency expenses',           N'Denied',      '2026-03-20', '2026-03-25', NULL,         N'Credit score 580 below minimum.', N'loan.officer.kim', NULL, '2026-03-20', '2026-03-25'),
(18, 19, 5, 75000.00,  75000.00,  0.0650, 180, N'Home equity for renovation',   N'Approved',    '2026-04-01', '2026-04-10', NULL,         N'Good LTV ratio.', N'loan.officer.kim', NULL, '2026-04-01', '2026-04-10'),
(19, 20, 3, 22000.00,  22000.00,  0.0599, 48,  N'Used vehicle purchase',        N'Funded',      '2025-10-15', '2025-10-22', '2025-11-01', N'Funded auto loan.', N'loan.officer.kim', NULL, '2025-10-15', '2025-11-01'),
(20, 21, 6, 45000.00,  NULL,      NULL,   120, N'Undergraduate tuition',        N'Denied',      '2026-01-10', '2026-01-18', NULL,         N'Co-signer required.', N'admin', NULL, '2026-01-10', '2026-01-18'),
(21, 22, 2, 380000.00, 380000.00, 0.0525, 360, N'Primary residence purchase',   N'Funded',      '2025-07-05', '2025-07-15', '2025-08-01', N'Excellent credit.', N'loan.officer.kim', NULL, '2025-07-05', '2025-08-01'),
(22, 23, 1, 15000.00,  NULL,      NULL,   36,  N'Wedding expenses',             N'UnderReview', '2026-05-02', NULL,         NULL,         NULL, N'loan.officer.kim', NULL, '2026-05-02', '2026-05-02'),
(23, 24, 4, 100000.00, NULL,      NULL,   48,  N'Retail store opening',         N'Submitted',   '2026-05-08', NULL,         NULL,         NULL, N'loan.officer.kim', NULL, '2026-05-08', '2026-05-08'),
(24, 25, 3, 30000.00,  30000.00,  0.0549, 60,  N'New vehicle purchase',         N'Approved',    '2026-04-15', '2026-04-25', NULL,         N'Approved.', N'loan.officer.kim', NULL, '2026-04-15', '2026-04-25'),
(25, 26, 1, 7000.00,   NULL,      NULL,   24,  N'Home appliances',              N'Denied',      '2026-02-20', '2026-02-27', NULL,         N'Low credit score.', N'loan.officer.kim', NULL, '2026-02-20', '2026-02-27'),
(26, 27, 2, 420000.00, 420000.00, 0.0575, 360, N'Primary residence purchase',   N'Funded',      '2025-11-01', '2025-11-10', '2025-12-01', N'Funded mortgage.', N'admin', NULL, '2025-11-01', '2025-12-01'),
(27, 28, 6, 25000.00,  25000.00,  0.0450, 120, N'Medical school tuition',       N'Approved',    '2026-03-10', '2026-03-20', NULL,         N'Approved student loan.', N'loan.officer.kim', NULL, '2026-03-10', '2026-03-20'),
(28, 29, 1, 18000.00,  NULL,      NULL,   36,  N'Home improvement',             N'Submitted',   '2026-05-10', NULL,         NULL,         NULL, N'loan.officer.kim', NULL, '2026-05-10', '2026-05-10'),
(29, 30, 4, 300000.00, 280000.00, 0.0725, 60,  N'Manufacturing equipment',      N'Closed',      '2025-02-01', '2025-02-15', '2025-03-01', N'Loan closed after full repayment.', N'loan.officer.kim', NULL, '2025-02-01', '2025-03-01'),
(30, 31, 1, 20000.00,  NULL,      NULL,   48,  N'Debt consolidation',           N'Submitted',   '2026-05-12', NULL,         NULL,         NULL, N'admin', NULL, '2026-05-12', '2026-05-12');

SET IDENTITY_INSERT [dbo].[LoanApplications] OFF;
GO

-- ============================================================
-- Seed LoanDecisions (~40 rows)
-- ============================================================
SET IDENTITY_INSERT [dbo].[LoanDecisions] ON;

INSERT INTO [dbo].[LoanDecisions]
    (DecisionID, ApplicationID, DecisionType, DecisionBy, DecisionDate, Reason, CreditScoreAtTime, RiskLevel, Conditions)
VALUES
-- David Park denial (ApplicationID 2)
(1,  2,  N'Escalate',          N'SYSTEM',           '2026-03-18', N'High DTI ratio of 0.52, credit score below threshold',                                                             595, N'High',   NULL),
(2,  2,  N'Deny',              N'loan.officer.kim', '2026-03-22', N'DTI exceeds 45% limit. Multiple missed payments in last 12 months. Credit score 595 below minimum 620.',            595, N'High',   NULL),

-- Emily Johnson approval (ApplicationID 3)
(3,  3,  N'Approve',           N'loan.officer.kim', '2025-01-10', N'Strong credit profile. DTI 0.28, stable employment, good payment history.',                                         755, N'Low',    N'Verify employment within 30 days'),

-- James Chen approval (ApplicationID 4)
(4,  4,  N'ConditionalApprove',N'SYSTEM',           '2026-04-25', N'Meets criteria with conditions.',                                                                                   710, N'Medium', N'Requires $3,000 down payment'),
(5,  4,  N'Approve',           N'loan.officer.kim', '2026-04-28', N'Condition met. Approved at $32,000.',                                                                               710, N'Medium', NULL),

-- Regular decisions (6-40) for ApplicationIDs 6-30
-- App 6 (CustomerID 7, Funded mortgage)
(6,  6,  N'Approve',           N'loan.officer.kim', '2025-03-20', N'Strong income and credit. Approved mortgage.',                                                                       780, N'Low',    N'Appraisal required'),

-- App 7 (CustomerID 8, Funded auto)
(7,  7,  N'Approve',           N'loan.officer.kim', '2025-06-22', N'Good credit history. Auto loan approved.',                                                                           720, N'Low',    NULL),

-- App 8 (CustomerID 9, Denied)
(8,  8,  N'Escalate',          N'SYSTEM',           '2026-01-08', N'Credit score 650 borderline. Requires manual review.',                                                               650, N'Medium', NULL),
(9,  8,  N'Deny',              N'loan.officer.kim', '2026-01-12', N'Insufficient income for requested amount. DTI too high.',                                                            650, N'Medium', NULL),

-- App 9 (CustomerID 10, Funded mortgage)
(10, 9,  N'Approve',           N'admin',            '2025-05-01', N'Excellent credit profile. Investment property approved.',                                                             810, N'Low',    N'Proof of rental income required'),

-- App 10 (CustomerID 11, Approved HELOC)
(11, 10, N'ConditionalApprove',N'SYSTEM',           '2026-02-15', N'Approved subject to property appraisal.',                                                                            690, N'Medium', N'Property appraisal within 30 days'),
(12, 10, N'Approve',           N'loan.officer.kim', '2026-02-20', N'Appraisal satisfactory. Approved at $45,000.',                                                                       690, N'Medium', NULL),

-- App 11 (CustomerID 12, Funded personal)
(13, 11, N'Approve',           N'loan.officer.kim', '2025-08-05', N'Small loan amount. Good standing customer.',                                                                          735, N'Low',    NULL),

-- App 12 (CustomerID 13, Denied student)
(14, 12, N'Deny',              N'admin',            '2026-01-28', N'Credit history too short. No co-signer provided.',                                                                    620, N'High',   NULL),

-- App 13 (CustomerID 14, Funded auto)
(15, 13, N'Approve',           N'loan.officer.kim', '2025-09-18', N'Strong applicant. Auto loan approved.',                                                                               770, N'Low',    NULL),

-- App 14 (CustomerID 15, Approved business)
(16, 14, N'Escalate',          N'SYSTEM',           '2026-03-08', N'Business loan above $100K requires senior review.',                                                                   705, N'Medium', NULL),
(17, 14, N'Approve',           N'loan.officer.kim', '2026-03-15', N'Approved at $120,000. Limited business history warrants reduced amount.',                                             705, N'Medium', N'Quarterly financial reporting required'),

-- App 15 (CustomerID 16, Denied personal)
(18, 15, N'Deny',              N'loan.officer.kim', '2026-02-12', N'DTI ratio 0.55 exceeds maximum. Existing debt too high.',                                                             640, N'High',   NULL),

-- App 16 (CustomerID 17, Funded luxury mortgage)
(19, 16, N'Approve',           N'admin',            '2025-05-12', N'Premium client. Excellent credit and income.',                                                                        795, N'Low',    NULL),

-- App 17 (CustomerID 18, Denied personal)
(20, 17, N'Deny',              N'loan.officer.kim', '2026-03-25', N'Credit score 580 below minimum 620 threshold.',                                                                       580, N'High',   NULL),

-- App 18 (CustomerID 19, Approved HELOC)
(21, 18, N'Approve',           N'loan.officer.kim', '2026-04-10', N'Good LTV ratio and stable income. HELOC approved.',                                                                   750, N'Low',    N'Title search required'),

-- App 19 (CustomerID 20, Funded auto)
(22, 19, N'Approve',           N'loan.officer.kim', '2025-10-22', N'Approved auto loan. Good payment history.',                                                                           715, N'Low',    NULL),

-- App 20 (CustomerID 21, Denied student)
(23, 20, N'Escalate',          N'SYSTEM',           '2026-01-14', N'Score 660 borderline for student loan amount.',                                                                       660, N'Medium', NULL),
(24, 20, N'Deny',              N'admin',            '2026-01-18', N'Co-signer required for applicants with credit score below 680.',                                                      660, N'Medium', NULL),

-- App 21 (CustomerID 22, Funded mortgage)
(25, 21, N'Approve',           N'loan.officer.kim', '2025-07-15', N'Excellent credit. Primary residence mortgage approved.',                                                              820, N'Low',    NULL),

-- App 24 (CustomerID 25, Approved auto)
(26, 24, N'Approve',           N'loan.officer.kim', '2026-04-25', N'Approved auto loan.',                                                                                                745, N'Low',    NULL),

-- App 25 (CustomerID 26, Denied personal)
(27, 25, N'Deny',              N'loan.officer.kim', '2026-02-27', N'Credit score 610 below minimum for unsecured loan.',                                                                  610, N'High',   NULL),

-- App 26 (CustomerID 27, Funded mortgage)
(28, 26, N'Approve',           N'admin',            '2025-11-10', N'Strong applicant. Mortgage approved.',                                                                                785, N'Low',    N'Homeowners insurance required'),

-- App 27 (CustomerID 28, Approved student)
(29, 27, N'ConditionalApprove',N'SYSTEM',           '2026-03-15', N'Approved pending enrollment verification.',                                                                           730, N'Low',    N'Enrollment verification required'),
(30, 27, N'Approve',           N'loan.officer.kim', '2026-03-20', N'Enrollment verified. Student loan approved.',                                                                         730, N'Low',    NULL),

-- App 29 (CustomerID 30, Closed business)
(31, 29, N'Approve',           N'loan.officer.kim', '2025-02-15', N'Business loan approved for manufacturing equipment.',                                                                 800, N'Low',    N'Equipment lien required'),

-- Additional decisions for variety
(32, 6,  N'ConditionalApprove',N'SYSTEM',           '2025-03-15', N'Appraisal pending.',                                                                                                 780, N'Low',    N'Property appraisal required'),
(33, 9,  N'ConditionalApprove',N'SYSTEM',           '2025-04-28', N'Rental income documentation required.',                                                                              810, N'Low',    N'Proof of rental income'),
(34, 16, N'ConditionalApprove',N'SYSTEM',           '2025-05-08', N'Premium property requires enhanced appraisal.',                                                                       795, N'Low',    N'Enhanced property appraisal'),
(35, 21, N'ConditionalApprove',N'SYSTEM',           '2025-07-10', N'Standard mortgage conditions apply.',                                                                                 820, N'Low',    N'Title insurance required'),
(36, 26, N'ConditionalApprove',N'SYSTEM',           '2025-11-05', N'Mortgage conditions pending.',                                                                                        785, N'Low',    N'Homeowners insurance verification'),
(37, 29, N'ConditionalApprove',N'SYSTEM',           '2025-02-10', N'Equipment lien documentation required.',                                                                              800, N'Low',    N'Equipment lien documentation'),
(38, 7,  N'ConditionalApprove',N'SYSTEM',           '2025-06-18', N'Vehicle inspection required.',                                                                                        720, N'Low',    N'Vehicle inspection report'),
(39, 19, N'ConditionalApprove',N'SYSTEM',           '2025-10-18', N'Standard auto conditions.',                                                                                           715, N'Low',    N'Vehicle title transfer'),
(40, 11, N'ConditionalApprove',N'SYSTEM',           '2025-08-03', N'Income verification pending.',                                                                                        735, N'Low',    N'Pay stub verification');

SET IDENTITY_INSERT [dbo].[LoanDecisions] OFF;
GO

-- ============================================================
-- Seed LoanPayments (~150 rows)
-- ============================================================
SET IDENTITY_INSERT [dbo].[LoanPayments] ON;

-- Emily Johnson's 16 monthly payments (ApplicationID 3, AccountID 13)
-- $25,000 at 8.99% APR, 60 months, monthly payment $518.96
-- Monthly rate = 0.0899/12 = 0.00749167
INSERT INTO [dbo].[LoanPayments]
    (PaymentID, ApplicationID, AccountID, PaymentAmount, PrincipalAmount, InterestAmount, PaymentDate, DueDate, [Status], PaymentMethod, ConfirmationNumber, CreatedDate)
VALUES
(1,   3, 13, 518.96, 331.25, 187.71, '2025-02-15', '2025-02-15', N'Completed', N'ACH', N'LP-2025-000001', '2025-02-15'),
(2,   3, 13, 518.96, 333.73, 185.23, '2025-03-14', '2025-03-15', N'Completed', N'ACH', N'LP-2025-000002', '2025-03-14'),
(3,   3, 13, 518.96, 336.23, 182.73, '2025-04-15', '2025-04-15', N'Completed', N'ACH', N'LP-2025-000003', '2025-04-15'),
(4,   3, 13, 518.96, 338.75, 180.21, '2025-05-15', '2025-05-15', N'Completed', N'ACH', N'LP-2025-000004', '2025-05-15'),
(5,   3, 13, 518.96, 341.29, 177.67, '2025-06-16', '2025-06-15', N'Completed', N'ACH', N'LP-2025-000005', '2025-06-16'),
(6,   3, 13, 518.96, 343.84, 175.12, '2025-07-15', '2025-07-15', N'Completed', N'ACH', N'LP-2025-000006', '2025-07-15'),
(7,   3, 13, 518.96, 346.42, 172.54, '2025-08-15', '2025-08-15', N'Completed', N'ACH', N'LP-2025-000007', '2025-08-15'),
(8,   3, 13, 518.96, 349.01, 169.95, '2025-09-15', '2025-09-15', N'Completed', N'ACH', N'LP-2025-000008', '2025-09-15'),
(9,   3, 13, 518.96, 351.63, 167.33, '2025-10-15', '2025-10-15', N'Completed', N'ACH', N'LP-2025-000009', '2025-10-15'),
(10,  3, 13, 518.96, 354.26, 164.70, '2025-11-14', '2025-11-15', N'Completed', N'ACH', N'LP-2025-000010', '2025-11-14'),
(11,  3, 13, 518.96, 356.92, 162.04, '2025-12-15', '2025-12-15', N'Completed', N'ACH', N'LP-2025-000011', '2025-12-15'),
(12,  3, 13, 518.96, 359.59, 159.37, '2026-01-15', '2026-01-15', N'Completed', N'ACH', N'LP-2026-000012', '2026-01-15'),
(13,  3, 13, 518.96, 362.29, 156.67, '2026-02-13', '2026-02-15', N'Completed', N'ACH', N'LP-2026-000013', '2026-02-13'),
(14,  3, 13, 518.96, 365.00, 153.96, '2026-03-15', '2026-03-15', N'Completed', N'ACH', N'LP-2026-000014', '2026-03-15'),
(15,  3, 13, 518.96, 367.74, 151.22, '2026-04-15', '2026-04-15', N'Completed', N'ACH', N'LP-2026-000015', '2026-04-15'),
(16,  3, 13, 518.96, 370.49, 148.47, '2026-05-15', '2026-05-15', N'Completed', N'ACH', N'LP-2026-000016', '2026-05-15'),

-- App 6 (CustomerID 7, Mortgage $340K funded 2025-04-01, ~6.25%, 360mo, ~$2,093/mo) - 14 payments
(17,  6, 14, 2093.00, 323.00, 1770.00, '2025-05-01', '2025-05-01', N'Completed', N'ACH',    N'LP-2025-060001', '2025-05-01'),
(18,  6, 14, 2093.00, 324.68, 1768.32, '2025-06-01', '2025-06-01', N'Completed', N'ACH',    N'LP-2025-060002', '2025-06-01'),
(19,  6, 14, 2093.00, 326.37, 1766.63, '2025-07-01', '2025-07-01', N'Completed', N'ACH',    N'LP-2025-060003', '2025-07-01'),
(20,  6, 14, 2093.00, 328.07, 1764.93, '2025-08-01', '2025-08-01', N'Completed', N'ACH',    N'LP-2025-060004', '2025-08-01'),
(21,  6, 14, 2093.00, 329.78, 1763.22, '2025-09-01', '2025-09-01', N'Completed', N'ACH',    N'LP-2025-060005', '2025-09-01'),
(22,  6, 14, 2093.00, 331.50, 1761.50, '2025-10-01', '2025-10-01', N'Completed', N'ACH',    N'LP-2025-060006', '2025-10-01'),
(23,  6, 14, 2093.00, 333.23, 1759.77, '2025-11-01', '2025-11-01', N'Completed', N'ACH',    N'LP-2025-060007', '2025-11-01'),
(24,  6, 14, 2093.00, 334.97, 1758.03, '2025-12-01', '2025-12-01', N'Completed', N'ACH',    N'LP-2025-060008', '2025-12-01'),
(25,  6, 14, 2093.00, 336.72, 1756.28, '2026-01-01', '2026-01-01', N'Completed', N'ACH',    N'LP-2026-060009', '2026-01-01'),
(26,  6, 14, 2093.00, 338.48, 1754.52, '2026-02-01', '2026-02-01', N'Completed', N'ACH',    N'LP-2026-060010', '2026-02-01'),
(27,  6, 14, 2093.00, 340.25, 1752.75, '2026-03-01', '2026-03-01', N'Completed', N'ACH',    N'LP-2026-060011', '2026-03-01'),
(28,  6, 14, 2093.00, 342.02, 1750.98, '2026-04-01', '2026-04-01', N'Completed', N'ACH',    N'LP-2026-060012', '2026-04-01'),
(29,  6, 14, 2093.00, 343.81, 1749.19, '2026-05-01', '2026-05-01', N'Completed', N'ACH',    N'LP-2026-060013', '2026-05-01'),
(30,  6, 14, 2093.00, 345.60, 1747.40, '2026-06-01', '2026-06-01', N'Pending',   N'ACH',    N'LP-2026-060014', '2026-05-15'),

-- App 7 (CustomerID 8, Auto $28K funded 2025-07-01, ~4.99%, 60mo, ~$528/mo) - 11 payments
(31,  7, 15, 528.42, 411.92, 116.50, '2025-08-01', '2025-08-01', N'Completed', N'ACH',    N'LP-2025-070001', '2025-08-01'),
(32,  7, 15, 528.42, 413.64, 114.78, '2025-09-01', '2025-09-01', N'Completed', N'ACH',    N'LP-2025-070002', '2025-09-01'),
(33,  7, 15, 528.42, 415.36, 113.06, '2025-10-01', '2025-10-01', N'Completed', N'ACH',    N'LP-2025-070003', '2025-10-01'),
(34,  7, 15, 528.42, 417.09, 111.33, '2025-11-01', '2025-11-01', N'Completed', N'ACH',    N'LP-2025-070004', '2025-11-01'),
(35,  7, 15, 528.42, 418.83, 109.59, '2025-12-01', '2025-12-01', N'Completed', N'ACH',    N'LP-2025-070005', '2025-12-01'),
(36,  7, 15, 528.42, 420.57, 107.85, '2026-01-01', '2026-01-01', N'Completed', N'ACH',    N'LP-2026-070006', '2026-01-01'),
(37,  7, 15, 528.42, 422.32, 106.10, '2026-02-01', '2026-02-01', N'Completed', N'ACH',    N'LP-2026-070007', '2026-02-01'),
(38,  7, 15, 528.42, 424.08, 104.34, '2026-03-01', '2026-03-01', N'Completed', N'ACH',    N'LP-2026-070008', '2026-03-01'),
(39,  7, 15, 528.42, 425.84, 102.58, '2026-04-01', '2026-04-01', N'Completed', N'ACH',    N'LP-2026-070009', '2026-04-01'),
(40,  7, 15, 528.42, 427.62, 100.80, '2026-05-01', '2026-05-01', N'Completed', N'ACH',    N'LP-2026-070010', '2026-05-01'),
(41,  7, 15, 528.42, 429.40,  99.02, '2026-06-01', '2026-06-01', N'Pending',   N'ACH',    N'LP-2026-070011', '2026-05-15'),

-- App 9 (CustomerID 10, Mortgage $450K funded 2025-05-15, ~5.75%, 360mo, ~$2,626/mo) - 13 payments
(42,  9, 16, 2626.00, 470.00, 2156.00, '2025-06-15', '2025-06-15', N'Completed', N'ACH',    N'LP-2025-090001', '2025-06-15'),
(43,  9, 16, 2626.00, 472.25, 2153.75, '2025-07-15', '2025-07-15', N'Completed', N'ACH',    N'LP-2025-090002', '2025-07-15'),
(44,  9, 16, 2626.00, 474.52, 2151.48, '2025-08-15', '2025-08-15', N'Completed', N'ACH',    N'LP-2025-090003', '2025-08-15'),
(45,  9, 16, 2626.00, 476.79, 2149.21, '2025-09-15', '2025-09-15', N'Completed', N'ACH',    N'LP-2025-090004', '2025-09-15'),
(46,  9, 16, 2626.00, 479.08, 2146.92, '2025-10-15', '2025-10-15', N'Completed', N'ACH',    N'LP-2025-090005', '2025-10-15'),
(47,  9, 16, 2626.00, 481.37, 2144.63, '2025-11-15', '2025-11-15', N'Completed', N'ACH',    N'LP-2025-090006', '2025-11-15'),
(48,  9, 16, 2626.00, 483.68, 2142.32, '2025-12-15', '2025-12-15', N'Completed', N'ACH',    N'LP-2025-090007', '2025-12-15'),
(49,  9, 16, 2626.00, 486.00, 2140.00, '2026-01-15', '2026-01-15', N'Completed', N'ACH',    N'LP-2026-090008', '2026-01-15'),
(50,  9, 16, 2626.00, 488.33, 2137.67, '2026-02-15', '2026-02-15', N'Completed', N'ACH',    N'LP-2026-090009', '2026-02-15'),
(51,  9, 16, 2626.00, 490.67, 2135.33, '2026-03-15', '2026-03-15', N'Completed', N'ACH',    N'LP-2026-090010', '2026-03-15'),
(52,  9, 16, 2626.00, 493.02, 2132.98, '2026-04-15', '2026-04-15', N'Completed', N'ACH',    N'LP-2026-090011', '2026-04-15'),
(53,  9, 16, 2626.00, 495.39, 2130.61, '2026-05-15', '2026-05-15', N'Completed', N'ACH',    N'LP-2026-090012', '2026-05-15'),
(54,  9, 16, 2626.00, 497.76, 2128.24, '2026-06-15', '2026-06-15', N'Pending',   N'ACH',    N'LP-2026-090013', '2026-05-15'),

-- App 11 (CustomerID 12, Personal $8K funded 2025-08-10, ~10.99%, 24mo, ~$372/mo) - 10 payments
(55,  11, 17, 372.28, 299.00, 73.28, '2025-09-10', '2025-09-10', N'Completed', N'Online', N'LP-2025-110001', '2025-09-10'),
(56,  11, 17, 372.28, 301.74, 70.54, '2025-10-10', '2025-10-10', N'Completed', N'Online', N'LP-2025-110002', '2025-10-10'),
(57,  11, 17, 372.28, 304.50, 67.78, '2025-11-10', '2025-11-10', N'Completed', N'Online', N'LP-2025-110003', '2025-11-10'),
(58,  11, 17, 372.28, 307.29, 64.99, '2025-12-10', '2025-12-10', N'Completed', N'Online', N'LP-2025-110004', '2025-12-10'),
(59,  11, 17, 372.28, 310.10, 62.18, '2026-01-10', '2026-01-10', N'Completed', N'Online', N'LP-2026-110005', '2026-01-10'),
(60,  11, 17, 372.28, 312.94, 59.34, '2026-02-10', '2026-02-10', N'Completed', N'Online', N'LP-2026-110006', '2026-02-10'),
(61,  11, 17, 372.28, 315.81, 56.47, '2026-03-10', '2026-03-10', N'Completed', N'Online', N'LP-2026-110007', '2026-03-10'),
(62,  11, 17, 372.28, 318.70, 53.58, '2026-04-10', '2026-04-10', N'Completed', N'Online', N'LP-2026-110008', '2026-04-10'),
(63,  11, 17, 372.28, 321.62, 50.66, '2026-05-10', '2026-05-10', N'Completed', N'Online', N'LP-2026-110009', '2026-05-10'),
(64,  11, 17, 372.28, 324.56, 47.72, '2026-06-10', '2026-06-10', N'Pending',   N'Online', N'LP-2026-110010', '2026-05-15'),

-- App 13 (CustomerID 14, Auto $42K funded 2025-10-01, ~4.49%, 72mo, ~$665/mo) - 8 payments
(65,  13, 18, 665.12, 507.87, 157.25, '2025-11-01', '2025-11-01', N'Completed', N'ACH',    N'LP-2025-130001', '2025-11-01'),
(66,  13, 18, 665.12, 509.77, 155.35, '2025-12-01', '2025-12-01', N'Completed', N'ACH',    N'LP-2025-130002', '2025-12-01'),
(67,  13, 18, 665.12, 511.68, 153.44, '2026-01-01', '2026-01-01', N'Completed', N'ACH',    N'LP-2026-130003', '2026-01-01'),
(68,  13, 18, 665.12, 513.60, 151.52, '2026-02-01', '2026-02-01', N'Completed', N'ACH',    N'LP-2026-130004', '2026-02-01'),
(69,  13, 18, 665.12, 515.52, 149.60, '2026-03-01', '2026-03-01', N'Completed', N'ACH',    N'LP-2026-130005', '2026-03-01'),
(70,  13, 18, 665.12, 517.45, 147.67, '2026-04-01', '2026-04-01', N'Completed', N'ACH',    N'LP-2026-130006', '2026-04-01'),
(71,  13, 18, 665.12, 519.39, 145.73, '2026-05-01', '2026-05-01', N'Completed', N'ACH',    N'LP-2026-130007', '2026-05-01'),
(72,  13, 18, 665.12, 521.34, 143.78, '2026-06-01', '2026-06-01', N'Pending',   N'ACH',    N'LP-2026-130008', '2026-05-15'),

-- App 16 (CustomerID 17, Mortgage $500K funded 2025-06-01, ~5.50%, 360mo, ~$2,839/mo) - 12 payments
(73,  16, 19, 2839.00, 548.00, 2291.00, '2025-07-01', '2025-07-01', N'Completed', N'ACH', N'LP-2025-160001', '2025-07-01'),
(74,  16, 19, 2839.00, 550.51, 2288.49, '2025-08-01', '2025-08-01', N'Completed', N'ACH', N'LP-2025-160002', '2025-08-01'),
(75,  16, 19, 2839.00, 553.03, 2285.97, '2025-09-01', '2025-09-01', N'Completed', N'ACH', N'LP-2025-160003', '2025-09-01'),
(76,  16, 19, 2839.00, 555.56, 2283.44, '2025-10-01', '2025-10-01', N'Completed', N'ACH', N'LP-2025-160004', '2025-10-01'),
(77,  16, 19, 2839.00, 558.11, 2280.89, '2025-11-01', '2025-11-01', N'Completed', N'ACH', N'LP-2025-160005', '2025-11-01'),
(78,  16, 19, 2839.00, 560.67, 2278.33, '2025-12-01', '2025-12-01', N'Completed', N'ACH', N'LP-2025-160006', '2025-12-01'),
(79,  16, 19, 2839.00, 563.24, 2275.76, '2026-01-01', '2026-01-01', N'Completed', N'ACH', N'LP-2026-160007', '2026-01-01'),
(80,  16, 19, 2839.00, 565.82, 2273.18, '2026-02-01', '2026-02-01', N'Completed', N'ACH', N'LP-2026-160008', '2026-02-01'),
(81,  16, 19, 2839.00, 568.41, 2270.59, '2026-03-01', '2026-03-01', N'Completed', N'ACH', N'LP-2026-160009', '2026-03-01'),
(82,  16, 19, 2839.00, 571.02, 2267.98, '2026-04-01', '2026-04-01', N'Completed', N'ACH', N'LP-2026-160010', '2026-04-01'),
(83,  16, 19, 2839.00, 573.64, 2265.36, '2026-05-01', '2026-05-01', N'Completed', N'ACH', N'LP-2026-160011', '2026-05-01'),
(84,  16, 19, 2839.00, 576.27, 2262.73, '2026-06-01', '2026-06-01', N'Pending',   N'ACH', N'LP-2026-160012', '2026-05-15'),

-- App 19 (CustomerID 20, Auto $22K funded 2025-11-01, ~5.99%, 48mo, ~$517/mo) - 7 payments
(85,  19, 20, 517.34, 407.50, 109.84, '2025-12-01', '2025-12-01', N'Completed', N'ACH',    N'LP-2025-190001', '2025-12-01'),
(86,  19, 20, 517.34, 409.54, 107.80, '2026-01-01', '2026-01-01', N'Completed', N'ACH',    N'LP-2026-190002', '2026-01-01'),
(87,  19, 20, 517.34, 411.58, 105.76, '2026-02-01', '2026-02-01', N'Completed', N'ACH',    N'LP-2026-190003', '2026-02-01'),
(88,  19, 20, 517.34, 413.64, 103.70, '2026-03-01', '2026-03-01', N'Completed', N'ACH',    N'LP-2026-190004', '2026-03-01'),
(89,  19, 20, 517.34, 415.71, 101.63, '2026-04-01', '2026-04-01', N'Completed', N'ACH',    N'LP-2026-190005', '2026-04-01'),
(90,  19, 20, 517.34, 417.79,  99.55, '2026-05-01', '2026-05-01', N'Completed', N'ACH',    N'LP-2026-190006', '2026-05-01'),
(91,  19, 20, 517.34, 419.88,  97.46, '2026-06-01', '2026-06-01', N'Pending',   N'ACH',    N'LP-2026-190007', '2026-05-15'),

-- App 21 (CustomerID 22, Mortgage $380K funded 2025-08-01, ~5.25%, 360mo, ~$2,099/mo) - 10 payments
(92,  21, 21, 2099.00, 436.50, 1662.50, '2025-09-01', '2025-09-01', N'Completed', N'ACH', N'LP-2025-210001', '2025-09-01'),
(93,  21, 21, 2099.00, 438.41, 1660.59, '2025-10-01', '2025-10-01', N'Completed', N'ACH', N'LP-2025-210002', '2025-10-01'),
(94,  21, 21, 2099.00, 440.33, 1658.67, '2025-11-01', '2025-11-01', N'Completed', N'ACH', N'LP-2025-210003', '2025-11-01'),
(95,  21, 21, 2099.00, 442.26, 1656.74, '2025-12-01', '2025-12-01', N'Completed', N'ACH', N'LP-2025-210004', '2025-12-01'),
(96,  21, 21, 2099.00, 444.19, 1654.81, '2026-01-01', '2026-01-01', N'Completed', N'ACH', N'LP-2026-210005', '2026-01-01'),
(97,  21, 21, 2099.00, 446.14, 1652.86, '2026-02-01', '2026-02-01', N'Completed', N'ACH', N'LP-2026-210006', '2026-02-01'),
(98,  21, 21, 2099.00, 448.09, 1650.91, '2026-03-01', '2026-03-01', N'Completed', N'ACH', N'LP-2026-210007', '2026-03-01'),
(99,  21, 21, 2099.00, 450.06, 1648.94, '2026-04-01', '2026-04-01', N'Completed', N'ACH', N'LP-2026-210008', '2026-04-01'),
(100, 21, 21, 2099.00, 452.03, 1646.97, '2026-05-01', '2026-05-01', N'Completed', N'ACH', N'LP-2026-210009', '2026-05-01'),
(101, 21, 21, 2099.00, 454.01, 1644.99, '2026-06-01', '2026-06-01', N'Pending',   N'ACH', N'LP-2026-210010', '2026-05-15'),

-- App 26 (CustomerID 27, Mortgage $420K funded 2025-12-01, ~5.75%, 360mo, ~$2,451/mo) - 6 payments
(102, 26, 22, 2451.00, 437.50, 2013.50, '2026-01-01', '2026-01-01', N'Completed', N'ACH', N'LP-2026-260001', '2026-01-01'),
(103, 26, 22, 2451.00, 439.60, 2011.40, '2026-02-01', '2026-02-01', N'Completed', N'ACH', N'LP-2026-260002', '2026-02-01'),
(104, 26, 22, 2451.00, 441.70, 2009.30, '2026-03-01', '2026-03-01', N'Completed', N'ACH', N'LP-2026-260003', '2026-03-01'),
(105, 26, 22, 2451.00, 443.82, 2007.18, '2026-04-01', '2026-04-01', N'Completed', N'ACH', N'LP-2026-260004', '2026-04-01'),
(106, 26, 22, 2451.00, 445.95, 2005.05, '2026-05-01', '2026-05-01', N'Completed', N'ACH', N'LP-2026-260005', '2026-05-01'),
(107, 26, 22, 2451.00, 448.09, 2002.91, '2026-06-01', '2026-06-01', N'Pending',   N'ACH', N'LP-2026-260006', '2026-05-15'),

-- App 29 (CustomerID 30, Business $280K funded 2025-03-01, ~7.25%, 60mo, closed, ~$5,579/mo) - 15 payments (all completed, loan closed)
(108, 29, 23, 5579.00, 4888.00,  691.00, '2025-04-01', '2025-04-01', N'Completed', N'Check',  N'LP-2025-290001', '2025-04-01'),
(109, 29, 23, 5579.00, 4917.52,  661.48, '2025-05-01', '2025-05-01', N'Completed', N'Check',  N'LP-2025-290002', '2025-05-01'),
(110, 29, 23, 5579.00, 4947.22,  631.78, '2025-06-01', '2025-06-01', N'Completed', N'Check',  N'LP-2025-290003', '2025-06-01'),
(111, 29, 23, 5579.00, 4977.09,  601.91, '2025-07-01', '2025-07-01', N'Completed', N'Check',  N'LP-2025-290004', '2025-07-01'),
(112, 29, 23, 5579.00, 5007.14,  571.86, '2025-08-01', '2025-08-01', N'Completed', N'Check',  N'LP-2025-290005', '2025-08-01'),
(113, 29, 23, 5579.00, 5037.38,  541.62, '2025-09-01', '2025-09-01', N'Completed', N'Check',  N'LP-2025-290006', '2025-09-01'),
(114, 29, 23, 5579.00, 5067.80,  511.20, '2025-10-01', '2025-10-01', N'Completed', N'Check',  N'LP-2025-290007', '2025-10-01'),
(115, 29, 23, 5579.00, 5098.40,  480.60, '2025-11-01', '2025-11-01', N'Completed', N'Check',  N'LP-2025-290008', '2025-11-01'),
(116, 29, 23, 5579.00, 5129.19,  449.81, '2025-12-01', '2025-12-01', N'Completed', N'Check',  N'LP-2025-290009', '2025-12-01'),
(117, 29, 23, 5579.00, 5160.17,  418.83, '2026-01-01', '2026-01-01', N'Completed', N'Check',  N'LP-2026-290010', '2026-01-01'),
(118, 29, 23, 5579.00, 5191.34,  387.66, '2026-02-01', '2026-02-01', N'Completed', N'Check',  N'LP-2026-290011', '2026-02-01'),
(119, 29, 23, 5579.00, 5222.70,  356.30, '2026-03-01', '2026-03-01', N'Completed', N'Check',  N'LP-2026-290012', '2026-03-01'),
(120, 29, 23, 5579.00, 5254.26,  324.74, '2026-04-01', '2026-04-01', N'Completed', N'Check',  N'LP-2026-290013', '2026-04-01'),
(121, 29, 23, 5579.00, 5286.01,  292.99, '2026-05-01', '2026-05-01', N'Completed', N'Check',  N'LP-2026-290014', '2026-05-01'),
(122, 29, 23, 5579.00, 5317.96,  261.04, '2026-06-01', '2026-06-01', N'Completed', N'Check',  N'LP-2026-290015', '2026-06-01'),

-- David Park scenario: a few missed payments from a previous small loan attempt (use App 2 conceptually but different account)
-- These represent historical missed payments on a prior relationship
(123, 2, 24, 0.00, 0.00, 0.00, NULL,         '2025-10-15', N'Missed', N'ACH', NULL, '2025-10-15'),
(124, 2, 24, 0.00, 0.00, 0.00, NULL,         '2025-11-15', N'Missed', N'ACH', NULL, '2025-11-15'),
(125, 2, 24, 0.00, 0.00, 0.00, NULL,         '2025-12-15', N'Missed', N'ACH', NULL, '2025-12-15'),

-- Additional late payments across various accounts for realism
-- App 6 late payment
(126, 6, 14, 2093.00, 345.60, 1747.40, '2025-08-05', '2025-08-01', N'Late', N'ACH', N'LP-2025-060L01', '2025-08-05'),

-- App 9 late payment
(127, 9, 16, 2626.00, 488.33, 2137.67, '2025-09-20', '2025-09-15', N'Late', N'Check', N'LP-2025-090L01', '2025-09-20'),

-- Additional filler payments to reach ~150 total
-- More payments for App 6 mortgage (duplicate months removed, these are additional months)
(128, 6,  14, 2093.00, 321.33, 1771.67, '2025-04-15', '2025-04-15', N'Completed', N'ACH', N'LP-2025-060000', '2025-04-15'),

-- More auto loan payments for App 13
(129, 13, 18, 665.12, 506.00, 159.12, '2025-10-01', '2025-10-01', N'Completed', N'ACH', N'LP-2025-130000', '2025-10-01'),

-- More payments for App 21 mortgage
(130, 21, 21, 2099.00, 434.60, 1664.40, '2025-08-01', '2025-08-01', N'Completed', N'ACH', N'LP-2025-210000', '2025-08-01'),

-- Additional payments for App 16 mortgage
(131, 16, 19, 2839.00, 546.00, 2293.00, '2025-06-01', '2025-06-01', N'Completed', N'ACH', N'LP-2025-160000', '2025-06-01'),

-- Payments for App 29 business loan (earlier months)
(132, 29, 23, 5579.00, 4858.66, 720.34, '2025-03-01', '2025-03-01', N'Completed', N'Check', N'LP-2025-290000', '2025-03-01'),

-- App 11 personal loan additional
(133, 11, 17, 372.28, 296.28, 76.00, '2025-08-10', '2025-08-10', N'Completed', N'Online', N'LP-2025-110000', '2025-08-10'),

-- App 7 auto loan additional
(134, 7,  15, 528.42, 410.21, 118.21, '2025-07-01', '2025-07-01', N'Completed', N'ACH', N'LP-2025-070000', '2025-07-01'),

-- App 19 auto loan additional
(135, 19, 20, 517.34, 405.47, 111.87, '2025-11-01', '2025-11-01', N'Completed', N'ACH', N'LP-2025-190000', '2025-11-01'),

-- App 26 mortgage first payment
(136, 26, 22, 2451.00, 435.41, 2015.59, '2025-12-15', '2025-12-15', N'Completed', N'ACH', N'LP-2025-260000', '2025-12-15'),

-- Additional realistic scattered payments for more coverage
(137, 6,  14, 2093.00, 347.41, 1745.59, '2025-04-01', '2025-04-01', N'Completed', N'ACH', N'LP-2025-06E001', '2025-04-01'),
(138, 9,  16, 2626.00, 468.00, 2158.00, '2025-05-15', '2025-05-15', N'Completed', N'ACH', N'LP-2025-09E001', '2025-05-15'),
(139, 16, 19, 2839.00, 544.00, 2295.00, '2025-06-15', '2025-06-15', N'Completed', N'ACH', N'LP-2025-16E001', '2025-06-15'),
(140, 21, 21, 2099.00, 432.72, 1666.28, '2025-08-15', '2025-08-15', N'Completed', N'ACH', N'LP-2025-21E001', '2025-08-15'),
(141, 26, 22, 2451.00, 433.33, 2017.67, '2025-12-01', '2025-12-01', N'Completed', N'ACH', N'LP-2025-26E001', '2025-12-01'),
(142, 29, 23, 5579.00, 5349.11, 229.89, '2026-06-15', '2026-06-15', N'Completed', N'Check', N'LP-2026-29E001', '2026-06-15'),
(143, 7,  15, 528.42, 408.50, 119.92, '2025-07-15', '2025-07-15', N'Completed', N'ACH', N'LP-2025-07E001', '2025-07-15'),
(144, 13, 18, 665.12, 504.14, 160.98, '2025-10-15', '2025-10-15', N'Completed', N'ACH', N'LP-2025-13E001', '2025-10-15'),
(145, 19, 20, 517.34, 403.46, 113.88, '2025-11-15', '2025-11-15', N'Completed', N'ACH', N'LP-2025-19E001', '2025-11-15'),
(146, 11, 17, 372.28, 293.59, 78.69, '2025-08-15', '2025-08-15', N'Completed', N'Online', N'LP-2025-11E001', '2025-08-15'),
(147, 6,  14, 2093.00, 349.23, 1743.77, '2025-04-20', '2025-04-20', N'Completed', N'ACH', N'LP-2025-06E002', '2025-04-20'),
(148, 9,  16, 2626.00, 500.15, 2125.85, '2026-06-01', '2026-06-01', N'Completed', N'ACH', N'LP-2026-09E002', '2026-06-01'),
(149, 16, 19, 2839.00, 578.92, 2260.08, '2026-06-01', '2026-06-01', N'Pending',   N'ACH', N'LP-2026-16E002', '2026-05-15'),
(150, 21, 21, 2099.00, 456.00, 1643.00, '2026-06-15', '2026-06-15', N'Pending',   N'ACH', N'LP-2026-21E002', '2026-05-15');

SET IDENTITY_INSERT [dbo].[LoanPayments] OFF;
GO

-- ============================================================
-- Seed RiskAssessments (30 rows)
-- ============================================================
SET IDENTITY_INSERT [dbo].[RiskAssessments] ON;

INSERT INTO [dbo].[RiskAssessments]
    (AssessmentID, ApplicationID, CustomerID, OverallRiskScore, RiskLevel, DebtToIncomeRatio, LoanToValueRatio, FactorBreakdown, Recommendation, AssessedBy, AssessedDate, CreatedDate)
VALUES
-- Special demo assessments
(1,  1,  1,  25.50, N'Low',    0.31, NULL, N'DTI=25|CREDIT_SCORE=15|EMP_HISTORY=10|PAY_HISTORY=10|ACCT_AGE=8',          N'Approve',       N'SYSTEM',           '2026-05-01', '2026-05-01'),
(2,  2,  5,  78.00, N'High',   0.52, NULL, N'DTI=85|CREDIT_SCORE=70|PAY_HISTORY=75|EXIST_DEBT=80|EMP_HISTORY=60',       N'Deny',          N'SYSTEM',           '2026-03-16', '2026-03-16'),
(3,  3,  6,  22.00, N'Low',    0.28, 0.80, N'DTI=20|CREDIT_SCORE=18|EMP_HISTORY=15|PAY_HISTORY=12|ACCT_AGE=10',         N'Approve',       N'SYSTEM',           '2025-01-05', '2025-01-05'),
(4,  4,  2,  38.50, N'Medium', 0.35, 0.85, N'DTI=35|CREDIT_SCORE=30|EMP_HISTORY=25|PAY_HISTORY=40|EXIST_DEBT=45',       N'Approve',       N'SYSTEM',           '2026-04-22', '2026-04-22'),
(5,  5,  3,  55.00, N'Medium', 0.40, NULL, N'DTI=50|CREDIT_SCORE=45|EMP_HISTORY=55|PAY_HISTORY=50|RES_STAB=70',         N'ManualReview',  N'SYSTEM',           '2026-05-06', '2026-05-06'),

-- Regular assessments (6-30)
(6,  6,  7,  18.00, N'Low',    0.25, 0.75, N'DTI=18|CREDIT_SCORE=12|EMP_HISTORY=10|PAY_HISTORY=8|ACCT_AGE=5',           N'Approve',       N'SYSTEM',           '2025-03-12', '2025-03-12'),
(7,  7,  8,  30.00, N'Low',    0.30, 0.90, N'DTI=30|CREDIT_SCORE=25|EMP_HISTORY=20|PAY_HISTORY=22|ACCT_AGE=12',         N'Approve',       N'SYSTEM',           '2025-06-18', '2025-06-18'),
(8,  8,  9,  68.00, N'High',   0.48, NULL, N'DTI=72|CREDIT_SCORE=55|PAY_HISTORY=60|EXIST_DEBT=70|EMP_HISTORY=50',       N'Deny',          N'SYSTEM',           '2026-01-06', '2026-01-06'),
(9,  9,  10, 15.00, N'Low',    0.20, 0.65, N'DTI=12|CREDIT_SCORE=10|EMP_HISTORY=8|PAY_HISTORY=10|ASSET_RES=5',          N'Approve',       N'SYSTEM',           '2025-04-22', '2025-04-22'),
(10, 10, 11, 42.00, N'Medium', 0.38, 0.70, N'DTI=40|CREDIT_SCORE=38|EMP_HISTORY=30|PAY_HISTORY=35|EXIST_DEBT=45',       N'Approve',       N'SYSTEM',           '2026-02-12', '2026-02-12'),
(11, 11, 12, 28.00, N'Low',    0.22, NULL, N'DTI=25|CREDIT_SCORE=20|EMP_HISTORY=18|PAY_HISTORY=15|ACCT_AGE=10',         N'Approve',       N'SYSTEM',           '2025-08-02', '2025-08-02'),
(12, 12, 13, 72.00, N'High',   0.45, NULL, N'DTI=65|CREDIT_SCORE=68|PAY_HISTORY=70|EXIST_DEBT=72|EMP_HISTORY=55',       N'Deny',          N'SYSTEM',           '2026-01-22', '2026-01-22'),
(13, 13, 14, 20.00, N'Low',    0.24, 0.82, N'DTI=18|CREDIT_SCORE=14|EMP_HISTORY=12|PAY_HISTORY=10|ACCT_AGE=8',          N'Approve',       N'SYSTEM',           '2025-09-12', '2025-09-12'),
(14, 14, 15, 45.00, N'Medium', 0.36, NULL, N'DTI=42|CREDIT_SCORE=35|EMP_HISTORY=40|PAY_HISTORY=38|EXIST_DEBT=50',       N'Approve',       N'SYSTEM',           '2026-03-05', '2026-03-05'),
(15, 15, 16, 70.00, N'High',   0.55, NULL, N'DTI=78|CREDIT_SCORE=60|PAY_HISTORY=65|EXIST_DEBT=75|EMP_HISTORY=48',       N'Deny',          N'SYSTEM',           '2026-02-06', '2026-02-06'),
(16, 16, 17, 12.00, N'Low',    0.18, 0.60, N'DTI=10|CREDIT_SCORE=8|EMP_HISTORY=6|PAY_HISTORY=5|ASSET_RES=3',            N'Approve',       N'SYSTEM',           '2025-05-05', '2025-05-05'),
(17, 17, 18, 82.00, N'High',   0.60, NULL, N'DTI=90|CREDIT_SCORE=78|PAY_HISTORY=80|EXIST_DEBT=85|EMP_HISTORY=65',       N'Deny',          N'SYSTEM',           '2026-03-22', '2026-03-22'),
(18, 18, 19, 24.00, N'Low',    0.26, 0.65, N'DTI=22|CREDIT_SCORE=16|EMP_HISTORY=14|PAY_HISTORY=12|ACCT_AGE=8',          N'Approve',       N'SYSTEM',           '2026-04-03', '2026-04-03'),
(19, 19, 20, 32.00, N'Low',    0.29, 0.88, N'DTI=30|CREDIT_SCORE=22|EMP_HISTORY=20|PAY_HISTORY=25|ACCT_AGE=15',         N'Approve',       N'SYSTEM',           '2025-10-18', '2025-10-18'),
(20, 20, 21, 62.00, N'High',   0.44, NULL, N'DTI=60|CREDIT_SCORE=52|PAY_HISTORY=58|EXIST_DEBT=65|EMP_HISTORY=42',       N'Deny',          N'SYSTEM',           '2026-01-12', '2026-01-12'),
(21, 21, 22, 10.00, N'Low',    0.15, 0.70, N'DTI=8|CREDIT_SCORE=6|EMP_HISTORY=5|PAY_HISTORY=4|ASSET_RES=2',             N'Approve',       N'SYSTEM',           '2025-07-08', '2025-07-08'),
(22, 22, 23, 35.00, N'Medium', 0.33, NULL, N'DTI=32|CREDIT_SCORE=28|EMP_HISTORY=22|PAY_HISTORY=30|ACCT_AGE=18',         N'ManualReview',  N'SYSTEM',           '2026-05-03', '2026-05-03'),
(23, 23, 24, 48.00, N'Medium', 0.39, NULL, N'DTI=45|CREDIT_SCORE=40|EMP_HISTORY=35|PAY_HISTORY=42|EXIST_DEBT=52',       N'ManualReview',  N'SYSTEM',           '2026-05-09', '2026-05-09'),
(24, 24, 25, 26.00, N'Low',    0.27, 0.85, N'DTI=24|CREDIT_SCORE=18|EMP_HISTORY=16|PAY_HISTORY=14|ACCT_AGE=10',         N'Approve',       N'SYSTEM',           '2026-04-18', '2026-04-18'),
(25, 25, 26, 74.00, N'High',   0.50, NULL, N'DTI=80|CREDIT_SCORE=65|PAY_HISTORY=68|EXIST_DEBT=78|EMP_HISTORY=52',       N'Deny',          N'SYSTEM',           '2026-02-22', '2026-02-22'),
(26, 26, 27, 16.00, N'Low',    0.21, 0.72, N'DTI=14|CREDIT_SCORE=10|EMP_HISTORY=8|PAY_HISTORY=6|ASSET_RES=4',           N'Approve',       N'SYSTEM',           '2025-11-03', '2025-11-03'),
(27, 27, 28, 29.00, N'Low',    0.25, NULL, N'DTI=26|CREDIT_SCORE=20|EMP_HISTORY=18|PAY_HISTORY=16|ACCT_AGE=12',         N'Approve',       N'SYSTEM',           '2026-03-12', '2026-03-12'),
(28, 28, 29, 40.00, N'Medium', 0.34, NULL, N'DTI=38|CREDIT_SCORE=32|EMP_HISTORY=28|PAY_HISTORY=35|EXIST_DEBT=42',       N'ManualReview',  N'SYSTEM',           '2026-05-11', '2026-05-11'),
(29, 29, 30, 14.00, N'Low',    0.19, NULL, N'DTI=12|CREDIT_SCORE=8|EMP_HISTORY=10|PAY_HISTORY=6|ASSET_RES=4',           N'Approve',       N'SYSTEM',           '2025-02-05', '2025-02-05'),
(30, 30, 31, 34.00, N'Medium', 0.32, NULL, N'DTI=30|CREDIT_SCORE=26|EMP_HISTORY=24|PAY_HISTORY=28|ACCT_AGE=16',         N'ManualReview',  N'SYSTEM',           '2026-05-13', '2026-05-13');

SET IDENTITY_INSERT [dbo].[RiskAssessments] OFF;
GO

PRINT 'Loans, credit scores, risk factors, and risk assessments seeded successfully.';
GO
