USE [ZavaBankDB];
GO

-- ============================================================================
-- 41-seed-transactions.sql
-- Seeds ~2,000 Transactions and ~500 TransactionArchive rows
-- ============================================================================

-- ============================================================================
-- PART 1: Explicit demo customer transactions (Nov 2025 - May 2026)
-- ============================================================================

-- --------------------------------------------------------------------------
-- Maria Rodriguez (AccountID 1=Checking, 2=Savings) ~30 transactions
-- Normal checking: biweekly payroll, rent, groceries, utilities, savings xfers
-- --------------------------------------------------------------------------
INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel, Memo, CreatedDate)
VALUES
-- November 2025
(1, 1, 2850.00, 3200.00, 'Payroll Deposit - Acme Corp', 'TXN-2025-A1B2C301', '2025-11-14', '2025-11-14', 'Posted', 'Online', NULL, '2025-11-14'),
(1, 6, 1400.00, 1800.00, 'Monthly Rent Payment', 'TXN-2025-A1B2C302', '2025-11-15', '2025-11-15', 'Posted', 'Online', 'Nov rent', '2025-11-15'),
(1, 2, 87.52, 1712.48, 'Whole Foods Market #1234', 'TXN-2025-A1B2C303', '2025-11-17', '2025-11-17', 'Posted', 'Mobile', NULL, '2025-11-17'),
(1, 1, 2850.00, 4562.48, 'Payroll Deposit - Acme Corp', 'TXN-2025-A1B2C304', '2025-11-28', '2025-11-28', 'Posted', 'Online', NULL, '2025-11-28'),
(1, 6, 125.00, 4437.48, 'Xfinity Internet Bill', 'TXN-2025-A1B2C305', '2025-11-30', '2025-11-30', 'Posted', 'Online', NULL, '2025-11-30'),
-- December 2025
(1, 6, 1400.00, 3037.48, 'Monthly Rent Payment', 'TXN-2025-A1B2C306', '2025-12-01', '2025-12-01', 'Posted', 'Online', 'Dec rent', '2025-12-01'),
(1, 2, 153.27, 2884.21, 'Target Store #5678', 'TXN-2025-A1B2C307', '2025-12-05', '2025-12-05', 'Posted', 'Mobile', NULL, '2025-12-05'),
(1, 1, 2850.00, 5734.21, 'Payroll Deposit - Acme Corp', 'TXN-2025-A1B2C308', '2025-12-12', '2025-12-12', 'Posted', 'Online', NULL, '2025-12-12'),
(1, 3, 500.00, 5234.21, 'Transfer to Savings', 'TXN-2025-A1B2C309', '2025-12-13', '2025-12-13', 'Posted', 'Online', NULL, '2025-12-13'),
(2, 1, 500.00, 13300.00, 'Transfer from Checking', 'TXN-2025-A1B2C310', '2025-12-13', '2025-12-13', 'Posted', 'Online', NULL, '2025-12-13'),
(1, 1, 2850.00, 8084.21, 'Payroll Deposit - Acme Corp', 'TXN-2025-A1B2C311', '2025-12-26', '2025-12-26', 'Posted', 'Online', NULL, '2025-12-26'),
(1, 2, 200.00, 7884.21, 'ATM Withdrawal - Chase ATM', 'TXN-2025-A1B2C312', '2025-12-28', '2025-12-28', 'Posted', 'ATM', NULL, '2025-12-28'),
-- January 2026
(1, 6, 1400.00, 6484.21, 'Monthly Rent Payment', 'TXN-2026-A1B2C313', '2026-01-01', '2026-01-01', 'Posted', 'Online', 'Jan rent', '2026-01-01'),
(1, 1, 2850.00, 9334.21, 'Payroll Deposit - Acme Corp', 'TXN-2026-A1B2C314', '2026-01-09', '2026-01-09', 'Posted', 'Online', NULL, '2026-01-09'),
(1, 2, 65.40, 9268.81, 'Trader Joes #0912', 'TXN-2026-A1B2C315', '2026-01-11', '2026-01-11', 'Posted', 'Mobile', NULL, '2026-01-11'),
(1, 6, 89.00, 9179.81, 'Electric Bill - ConEdison', 'TXN-2026-A1B2C316', '2026-01-15', '2026-01-15', 'Posted', 'Online', NULL, '2026-01-15'),
(1, 1, 2850.00, 12029.81, 'Payroll Deposit - Acme Corp', 'TXN-2026-A1B2C317', '2026-01-23', '2026-01-23', 'Posted', 'Online', NULL, '2026-01-23'),
-- February 2026
(1, 6, 1400.00, 10629.81, 'Monthly Rent Payment', 'TXN-2026-A1B2C318', '2026-02-01', '2026-02-01', 'Posted', 'Online', 'Feb rent', '2026-02-01'),
(1, 1, 2850.00, 13479.81, 'Payroll Deposit - Acme Corp', 'TXN-2026-A1B2C319', '2026-02-06', '2026-02-06', 'Posted', 'Online', NULL, '2026-02-06'),
(1, 2, 112.88, 13366.93, 'Whole Foods Market #1234', 'TXN-2026-A1B2C320', '2026-02-10', '2026-02-10', 'Posted', 'Mobile', NULL, '2026-02-10'),
(1, 3, 1000.00, 12366.93, 'Transfer to Savings', 'TXN-2026-A1B2C321', '2026-02-15', '2026-02-15', 'Posted', 'Online', NULL, '2026-02-15'),
(2, 1, 1000.00, 14300.00, 'Transfer from Checking', 'TXN-2026-A1B2C322', '2026-02-15', '2026-02-15', 'Posted', 'Online', NULL, '2026-02-15'),
(1, 1, 2850.00, 15216.93, 'Payroll Deposit - Acme Corp', 'TXN-2026-A1B2C323', '2026-02-20', '2026-02-20', 'Posted', 'Online', NULL, '2026-02-20'),
-- March 2026
(1, 6, 1400.00, 13816.93, 'Monthly Rent Payment', 'TXN-2026-A1B2C324', '2026-03-01', '2026-03-01', 'Posted', 'Online', 'Mar rent', '2026-03-01'),
(1, 1, 2850.00, 16666.93, 'Payroll Deposit - Acme Corp', 'TXN-2026-A1B2C325', '2026-03-06', '2026-03-06', 'Posted', 'Online', NULL, '2026-03-06'),
(1, 6, 125.00, 16541.93, 'Xfinity Internet Bill', 'TXN-2026-A1B2C326', '2026-03-10', '2026-03-10', 'Posted', 'Online', NULL, '2026-03-10'),
-- April-May 2026
(1, 6, 1400.00, 15141.93, 'Monthly Rent Payment', 'TXN-2026-A1B2C327', '2026-04-01', '2026-04-01', 'Posted', 'Online', 'Apr rent', '2026-04-01'),
(1, 1, 2850.00, 17991.93, 'Payroll Deposit - Acme Corp', 'TXN-2026-A1B2C328', '2026-04-10', '2026-04-10', 'Posted', 'Online', NULL, '2026-04-10'),
(1, 6, 1400.00, 16591.93, 'Monthly Rent Payment', 'TXN-2026-A1B2C329', '2026-05-01', '2026-05-01', 'Posted', 'Online', 'May rent', '2026-05-01'),
(1, 1, 2850.00, 19441.93, 'Payroll Deposit - Acme Corp', 'TXN-2026-A1B2C330', '2026-05-09', '2026-05-09', 'Posted', 'Online', NULL, '2026-05-09'),
(2, 5, 18.75, 14318.75, 'Monthly Interest Payment', 'TXN-2026-A1B2C331', '2026-04-30', '2026-04-30', 'Posted', 'Online', NULL, '2026-04-30');
GO

