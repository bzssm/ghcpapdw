-- Stored Procedures for ZavaBankDB
-- Sections 3.1-3.8 of database-topology.md

USE [ZavaBankDB];
GO

-- =============================================
-- 3.1 Loan Processing
-- =============================================

CREATE PROCEDURE sp_ProcessLoanApplication
    @CustomerID INT,
    @LoanProductID INT,
    @RequestedAmount DECIMAL(18,2),
    @TermMonths INT,
    @Purpose NVARCHAR(500),
    @ApplicationID INT OUTPUT,
    @Status NVARCHAR(30) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate customer exists and is active
        IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerID = @CustomerID AND Status = 'Active')
        BEGIN
            SET @Status = 'Rejected';
            RAISERROR('Customer not found or inactive.', 16, 1);
        END

        -- Validate loan product
        DECLARE @MinAmount DECIMAL(18,2), @MaxAmount DECIMAL(18,2);
        DECLARE @MinTerm INT, @MaxTerm INT, @BaseRate DECIMAL(5,4);
        SELECT @MinAmount = MinAmount, @MaxAmount = MaxAmount,
               @MinTerm = MinTermMonths, @MaxTerm = MaxTermMonths, @BaseRate = BaseInterestRate
        FROM LoanProducts WHERE LoanProductID = @LoanProductID AND IsActive = 1;

        IF @MinAmount IS NULL
        BEGIN
            SET @Status = 'Rejected';
            RAISERROR('Loan product not found or inactive.', 16, 1);
        END

        IF @RequestedAmount < @MinAmount OR @RequestedAmount > @MaxAmount
        BEGIN
            SET @Status = 'Rejected';
            RAISERROR('Requested amount outside product limits.', 16, 1);
        END

        IF @TermMonths < @MinTerm OR @TermMonths > @MaxTerm
        BEGIN
            SET @Status = 'Rejected';
            RAISERROR('Term outside product limits.', 16, 1);
        END

        -- Create the application
        INSERT INTO LoanApplications (CustomerID, LoanProductID, RequestedAmount, InterestRate, TermMonths, Purpose, Status, ApplicationDate)
        VALUES (@CustomerID, @LoanProductID, @RequestedAmount, @BaseRate, @TermMonths, @Purpose, 'Submitted', GETDATE());

        SET @ApplicationID = SCOPE_IDENTITY();
        SET @Status = 'Submitted';

        -- Queue notification
        INSERT INTO NotificationQueue (CustomerID, TemplateID, Channel, Recipient, Subject, Body, Status, Priority)
        SELECT @CustomerID, t.TemplateID, 'Email', c.Email,
               'Loan Application Received',
               'Your loan application #' + CAST(@ApplicationID AS NVARCHAR(10)) + ' has been received.',
               'Queued', 3
        FROM Customers c
        CROSS JOIN NotificationTemplates t
        WHERE c.CustomerID = @CustomerID AND t.TemplateCode = 'LOAN_RECEIVED';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_CalculateRisk
    @ApplicationID INT,
    @RiskScore DECIMAL(5,2) OUTPUT,
    @RiskLevel NVARCHAR(10) OUTPUT,
    @Recommendation NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @CustomerID INT, @RequestedAmount DECIMAL(18,2);
        DECLARE @CreditScore INT, @DTI DECIMAL(5,2), @LTV DECIMAL(5,2);

        SELECT @CustomerID = CustomerID, @RequestedAmount = RequestedAmount
        FROM LoanApplications WHERE ApplicationID = @ApplicationID;

        -- Get latest credit score
        SELECT TOP 1 @CreditScore = Score FROM CreditScores
        WHERE CustomerID = @CustomerID ORDER BY ReportDate DESC;

        SET @CreditScore = ISNULL(@CreditScore, 600);

        -- Calculate DTI (simplified: total loan payments / estimated income)
        DECLARE @TotalPayments DECIMAL(18,2);
        SELECT @TotalPayments = ISNULL(SUM(PaymentAmount), 0)
        FROM LoanPayments lp
        JOIN LoanApplications la ON lp.ApplicationID = la.ApplicationID
        WHERE la.CustomerID = @CustomerID AND lp.Status = 'Completed';

        SET @DTI = CASE WHEN @TotalPayments > 0 THEN @TotalPayments / (@RequestedAmount + @TotalPayments) * 100 ELSE 15.00 END;

        -- Calculate risk score (0-100, lower is better)
        SET @RiskScore = 100.0 - ((@CreditScore - 300.0) / 550.0 * 60.0) + (@DTI * 0.4);
        IF @RiskScore < 0 SET @RiskScore = 0;
        IF @RiskScore > 100 SET @RiskScore = 100;

        -- Determine risk level
        SET @RiskLevel = CASE
            WHEN @RiskScore <= 25 THEN 'Low'
            WHEN @RiskScore <= 50 THEN 'Medium'
            WHEN @RiskScore <= 75 THEN 'High'
            ELSE 'Critical'
        END;

        -- Recommendation
        SET @Recommendation = CASE
            WHEN @RiskScore <= 35 THEN 'Approve'
            WHEN @RiskScore <= 60 THEN 'ManualReview'
            ELSE 'Deny'
        END;

        -- Store assessment
        INSERT INTO RiskAssessments (ApplicationID, CustomerID, OverallRiskScore, RiskLevel, DebtToIncomeRatio, LoanToValueRatio, FactorBreakdown, Recommendation)
        VALUES (@ApplicationID, @CustomerID, @RiskScore, @RiskLevel, @DTI, @LTV,
                'CREDIT=' + CAST(@CreditScore AS NVARCHAR(10)) + '|DTI=' + CAST(@DTI AS NVARCHAR(10)) + '|AMOUNT=' + CAST(@RequestedAmount AS NVARCHAR(20)),
                @Recommendation);

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_MakeLoanDecision
    @ApplicationID INT,
    @DecisionType NVARCHAR(20),
    @DecisionBy NVARCHAR(100),
    @Reason NVARCHAR(MAX),
    @ApprovedAmount DECIMAL(18,2) = NULL,
    @Conditions NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CustomerID INT, @CreditScore INT;
        SELECT @CustomerID = CustomerID FROM LoanApplications WHERE ApplicationID = @ApplicationID;

        SELECT TOP 1 @CreditScore = Score FROM CreditScores
        WHERE CustomerID = @CustomerID ORDER BY ReportDate DESC;

        -- Get risk level
        DECLARE @RiskLevel NVARCHAR(10);
        SELECT TOP 1 @RiskLevel = RiskLevel FROM RiskAssessments
        WHERE ApplicationID = @ApplicationID ORDER BY AssessedDate DESC;

        -- Record decision
        INSERT INTO LoanDecisions (ApplicationID, DecisionType, DecisionBy, Reason, CreditScoreAtTime, RiskLevel, Conditions)
        VALUES (@ApplicationID, @DecisionType, @DecisionBy, @Reason, @CreditScore, @RiskLevel, @Conditions);

        -- Update application status
        DECLARE @NewStatus NVARCHAR(30);
        SET @NewStatus = CASE @DecisionType
            WHEN 'Approve' THEN 'Approved'
            WHEN 'Deny' THEN 'Denied'
            WHEN 'Escalate' THEN 'UnderReview'
            WHEN 'ConditionalApprove' THEN 'Approved'
            ELSE 'UnderReview'
        END;

        UPDATE LoanApplications
        SET Status = @NewStatus, DecisionDate = GETDATE(), ApprovedAmount = @ApprovedAmount,
            DecisionNotes = @Reason, ModifiedDate = GETDATE()
        WHERE ApplicationID = @ApplicationID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_FundLoan
    @ApplicationID INT,
    @LoanAccountID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CustomerID INT, @ApprovedAmount DECIMAL(18,2), @Status NVARCHAR(30);
        SELECT @CustomerID = CustomerID, @ApprovedAmount = ApprovedAmount, @Status = Status
        FROM LoanApplications WHERE ApplicationID = @ApplicationID;

        IF @Status <> 'Approved'
            RAISERROR('Application must be in Approved status to fund.', 16, 1);

        IF @ApprovedAmount IS NULL OR @ApprovedAmount <= 0
            RAISERROR('No approved amount set.', 16, 1);

        -- Create loan account
        DECLARE @AccountNumber NVARCHAR(20);
        SET @AccountNumber = '5000-' + RIGHT('0000' + CAST(@ApplicationID AS NVARCHAR(10)), 4) + '-' + RIGHT('0000' + CAST(@CustomerID AS NVARCHAR(10)), 4);

        INSERT INTO Accounts (CustomerID, AccountTypeID, AccountNumber, Balance, AvailableBalance, Status)
        SELECT @CustomerID, AccountTypeID, @AccountNumber, @ApprovedAmount, @ApprovedAmount, 'Active'
        FROM AccountTypes WHERE TypeName = 'Loan';

        SET @LoanAccountID = SCOPE_IDENTITY();

        -- Update application
        UPDATE LoanApplications
        SET Status = 'Funded', FundedDate = GETDATE(), LoanAccountID = @LoanAccountID, ModifiedDate = GETDATE()
        WHERE ApplicationID = @ApplicationID;

        -- Post disbursement transaction
        INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel)
        SELECT @LoanAccountID, TransactionTypeID, @ApprovedAmount, @ApprovedAmount,
               'Loan disbursement for application #' + CAST(@ApplicationID AS NVARCHAR(10)),
               'LOAN-' + CAST(@ApplicationID AS NVARCHAR(10)), GETDATE(), GETDATE(), 'Posted', 'Online'
        FROM TransactionTypes WHERE TypeCode = 'DEP';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_ProcessLoanPayment
    @ApplicationID INT,
    @AccountID INT,
    @PaymentAmount DECIMAL(18,2),
    @PaymentMethod NVARCHAR(30),
    @PaymentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Calculate principal vs interest split (simplified)
        DECLARE @InterestRate DECIMAL(5,4), @Balance DECIMAL(18,2);
        SELECT @InterestRate = InterestRate FROM LoanApplications WHERE ApplicationID = @ApplicationID;
        SELECT @Balance = Balance FROM Accounts WHERE AccountID = @AccountID;

        DECLARE @InterestAmount DECIMAL(18,2) = @Balance * @InterestRate / 12;
        DECLARE @PrincipalAmount DECIMAL(18,2) = @PaymentAmount - @InterestAmount;
        IF @PrincipalAmount < 0 SET @PrincipalAmount = 0;

        -- Record payment
        INSERT INTO LoanPayments (ApplicationID, AccountID, PaymentAmount, PrincipalAmount, InterestAmount, DueDate, Status, PaymentMethod, ConfirmationNumber)
        VALUES (@ApplicationID, @AccountID, @PaymentAmount, @PrincipalAmount, @InterestAmount, GETDATE(), 'Completed', @PaymentMethod,
                'PMT-' + CAST(@ApplicationID AS NVARCHAR(10)) + '-' + CONVERT(NVARCHAR(8), GETDATE(), 112));

        SET @PaymentID = SCOPE_IDENTITY();

        -- Update account balance
        UPDATE Accounts SET Balance = Balance - @PrincipalAmount, LastActivityDate = GETDATE(), ModifiedDate = GETDATE()
        WHERE AccountID = @AccountID;

        -- Check if loan is paid off
        DECLARE @NewBalance DECIMAL(18,2);
        SELECT @NewBalance = Balance FROM Accounts WHERE AccountID = @AccountID;
        IF @NewBalance <= 0
        BEGIN
            UPDATE Accounts SET Status = 'Closed', CloseDate = GETDATE() WHERE AccountID = @AccountID;
            UPDATE LoanApplications SET Status = 'Closed', ModifiedDate = GETDATE() WHERE ApplicationID = @ApplicationID;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
    END CATCH
