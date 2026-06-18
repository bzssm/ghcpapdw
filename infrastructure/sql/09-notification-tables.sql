-- Notification Tables: NotificationTemplates, NotificationQueue, NotificationLog
-- Section 2.8 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE NotificationTemplates (
    TemplateID          INT IDENTITY(1,1) PRIMARY KEY,
    TemplateName        NVARCHAR(100) NOT NULL,
    TemplateCode        NVARCHAR(30) NOT NULL UNIQUE,
    Channel             NVARCHAR(20) NOT NULL,
    Subject             NVARCHAR(255),
    BodyTemplate        NVARCHAR(MAX),
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE NotificationQueue (
    QueueID             INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL REFERENCES Customers(CustomerID),
    TemplateID          INT NOT NULL REFERENCES NotificationTemplates(TemplateID),
    Channel             NVARCHAR(20) NOT NULL,
    Recipient           NVARCHAR(255) NOT NULL,
    Subject             NVARCHAR(255),
    Body                NVARCHAR(MAX),
    Status              NVARCHAR(20) DEFAULT 'Queued',
    Priority            INT DEFAULT 5,
    ScheduledDate       DATETIME DEFAULT GETDATE(),
    AttemptCount        INT DEFAULT 0,
    MaxAttempts         INT DEFAULT 3,
    LastAttemptDate     DATETIME NULL,
    ErrorMessage        NVARCHAR(500) NULL,
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE NotificationLog (
    LogID               INT IDENTITY(1,1) PRIMARY KEY,
    QueueID             INT NULL REFERENCES NotificationQueue(QueueID),
    CustomerID          INT NOT NULL,
    Channel             NVARCHAR(20),
    Recipient           NVARCHAR(255),
    Status              NVARCHAR(20),
    SentDate            DATETIME DEFAULT GETDATE(),
    ResponseCode        NVARCHAR(50),
    ErrorDetails        NVARCHAR(500)
);
GO

PRINT 'Notification tables created successfully.';
GO