-- --------------------------------------------------------------------------
-- James Chen (AccountID 3=Checking, 4=Savings) ~35 transactions
-- Normal activity PLUS suspicious structuring pattern
-- --------------------------------------------------------------------------
INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel, Memo, CreatedDate)
VALUES
-- Normal activity Nov-Apr
(3, 1, 4200.00, 9500.00, 'Payroll Deposit - TechVentures Inc', 'TXN-2025-B3D4E501', '2025-11-15', '2025-11-15', 'Posted', 'Online', NULL, '2025-11-15'),
(3, 6, 1850.00, 7650.00, 'Monthly Mortgage Payment', 'TXN-2025-B3D4E502', '2025-11-20', '2025-11-20', 'Posted', 'Online', NULL, '2025-11-20'),
(3, 2, 60.00, 7590.00, 'ATM Withdrawal - BofA ATM', 'TXN-2025-B3D4E503', '2025-11-22', '2025-11-22', 'Posted', 'ATM', NULL, '2025-11-22'),
(3, 1, 4200.00, 11790.00, 'Payroll Deposit - TechVentures Inc', 'TXN-2025-B3D4E504', '2025-11-30', '2025-11-30', 'Posted', 'Online', NULL, '2025-11-30'),
(3, 6, 1850.00, 9940.00, 'Monthly Mortgage Payment', 'TXN-2025-B3D4E505', '2025-12-20', '2025-12-20', 'Posted', 'Online', NULL, '2025-12-20'),
(3, 1, 4200.00, 14140.00, 'Payroll Deposit - TechVentures Inc', 'TXN-2025-B3D4E506', '2025-12-15', '2025-12-15', 'Posted', 'Online', NULL, '2025-12-15'),
(3, 2, 250.00, 13890.00, 'ATM Withdrawal - Chase ATM', 'TXN-2025-B3D4E507', '2025-12-23', '2025-12-23', 'Posted', 'ATM', NULL, '2025-12-23'),
(3, 3, 2000.00, 11890.00, 'Transfer to Savings', 'TXN-2025-B3D4E508', '2025-12-28', '2025-12-28', 'Posted', 'Online', NULL, '2025-12-28'),
(4, 1, 2000.00, 37400.00, 'Transfer from Checking', 'TXN-2025-B3D4E509', '2025-12-28', '2025-12-28', 'Posted', 'Online', NULL, '2025-12-28'),
(3, 1, 4200.00, 16090.00, 'Payroll Deposit - TechVentures Inc', 'TXN-2026-B3D4E510', '2026-01-15', '2026-01-15', 'Posted', 'Online', NULL, '2026-01-15'),
(3, 6, 1850.00, 14240.00, 'Monthly Mortgage Payment', 'TXN-2026-B3D4E511', '2026-01-20', '2026-01-20', 'Posted', 'Online', NULL, '2026-01-20'),
(3, 6, 180.00, 14060.00, 'Verizon Wireless Bill', 'TXN-2026-B3D4E512', '2026-01-25', '2026-01-25', 'Posted', 'Online', NULL, '2026-01-25'),
(3, 1, 4200.00, 18260.00, 'Payroll Deposit - TechVentures Inc', 'TXN-2026-B3D4E513', '2026-02-14', '2026-02-14', 'Posted', 'Online', NULL, '2026-02-14'),
(3, 6, 1850.00, 16410.00, 'Monthly Mortgage Payment', 'TXN-2026-B3D4E514', '2026-02-20', '2026-02-20', 'Posted', 'Online', NULL, '2026-02-20'),
(3, 2, 135.50, 16274.50, 'Best Buy #3344', 'TXN-2026-B3D4E515', '2026-02-22', '2026-02-22', 'Posted', 'Mobile', NULL, '2026-02-22'),
(3, 1, 4200.00, 20474.50, 'Payroll Deposit - TechVentures Inc', 'TXN-2026-B3D4E516', '2026-03-15', '2026-03-15', 'Posted', 'Online', NULL, '2026-03-15'),
(3, 6, 1850.00, 18624.50, 'Monthly Mortgage Payment', 'TXN-2026-B3D4E517', '2026-03-20', '2026-03-20', 'Posted', 'Online', NULL, '2026-03-20'),
(3, 1, 4200.00, 22824.50, 'Payroll Deposit - TechVentures Inc', 'TXN-2026-B3D4E518', '2026-04-15', '2026-04-15', 'Posted', 'Online', NULL, '2026-04-15'),
(3, 6, 1850.00, 20974.50, 'Monthly Mortgage Payment', 'TXN-2026-B3D4E519', '2026-04-20', '2026-04-20', 'Posted', 'Online', NULL, '2026-04-20'),
(3, 1, 4200.00, 25174.50, 'Payroll Deposit - TechVentures Inc', 'TXN-2026-B3D4E520', '2026-05-01', '2026-05-01', 'Posted', 'Online', NULL, '2026-05-01'),
(3, 6, 1850.00, 23324.50, 'Monthly Mortgage Payment', 'TXN-2026-B3D4E521', '2026-05-05', '2026-05-05', 'Posted', 'Online', NULL, '2026-05-05'),
(4, 5, 44.25, 37444.25, 'Monthly Interest Payment', 'TXN-2026-B3D4E522', '2026-04-30', '2026-04-30', 'Posted', 'Online', NULL, '2026-04-30'),