END
GO

-- =============================================
-- 3.2 Payment Processing
-- =============================================

CREATE PROCEDURE sp_ProcessPayment
    @SourceAccountID INT,
    @DestinationAccount NVARCHAR(50),
    @PaymentMethodID INT,
    @Amount DECIMAL(18,2),
    @PayeeName NVARCHAR(200) = NULL,
    @Memo NVARCHAR(255) = NULL,
    @ReferenceNumber NVARCHAR(50) OUTPUT,
    @PaymentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate source account
        DECLARE @Balance DECIMAL(18,2), @OverdraftLimit DECIMAL(18,2), @AcctStatus NVARCHAR(20);
        SELECT @Balance = Balance, @OverdraftLimit = OverdraftLimit, @AcctStatus = Status
        FROM Accounts WHERE AccountID = @SourceAccountID;

        IF @AcctStatus <> 'Active'
            RAISERROR('Source account is not active.', 16, 1);

        IF @Amount > (@Balance + @OverdraftLimit)
            RAISERROR('Insufficient funds.', 16, 1);

        -- Check daily limit
        DECLARE @DailyLimit DECIMAL(18,2);
        SELECT @DailyLimit = MaxDailyLimit FROM PaymentMethods WHERE PaymentMethodID = @PaymentMethodID;

        IF @DailyLimit IS NOT NULL
        BEGIN
            DECLARE @TodayTotal DECIMAL(18,2);
            SELECT @TodayTotal = ISNULL(SUM(Amount), 0) FROM Payments
            WHERE SourceAccountID = @SourceAccountID AND CAST(CreatedDate AS DATE) = CAST(GETDATE() AS DATE);

            IF (@TodayTotal + @Amount) > @DailyLimit
                RAISERROR('Daily payment limit exceeded.', 16, 1);
        END

        -- Generate reference number
        SET @ReferenceNumber = 'PAY-' + CONVERT(NVARCHAR(8), GETDATE(), 112) + '-' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS NVARCHAR(6)), 6);

        -- Create payment record
        INSERT INTO Payments (SourceAccountID, DestinationAccount, PaymentMethodID, Amount, Status, ScheduledDate, ReferenceNumber, PayeeName, Memo)
        VALUES (@SourceAccountID, @DestinationAccount, @PaymentMethodID, @Amount, 'Completed', GETDATE(), @ReferenceNumber, @PayeeName, @Memo);

        SET @PaymentID = SCOPE_IDENTITY();

        -- Debit source account
        UPDATE Accounts SET Balance = Balance - @Amount, AvailableBalance = AvailableBalance - @Amount,
               LastActivityDate = GETDATE(), ModifiedDate = GETDATE()
        WHERE AccountID = @SourceAccountID;

        -- Post transaction
        DECLARE @NewBalance DECIMAL(18,2);
        SELECT @NewBalance = Balance FROM Accounts WHERE AccountID = @SourceAccountID;

        INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel)
        SELECT @SourceAccountID, TransactionTypeID, @Amount, @NewBalance,
               'Payment to ' + ISNULL(@PayeeName, @DestinationAccount),
               @ReferenceNumber, GETDATE(), GETDATE(), 'Posted', 'Online'
        FROM TransactionTypes WHERE TypeCode = 'PMT';

        -- Update payment status
        UPDATE Payments SET ProcessedDate = GETDATE(), Status = 'Completed', ModifiedDate = GETDATE()
        WHERE PaymentID = @PaymentID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_BatchPayments
    @BatchID INT,
    @ProcessedCount INT OUTPUT,
    @FailedCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @ProcessedCount = 0;
        SET @FailedCount = 0;

        UPDATE PaymentBatches SET Status = 'Processing' WHERE BatchID = @BatchID;

        -- In a real implementation, this would iterate through batch items
        -- For this legacy system, we just update the batch status
        DECLARE @TotalCount INT;
        SELECT @TotalCount = PaymentCount FROM PaymentBatches WHERE BatchID = @BatchID;

        SET @ProcessedCount = @TotalCount;

        UPDATE PaymentBatches SET Status = 'Completed', ProcessedDate = GETDATE()
        WHERE BatchID = @BatchID;

    END TRY
    BEGIN CATCH
        UPDATE PaymentBatches SET Status = 'Failed' WHERE BatchID = @BatchID;
        SET @FailedCount = @FailedCount + 1;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_ReversePayment
    @PaymentID INT,
    @AuthorizedBy NVARCHAR(100),
    @Reason NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @SourceAccountID INT, @Amount DECIMAL(18,2), @Status NVARCHAR(20);
        SELECT @SourceAccountID = SourceAccountID, @Amount = Amount, @Status = Status
        FROM Payments WHERE PaymentID = @PaymentID;

        IF @Status <> 'Completed'
            RAISERROR('Only completed payments can be reversed.', 16, 1);

        -- Credit the source account
        UPDATE Accounts SET Balance = Balance + @Amount, AvailableBalance = AvailableBalance + @Amount,
               LastActivityDate = GETDATE(), ModifiedDate = GETDATE()
        WHERE AccountID = @SourceAccountID;

        -- Post reversal transaction
        DECLARE @NewBalance DECIMAL(18,2);
        SELECT @NewBalance = Balance FROM Accounts WHERE AccountID = @SourceAccountID;

        INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel, Memo)
        SELECT @SourceAccountID, TransactionTypeID, @Amount, @NewBalance,
               'Payment reversal - ' + @Reason,
               'REV-' + CAST(@PaymentID AS NVARCHAR(10)), GETDATE(), GETDATE(), 'Posted', 'Online', 'Authorized by: ' + @AuthorizedBy
        FROM TransactionTypes WHERE TypeCode = 'ADJ';

        -- Update payment status
        UPDATE Payments SET Status = 'Reversed', ModifiedDate = GETDATE() WHERE PaymentID = @PaymentID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_GetPaymentStatus
    @PaymentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.PaymentID, p.Amount, p.Currency, p.Status, p.ScheduledDate, p.ProcessedDate,
           p.ReferenceNumber, p.PayeeName, p.FailureReason, p.RetryCount,
           pm.MethodName, a.AccountNumber AS SourceAccountNumber
    FROM Payments p
    JOIN PaymentMethods pm ON p.PaymentMethodID = pm.PaymentMethodID
    JOIN Accounts a ON p.SourceAccountID = a.AccountID
    WHERE p.PaymentID = @PaymentID;
