-- Alert Tables: AlertRules, AccountAlerts, AlertHistory
-- Section 2.13 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE AlertRules (
    RuleID              INT IDENTITY(1,1) PRIMARY KEY,
    RuleName            NVARCHAR(100) NOT NULL,
    RuleCode            NVARCHAR(30) NOT NULL UNIQUE,
    DefaultThreshold    NVARCHAR(50),
    Category            NVARCHAR(30),
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE AccountAlerts (
    AccountAlertID      INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    AccountID           INT NOT NULL REFERENCES Accounts(AccountID),
    RuleID              INT NOT NULL REFERENCES AlertRules(RuleID),
    Threshold           NVARCHAR(50),
    NotificationChannel NVARCHAR(20) DEFAULT 'Email',
    IsEnabled           BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    ModifiedDate        DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE AlertHistory (
    AlertHistoryID      INT IDENTITY(1,1) PRIMARY KEY,
    AccountAlertID      INT NOT NULL REFERENCES AccountAlerts(AccountAlertID),
    TriggeredDate       DATETIME DEFAULT GETDATE(),
    TriggerValue        NVARCHAR(100),
    NotificationSent    BIT DEFAULT 0,
    NotificationDate    DATETIME NULL,
    Details             NVARCHAR(500)
);
GO

PRINT 'Alert tables created successfully.';
GO