-- *** SUSPICIOUS STRUCTURING PATTERN: 8 rapid transfers just under $500 ***
(3, 3, 499.00, 22825.50, 'Online Transfer - External Account', 'TXN-2026-B3D4E523', '2026-05-10 09:14:00', '2026-05-10 09:14:00', 'Posted', 'Online', NULL, '2026-05-10'),
(3, 3, 498.00, 22327.50, 'Online Transfer - External Account', 'TXN-2026-B3D4E524', '2026-05-10 11:42:00', '2026-05-10 11:42:00', 'Posted', 'Online', NULL, '2026-05-10'),
(3, 3, 497.00, 21830.50, 'Online Transfer - External Account', 'TXN-2026-B3D4E525', '2026-05-10 15:05:00', '2026-05-10 15:05:00', 'Posted', 'Online', NULL, '2026-05-10'),
(3, 3, 499.50, 21331.00, 'Online Transfer - External Account', 'TXN-2026-B3D4E526', '2026-05-11 08:30:00', '2026-05-11 08:30:00', 'Posted', 'Online', NULL, '2026-05-11'),
(3, 3, 495.00, 20836.00, 'Online Transfer - External Account', 'TXN-2026-B3D4E527', '2026-05-11 13:18:00', '2026-05-11 13:18:00', 'Posted', 'Online', NULL, '2026-05-11'),
(3, 3, 498.50, 20337.50, 'Online Transfer - External Account', 'TXN-2026-B3D4E528', '2026-05-11 17:45:00', '2026-05-11 17:45:00', 'Posted', 'Online', NULL, '2026-05-11'),
(3, 3, 496.00, 19841.50, 'Online Transfer - External Account', 'TXN-2026-B3D4E529', '2026-05-12 10:22:00', '2026-05-12 10:22:00', 'Posted', 'Online', NULL, '2026-05-12'),
(3, 3, 499.99, 19341.51, 'Online Transfer - External Account', 'TXN-2026-B3D4E530', '2026-05-12 14:55:00', '2026-05-12 14:55:00', 'Posted', 'Online', NULL, '2026-05-12');
GO

-- Update suspicious transfers with CounterpartyAccount values
UPDATE Transactions SET CounterpartyAccount = 'EXT-9901' WHERE ReferenceNumber = 'TXN-2026-B3D4E523';
UPDATE Transactions SET CounterpartyAccount = 'EXT-9902' WHERE ReferenceNumber = 'TXN-2026-B3D4E524';
UPDATE Transactions SET CounterpartyAccount = 'EXT-9903' WHERE ReferenceNumber = 'TXN-2026-B3D4E525';
UPDATE Transactions SET CounterpartyAccount = 'EXT-9904' WHERE ReferenceNumber = 'TXN-2026-B3D4E526';
UPDATE Transactions SET CounterpartyAccount = 'EXT-9905' WHERE ReferenceNumber = 'TXN-2026-B3D4E527';
UPDATE Transactions SET CounterpartyAccount = 'EXT-9906' WHERE ReferenceNumber = 'TXN-2026-B3D4E528';
UPDATE Transactions SET CounterpartyAccount = 'EXT-9907' WHERE ReferenceNumber = 'TXN-2026-B3D4E529';
UPDATE Transactions SET CounterpartyAccount = 'EXT-9908' WHERE ReferenceNumber = 'TXN-2026-B3D4E530';
GO