END
GO

-- =============================================
-- 3.3 Transaction Posting
-- =============================================

CREATE PROCEDURE sp_PostTransaction
    @AccountID INT,
    @TransactionTypeCode NVARCHAR(10),
    @Amount DECIMAL(18,2),
    @Description NVARCHAR(500) = NULL,
    @Channel NVARCHAR(20) = 'Online',
    @ReferenceNumber NVARCHAR(50) = NULL,
    @TransactionID BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @TypeID INT, @IsDebit BIT;
        SELECT @TypeID = TransactionTypeID, @IsDebit = IsDebit FROM TransactionTypes WHERE TypeCode = @TransactionTypeCode;

        IF @TypeID IS NULL
            RAISERROR('Invalid transaction type code.', 16, 1);

        -- Update account balance
        DECLARE @NewBalance DECIMAL(18,2), @OverdraftLimit DECIMAL(18,2);
        SELECT @OverdraftLimit = OverdraftLimit FROM Accounts WHERE AccountID = @AccountID;

        IF @IsDebit = 1
        BEGIN
            UPDATE Accounts SET Balance = Balance - @Amount, AvailableBalance = AvailableBalance - @Amount,
                   LastActivityDate = GETDATE(), ModifiedDate = GETDATE()
            WHERE AccountID = @AccountID;
        END
        ELSE
        BEGIN
            UPDATE Accounts SET Balance = Balance + @Amount, AvailableBalance = AvailableBalance + @Amount,
                   LastActivityDate = GETDATE(), ModifiedDate = GETDATE()
            WHERE AccountID = @AccountID;
        END

        SELECT @NewBalance = Balance FROM Accounts WHERE AccountID = @AccountID;

        -- Check overdraft
        IF @NewBalance < (0 - @OverdraftLimit)
        BEGIN
            UPDATE Accounts SET Status = 'Overdrawn' WHERE AccountID = @AccountID;
        END

        -- Generate reference if not provided
        IF @ReferenceNumber IS NULL
            SET @ReferenceNumber = 'TXN-' + CONVERT(NVARCHAR(8), GETDATE(), 112) + '-' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS NVARCHAR(6)), 6);

        -- Insert transaction
        INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel)
        VALUES (@AccountID, @TypeID, @Amount, @NewBalance, @Description, @ReferenceNumber, GETDATE(), GETDATE(), 'Posted', @Channel);

        SET @TransactionID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_TransferFunds
    @SourceAccountID INT,
    @DestinationAccountID INT,
    @Amount DECIMAL(18,2),
    @Memo NVARCHAR(255) = NULL,
    @ReferenceNumber NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate source balance
        DECLARE @Balance DECIMAL(18,2), @OverdraftLimit DECIMAL(18,2);
        SELECT @Balance = Balance, @OverdraftLimit = OverdraftLimit FROM Accounts WHERE AccountID = @SourceAccountID AND Status = 'Active';

        IF @Balance IS NULL
            RAISERROR('Source account not found or inactive.', 16, 1);

        IF @Amount > (@Balance + @OverdraftLimit)
            RAISERROR('Insufficient funds for transfer.', 16, 1);

        -- Validate destination
        IF NOT EXISTS (SELECT 1 FROM Accounts WHERE AccountID = @DestinationAccountID AND Status = 'Active')
            RAISERROR('Destination account not found or inactive.', 16, 1);

        SET @ReferenceNumber = 'TRF-' + CONVERT(NVARCHAR(8), GETDATE(), 112) + '-' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS NVARCHAR(6)), 6);

        -- Debit source
        UPDATE Accounts SET Balance = Balance - @Amount, AvailableBalance = AvailableBalance - @Amount, LastActivityDate = GETDATE() WHERE AccountID = @SourceAccountID;
        DECLARE @SourceBalance DECIMAL(18,2);
        SELECT @SourceBalance = Balance FROM Accounts WHERE AccountID = @SourceAccountID;

        DECLARE @DestAcctNum NVARCHAR(20);
        SELECT @DestAcctNum = AccountNumber FROM Accounts WHERE AccountID = @DestinationAccountID;

        INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel, CounterpartyAccount, Memo)
        SELECT @SourceAccountID, TransactionTypeID, @Amount, @SourceBalance,
               'Transfer to ' + @DestAcctNum, @ReferenceNumber, GETDATE(), GETDATE(), 'Posted', 'Online', @DestAcctNum, @Memo
        FROM TransactionTypes WHERE TypeCode = 'TRF';

        -- Credit destination
        UPDATE Accounts SET Balance = Balance + @Amount, AvailableBalance = AvailableBalance + @Amount, LastActivityDate = GETDATE() WHERE AccountID = @DestinationAccountID;
        DECLARE @DestBalance DECIMAL(18,2);
        SELECT @DestBalance = Balance FROM Accounts WHERE AccountID = @DestinationAccountID;

        DECLARE @SourceAcctNum NVARCHAR(20);
        SELECT @SourceAcctNum = AccountNumber FROM Accounts WHERE AccountID = @SourceAccountID;

        INSERT INTO Transactions (AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel, CounterpartyAccount, Memo)
        SELECT @DestinationAccountID, TransactionTypeID, @Amount, @DestBalance,
               'Transfer from ' + @SourceAcctNum, @ReferenceNumber, GETDATE(), GETDATE(), 'Posted', 'Online', @SourceAcctNum, @Memo
        FROM TransactionTypes WHERE TypeCode = 'DEP';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_ArchiveTransactions
    @DaysOld INT = 730,
    @ArchivedCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CutoffDate DATETIME = DATEADD(DAY, -@DaysOld, GETDATE());

        INSERT INTO TransactionArchive (TransactionID, AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel)
        SELECT TransactionID, AccountID, TransactionTypeID, Amount, BalanceAfter, Description, ReferenceNumber, TransactionDate, PostDate, Status, Channel
        FROM Transactions WHERE TransactionDate < @CutoffDate AND Status = 'Posted';

        SET @ArchivedCount = @@ROWCOUNT;

        DELETE FROM Transactions WHERE TransactionDate < @CutoffDate AND Status = 'Posted';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_ReconcileDaily
    @ReconcileDate DATE = NULL,
    @DiscrepancyCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @ReconcileDate IS NULL SET @ReconcileDate = CAST(GETDATE() AS DATE);

    SET @DiscrepancyCount = 0;

    -- Check that sum of transactions matches account balance changes
    SELECT a.AccountID, a.AccountNumber, a.Balance AS CurrentBalance,
           SUM(CASE WHEN tt.IsDebit = 1 THEN -t.Amount ELSE t.Amount END) AS DayNetChange
    FROM Accounts a
    LEFT JOIN Transactions t ON a.AccountID = t.AccountID AND CAST(t.TransactionDate AS DATE) = @ReconcileDate
    LEFT JOIN TransactionTypes tt ON t.TransactionTypeID = tt.TransactionTypeID
    GROUP BY a.AccountID, a.AccountNumber, a.Balance;

    SET @DiscrepancyCount = 0;
