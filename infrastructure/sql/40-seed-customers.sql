USE [ZavaBankDB];
GO

-- ============================================================
-- 40-seed-customers.sql
-- Seeds: AccountTypes, TransactionTypes, LoanProducts,
--        PaymentMethods, Customers (50), Accounts (~120)
-- ============================================================

-- ----------------------------------------------------------
-- AccountTypes (5 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [AccountTypes] ON;
GO

INSERT INTO AccountTypes (AccountTypeID, TypeName, Description, InterestRate, MinimumBalance, IsActive, CreatedDate, ModifiedDate)
VALUES (1, N'Checking',    N'Standard checking account',  0.0010, 0.00,    1, '2026-05-14', '2026-05-14');
INSERT INTO AccountTypes (AccountTypeID, TypeName, Description, InterestRate, MinimumBalance, IsActive, CreatedDate, ModifiedDate)
VALUES (2, N'Savings',     N'Standard savings account',   0.0150, 25.00,   1, '2026-05-14', '2026-05-14');
INSERT INTO AccountTypes (AccountTypeID, TypeName, Description, InterestRate, MinimumBalance, IsActive, CreatedDate, ModifiedDate)
VALUES (3, N'Loan',        N'Loan account',               0.0000, 0.00,    1, '2026-05-14', '2026-05-14');
INSERT INTO AccountTypes (AccountTypeID, TypeName, Description, InterestRate, MinimumBalance, IsActive, CreatedDate, ModifiedDate)
VALUES (4, N'CD',          N'Certificate of Deposit',     0.0425, 1000.00, 1, '2026-05-14', '2026-05-14');
INSERT INTO AccountTypes (AccountTypeID, TypeName, Description, InterestRate, MinimumBalance, IsActive, CreatedDate, ModifiedDate)
VALUES (5, N'MoneyMarket', N'Money Market account',       0.0300, 2500.00, 1, '2026-05-14', '2026-05-14');

SET IDENTITY_INSERT [AccountTypes] OFF;
GO

-- ----------------------------------------------------------
-- TransactionTypes (7 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [TransactionTypes] ON;
GO

INSERT INTO TransactionTypes (TransactionTypeID, TypeCode, TypeName, Description, IsDebit, IsActive)
VALUES (1, N'DEP', N'Deposit',    N'Credit deposit',      0, 1);
INSERT INTO TransactionTypes (TransactionTypeID, TypeCode, TypeName, Description, IsDebit, IsActive)
VALUES (2, N'WDR', N'Withdrawal', N'Cash withdrawal',     1, 1);
INSERT INTO TransactionTypes (TransactionTypeID, TypeCode, TypeName, Description, IsDebit, IsActive)
VALUES (3, N'TRF', N'Transfer',   N'Account transfer',    1, 1);
INSERT INTO TransactionTypes (TransactionTypeID, TypeCode, TypeName, Description, IsDebit, IsActive)
VALUES (4, N'FEE', N'Fee',        N'Service fee',         1, 1);
INSERT INTO TransactionTypes (TransactionTypeID, TypeCode, TypeName, Description, IsDebit, IsActive)
VALUES (5, N'INT', N'Interest',   N'Interest credit',     0, 1);
INSERT INTO TransactionTypes (TransactionTypeID, TypeCode, TypeName, Description, IsDebit, IsActive)
VALUES (6, N'PMT', N'Payment',    N'Bill payment',        1, 1);
INSERT INTO TransactionTypes (TransactionTypeID, TypeCode, TypeName, Description, IsDebit, IsActive)
VALUES (7, N'ADJ', N'Adjustment', N'Balance adjustment',  0, 1);

SET IDENTITY_INSERT [TransactionTypes] OFF;
GO

-- ----------------------------------------------------------
-- LoanProducts (6 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [LoanProducts] ON;
GO

INSERT INTO LoanProducts (LoanProductID, ProductName, ProductCode, MinAmount, MaxAmount, MinTermMonths, MaxTermMonths, BaseInterestRate, RequiresCollateral, IsActive, CreatedDate)
VALUES (1, N'Personal Loan', N'PERS', 1000.00,   50000.00,   12,  60,  0.0899, 0, 1, '2026-05-14');
INSERT INTO LoanProducts (LoanProductID, ProductName, ProductCode, MinAmount, MaxAmount, MinTermMonths, MaxTermMonths, BaseInterestRate, RequiresCollateral, IsActive, CreatedDate)
VALUES (2, N'Mortgage',      N'MORT', 50000.00,  1000000.00, 120, 360, 0.0649, 1, 1, '2026-05-14');
INSERT INTO LoanProducts (LoanProductID, ProductName, ProductCode, MinAmount, MaxAmount, MinTermMonths, MaxTermMonths, BaseInterestRate, RequiresCollateral, IsActive, CreatedDate)
VALUES (3, N'Auto Loan',     N'AUTO', 5000.00,   100000.00,  24,  84,  0.0549, 1, 1, '2026-05-14');
INSERT INTO LoanProducts (LoanProductID, ProductName, ProductCode, MinAmount, MaxAmount, MinTermMonths, MaxTermMonths, BaseInterestRate, RequiresCollateral, IsActive, CreatedDate)
VALUES (4, N'Business Loan', N'BUSI', 10000.00,  500000.00,  12,  120, 0.0799, 0, 1, '2026-05-14');
INSERT INTO LoanProducts (LoanProductID, ProductName, ProductCode, MinAmount, MaxAmount, MinTermMonths, MaxTermMonths, BaseInterestRate, RequiresCollateral, IsActive, CreatedDate)
VALUES (5, N'Home Equity',   N'HEQY', 10000.00,  500000.00,  60,  240, 0.0599, 1, 1, '2026-05-14');
INSERT INTO LoanProducts (LoanProductID, ProductName, ProductCode, MinAmount, MaxAmount, MinTermMonths, MaxTermMonths, BaseInterestRate, RequiresCollateral, IsActive, CreatedDate)
VALUES (6, N'Student Loan',  N'STUD', 1000.00,   100000.00,  60,  240, 0.0499, 0, 1, '2026-05-14');

SET IDENTITY_INSERT [LoanProducts] OFF;
GO

-- ----------------------------------------------------------
-- PaymentMethods (5 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [PaymentMethods] ON;
GO

INSERT INTO PaymentMethods (PaymentMethodID, MethodName, MethodCode, ProcessingFee, MaxDailyLimit, IsActive, CreatedDate)
VALUES (1, N'ACH',              N'ACH',  0.50,  25000.00,  1, '2026-05-14');
INSERT INTO PaymentMethods (PaymentMethodID, MethodName, MethodCode, ProcessingFee, MaxDailyLimit, IsActive, CreatedDate)
VALUES (2, N'Wire',             N'WIRE', 25.00, 500000.00, 1, '2026-05-14');
INSERT INTO PaymentMethods (PaymentMethodID, MethodName, MethodCode, ProcessingFee, MaxDailyLimit, IsActive, CreatedDate)
VALUES (3, N'Check',            N'CHK',  0.00,  50000.00,  1, '2026-05-14');
INSERT INTO PaymentMethods (PaymentMethodID, MethodName, MethodCode, ProcessingFee, MaxDailyLimit, IsActive, CreatedDate)
VALUES (4, N'InternalTransfer', N'INTL', 0.00,  100000.00, 1, '2026-05-14');
INSERT INTO PaymentMethods (PaymentMethodID, MethodName, MethodCode, ProcessingFee, MaxDailyLimit, IsActive, CreatedDate)
VALUES (5, N'Debit',            N'DEBT', 1.50,  5000.00,   1, '2026-05-14');

SET IDENTITY_INSERT [PaymentMethods] OFF;
GO

-- ----------------------------------------------------------
-- Customers (50 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [Customers] ON;
GO

-- Special demo customers (IDs 1-6)
INSERT INTO Customers (CustomerID, FirstName, LastName, MiddleName, DateOfBirth, SSN, Email, Phone, AddressLine1, AddressLine2, City, State, ZipCode, Country, CustomerSince, Status, RiskRating, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy)
VALUES (1, N'Maria', N'Rodriguez', NULL, '1985-03-15', N'345-67-8901', N'maria.rodriguez@email.com', N'512-555-0101', N'742 Oak Avenue', NULL, N'Austin', N'TX', N'78701', N'US', '2018-06-15', N'Active', N'Low', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM');

INSERT INTO Customers (CustomerID, FirstName, LastName, MiddleName, DateOfBirth, SSN, Email, Phone, AddressLine1, AddressLine2, City, State, ZipCode, Country, CustomerSince, Status, RiskRating, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy)
VALUES (2, N'James', N'Chen', NULL, '1978-11-22', N'456-78-9012', N'james.chen@email.com', N'415-555-0102', N'1589 Market Street', NULL, N'San Francisco', N'CA', N'94103', N'US', '2015-02-10', N'Active', N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM');

INSERT INTO Customers (CustomerID, FirstName, LastName, MiddleName, DateOfBirth, SSN, Email, Phone, AddressLine1, AddressLine2, City, State, ZipCode, Country, CustomerSince, Status, RiskRating, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy)
VALUES (3, N'Viktor', N'Petrov', NULL, '1970-07-08', N'567-89-0123', N'viktor.petrov@email.com', N'202-555-0103', N'2200 Connecticut Ave NW', NULL, N'Washington', N'DC', N'20008', N'US', '2022-09-01', N'Active', N'High', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM');

INSERT INTO Customers (CustomerID, FirstName, LastName, MiddleName, DateOfBirth, SSN, Email, Phone, AddressLine1, AddressLine2, City, State, ZipCode, Country, CustomerSince, Status, RiskRating, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy)
VALUES (4, N'Sarah', N'Miller', NULL, '1992-01-30', N'678-90-1234', N'sarah.miller@email.com', N'503-555-0104', N'456 Elm Street', N'Apt 3B', N'Portland', N'OR', N'97201', N'US', '2020-11-05', N'Active', N'Low', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM');

INSERT INTO Customers (CustomerID, FirstName, LastName, MiddleName, DateOfBirth, SSN, Email, Phone, AddressLine1, AddressLine2, City, State, ZipCode, Country, CustomerSince, Status, RiskRating, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy)
VALUES (5, N'David', N'Park', NULL, '1988-05-17', N'789-01-2345', N'david.park@email.com', N'310-555-0105', N'8821 Wilshire Blvd', NULL, N'Los Angeles', N'CA', N'90048', N'US', '2019-03-22', N'Active', N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM');

INSERT INTO Customers (CustomerID, FirstName, LastName, MiddleName, DateOfBirth, SSN, Email, Phone, AddressLine1, AddressLine2, City, State, ZipCode, Country, CustomerSince, Status, RiskRating, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy)
VALUES (6, N'Emily', N'Johnson', NULL, '1990-09-12', N'890-12-3456', N'emily.johnson@email.com', N'617-555-0106', N'334 Beacon Street', NULL, N'Boston', N'MA', N'02116', N'US', '2016-08-01', N'Active', N'Low', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM');

-- Regular customers (IDs 7-50)
INSERT INTO Customers (CustomerID, FirstName, LastName, MiddleName, DateOfBirth, SSN, Email, Phone, AddressLine1, AddressLine2, City, State, ZipCode, Country, CustomerSince, Status, RiskRating, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy)
VALUES
 (7,  N'Robert',      N'Williams',   NULL, '1975-06-20', N'123-45-0007', N'robert.williams@email.com',   N'212-555-0107', N'450 Broadway',             NULL,       N'New York',       N'NY', N'10013', N'US', '2010-03-15', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (8,  N'Jennifer',    N'Davis',      NULL, '1982-09-05', N'123-45-0008', N'jennifer.davis@email.com',    N'305-555-0108', N'1200 Brickell Ave',       N'Suite 400', N'Miami',        N'FL', N'33131', N'US', '2012-07-22', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (9,  N'Michael',     N'Brown',      NULL, '1968-02-14', N'123-45-0009', N'michael.brown@email.com',     N'312-555-0109', N'233 S Wacker Dr',         NULL,       N'Chicago',        N'IL', N'60606', N'US', '2008-01-10', N'Active',    N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (10, N'Patricia',    N'Wilson',     NULL, '1990-12-01', N'123-45-0010', N'patricia.wilson@email.com',   N'303-555-0110', N'1601 Blake St',           NULL,       N'Denver',         N'CO', N'80202', N'US', '2017-05-18', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (11, N'Thomas',      N'Anderson',   NULL, '1963-08-28', N'123-45-0011', N'thomas.anderson@email.com',   N'404-555-0111', N'265 Peachtree St NE',     NULL,       N'Atlanta',        N'GA', N'30303', N'US', '2005-11-30', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (12, N'Linda',       N'Taylor',     NULL, '1979-04-10', N'123-45-0012', N'linda.taylor@email.com',      N'206-555-0112', N'801 2nd Ave',              NULL,       N'Seattle',        N'WA', N'98104', N'US', '2014-09-08', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (13, N'Christopher', N'Martinez',   NULL, '1987-11-17', N'123-45-0013', N'christopher.martinez@email.com', N'216-555-0113', N'1100 Superior Ave',    NULL,       N'Cleveland',      N'OH', N'44114', N'US', '2019-02-14', N'Active',    N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (14, N'Barbara',     N'Garcia',     NULL, '1972-07-23', N'123-45-0014', N'barbara.garcia@email.com',    N'704-555-0114', N'401 S Tryon St',          NULL,       N'Charlotte',      N'NC', N'28202', N'US', '2011-06-05', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (15, N'Daniel',      N'Thompson',   NULL, '1995-01-08', N'123-45-0015', N'daniel.thompson@email.com',   N'602-555-0115', N'2 N Central Ave',         NULL,       N'Phoenix',        N'AZ', N'85004', N'US', '2020-08-20', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (16, N'Susan',       N'White',      NULL, '1960-05-30', N'123-45-0016', N'susan.white@email.com',       N'702-555-0116', N'3570 Las Vegas Blvd S',   NULL,       N'Las Vegas',      N'NV', N'89109', N'US', '2007-04-12', N'Active',    N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (17, N'Matthew',     N'Harris',     NULL, '1983-10-19', N'123-45-0017', N'matthew.harris@email.com',    N'612-555-0117', N'250 Marquette Ave S',     NULL,       N'Minneapolis',    N'MN', N'55401', N'US', '2016-01-25', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (18, N'Jessica',     N'Lewis',      NULL, '1991-03-27', N'123-45-0018', N'jessica.lewis@email.com',     N'813-555-0118', N'100 N Tampa St',          NULL,       N'Tampa',          N'FL', N'33602', N'US', '2021-03-10', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (19, N'Andrew',      N'Clark',      NULL, '1976-12-03', N'123-45-0019', N'andrew.clark@email.com',      N'614-555-0119', N'41 S High St',            NULL,       N'Columbus',       N'OH', N'43215', N'US', '2009-10-01', N'Active',    N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (20, N'Karen',       N'Robinson',   NULL, '1986-08-15', N'123-45-0020', N'karen.robinson@email.com',    N'919-555-0120', N'150 Fayetteville St',     NULL,       N'Raleigh',        N'NC', N'27601', N'US', '2018-12-01', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (21, N'Joseph',      N'Walker',     NULL, '1969-09-22', N'123-45-0021', N'joseph.walker@email.com',     N'520-555-0121', N'110 S Church Ave',        NULL,       N'Tucson',         N'AZ', N'85701', N'US', '2006-05-17', N'Active',    N'High',   GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (22, N'Nancy',       N'Allen',      NULL, '1993-06-11', N'123-45-0022', N'nancy.allen@email.com',       N'503-555-0122', N'1001 SW 5th Ave',         NULL,       N'Portland',       N'OR', N'97204', N'US', '2022-01-15', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (23, N'Ryan',        N'Young',      NULL, '1980-04-02', N'123-45-0023', N'ryan.young@email.com',        N'469-555-0123', N'1717 Main St',            NULL,       N'Dallas',         N'TX', N'75201', N'US', '2013-08-30', N'Active',    N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (24, N'Elizabeth',   N'King',       NULL, '1997-02-18', N'123-45-0024', N'elizabeth.king@email.com',    N'615-555-0124', N'150 4th Ave N',           NULL,       N'Nashville',      N'TN', N'37219', N'US', '2023-04-05', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (25, N'Brandon',     N'Scott',      NULL, '1974-11-09', N'123-45-0025', N'brandon.scott@email.com',     N'314-555-0125', N'1 S Memorial Dr',         NULL,       N'Saint Louis',    N'MO', N'63102', N'US', '2010-07-14', N'Suspended', N'High',   GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (26, N'Rebecca',     N'Adams',      NULL, '1988-07-26', N'123-45-0026', N'rebecca.adams@email.com',     N'317-555-0126', N'120 Monument Cir',        NULL,       N'Indianapolis',   N'IN', N'46204', N'US', '2015-11-20', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (27, N'Marcus',      N'Washington', NULL, '1965-03-14', N'123-45-0027', N'marcus.washington@email.com', N'410-555-0127', N'100 E Pratt St',          NULL,       N'Baltimore',      N'MD', N'21202', N'US', '2008-09-05', N'Active',    N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (28, N'Keisha',      N'Jackson',    NULL, '1984-10-31', N'123-45-0028', N'keisha.jackson@email.com',    N'901-555-0128', N'67 Madison Ave',          NULL,       N'Memphis',        N'TN', N'38103', N'US', '2017-02-28', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (29, N'Wei',         N'Zhang',      NULL, '1992-05-20', N'123-45-0029', N'wei.zhang@email.com',         N'408-555-0129', N'200 S 1st St',            NULL,       N'San Jose',       N'CA', N'95113', N'US', '2021-06-12', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (30, N'Alejandro',   N'Hernandez',  NULL, '1977-08-07', N'123-45-0030', N'alejandro.hernandez@email.com', N'210-555-0130', N'300 Alamo Plaza',     NULL,       N'San Antonio',    N'TX', N'78205', N'US', '2012-03-19', N'Active',    N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (31, N'Priya',       N'Patel',      NULL, '1994-01-25', N'123-45-0031', N'priya.patel@email.com',       N'732-555-0131', N'1 Journal Sq',            NULL,       N'Jersey City',    N'NJ', N'07306', N'US', '2020-10-08', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (32, N'Darnell',     N'Thomas',     NULL, '1971-06-13', N'123-45-0032', N'darnell.thomas@email.com',    N'504-555-0132', N'701 Poydras St',          NULL,       N'New Orleans',    N'LA', N'70139', N'US', '2009-12-22', N'Suspended', N'High',   GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (33, N'Yuki',        N'Tanaka',     NULL, '1989-09-16', N'123-45-0033', N'yuki.tanaka@email.com',       N'808-555-0133', N'1001 Bishop St',          NULL,       N'Honolulu',       N'HI', N'96813', N'US', '2019-07-01', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (34, N'Carlos',      N'Rivera',     NULL, '1967-12-28', N'123-45-0034', N'carlos.rivera@email.com',     N'407-555-0134', N'200 S Orange Ave',        NULL,       N'Orlando',        N'FL', N'32801', N'US', '2006-08-15', N'Closed',    N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (35, N'Fatima',      N'Ali',        NULL, '1996-04-03', N'123-45-0035', N'fatima.ali@email.com',        N'313-555-0135', N'1 Campus Martius',        NULL,       N'Detroit',        N'MI', N'48226', N'US', '2023-01-20', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (36, N'Anthony',     N'Moore',      NULL, '1981-02-09', N'123-45-0036', N'anthony.moore@email.com',     N'412-555-0136', N'600 Grant St',            NULL,       N'Pittsburgh',     N'PA', N'15219', N'US', '2014-04-10', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (37, N'Stephanie',   N'Lee',        NULL, '1973-07-19', N'123-45-0037', N'stephanie.lee@email.com',     N'925-555-0137', N'2121 N California Blvd',  NULL,       N'Walnut Creek',   N'CA', N'94596', N'US', '2011-09-28', N'Active',    N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (38, N'Jamal',       N'Carter',     NULL, '1986-05-24', N'123-45-0038', N'jamal.carter@email.com',      N'770-555-0138', N'191 Peachtree St NE',     NULL,       N'Atlanta',        N'GA', N'30303', N'US', '2018-08-14', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (39, N'Mei',         N'Wong',       NULL, '1998-11-06', N'123-45-0039', N'mei.wong@email.com',          N'415-555-0139', N'560 Mission St',          NULL,       N'San Francisco',  N'CA', N'94105', N'US', '2024-02-01', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (40, N'Derek',       N'Nelson',     NULL, '1955-10-12', N'123-45-0040', N'derek.nelson@email.com',      N'480-555-0140', N'20 E Thomas Rd',          NULL,       N'Phoenix',        N'AZ', N'85012', N'US', '2005-06-01', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (41, N'Gabriela',    N'Morales',    NULL, '1991-08-21', N'123-45-0041', N'gabriela.morales@email.com',  N'713-555-0141', N'1000 Main St',            NULL,       N'Houston',        N'TX', N'77002', N'US', '2022-05-10', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (42, N'Terrence',    N'Brooks',     NULL, '1978-03-30', N'123-45-0042', N'terrence.brooks@email.com',   N'803-555-0142', N'1320 Main St',            NULL,       N'Columbia',       N'SC', N'29201', N'US', '2013-11-17', N'Active',    N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (43, N'Anika',       N'Gupta',      NULL, '1999-06-08', N'123-45-0043', N'anika.gupta@email.com',       N'571-555-0143', N'1750 Tysons Blvd',        NULL,       N'McLean',         N'VA', N'22102', N'US', '2024-01-08', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (44, N'Patrick',     N'OBrien',     NULL, '1970-01-15', N'123-45-0044', N'patrick.obrien@email.com',    N'857-555-0144', N'75 State St',             NULL,       N'Boston',         N'MA', N'02109', N'US', '2007-10-22', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (45, N'Tanya',       N'Reed',       NULL, '1985-12-19', N'123-45-0045', N'tanya.reed@email.com',        N'414-555-0145', N'330 E Kilbourn Ave',      NULL,       N'Milwaukee',      N'WI', N'53202', N'US', '2016-06-30', N'Active',    N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (46, N'Hiroshi',     N'Nakamura',   NULL, '1983-04-27', N'123-45-0046', N'hiroshi.nakamura@email.com',  N'425-555-0146', N'10655 NE 4th St',         NULL,       N'Bellevue',       N'WA', N'98004', N'US', '2015-03-11', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (47, N'Olivia',      N'Evans',      NULL, '1993-02-06', N'123-45-0047', N'olivia.evans@email.com',      N'919-555-0147', N'200 E Martin Luther King', NULL,      N'Durham',         N'NC', N'27701', N'US', '2021-09-14', N'Closed',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (48, N'Samuel',      N'Mitchell',   NULL, '1966-07-04', N'123-45-0048', N'samuel.mitchell@email.com',   N'515-555-0148', N'801 Grand Ave',           NULL,       N'Des Moines',     N'IA', N'50309', N'US', '2008-02-18', N'Active',    N'Medium', GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (49, N'Latoya',      N'Campbell',   NULL, '1987-10-13', N'123-45-0049', N'latoya.campbell@email.com',   N'502-555-0149', N'400 W Market St',         NULL,       N'Louisville',     N'KY', N'40202', N'US', '2019-12-05', N'Suspended', N'High',   GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM'),
 (50, N'Ethan',       N'Cooper',     NULL, '2000-03-22', N'123-45-0050', N'ethan.cooper@email.com',      N'801-555-0150', N'15 W South Temple',       NULL,       N'Salt Lake City', N'UT', N'84101', N'US', '2023-07-01', N'Active',    N'Low',    GETDATE(), GETDATE(), N'SYSTEM', N'SYSTEM');

SET IDENTITY_INSERT [Customers] OFF;
GO

-- ----------------------------------------------------------
-- Accounts (~120 rows)
-- ----------------------------------------------------------
SET IDENTITY_INSERT [Accounts] ON;
GO

-- === Special demo customer accounts (IDs 1-13) ===
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (1,  1, 1, N'1001-0001-0001',  4250.75,    4250.75,   N'Active',    '2018-06-15', NULL, '2025-05-10', 500.00,  0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (2,  1, 2, N'1001-0001-0002',  12800.00,   12800.00,  N'Active',    '2018-06-15', NULL, '2025-05-08', 0.00,    16.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (3,  2, 1, N'1001-0002-0001',  8920.33,    8920.33,   N'Active',    '2015-02-10', NULL, '2025-05-12', 1000.00, 0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (4,  2, 2, N'1001-0002-0002',  35400.00,   35400.00,  N'Active',    '2015-02-10', NULL, '2025-05-11', 0.00,    44.25,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (5,  3, 1, N'1001-0003-0001',  156000.00,  156000.00, N'Active',    '2022-09-01', NULL, '2025-05-13', 2000.00, 0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (6,  3, 2, N'1001-0003-0002',  89000.00,   89000.00,  N'Active',    '2022-09-01', NULL, '2025-05-09', 0.00,    111.25, GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (7,  4, 1, N'1001-0004-0001',  -45.00,     -45.00,    N'Overdrawn', '2020-11-05', NULL, '2025-05-13', 200.00,  0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (8,  4, 2, N'1001-0004-0002',  150.25,     150.25,    N'Active',    '2020-11-05', NULL, '2025-05-07', 0.00,    0.19,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (9,  5, 1, N'1001-0005-0001',  2100.50,    2100.50,   N'Active',    '2019-03-22', NULL, '2025-05-12', 500.00,  0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (10, 5, 2, N'1001-0005-0002',  890.00,     890.00,    N'Active',    '2019-03-22', NULL, '2025-05-06', 0.00,    1.11,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (11, 6, 1, N'1001-0006-0001',  7650.00,    7650.00,   N'Active',    '2016-08-01', NULL, '2025-05-13', 1000.00, 0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (12, 6, 2, N'1001-0006-0002',  22300.00,   22300.00,  N'Active',    '2016-08-01', NULL, '2025-05-10', 0.00,    27.88,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (13, 6, 3, N'1001-0006-0003',  18500.00,   0.00,      N'Active',    '2025-01-15', NULL, '2025-05-01', 0.00,    0.00,   GETDATE(), GETDATE());

-- === Regular customer accounts (IDs 14-120) ===

-- Customer 7: Robert Williams – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (14, 7, 1, N'1001-0007-0001', 5320.40,   5320.40,   N'Active', '2010-03-15', NULL, '2025-05-11', 500.00,  0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (15, 7, 2, N'1001-0007-0002', 18200.00,  18200.00,  N'Active', '2010-03-15', NULL, '2025-05-09', 0.00,    22.75,  GETDATE(), GETDATE());

-- Customer 8: Jennifer Davis – Checking + Savings + CD
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (16, 8, 1, N'1001-0008-0001', 3450.90,   3450.90,   N'Active', '2012-07-22', NULL, '2025-05-12', 500.00,  0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (17, 8, 2, N'1001-0008-0002', 9800.00,   9800.00,   N'Active', '2012-07-22', NULL, '2025-05-10', 0.00,    12.25,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (18, 8, 4, N'1001-0008-0003', 25000.00,  25000.00,  N'Active', '2014-01-10', NULL, '2025-05-01', 0.00,    88.54,  GETDATE(), GETDATE());

-- Customer 9: Michael Brown – Checking + Savings + MoneyMarket
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (19, 9, 1, N'1001-0009-0001', 12400.00,  12400.00,  N'Active', '2008-01-10', NULL, '2025-05-13', 1000.00, 0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (20, 9, 2, N'1001-0009-0002', 45000.00,  45000.00,  N'Active', '2008-01-10', NULL, '2025-05-08', 0.00,    56.25,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (21, 9, 5, N'1001-0009-0003', 75000.00,  75000.00,  N'Active', '2010-06-01', NULL, '2025-05-05', 0.00,    187.50, GETDATE(), GETDATE());

-- Customer 10: Patricia Wilson – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (22, 10, 1, N'1001-0010-0001', 2780.15,  2780.15,  N'Active', '2017-05-18', NULL, '2025-05-12', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (23, 10, 2, N'1001-0010-0002', 6500.00,  6500.00,  N'Active', '2017-05-18', NULL, '2025-05-10', 0.00,    8.13,  GETDATE(), GETDATE());

-- Customer 11: Thomas Anderson – Checking + Savings + CD + MoneyMarket
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (24, 11, 1, N'1001-0011-0001', 8900.00,  8900.00,  N'Active', '2005-11-30', NULL, '2025-05-13', 1000.00, 0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (25, 11, 2, N'1001-0011-0002', 32000.00, 32000.00, N'Active', '2005-11-30', NULL, '2025-05-11', 0.00,    40.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (26, 11, 4, N'1001-0011-0003', 50000.00, 50000.00, N'Active', '2008-03-15', NULL, '2025-05-01', 0.00,    177.08, GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (27, 11, 5, N'1001-0011-0004', 120000.00,120000.00,N'Active', '2010-01-20', NULL, '2025-05-03', 0.00,    300.00, GETDATE(), GETDATE());

-- Customer 12: Linda Taylor – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (28, 12, 1, N'1001-0012-0001', 4100.25,  4100.25,  N'Active', '2014-09-08', NULL, '2025-05-12', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (29, 12, 2, N'1001-0012-0002', 14500.00, 14500.00, N'Active', '2014-09-08', NULL, '2025-05-09', 0.00,    18.13, GETDATE(), GETDATE());

-- Customer 13: Christopher Martinez – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (30, 13, 1, N'1001-0013-0001', 1890.60,  1890.60,  N'Active', '2019-02-14', NULL, '2025-05-13', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (31, 13, 2, N'1001-0013-0002', 3200.00,  3200.00,  N'Active', '2019-02-14', NULL, '2025-05-08', 0.00,    4.00,  GETDATE(), GETDATE());

-- Customer 14: Barbara Garcia – Checking + Savings + CD
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (32, 14, 1, N'1001-0014-0001', 6200.80,  6200.80,  N'Active', '2011-06-05', NULL, '2025-05-11', 500.00,  0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (33, 14, 2, N'1001-0014-0002', 21000.00, 21000.00, N'Active', '2011-06-05', NULL, '2025-05-07', 0.00,    26.25,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (34, 14, 4, N'1001-0014-0003', 15000.00, 15000.00, N'Active', '2013-09-20', NULL, '2025-05-01', 0.00,    53.13,  GETDATE(), GETDATE());

-- Customer 15: Daniel Thompson – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (35, 15, 1, N'1001-0015-0001', 1250.00,  1250.00,  N'Active', '2020-08-20', NULL, '2025-05-13', 200.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (36, 15, 2, N'1001-0015-0002', 2100.00,  2100.00,  N'Active', '2020-08-20', NULL, '2025-05-09', 0.00,    2.63,  GETDATE(), GETDATE());

-- Customer 16: Susan White – Checking + Savings + MoneyMarket
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (37, 16, 1, N'1001-0016-0001', 9800.00,  9800.00,  N'Active', '2007-04-12', NULL, '2025-05-12', 1000.00, 0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (38, 16, 2, N'1001-0016-0002', 28000.00, 28000.00, N'Active', '2007-04-12', NULL, '2025-05-08', 0.00,    35.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (39, 16, 5, N'1001-0016-0003', 55000.00, 55000.00, N'Active', '2009-08-01', NULL, '2025-05-04', 0.00,    137.50, GETDATE(), GETDATE());

-- Customer 17: Matthew Harris – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (40, 17, 1, N'1001-0017-0001', 3670.00,  3670.00,  N'Active', '2016-01-25', NULL, '2025-05-13', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (41, 17, 2, N'1001-0017-0002', 11200.00, 11200.00, N'Active', '2016-01-25', NULL, '2025-05-10', 0.00,    14.00, GETDATE(), GETDATE());

-- Customer 18: Jessica Lewis – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (42, 18, 1, N'1001-0018-0001', 2340.75,  2340.75,  N'Active', '2021-03-10', NULL, '2025-05-12', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (43, 18, 2, N'1001-0018-0002', 5600.00,  5600.00,  N'Active', '2021-03-10', NULL, '2025-05-09', 0.00,    7.00,  GETDATE(), GETDATE());

-- Customer 19: Andrew Clark – Checking + Savings + CD
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (44, 19, 1, N'1001-0019-0001', 7800.20,  7800.20,  N'Active', '2009-10-01', NULL, '2025-05-13', 1000.00, 0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (45, 19, 2, N'1001-0019-0002', 19500.00, 19500.00, N'Active', '2009-10-01', NULL, '2025-05-08', 0.00,    24.38,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (46, 19, 4, N'1001-0019-0003', 30000.00, 30000.00, N'Active', '2012-04-15', NULL, '2025-05-01', 0.00,    106.25, GETDATE(), GETDATE());

-- Customer 20: Karen Robinson – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (47, 20, 1, N'1001-0020-0001', 4560.30,  4560.30,  N'Active', '2018-12-01', NULL, '2025-05-12', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (48, 20, 2, N'1001-0020-0002', 8900.00,  8900.00,  N'Active', '2018-12-01', NULL, '2025-05-09', 0.00,    11.13, GETDATE(), GETDATE());

-- Customer 21: Joseph Walker – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (49, 21, 1, N'1001-0021-0001', 15200.00, 15200.00, N'Frozen', '2006-05-17', NULL, '2025-04-20', 1000.00, 0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (50, 21, 2, N'1001-0021-0002', 42000.00, 42000.00, N'Frozen', '2006-05-17', NULL, '2025-04-20', 0.00,    52.50, GETDATE(), GETDATE());

-- Customer 22: Nancy Allen – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (51, 22, 1, N'1001-0022-0001', 1980.45,  1980.45,  N'Active', '2022-01-15', NULL, '2025-05-13', 200.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (52, 22, 2, N'1001-0022-0002', 3400.00,  3400.00,  N'Active', '2022-01-15', NULL, '2025-05-10', 0.00,    4.25,  GETDATE(), GETDATE());

-- Customer 23: Ryan Young – Checking + Savings + Loan
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (53, 23, 1, N'1001-0023-0001', 6700.00,  6700.00,  N'Active', '2013-08-30', NULL, '2025-05-12', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (54, 23, 2, N'1001-0023-0002', 15800.00, 15800.00, N'Active', '2013-08-30', NULL, '2025-05-08', 0.00,    19.75, GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (55, 23, 3, N'1001-0023-0003', 28000.00, 0.00,     N'Active', '2024-06-01', NULL, '2025-05-01', 0.00,    0.00,  GETDATE(), GETDATE());

-- Customer 24: Elizabeth King – Checking only
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (56, 24, 1, N'1001-0024-0001', 890.50,   890.50,   N'Active', '2023-04-05', NULL, '2025-05-13', 200.00,  0.00,  GETDATE(), GETDATE());

-- Customer 25: Brandon Scott – Checking + Savings (Frozen – Suspended customer)
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (57, 25, 1, N'1001-0025-0001', 24500.00, 24500.00, N'Frozen', '2010-07-14', NULL, '2025-03-15', 1000.00, 0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (58, 25, 2, N'1001-0025-0002', 68000.00, 68000.00, N'Frozen', '2010-07-14', NULL, '2025-03-15', 0.00,    85.00, GETDATE(), GETDATE());

-- Customer 26: Rebecca Adams – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (59, 26, 1, N'1001-0026-0001', 3150.90,  3150.90,  N'Active', '2015-11-20', NULL, '2025-05-12', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (60, 26, 2, N'1001-0026-0002', 7200.00,  7200.00,  N'Active', '2015-11-20', NULL, '2025-05-08', 0.00,    9.00,  GETDATE(), GETDATE());

-- Customer 27: Marcus Washington – Checking + Savings + MoneyMarket
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (61, 27, 1, N'1001-0027-0001', 11200.00, 11200.00, N'Active', '2008-09-05', NULL, '2025-05-13', 1000.00, 0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (62, 27, 2, N'1001-0027-0002', 38000.00, 38000.00, N'Active', '2008-09-05', NULL, '2025-05-09', 0.00,    47.50,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (63, 27, 5, N'1001-0027-0003', 95000.00, 95000.00, N'Active', '2011-02-14', NULL, '2025-05-04', 0.00,    237.50, GETDATE(), GETDATE());

-- Customer 28: Keisha Jackson – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (64, 28, 1, N'1001-0028-0001', 2890.00,  2890.00,  N'Active', '2017-02-28', NULL, '2025-05-11', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (65, 28, 2, N'1001-0028-0002', 6100.00,  6100.00,  N'Active', '2017-02-28', NULL, '2025-05-09', 0.00,    7.63,  GETDATE(), GETDATE());

-- Customer 29: Wei Zhang – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (66, 29, 1, N'1001-0029-0001', 4780.20,  4780.20,  N'Active', '2021-06-12', NULL, '2025-05-13', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (67, 29, 2, N'1001-0029-0002', 12300.00, 12300.00, N'Active', '2021-06-12', NULL, '2025-05-10', 0.00,    15.38, GETDATE(), GETDATE());

-- Customer 30: Alejandro Hernandez – Checking + Savings + CD
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (68, 30, 1, N'1001-0030-0001', 8100.00,  8100.00,  N'Active', '2012-03-19', NULL, '2025-05-12', 500.00,  0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (69, 30, 2, N'1001-0030-0002', 24000.00, 24000.00, N'Active', '2012-03-19', NULL, '2025-05-08', 0.00,    30.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (70, 30, 4, N'1001-0030-0003', 40000.00, 40000.00, N'Active', '2015-01-10', NULL, '2025-05-01', 0.00,    141.67, GETDATE(), GETDATE());

-- Customer 31: Priya Patel – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (71, 31, 1, N'1001-0031-0001', 3450.00,  3450.00,  N'Active', '2020-10-08', NULL, '2025-05-13', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (72, 31, 2, N'1001-0031-0002', 8800.00,  8800.00,  N'Active', '2020-10-08', NULL, '2025-05-10', 0.00,    11.00, GETDATE(), GETDATE());

-- Customer 32: Darnell Thomas – Checking + Savings (Frozen – Suspended customer)
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (73, 32, 1, N'1001-0032-0001', 31000.00, 31000.00, N'Frozen', '2009-12-22', NULL, '2025-02-28', 1000.00, 0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (74, 32, 2, N'1001-0032-0002', 54000.00, 54000.00, N'Frozen', '2009-12-22', NULL, '2025-02-28', 0.00,    67.50, GETDATE(), GETDATE());

-- Customer 33: Yuki Tanaka – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (75, 33, 1, N'1001-0033-0001', 5900.00,  5900.00,  N'Active', '2019-07-01', NULL, '2025-05-12', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (76, 33, 2, N'1001-0033-0002', 16700.00, 16700.00, N'Active', '2019-07-01', NULL, '2025-05-09', 0.00,    20.88, GETDATE(), GETDATE());

-- Customer 34: Carlos Rivera – Checking + Savings (Closed)
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (77, 34, 1, N'1001-0034-0001', 0.00,     0.00,     N'Closed', '2006-08-15', '2024-06-30', '2024-06-30', 0.00, 0.00, GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (78, 34, 2, N'1001-0034-0002', 0.00,     0.00,     N'Closed', '2006-08-15', '2024-06-30', '2024-06-30', 0.00, 0.00, GETDATE(), GETDATE());

-- Customer 35: Fatima Ali – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (79, 35, 1, N'1001-0035-0001', 1120.00,  1120.00,  N'Active', '2023-01-20', NULL, '2025-05-13', 200.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (80, 35, 2, N'1001-0035-0002', 2500.00,  2500.00,  N'Active', '2023-01-20', NULL, '2025-05-10', 0.00,    3.13,  GETDATE(), GETDATE());

-- Customer 36: Anthony Moore – Checking + Savings + CD
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (81, 36, 1, N'1001-0036-0001', 4900.00,  4900.00,  N'Active', '2014-04-10', NULL, '2025-05-12', 500.00,  0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (82, 36, 2, N'1001-0036-0002', 13500.00, 13500.00, N'Active', '2014-04-10', NULL, '2025-05-08', 0.00,    16.88,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (83, 36, 4, N'1001-0036-0003', 20000.00, 20000.00, N'Active', '2016-07-01', NULL, '2025-05-01', 0.00,    70.83,  GETDATE(), GETDATE());

-- Customer 37: Stephanie Lee – Checking + Savings + MoneyMarket
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (84, 37, 1, N'1001-0037-0001', 7200.50,  7200.50,  N'Active', '2011-09-28', NULL, '2025-05-13', 500.00,  0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (85, 37, 2, N'1001-0037-0002', 27000.00, 27000.00, N'Active', '2011-09-28', NULL, '2025-05-09', 0.00,    33.75,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (86, 37, 5, N'1001-0037-0003', 45000.00, 45000.00, N'Active', '2013-05-15', NULL, '2025-05-05', 0.00,    112.50, GETDATE(), GETDATE());

-- Customer 38: Jamal Carter – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (87, 38, 1, N'1001-0038-0001', 3890.00,  3890.00,  N'Active', '2018-08-14', NULL, '2025-05-11', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (88, 38, 2, N'1001-0038-0002', 9400.00,  9400.00,  N'Active', '2018-08-14', NULL, '2025-05-09', 0.00,    11.75, GETDATE(), GETDATE());

-- Customer 39: Mei Wong – Checking only
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (89, 39, 1, N'1001-0039-0001', 620.00,   620.00,   N'Active', '2024-02-01', NULL, '2025-05-13', 200.00,  0.00,  GETDATE(), GETDATE());

-- Customer 40: Derek Nelson – Checking + Savings + CD + MoneyMarket
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (90, 40, 1, N'1001-0040-0001', 10500.00, 10500.00, N'Active', '2005-06-01', NULL, '2025-05-12', 1000.00, 0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (91, 40, 2, N'1001-0040-0002', 52000.00, 52000.00, N'Active', '2005-06-01', NULL, '2025-05-08', 0.00,    65.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (92, 40, 4, N'1001-0040-0003', 80000.00, 80000.00, N'Active', '2008-11-01', NULL, '2025-05-01', 0.00,    283.33, GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (93, 40, 5, N'1001-0040-0004', 150000.00,150000.00,N'Active', '2010-04-15', NULL, '2025-05-03', 0.00,    375.00, GETDATE(), GETDATE());

-- Customer 41: Gabriela Morales – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (94, 41, 1, N'1001-0041-0001', 2670.00,  2670.00,  N'Active', '2022-05-10', NULL, '2025-05-13', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (95, 41, 2, N'1001-0041-0002', 5100.00,  5100.00,  N'Active', '2022-05-10', NULL, '2025-05-10', 0.00,    6.38,  GETDATE(), GETDATE());

-- Customer 42: Terrence Brooks – Checking + Savings + Loan
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (96, 42, 1, N'1001-0042-0001', 5600.00,  5600.00,  N'Active', '2013-11-17', NULL, '2025-05-12', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (97, 42, 2, N'1001-0042-0002', 17800.00, 17800.00, N'Active', '2013-11-17', NULL, '2025-05-09', 0.00,    22.25, GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (98, 42, 3, N'1001-0042-0003', 45000.00, 0.00,     N'Active', '2023-09-01', NULL, '2025-05-01', 0.00,    0.00,  GETDATE(), GETDATE());

-- Customer 43: Anika Gupta – Checking only
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (99, 43, 1, N'1001-0043-0001', 450.75,   450.75,   N'Active', '2024-01-08', NULL, '2025-05-13', 200.00,  0.00,  GETDATE(), GETDATE());

-- Customer 44: Patrick OBrien – Checking + Savings + CD
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (100, 44, 1, N'1001-0044-0001', 9200.00,  9200.00,  N'Active', '2007-10-22', NULL, '2025-05-11', 1000.00, 0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (101, 44, 2, N'1001-0044-0002', 41000.00, 41000.00, N'Active', '2007-10-22', NULL, '2025-05-08', 0.00,    51.25,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (102, 44, 4, N'1001-0044-0003', 60000.00, 60000.00, N'Active', '2010-03-01', NULL, '2025-05-01', 0.00,    212.50, GETDATE(), GETDATE());

-- Customer 45: Tanya Reed – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (103, 45, 1, N'1001-0045-0001', 4300.00,  4300.00,  N'Active', '2016-06-30', NULL, '2025-05-12', 500.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (104, 45, 2, N'1001-0045-0002', 10500.00, 10500.00, N'Active', '2016-06-30', NULL, '2025-05-09', 0.00,    13.13, GETDATE(), GETDATE());

-- Customer 46: Hiroshi Nakamura – Checking + Savings + MoneyMarket
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (105, 46, 1, N'1001-0046-0001', 6100.00,  6100.00,  N'Active', '2015-03-11', NULL, '2025-05-13', 500.00,  0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (106, 46, 2, N'1001-0046-0002', 19000.00, 19000.00, N'Active', '2015-03-11', NULL, '2025-05-09', 0.00,    23.75,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (107, 46, 5, N'1001-0046-0003', 35000.00, 35000.00, N'Active', '2017-06-01', NULL, '2025-05-04', 0.00,    87.50,  GETDATE(), GETDATE());

-- Customer 47: Olivia Evans – Checking + Savings (Closed)
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (108, 47, 1, N'1001-0047-0001', 0.00,     0.00,     N'Closed', '2021-09-14', '2024-12-15', '2024-12-15', 0.00, 0.00, GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (109, 47, 2, N'1001-0047-0002', 0.00,     0.00,     N'Closed', '2021-09-14', '2024-12-15', '2024-12-15', 0.00, 0.00, GETDATE(), GETDATE());

-- Customer 48: Samuel Mitchell – Checking + Savings + CD
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (110, 48, 1, N'1001-0048-0001', 8400.00,  8400.00,  N'Active', '2008-02-18', NULL, '2025-05-12', 1000.00, 0.00,   GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (111, 48, 2, N'1001-0048-0002', 29000.00, 29000.00, N'Active', '2008-02-18', NULL, '2025-05-08', 0.00,    36.25,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (112, 48, 4, N'1001-0048-0003', 35000.00, 35000.00, N'Active', '2011-08-01', NULL, '2025-05-01', 0.00,    123.96, GETDATE(), GETDATE());

-- Customer 49: Latoya Campbell – Checking + Savings (Frozen – Suspended customer)
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (113, 49, 1, N'1001-0049-0001', 18900.00, 18900.00, N'Frozen', '2019-12-05', NULL, '2025-04-10', 1000.00, 0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (114, 49, 2, N'1001-0049-0002', 37000.00, 37000.00, N'Frozen', '2019-12-05', NULL, '2025-04-10', 0.00,    46.25, GETDATE(), GETDATE());

-- Customer 50: Ethan Cooper – Checking + Savings
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (115, 50, 1, N'1001-0050-0001', 780.00,   780.00,   N'Active', '2023-07-01', NULL, '2025-05-13', 200.00,  0.00,  GETDATE(), GETDATE());
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (116, 50, 2, N'1001-0050-0002', 1800.00,  1800.00,  N'Active', '2023-07-01', NULL, '2025-05-10', 0.00,    2.25,  GETDATE(), GETDATE());

-- Additional accounts to reach ~120 (extra accounts for some customers)

-- Customer 7: Robert Williams – add CD
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (117, 7, 4, N'1001-0007-0003', 10000.00, 10000.00, N'Active', '2012-06-01', NULL, '2025-05-01', 0.00, 35.42, GETDATE(), GETDATE());

-- Customer 12: Linda Taylor – add MoneyMarket
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (118, 12, 5, N'1001-0012-0003', 28000.00, 28000.00, N'Active', '2016-11-01', NULL, '2025-05-04', 0.00, 70.00, GETDATE(), GETDATE());

-- Customer 20: Karen Robinson – add Loan
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (119, 20, 3, N'1001-0020-0003', 12000.00, 0.00, N'Active', '2024-03-15', NULL, '2025-05-01', 0.00, 0.00, GETDATE(), GETDATE());

-- Customer 38: Jamal Carter – add CD
INSERT INTO Accounts (AccountID, CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status, OpenDate, CloseDate, LastActivityDate, OverdraftLimit, InterestAccrued, CreatedDate, ModifiedDate)
VALUES (120, 38, 4, N'1001-0038-0003', 15000.00, 15000.00, N'Active', '2020-01-15', NULL, '2025-05-01', 0.00, 53.13, GETDATE(), GETDATE());

SET IDENTITY_INSERT [Accounts] OFF;
GO

PRINT 'Seed data for AccountTypes, TransactionTypes, LoanProducts, PaymentMethods, Customers, and Accounts inserted successfully.';
GO