-- --------------------------------------------------------------------------
-- Viktor Petrov (AccountID 5=Checking, 6=Savings) ~18 transactions
-- Large/unusual: international wires, large round-number withdrawals
-- --------------------------------------------------------------------------
INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel, CounterpartyAccount, Memo, CreatedDate)
VALUES
(5, 1, 50000.00, 180000.00, 'Wire Transfer from Intl - Zurich Holdings AG', 'TXN-2025-C5F6G701', '2025-11-18', '2025-11-18', 'Posted', 'Wire', 'CH93-0076-2011-6238-5295-7', NULL, '2025-11-18'),
(5, 2, 25000.00, 155000.00, 'Counter Withdrawal - Cashiers Check', 'TXN-2025-C5F6G702', '2025-11-25', '2025-11-25', 'Posted', 'Branch', NULL, NULL, '2025-11-25'),
(5, 1, 35000.00, 190000.00, 'Wire Transfer from Intl - Cayman National Bank', 'TXN-2025-C5F6G703', '2025-12-10', '2025-12-10', 'Posted', 'Wire', 'KY21-CNBK-0001-0000-1234-56', NULL, '2025-12-10'),
(5, 2, 30000.00, 160000.00, 'Counter Withdrawal - Cash', 'TXN-2025-C5F6G704', '2025-12-18', '2025-12-18', 'Posted', 'Branch', NULL, NULL, '2025-12-18'),
(5, 3, 15000.00, 145000.00, 'Transfer to Savings', 'TXN-2025-C5F6G705', '2025-12-20', '2025-12-20', 'Posted', 'Online', NULL, NULL, '2025-12-20'),
(6, 1, 15000.00, 104000.00, 'Transfer from Checking', 'TXN-2025-C5F6G706', '2025-12-20', '2025-12-20', 'Posted', 'Online', NULL, NULL, '2025-12-20'),
(5, 1, 45000.00, 190000.00, 'Wire Transfer from Intl - Singapore Trade Corp', 'TXN-2026-C5F6G707', '2026-01-15', '2026-01-15', 'Posted', 'Wire', 'SG68-OCBC-0000-0012-3456-78', NULL, '2026-01-15'),
(5, 2, 40000.00, 150000.00, 'Counter Withdrawal - Cash', 'TXN-2026-C5F6G708', '2026-01-22', '2026-01-22', 'Posted', 'Branch', NULL, NULL, '2026-01-22'),
(5, 4, 45.00, 149955.00, 'Wire Transfer Fee', 'TXN-2026-C5F6G709', '2026-01-15', '2026-01-15', 'Posted', 'Wire', NULL, NULL, '2026-01-15'),
(5, 1, 28000.00, 177955.00, 'Wire Transfer from Intl - Dubai Investments LLC', 'TXN-2026-C5F6G710', '2026-02-20', '2026-02-20', 'Posted', 'Wire', 'AE07-0331-2345-6789-0123-456', NULL, '2026-02-20'),
(5, 2, 20000.00, 157955.00, 'Counter Withdrawal - Cashiers Check', 'TXN-2026-C5F6G711', '2026-03-05', '2026-03-05', 'Posted', 'Branch', NULL, NULL, '2026-03-05'),
(5, 1, 32000.00, 189955.00, 'Wire Transfer from Intl - Zurich Holdings AG', 'TXN-2026-C5F6G712', '2026-03-18', '2026-03-18', 'Posted', 'Wire', 'CH93-0076-2011-6238-5295-7', NULL, '2026-03-18'),
(5, 2, 35000.00, 154955.00, 'Counter Withdrawal - Cash', 'TXN-2026-C5F6G713', '2026-04-02', '2026-04-02', 'Posted', 'Branch', NULL, NULL, '2026-04-02'),
(5, 4, 45.00, 154910.00, 'Wire Transfer Fee', 'TXN-2026-C5F6G714', '2026-03-18', '2026-03-18', 'Posted', 'Wire', NULL, NULL, '2026-03-18'),
(5, 1, 25000.00, 179910.00, 'Wire Transfer from Intl - London Capital Group', 'TXN-2026-C5F6G715', '2026-04-22', '2026-04-22', 'Posted', 'Wire', 'GB29-NWBK-6016-1331-9268-19', NULL, '2026-04-22'),
(5, 2, 25000.00, 154910.00, 'Counter Withdrawal - Cash', 'TXN-2026-C5F6G716', '2026-05-01', '2026-05-01', 'Posted', 'Branch', NULL, NULL, '2026-05-01'),
(6, 5, 112.50, 104112.50, 'Monthly Interest Payment', 'TXN-2026-C5F6G717', '2026-04-30', '2026-04-30', 'Posted', 'Online', NULL, NULL, '2026-04-30'),
(5, 1, 50000.00, 204910.00, 'Wire Transfer from Intl - Cayman National Bank', 'TXN-2026-C5F6G718', '2026-05-10', NULL, 'Pending', 'Wire', 'KY21-CNBK-0001-0000-1234-56', NULL, '2026-05-10');
GO