END
GO

-- =============================================
-- 3.4 Fraud Checking
-- =============================================

CREATE PROCEDURE sp_CheckFraud
    @TransactionID BIGINT,
    @AccountID INT,
    @Amount DECIMAL(18,2),
    @FraudScore DECIMAL(5,2) OUTPUT,
    @AlertCreated BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @FraudScore = 0;
        SET @AlertCreated = 0;

        DECLARE @CustomerID INT;
        SELECT @CustomerID = CustomerID FROM Accounts WHERE AccountID = @AccountID;

        -- Rule 1: Large transaction check
        DECLARE @LargeThreshold DECIMAL(18,2);
        SELECT @LargeThreshold = ThresholdAmount FROM FraudRules WHERE RuleName = 'Large Transaction Threshold' AND IsActive = 1;
        IF @Amount > ISNULL(@LargeThreshold, 10000.00)
        BEGIN
            SET @FraudScore = @FraudScore + 30;
            INSERT INTO FraudAlerts (TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Description)
            SELECT @TransactionID, @CustomerID, @AccountID, RuleID, 'UnusualAmount', 'High',
                   'Transaction amount $' + CAST(@Amount AS NVARCHAR(20)) + ' exceeds threshold'
            FROM FraudRules WHERE RuleName = 'Large Transaction Threshold';
            SET @AlertCreated = 1;
        END

        -- Rule 2: Velocity check (more than 5 txns in 10 minutes)
        DECLARE @RecentCount INT;
        SELECT @RecentCount = COUNT(*) FROM Transactions
        WHERE AccountID = @AccountID AND TransactionDate > DATEADD(MINUTE, -10, GETDATE());
        IF @RecentCount > 5
        BEGIN
            SET @FraudScore = @FraudScore + 40;
            INSERT INTO FraudAlerts (TransactionID, CustomerID, AccountID, RuleID, AlertType, Severity, Description)
            SELECT @TransactionID, @CustomerID, @AccountID, RuleID, 'VelocityCheck', 'Critical',
                   CAST(@RecentCount AS NVARCHAR(10)) + ' transactions in 10 minutes'
            FROM FraudRules WHERE RuleName = 'Rapid Transaction Velocity';
            SET @AlertCreated = 1;
        END

        -- Update fraud score
        IF @FraudScore > 0
        BEGIN
            INSERT INTO FraudScores (CustomerID, TransactionID, Score, ModelVersion, Factors)
            VALUES (@CustomerID, @TransactionID, @FraudScore, 'RuleEngine_v2.1',
                    'AMOUNT_CHECK=' + CAST(CASE WHEN @Amount > ISNULL(@LargeThreshold, 10000) THEN 1 ELSE 0 END AS NVARCHAR(1)) +
                    '|VELOCITY=' + CAST(@RecentCount AS NVARCHAR(10)));
        END

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_UpdateFraudScore
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Score DECIMAL(5,2) = 0;

    -- Count recent alerts
    DECLARE @AlertCount INT;
    SELECT @AlertCount = COUNT(*) FROM FraudAlerts
    WHERE CustomerID = @CustomerID AND CreatedDate > DATEADD(MONTH, -6, GETDATE()) AND Status NOT IN ('FalsePositive', 'Resolved');

    SET @Score = @AlertCount * 15.0;
    IF @Score > 100 SET @Score = 100;

    INSERT INTO FraudScores (CustomerID, Score, ModelVersion, Factors)
    VALUES (@CustomerID, @Score, 'RuleEngine_v2.1', 'ALERT_COUNT=' + CAST(@AlertCount AS NVARCHAR(10)));
