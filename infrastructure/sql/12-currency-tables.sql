-- Currency Tables: CurrencyPairs, ExchangeRates
-- Section 2.11 of database-topology.md

USE [ZavaBankDB];
GO

CREATE TABLE CurrencyPairs (
    PairID              INT IDENTITY(1,1) PRIMARY KEY,
    BaseCurrency        NVARCHAR(3) NOT NULL,
    QuoteCurrency       NVARCHAR(3) NOT NULL,
    IsActive            BIT DEFAULT 1,
    CreatedDate         DATETIME DEFAULT GETDATE(),
    UNIQUE(BaseCurrency, QuoteCurrency)
);
GO

CREATE TABLE ExchangeRates (
    RateID              INT IDENTITY(1,1) PRIMARY KEY,
    PairID              INT NOT NULL REFERENCES CurrencyPairs(PairID),
    BidRate             DECIMAL(18,6) NOT NULL,
    AskRate             DECIMAL(18,6) NOT NULL,
    MidRate             DECIMAL(18,6) NOT NULL,
    EffectiveDate       DATETIME DEFAULT GETDATE(),
    ExpiryDate          DATETIME,
    Source              NVARCHAR(50) DEFAULT 'Reuters',
    CreatedDate         DATETIME DEFAULT GETDATE()
);
GO

PRINT 'Currency tables created successfully.';
GO