-- --------------------------------------------------------------------------
-- Sarah Miller (AccountID 7=Checking, 8=Savings) ~24 transactions
-- Declining balance story ending at -$45.00 with overdraft fees
-- --------------------------------------------------------------------------
INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel, Memo, CreatedDate)
VALUES
-- Earlier months - some income keeping her afloat
(7, 1, 1800.00, 2200.00, 'Payroll Deposit - City Diner', 'TXN-2025-D7H8I901', '2025-11-15', '2025-11-15', 'Posted', 'Online', NULL, '2025-11-15'),
(7, 6, 950.00, 1250.00, 'Monthly Rent Payment', 'TXN-2025-D7H8I902', '2025-11-18', '2025-11-18', 'Posted', 'Online', 'Nov rent', '2025-11-18'),
(7, 2, 45.00, 1205.00, 'ATM Withdrawal - TD Bank ATM', 'TXN-2025-D7H8I903', '2025-11-22', '2025-11-22', 'Posted', 'ATM', NULL, '2025-11-22'),
(7, 1, 1800.00, 3005.00, 'Payroll Deposit - City Diner', 'TXN-2025-D7H8I904', '2025-12-01', '2025-12-01', 'Posted', 'Online', NULL, '2025-12-01'),
(7, 6, 950.00, 2055.00, 'Monthly Rent Payment', 'TXN-2025-D7H8I905', '2025-12-05', '2025-12-05', 'Posted', 'Online', 'Dec rent', '2025-12-05'),
(7, 2, 180.00, 1875.00, 'Holiday Shopping - Amazon', 'TXN-2025-D7H8I906', '2025-12-15', '2025-12-15', 'Posted', 'Online', NULL, '2025-12-15'),
(7, 6, 75.00, 1800.00, 'Phone Bill - T-Mobile', 'TXN-2025-D7H8I907', '2025-12-18', '2025-12-18', 'Posted', 'Online', NULL, '2025-12-18'),
(7, 1, 1800.00, 3600.00, 'Payroll Deposit - City Diner', 'TXN-2026-D7H8I908', '2026-01-01', '2026-01-01', 'Posted', 'Online', NULL, '2026-01-01'),
(7, 6, 950.00, 2650.00, 'Monthly Rent Payment', 'TXN-2026-D7H8I909', '2026-01-05', '2026-01-05', 'Posted', 'Online', 'Jan rent', '2026-01-05'),
(7, 6, 320.00, 2330.00, 'Car Insurance - Geico', 'TXN-2026-D7H8I910', '2026-01-10', '2026-01-10', 'Posted', 'Online', NULL, '2026-01-10'),
(7, 2, 200.00, 2130.00, 'ATM Withdrawal - TD Bank ATM', 'TXN-2026-D7H8I911', '2026-01-20', '2026-01-20', 'Posted', 'ATM', NULL, '2026-01-20'),
-- Income becomes irregular / reduced
(7, 1, 1200.00, 3330.00, 'Payroll Deposit - City Diner', 'TXN-2026-D7H8I912', '2026-02-01', '2026-02-01', 'Posted', 'Online', 'Reduced hours', '2026-02-01'),
(7, 6, 950.00, 2380.00, 'Monthly Rent Payment', 'TXN-2026-D7H8I913', '2026-02-05', '2026-02-05', 'Posted', 'Online', 'Feb rent', '2026-02-05'),
(7, 6, 75.00, 2305.00, 'Phone Bill - T-Mobile', 'TXN-2026-D7H8I914', '2026-02-18', '2026-02-18', 'Posted', 'Online', NULL, '2026-02-18'),
(7, 1, 900.00, 3205.00, 'Payroll Deposit - City Diner', 'TXN-2026-D7H8I915', '2026-03-01', '2026-03-01', 'Posted', 'Online', 'Reduced hours', '2026-03-01'),
(7, 6, 950.00, 2255.00, 'Monthly Rent Payment', 'TXN-2026-D7H8I916', '2026-03-05', '2026-03-05', 'Posted', 'Online', 'Mar rent', '2026-03-05'),
(7, 6, 450.00, 1805.00, 'Emergency Car Repair', 'TXN-2026-D7H8I917', '2026-03-15', '2026-03-15', 'Posted', 'Mobile', NULL, '2026-03-15'),
(8, 5, 0.25, 150.50, 'Monthly Interest Payment', 'TXN-2026-D7H8I918', '2026-03-31', '2026-03-31', 'Posted', 'Online', NULL, '2026-03-31'),
-- April: last deposit then decline into overdraft
(7, 1, 900.00, 2705.00, 'Payroll Deposit - City Diner', 'TXN-2026-D7H8I919', '2026-04-01', '2026-04-01', 'Posted', 'Online', 'Final paycheck', '2026-04-01'),
(7, 6, 950.00, 1755.00, 'Monthly Rent Payment', 'TXN-2026-D7H8I920', '2026-04-05', '2026-04-05', 'Posted', 'Online', 'Apr rent', '2026-04-05'),
(7, 6, 320.00, 1435.00, 'Car Insurance - Geico', 'TXN-2026-D7H8I921', '2026-04-10', '2026-04-10', 'Posted', 'Online', NULL, '2026-04-10'),
(7, 2, 1200.00, 235.00, 'Medical Bill Payment', 'TXN-2026-D7H8I922', '2026-04-22', '2026-04-22', 'Posted', 'Online', 'Urgent care visit', '2026-04-22'),
(7, 6, 75.00, 160.00, 'Phone Bill - T-Mobile', 'TXN-2026-D7H8I923', '2026-04-25', '2026-04-25', 'Posted', 'Online', NULL, '2026-04-25'),
-- May: balance goes negative
(7, 6, 950.00, -790.00, 'Monthly Rent Payment', 'TXN-2026-D7H8I924', '2026-05-01', '2026-05-01', 'Posted', 'Online', 'May rent - NSF', '2026-05-01'),
(7, 4, 35.00, -825.00, 'Overdraft Fee', 'TXN-2026-D7H8I925', '2026-05-01', '2026-05-01', 'Posted', 'Online', 'Insufficient funds', '2026-05-01'),
-- Partial recovery attempt
(7, 1, 800.00, -25.00, 'Venmo Transfer from Friend', 'TXN-2026-D7H8I926', '2026-05-05', '2026-05-05', 'Posted', 'Mobile', 'Borrowed funds', '2026-05-05'),
(7, 2, 20.00, -45.00, 'Walgreens #5567', 'TXN-2026-D7H8I927', '2026-05-08', '2026-05-08', 'Posted', 'Mobile', NULL, '2026-05-08');
GO