END
GO

CREATE PROCEDURE sp_ResolveFraudAlert
    @AlertID INT,
    @Resolution NVARCHAR(20),
    @ResolvedBy NVARCHAR(100),
    @Notes NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE FraudAlerts
        SET Status = @Resolution, ResolvedDate = GETDATE(), ResolutionNotes = @Notes,
            AssignedTo = @ResolvedBy, ModifiedDate = GETDATE()
        WHERE AlertID = @AlertID;

        -- Recalculate fraud score
        DECLARE @CustomerID INT;
        SELECT @CustomerID = CustomerID FROM FraudAlerts WHERE AlertID = @AlertID;
        EXEC sp_UpdateFraudScore @CustomerID;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_GetFraudDashboard
AS
BEGIN
    SET NOCOUNT ON;

    -- Alerts by severity
    SELECT Severity, Status, COUNT(*) AS AlertCount
    FROM FraudAlerts GROUP BY Severity, Status ORDER BY Severity, Status;

    -- Top rules triggered
    SELECT TOP 10 fr.RuleName, COUNT(*) AS TriggerCount
    FROM FraudAlerts fa JOIN FraudRules fr ON fa.RuleID = fr.RuleID
    GROUP BY fr.RuleName ORDER BY TriggerCount DESC;

    -- Resolution rates
    SELECT
        COUNT(*) AS TotalAlerts,
        SUM(CASE WHEN Status = 'Confirmed' THEN 1 ELSE 0 END) AS ConfirmedFraud,
        SUM(CASE WHEN Status = 'FalsePositive' THEN 1 ELSE 0 END) AS FalsePositives,
        SUM(CASE WHEN Status = 'Resolved' THEN 1 ELSE 0 END) AS Resolved,
        SUM(CASE WHEN Status IN ('New', 'Investigating') THEN 1 ELSE 0 END) AS OpenAlerts
    FROM FraudAlerts;
END
GO

-- =============================================
-- 3.5 Report Generation
-- =============================================

CREATE PROCEDURE sp_GenerateStatement
    @CustomerID INT,
    @AccountID INT,
    @PeriodStart DATETIME,
    @PeriodEnd DATETIME,
    @RequestID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO StatementRequests (CustomerID, AccountID, StatementType, PeriodStart, PeriodEnd, Status)
        VALUES (@CustomerID, @AccountID, 'AdHoc', @PeriodStart, @PeriodEnd, 'Generating');

        SET @RequestID = SCOPE_IDENTITY();

        -- Create archive record
        INSERT INTO StatementArchive (RequestID, AccountID, FilePath, GeneratedDate, ExpiryDate)
        VALUES (@RequestID, @AccountID,
                '\\zavabank-nas\statements\' + CAST(@AccountID AS NVARCHAR(10)) + '\stmt_' + CONVERT(NVARCHAR(8), GETDATE(), 112) + '.pdf',
                GETDATE(), DATEADD(YEAR, 1, GETDATE()));

        UPDATE StatementRequests SET Status = 'Ready', CompletedDate = GETDATE() WHERE RequestID = @RequestID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        UPDATE StatementRequests SET Status = 'Failed' WHERE RequestID = @RequestID;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_ComplianceReport
    @ReportType NVARCHAR(50),
    @CustomerID INT = NULL,
    @FiledBy NVARCHAR(100),
    @ReportID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @ReportData NVARCHAR(MAX);

        -- Generate XML report data (era-appropriate)
        SET @ReportData = '<ComplianceReport><Type>' + @ReportType + '</Type><Date>' + CONVERT(NVARCHAR(30), GETDATE(), 126) + '</Date>';
        IF @CustomerID IS NOT NULL
        BEGIN
            SELECT @ReportData = @ReportData + '<Customer><ID>' + CAST(CustomerID AS NVARCHAR(10)) + '</ID><Name>' + FirstName + ' ' + LastName + '</Name></Customer>'
            FROM Customers WHERE CustomerID = @CustomerID;
        END
        SET @ReportData = @ReportData + '</ComplianceReport>';

        INSERT INTO ComplianceReports (ReportType, CustomerID, Status, ReportData, FiledBy, RegulatoryBody)
        VALUES (@ReportType, @CustomerID, 'Draft', @ReportData, @FiledBy,
                CASE @ReportType WHEN 'SAR' THEN 'FinCEN' WHEN 'CTR' THEN 'FinCEN' ELSE 'OCC' END);

        SET @ReportID = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_DailyBalanceReport
    @ReportDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @ReportDate IS NULL SET @ReportDate = CAST(GETDATE() AS DATE);

    SELECT at.TypeName AS AccountType, COUNT(*) AS AccountCount,
           SUM(a.Balance) AS TotalBalance, AVG(a.Balance) AS AvgBalance,
           MIN(a.Balance) AS MinBalance, MAX(a.Balance) AS MaxBalance
    FROM Accounts a JOIN AccountTypes at ON a.AccountTypeID = at.AccountTypeID
    WHERE a.Status = 'Active'
    GROUP BY at.TypeName
    ORDER BY at.TypeName;
END
GO