-- --------------------------------------------------------------------------
-- David Park (AccountID 9=Checking, 10=Savings) ~18 transactions
-- Low activity, some missed payments
-- --------------------------------------------------------------------------
INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel, Memo, CreatedDate)
VALUES
(9, 1, 2400.00, 3500.00, 'Payroll Deposit - Freelance Dev', 'TXN-2025-E9J0K101', '2025-11-20', '2025-11-20', 'Posted', 'Online', NULL, '2025-11-20'),
(9, 6, 1100.00, 2400.00, 'Monthly Rent Payment', 'TXN-2025-E9J0K102', '2025-12-01', '2025-12-01', 'Posted', 'Online', NULL, '2025-12-01'),
(9, 2, 80.00, 2320.00, 'ATM Withdrawal', 'TXN-2025-E9J0K103', '2025-12-10', '2025-12-10', 'Posted', 'ATM', NULL, '2025-12-10'),
(9, 1, 1800.00, 4120.00, 'Freelance Payment - Client A', 'TXN-2025-E9J0K104', '2025-12-22', '2025-12-22', 'Posted', 'Online', NULL, '2025-12-22'),
(9, 6, 1100.00, 3020.00, 'Monthly Rent Payment', 'TXN-2026-E9J0K105', '2026-01-01', '2026-01-01', 'Posted', 'Online', NULL, '2026-01-01'),
(9, 6, 150.00, 2870.00, 'Electric Bill - National Grid', 'TXN-2026-E9J0K106', '2026-01-15', '2026-01-15', 'Posted', 'Online', NULL, '2026-01-15'),
(9, 1, 2400.00, 5270.00, 'Freelance Payment - Client B', 'TXN-2026-E9J0K107', '2026-01-28', '2026-01-28', 'Posted', 'Online', NULL, '2026-01-28'),
(9, 6, 1100.00, 4170.00, 'Monthly Rent Payment', 'TXN-2026-E9J0K108', '2026-02-01', '2026-02-01', 'Posted', 'Online', NULL, '2026-02-01'),
-- Gap in income - missed payment scenario
(9, 6, 1100.00, 3070.00, 'Monthly Rent Payment', 'TXN-2026-E9J0K109', '2026-03-01', '2026-03-01', 'Posted', 'Online', NULL, '2026-03-01'),
(9, 2, 60.00, 3010.00, 'ATM Withdrawal', 'TXN-2026-E9J0K110', '2026-03-05', '2026-03-05', 'Posted', 'ATM', NULL, '2026-03-05'),
(9, 1, 1500.00, 4510.00, 'Freelance Payment - Client A', 'TXN-2026-E9J0K111', '2026-03-20', '2026-03-20', 'Posted', 'Online', 'Partial payment', '2026-03-20'),
(9, 6, 1100.00, 3410.00, 'Monthly Rent Payment', 'TXN-2026-E9J0K112', '2026-04-01', '2026-04-01', 'Posted', 'Online', NULL, '2026-04-01'),
(9, 6, 150.00, 3260.00, 'Electric Bill - National Grid', 'TXN-2026-E9J0K113', '2026-04-10', '2026-04-10', 'Posted', 'Online', NULL, '2026-04-10'),
(9, 2, 200.00, 3060.00, 'ATM Withdrawal', 'TXN-2026-E9J0K114', '2026-04-15', '2026-04-15', 'Posted', 'ATM', NULL, '2026-04-15'),
(9, 1, 1200.00, 4260.00, 'Freelance Payment - Client C', 'TXN-2026-E9J0K115', '2026-04-28', '2026-04-28', 'Posted', 'Online', NULL, '2026-04-28'),
(9, 6, 1100.00, 3160.00, 'Monthly Rent Payment', 'TXN-2026-E9J0K116', '2026-05-01', '2026-05-01', 'Posted', 'Online', NULL, '2026-05-01'),
(10, 5, 1.15, 891.15, 'Monthly Interest Payment', 'TXN-2026-E9J0K117', '2026-04-30', '2026-04-30', 'Posted', 'Online', NULL, '2026-04-30'),
(9, 6, 65.00, 3095.00, 'Spotify + Netflix Subscriptions', 'TXN-2026-E9J0K118', '2026-05-10', NULL, 'Pending', 'Online', NULL, '2026-05-10');
GO