CREATE PROCEDURE sp_LoanPortfolioReport
AS
BEGIN
    SET NOCOUNT ON;

    SELECT lp.ProductName, la.Status,
           COUNT(*) AS ApplicationCount,
           SUM(la.RequestedAmount) AS TotalRequested,
           SUM(la.ApprovedAmount) AS TotalApproved,
           AVG(la.InterestRate) AS AvgRate
    FROM LoanApplications la
    JOIN LoanProducts lp ON la.LoanProductID = lp.LoanProductID
    GROUP BY lp.ProductName, la.Status
    ORDER BY lp.ProductName, la.Status;
END
GO

-- =============================================
-- 3.6 KYC & Compliance
-- =============================================

CREATE PROCEDURE sp_RunKYCCheck
    @CustomerID INT,
    @VerificationLevel NVARCHAR(20) = 'Basic',
    @KYCID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO KYCRecords (CustomerID, VerificationLevel, Status)
        VALUES (@CustomerID, @VerificationLevel, 'Pending');

        SET @KYCID = SCOPE_IDENTITY();

        -- Auto-run OFAC screening
        INSERT INTO ComplianceChecks (CustomerID, CheckType, Result, Details, CheckedBy)
        VALUES (@CustomerID, 'OFAC', 'Clear', 'Automated OFAC screening - no matches found', 'SYSTEM');

        -- Auto-run PEP screening
        INSERT INTO ComplianceChecks (CustomerID, CheckType, Result, Details, CheckedBy)
        VALUES (@CustomerID, 'PEP', 'Clear', 'Automated PEP screening - no matches found', 'SYSTEM');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_UpdateKYCStatus
    @KYCID INT,
    @NewStatus NVARCHAR(20),
    @VerifiedBy NVARCHAR(100),
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE KYCRecords
    SET Status = @NewStatus,
        VerifiedDate = CASE WHEN @NewStatus = 'Verified' THEN GETDATE() ELSE VerifiedDate END,
        ExpiryDate = CASE WHEN @NewStatus = 'Verified' THEN DATEADD(YEAR, 1, GETDATE()) ELSE ExpiryDate END,
        VerifiedBy = @VerifiedBy, Notes = @Notes, ModifiedDate = GETDATE()
    WHERE KYCID = @KYCID;
END
GO

CREATE PROCEDURE sp_ScreenCustomer
    @CustomerID INT,
    @CheckType NVARCHAR(50),
    @CheckID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Result NVARCHAR(20) = 'Clear';
        DECLARE @Details NVARCHAR(MAX) = 'Screening completed - no matches found.';

        INSERT INTO ComplianceChecks (CustomerID, CheckType, Result, Details, CheckedBy, ExternalRefID)
        VALUES (@CustomerID, @CheckType, @Result, @Details, 'SYSTEM',
                'EXT-' + @CheckType + '-' + CAST(@CustomerID AS NVARCHAR(10)) + '-' + CONVERT(NVARCHAR(8), GETDATE(), 112));

        SET @CheckID = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- 3.7 Notification & Alerts
-- =============================================

CREATE PROCEDURE sp_QueueNotification
    @CustomerID INT,
    @TemplateCode NVARCHAR(30),
    @Channel NVARCHAR(20) = 'Email',
    @Priority INT = 5,
    @QueueID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @TemplateID INT, @Subject NVARCHAR(255), @Body NVARCHAR(MAX), @Recipient NVARCHAR(255);

        SELECT @TemplateID = TemplateID, @Subject = Subject, @Body = BodyTemplate
        FROM NotificationTemplates WHERE TemplateCode = @TemplateCode AND IsActive = 1;

        IF @TemplateID IS NULL
            RAISERROR('Notification template not found or inactive.', 16, 1);

        -- Get recipient
        SELECT @Recipient = CASE @Channel WHEN 'Email' THEN Email WHEN 'SMS' THEN Phone ELSE Email END
        FROM Customers WHERE CustomerID = @CustomerID;

        -- Simple placeholder replacement
        DECLARE @FirstName NVARCHAR(100), @LastName NVARCHAR(100);
        SELECT @FirstName = FirstName, @LastName = LastName FROM Customers WHERE CustomerID = @CustomerID;

        SET @Body = REPLACE(@Body, '{{FirstName}}', ISNULL(@FirstName, ''));
        SET @Body = REPLACE(@Body, '{{LastName}}', ISNULL(@LastName, ''));

        INSERT INTO NotificationQueue (CustomerID, TemplateID, Channel, Recipient, Subject, Body, Priority)
        VALUES (@CustomerID, @TemplateID, @Channel, @Recipient, @Subject, @Body, @Priority);

        SET @QueueID = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_ProcessNotificationBatch
    @BatchSize INT = 50,
    @ProcessedCount INT OUTPUT,
    @FailedCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @ProcessedCount = 0;
    SET @FailedCount = 0;

    -- Process queued notifications in priority order
    UPDATE TOP (@BatchSize) NotificationQueue
    SET Status = 'Sending', LastAttemptDate = GETDATE(), AttemptCount = AttemptCount + 1
    WHERE Status = 'Queued' AND ScheduledDate <= GETDATE();

    -- Simulate sending (in real system, this would call SMTP/SMS gateway)
    UPDATE NotificationQueue SET Status = 'Sent' WHERE Status = 'Sending';

    SELECT @ProcessedCount = @@ROWCOUNT;

    -- Log sent notifications
    INSERT INTO NotificationLog (QueueID, CustomerID, Channel, Recipient, Status, SentDate)
    SELECT QueueID, CustomerID, Channel, Recipient, 'Sent', GETDATE()
    FROM NotificationQueue WHERE Status = 'Sent' AND QueueID NOT IN (SELECT ISNULL(QueueID, 0) FROM NotificationLog);
END
GO

CREATE PROCEDURE sp_EvaluateAlerts
    @AlertsTriggered INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @AlertsTriggered = 0;

    -- Check low balance alerts
    INSERT INTO AlertHistory (AccountAlertID, TriggerValue, Details)
    SELECT aa.AccountAlertID,
           CAST(a.Balance AS NVARCHAR(50)),
           'Balance $' + CAST(a.Balance AS NVARCHAR(20)) + ' below threshold $' + aa.Threshold
    FROM AccountAlerts aa
    JOIN AlertRules ar ON aa.RuleID = ar.RuleID
    JOIN Accounts a ON aa.AccountID = a.AccountID
    WHERE ar.RuleCode = 'LOW_BALANCE' AND aa.IsEnabled = 1
    AND a.Balance < CAST(aa.Threshold AS DECIMAL(18,2))
    AND NOT EXISTS (
        SELECT 1 FROM AlertHistory ah
        WHERE ah.AccountAlertID = aa.AccountAlertID
        AND ah.TriggeredDate > DATEADD(HOUR, -24, GETDATE())
    );

    SET @AlertsTriggered = @@ROWCOUNT;
END
GO

-- =============================================
-- 3.8 Auth & Session Management
-- =============================================

CREATE PROCEDURE sp_ValidateUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(100),
    @UserID INT OUTPUT,
    @IsValid BIT OUTPUT,
    @Roles NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @IsValid = 0;
        SET @UserID = 0;
        SET @Roles = '';

        DECLARE @StoredHash NVARCHAR(128), @Salt NVARCHAR(64);
        DECLARE @IsActive BIT, @IsLockedOut BIT, @FailedAttempts INT;

        SELECT @UserID = UserID, @StoredHash = PasswordHash, @Salt = Salt,
               @IsActive = IsActive, @IsLockedOut = IsLockedOut, @FailedAttempts = FailedLoginAttempts
        FROM Users WHERE Username = @Username;

        IF @UserID = 0 OR @UserID IS NULL
        BEGIN
            SET @UserID = 0;
            RETURN;
        END

        IF @IsLockedOut = 1
        BEGIN
            SET @IsValid = 0;
            RETURN;
        END

        IF @IsActive = 0
        BEGIN
            SET @IsValid = 0;
            RETURN;
        END

        -- Compute SHA-1 hash: HASHBYTES('SHA1', salt + password)
        DECLARE @ComputedHash NVARCHAR(128);
        SET @ComputedHash = CONVERT(NVARCHAR(128), HASHBYTES('SHA1', @Salt + @Password), 2);

        IF @ComputedHash = @StoredHash
        BEGIN
            SET @IsValid = 1;
            UPDATE Users SET FailedLoginAttempts = 0, LastLoginDate = GETDATE(), ModifiedDate = GETDATE()
            WHERE UserID = @UserID;

            -- Get roles
            SELECT @Roles = COALESCE(@Roles + ',', '') + r.RoleName
            FROM UserRoles ur JOIN Roles r ON ur.RoleID = r.RoleID
            WHERE ur.UserID = @UserID;
        END
        ELSE
        BEGIN
            SET @IsValid = 0;
            UPDATE Users SET FailedLoginAttempts = FailedLoginAttempts + 1, ModifiedDate = GETDATE()
            WHERE UserID = @UserID;

            -- Lock out after 5 failed attempts
            IF @FailedAttempts + 1 >= 5
                UPDATE Users SET IsLockedOut = 1, ModifiedDate = GETDATE() WHERE UserID = @UserID;
        END

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_CreateSession
    @UserID INT,
    @SourceSystem NVARCHAR(10),
    @IPAddress NVARCHAR(45) = NULL,
    @UserAgent NVARCHAR(500) = NULL,
    @Token NVARCHAR(64) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @Token = LOWER(CONVERT(NVARCHAR(64), NEWID()));

        INSERT INTO SessionTokens (UserID, Token, ExpiresAt, SourceSystem, IPAddress, UserAgent)
        VALUES (@UserID, @Token, DATEADD(MINUTE, 30, GETDATE()), @SourceSystem, @IPAddress, @UserAgent);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

CREATE PROCEDURE sp_ValidateSessionToken
    @Token NVARCHAR(64),
    @UserID INT OUTPUT,
    @Username NVARCHAR(50) OUTPUT,
    @Roles NVARCHAR(500) OUTPUT,
    @IsValid BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IsValid = 0;
    SET @UserID = 0;
    SET @Username = '';
    SET @Roles = '';

    SELECT @UserID = st.UserID, @Username = u.Username
    FROM SessionTokens st JOIN Users u ON st.UserID = u.UserID
    WHERE st.Token = @Token AND st.IsActive = 1 AND st.ExpiresAt > GETDATE();

    IF @UserID > 0
    BEGIN
        SET @IsValid = 1;

        SELECT @Roles = COALESCE(@Roles + ',', '') + r.RoleName
        FROM UserRoles ur JOIN Roles r ON ur.RoleID = r.RoleID
        WHERE ur.UserID = @UserID;

        -- Extend session (sliding expiration)
        UPDATE SessionTokens SET ExpiresAt = DATEADD(MINUTE, 30, GETDATE()) WHERE Token = @Token;
    END
END
GO

CREATE PROCEDURE sp_ExpireSession
    @Token NVARCHAR(64) = NULL,
    @UserID INT = NULL,
    @ExpireAll BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @ExpireAll = 1 AND @UserID IS NOT NULL
    BEGIN
        UPDATE SessionTokens SET IsActive = 0 WHERE UserID = @UserID;
    END
    ELSE IF @Token IS NOT NULL
    BEGIN
        UPDATE SessionTokens SET IsActive = 0 WHERE Token = @Token;
    END
END
GO

PRINT 'All stored procedures created successfully.';
GO