-- --------------------------------------------------------------------------
-- Emily Johnson (AccountID 11=Checking, 12=Savings, 13=Loan) ~28 transactions
-- Active banking + monthly loan payments on account 13
-- --------------------------------------------------------------------------
INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel, Memo, CreatedDate)
VALUES
-- Regular checking activity
(11, 1, 3600.00, 8500.00, 'Payroll Deposit - Metro Health Systems', 'TXN-2025-F1L2M301', '2025-11-15', '2025-11-15', 'Posted', 'Online', NULL, '2025-11-15'),
(11, 6, 1650.00, 6850.00, 'Monthly Rent Payment', 'TXN-2025-F1L2M302', '2025-11-18', '2025-11-18', 'Posted', 'Online', NULL, '2025-11-18'),
(11, 2, 95.00, 6755.00, 'Costco Wholesale #1122', 'TXN-2025-F1L2M303', '2025-11-22', '2025-11-22', 'Posted', 'Mobile', NULL, '2025-11-22'),
(11, 1, 3600.00, 10355.00, 'Payroll Deposit - Metro Health Systems', 'TXN-2025-F1L2M304', '2025-11-30', '2025-11-30', 'Posted', 'Online', NULL, '2025-11-30'),
(13, 6, 485.50, 18014.50, 'Loan Payment - Personal Loan', 'TXN-2025-F1L2M305', '2025-12-01', '2025-12-01', 'Posted', 'Online', 'Dec loan pmt', '2025-12-01'),
(11, 6, 1650.00, 8705.00, 'Monthly Rent Payment', 'TXN-2025-F1L2M306', '2025-12-05', '2025-12-05', 'Posted', 'Online', NULL, '2025-12-05'),
(11, 1, 3600.00, 12305.00, 'Payroll Deposit - Metro Health Systems', 'TXN-2025-F1L2M307', '2025-12-15', '2025-12-15', 'Posted', 'Online', NULL, '2025-12-15'),
(11, 3, 1500.00, 10805.00, 'Transfer to Savings', 'TXN-2025-F1L2M308', '2025-12-16', '2025-12-16', 'Posted', 'Online', NULL, '2025-12-16'),
(12, 1, 1500.00, 23800.00, 'Transfer from Checking', 'TXN-2025-F1L2M309', '2025-12-16', '2025-12-16', 'Posted', 'Online', NULL, '2025-12-16'),
(13, 6, 485.50, 17529.00, 'Loan Payment - Personal Loan', 'TXN-2026-F1L2M310', '2026-01-01', '2026-01-01', 'Posted', 'Online', 'Jan loan pmt', '2026-01-01'),
(11, 1, 3600.00, 14405.00, 'Payroll Deposit - Metro Health Systems', 'TXN-2026-F1L2M311', '2026-01-15', '2026-01-15', 'Posted', 'Online', NULL, '2026-01-15'),
(11, 6, 1650.00, 12755.00, 'Monthly Rent Payment', 'TXN-2026-F1L2M312', '2026-01-18', '2026-01-18', 'Posted', 'Online', NULL, '2026-01-18'),
(11, 2, 200.00, 12555.00, 'ATM Withdrawal - Wells Fargo ATM', 'TXN-2026-F1L2M313', '2026-01-25', '2026-01-25', 'Posted', 'ATM', NULL, '2026-01-25'),
(13, 6, 485.50, 17043.50, 'Loan Payment - Personal Loan', 'TXN-2026-F1L2M314', '2026-02-01', '2026-02-01', 'Posted', 'Online', 'Feb loan pmt', '2026-02-01'),
(11, 1, 3600.00, 16155.00, 'Payroll Deposit - Metro Health Systems', 'TXN-2026-F1L2M315', '2026-02-14', '2026-02-14', 'Posted', 'Online', NULL, '2026-02-14'),
(11, 6, 1650.00, 14505.00, 'Monthly Rent Payment', 'TXN-2026-F1L2M316', '2026-02-18', '2026-02-18', 'Posted', 'Online', NULL, '2026-02-18'),
(11, 6, 135.00, 14370.00, 'Xfinity Internet Bill', 'TXN-2026-F1L2M317', '2026-02-20', '2026-02-20', 'Posted', 'Online', NULL, '2026-02-20'),
(13, 6, 485.50, 16558.00, 'Loan Payment - Personal Loan', 'TXN-2026-F1L2M318', '2026-03-01', '2026-03-01', 'Posted', 'Online', 'Mar loan pmt', '2026-03-01'),
(11, 1, 3600.00, 17970.00, 'Payroll Deposit - Metro Health Systems', 'TXN-2026-F1L2M319', '2026-03-15', '2026-03-15', 'Posted', 'Online', NULL, '2026-03-15'),
(11, 6, 1650.00, 16320.00, 'Monthly Rent Payment', 'TXN-2026-F1L2M320', '2026-03-18', '2026-03-18', 'Posted', 'Online', NULL, '2026-03-18'),
(13, 6, 485.50, 16072.50, 'Loan Payment - Personal Loan', 'TXN-2026-F1L2M321', '2026-04-01', '2026-04-01', 'Posted', 'Online', 'Apr loan pmt', '2026-04-01'),
(11, 1, 3600.00, 19920.00, 'Payroll Deposit - Metro Health Systems', 'TXN-2026-F1L2M322', '2026-04-15', '2026-04-15', 'Posted', 'Online', NULL, '2026-04-15'),
(11, 6, 1650.00, 18270.00, 'Monthly Rent Payment', 'TXN-2026-F1L2M323', '2026-04-18', '2026-04-18', 'Posted', 'Online', NULL, '2026-04-18'),
(11, 3, 2000.00, 16270.00, 'Transfer to Savings', 'TXN-2026-F1L2M324', '2026-04-20', '2026-04-20', 'Posted', 'Online', NULL, '2026-04-20'),
(12, 1, 2000.00, 25800.00, 'Transfer from Checking', 'TXN-2026-F1L2M325', '2026-04-20', '2026-04-20', 'Posted', 'Online', NULL, '2026-04-20'),
(12, 5, 28.50, 25828.50, 'Monthly Interest Payment', 'TXN-2026-F1L2M326', '2026-04-30', '2026-04-30', 'Posted', 'Online', NULL, '2026-04-30'),
(13, 6, 485.50, 15587.00, 'Loan Payment - Personal Loan', 'TXN-2026-F1L2M327', '2026-05-01', '2026-05-01', 'Posted', 'Online', 'May loan pmt', '2026-05-01'),
(11, 1, 3600.00, 19870.00, 'Payroll Deposit - Metro Health Systems', 'TXN-2026-F1L2M328', '2026-05-09', NULL, 'Pending', 'Online', NULL, '2026-05-09');
GO

-- ============================================================================
-- PART 2: Bulk transaction generation (~1,800 rows for accounts 14-120)
-- ============================================================================

DECLARE @i INT = 1;
DECLARE @AccountID INT;
DECLARE @TxnTypeID INT;
DECLARE @Amount DECIMAL(18,2);
DECLARE @TxnDate DATETIME;
DECLARE @Channel NVARCHAR(20);
DECLARE @Desc NVARCHAR(500);
DECLARE @RefNum NVARCHAR(50);
DECLARE @BalAfter DECIMAL(18,2);

WHILE @i <= 1800
BEGIN
    SET @AccountID = 14 + ABS(CHECKSUM(NEWID())) % 107;

    SET @TxnTypeID = CASE ABS(CHECKSUM(NEWID())) % 10
        WHEN 0 THEN 1  -- DEP
        WHEN 1 THEN 1  -- DEP
        WHEN 2 THEN 1  -- DEP
        WHEN 3 THEN 2  -- WDR
        WHEN 4 THEN 2  -- WDR
        WHEN 5 THEN 3  -- TRF
        WHEN 6 THEN 6  -- PMT
        WHEN 7 THEN 6  -- PMT
        WHEN 8 THEN 4  -- FEE
        WHEN 9 THEN 5  -- INT
    END;

    SET @Amount = CASE @TxnTypeID
        WHEN 1 THEN ROUND(100 + ABS(CHECKSUM(NEWID())) % 4900 + (ABS(CHECKSUM(NEWID())) % 100) / 100.0, 2)
        WHEN 2 THEN ROUND(20 + ABS(CHECKSUM(NEWID())) % 980 + (ABS(CHECKSUM(NEWID())) % 100) / 100.0, 2)
        WHEN 3 THEN ROUND(50 + ABS(CHECKSUM(NEWID())) % 2950 + (ABS(CHECKSUM(NEWID())) % 100) / 100.0, 2)
        WHEN 4 THEN ROUND(5 + ABS(CHECKSUM(NEWID())) % 45 + (ABS(CHECKSUM(NEWID())) % 100) / 100.0, 2)
        WHEN 5 THEN ROUND(1 + ABS(CHECKSUM(NEWID())) % 99 + (ABS(CHECKSUM(NEWID())) % 100) / 100.0, 2)
        WHEN 6 THEN ROUND(25 + ABS(CHECKSUM(NEWID())) % 475 + (ABS(CHECKSUM(NEWID())) % 100) / 100.0, 2)
    END;

    SET @TxnDate = DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 182), '2026-05-14');

    SET @Channel = CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'Online'
        WHEN 1 THEN 'ATM'
        WHEN 2 THEN 'Branch'
        WHEN 3 THEN 'Mobile'
        WHEN 4 THEN 'Wire'
    END;

    SET @Desc = CASE @TxnTypeID
        WHEN 1 THEN CASE ABS(CHECKSUM(NEWID())) % 4 WHEN 0 THEN 'Payroll Direct Deposit' WHEN 1 THEN 'ACH Deposit' WHEN 2 THEN 'Cash Deposit' ELSE 'Check Deposit' END
        WHEN 2 THEN CASE ABS(CHECKSUM(NEWID())) % 3 WHEN 0 THEN 'ATM Withdrawal' WHEN 1 THEN 'Counter Withdrawal' ELSE 'Cash Back' END
        WHEN 3 THEN 'Account Transfer'
        WHEN 4 THEN CASE ABS(CHECKSUM(NEWID())) % 3 WHEN 0 THEN 'Monthly Maintenance Fee' WHEN 1 THEN 'Overdraft Fee' ELSE 'Wire Transfer Fee' END
        WHEN 5 THEN 'Interest Payment'
        WHEN 6 THEN CASE ABS(CHECKSUM(NEWID())) % 4 WHEN 0 THEN 'Utility Payment' WHEN 1 THEN 'Insurance Premium' WHEN 2 THEN 'Rent Payment' ELSE 'Bill Payment' END
    END;

    SET @RefNum = 'TXN-' + FORMAT(@TxnDate, 'yyyy') + '-' + RIGHT('00000000' + CAST(@i + 200 AS NVARCHAR), 8);
    SET @BalAfter = ROUND(500 + ABS(CHECKSUM(NEWID())) % 15000 + (ABS(CHECKSUM(NEWID())) % 100) / 100.0, 2);

    INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel, Memo, CreatedDate)
    VALUES (@AccountID, @TxnTypeID, @Amount, @BalAfter, @Desc, @RefNum, @TxnDate, @TxnDate, 'Posted', @Channel, NULL, @TxnDate);

    SET @i = @i + 1;
END;
GO

-- ============================================================================
-- PART 3: TransactionArchive (~500 rows, May 2025 - October 2025)
-- ============================================================================

SET IDENTITY_INSERT TransactionArchive ON;

DECLARE @j INT = 1;
DECLARE @ArcAccountID INT;
DECLARE @ArcTxnTypeID INT;
DECLARE @ArcAmount DECIMAL(18,2);
DECLARE @ArcTxnDate DATETIME;
DECLARE @ArcBalAfter DECIMAL(18,2);
DECLARE @ArcChannel NVARCHAR(20);
DECLARE @ArcDesc NVARCHAR(500);

WHILE @j <= 500
BEGIN
    SET @ArcAccountID = 1 + ABS(CHECKSUM(NEWID())) % 120;

    SET @ArcTxnTypeID = CASE ABS(CHECKSUM(NEWID())) % 7
        WHEN 0 THEN 1
        WHEN 1 THEN 1
        WHEN 2 THEN 2
        WHEN 3 THEN 2
        WHEN 4 THEN 3
        WHEN 5 THEN 6
        ELSE 5
    END;

    SET @ArcAmount = ROUND(10 + ABS(CHECKSUM(NEWID())) % 4990 + (ABS(CHECKSUM(NEWID())) % 100) / 100.0, 2);
    SET @ArcTxnDate = DATEADD(DAY, -(182 + ABS(CHECKSUM(NEWID())) % 183), '2026-05-14');
    SET @ArcBalAfter = ROUND(200 + ABS(CHECKSUM(NEWID())) % 20000 + (ABS(CHECKSUM(NEWID())) % 100) / 100.0, 2);

    SET @ArcChannel = CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'Online'
        WHEN 1 THEN 'ATM'
        WHEN 2 THEN 'Branch'
        WHEN 3 THEN 'Mobile'
        ELSE 'Wire'
    END;

    SET @ArcDesc = CASE @ArcTxnTypeID
        WHEN 1 THEN 'Archived Deposit'
        WHEN 2 THEN 'Archived Withdrawal'
        WHEN 3 THEN 'Archived Transfer'
        WHEN 5 THEN 'Archived Interest'
        WHEN 6 THEN 'Archived Payment'
        ELSE 'Archived Transaction'
    END;

    INSERT INTO TransactionArchive (ArchiveID, TransactionID, AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel, ArchivedDate, ArchiveReason)
    VALUES (@j, 100000 + @j, @ArcAccountID, @ArcTxnTypeID, @ArcAmount, @ArcBalAfter, @ArcDesc,
            'ARC-' + FORMAT(@ArcTxnDate, 'yyyy') + '-' + RIGHT('00000000' + CAST(@j AS NVARCHAR), 8),
            @ArcTxnDate, @ArcTxnDate, 'Posted', @ArcChannel, DATEADD(DAY, 30, @ArcTxnDate), 'Aging');

    SET @j = @j + 1;
END;

SET IDENTITY_INSERT TransactionArchive OFF;
GO

PRINT 'Transactions and archive seeded successfully.';
GO
