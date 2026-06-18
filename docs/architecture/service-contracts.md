# WCF Service Contracts — Zava Bank

> **Status:** Design documentation — no compilable code  
> **Runtime:** Mono 6.12, .NET Framework 4.8, BasicHttpBinding, self-hosted console apps  
> **Protocol:** SOAP 1.1/XML only — no REST, no JSON  
> **Era:** 2005–2015 patterns — synchronous operations, no async/await

---

## Table of Contents

1. [ZavaRiskEngine](#1-zavariskengine)
2. [ZavaCurrencyService](#2-zavacurrencyservice)
3. [ZavaStatementService](#3-zavastatementservice)
4. [ZavaAlertService](#4-zavaalertservice)
5. [Shared Types](#5-shared-types)
6. [Hosting & Endpoint Configuration](#6-hosting--endpoint-configuration)

---

## 1. ZavaRiskEngine

**Endpoint:** `http://zava-risk-engine:8090/RiskEngine.svc`  
**WSDL:** `http://zava-risk-engine:8090/RiskEngine.svc?wsdl`  
**Namespace:** `http://zava.bank/wcf/risk/`  
**Callers:** ZavaLoanOriginationAPI (synchronous SOAP), RabbitMQ `q.loan.riskscore` (async re-scoring)  
**Database:** `CreditScores`, `RiskAssessments`, `RiskFactors`, `LoanApplications` tables; `sp_CalculateRisk` stored procedure

### 1.1 Service Contract

```csharp
[ServiceContract(Namespace = "http://zava.bank/wcf/risk/")]
public interface IZavaRiskEngine
{
    [OperationContract]
    [FaultContract(typeof(RiskScoringFault))]
    RiskScoreResponse ScoreLoan(LoanApplicationRequest request);

    [OperationContract]
    [FaultContract(typeof(RiskScoringFault))]
    MaxApprovedAmountResponse GetMaxApprovedAmount(MaxApprovedAmountRequest request);

    [OperationContract]
    [FaultContract(typeof(RiskScoringFault))]
    RiskAssessmentResponse GetRiskAssessment(RiskAssessmentRequest request);
}
```

### 1.2 Data Contracts — Requests

```csharp
[DataContract(Namespace = "http://zava.bank/wcf/risk/")]
public class LoanApplicationRequest
{
    [DataMember(Order = 1)]
    public int ApplicationID { get; set; }

    [DataMember(Order = 2)]
    public int CustomerID { get; set; }

    [DataMember(Order = 3)]
    public int LoanProductID { get; set; }

    [DataMember(Order = 4)]
    public decimal RequestedAmount { get; set; }

    [DataMember(Order = 5)]
    public int TermMonths { get; set; }

    [DataMember(Order = 6)]
    public string Purpose { get; set; }

    [DataMember(Order = 7)]
    public decimal AnnualIncome { get; set; }

    [DataMember(Order = 8)]
    public int CreditScoreProvided { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/risk/")]
public class MaxApprovedAmountRequest
{
    [DataMember(Order = 1)]
    public int CustomerID { get; set; }

    [DataMember(Order = 2)]
    public string RiskRating { get; set; }  // A-F from prior ScoreLoan call

    [DataMember(Order = 3)]
    public int LoanProductID { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/risk/")]
public class RiskAssessmentRequest
{
    [DataMember(Order = 1)]
    public int ApplicationID { get; set; }
}
```

### 1.3 Data Contracts — Responses

```csharp
[DataContract(Namespace = "http://zava.bank/wcf/risk/")]
public class RiskScoreResponse
{
    [DataMember(Order = 1)]
    public int ApplicationID { get; set; }

    [DataMember(Order = 2)]
    public decimal OverallRiskScore { get; set; }  // 0-100, lower is better

    [DataMember(Order = 3)]
    public string RiskRating { get; set; }  // A, B, C, D, E, F

    [DataMember(Order = 4)]
    public string RiskLevel { get; set; }  // Low, Medium, High, Critical

    [DataMember(Order = 5)]
    public string Recommendation { get; set; }  // Approve, Deny, ManualReview

    [DataMember(Order = 6)]
    public decimal DebtToIncomeRatio { get; set; }

    [DataMember(Order = 7)]
    public decimal LoanToValueRatio { get; set; }

    [DataMember(Order = 8)]
    public string FactorBreakdown { get; set; }  // pipe-delimited factor=score pairs

    [DataMember(Order = 9)]
    public decimal MaxApprovedAmount { get; set; }

    [DataMember(Order = 10)]
    public DateTime AssessedDate { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/risk/")]
public class MaxApprovedAmountResponse
{
    [DataMember(Order = 1)]
    public int CustomerID { get; set; }

    [DataMember(Order = 2)]
    public decimal MaxAmount { get; set; }

    [DataMember(Order = 3)]
    public decimal RecommendedRate { get; set; }  // suggested APR

    [DataMember(Order = 4)]
    public string RiskRating { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/risk/")]
public class RiskAssessmentResponse
{
    [DataMember(Order = 1)]
    public int AssessmentID { get; set; }

    [DataMember(Order = 2)]
    public int ApplicationID { get; set; }

    [DataMember(Order = 3)]
    public decimal OverallRiskScore { get; set; }

    [DataMember(Order = 4)]
    public string RiskLevel { get; set; }

    [DataMember(Order = 5)]
    public string Recommendation { get; set; }

    [DataMember(Order = 6)]
    public string FactorBreakdown { get; set; }

    [DataMember(Order = 7)]
    public DateTime AssessedDate { get; set; }

    [DataMember(Order = 8)]
    public string AssessedBy { get; set; }
}
```

### 1.4 Fault Contract

```csharp
[DataContract(Namespace = "http://zava.bank/wcf/risk/")]
public class RiskScoringFault
{
    [DataMember]
    public string ErrorCode { get; set; }
    // INVALID_CUSTOMER, MISSING_CREDIT_SCORE, RISK_ENGINE_UNAVAILABLE,
    // INVALID_APPLICATION, SCORING_TIMEOUT

    [DataMember]
    public string ErrorMessage { get; set; }

    [DataMember]
    public int ApplicationID { get; set; }

    [DataMember]
    public DateTime Timestamp { get; set; }
}
```

### 1.5 XML Examples

**ScoreLoan Request:**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:risk="http://zava.bank/wcf/risk/">
  <soapenv:Body>
    <risk:ScoreLoan>
      <risk:request>
        <risk:ApplicationID>142</risk:ApplicationID>
        <risk:CustomerID>98765</risk:CustomerID>
        <risk:LoanProductID>2</risk:LoanProductID>
        <risk:RequestedAmount>25000.00</risk:RequestedAmount>
        <risk:TermMonths>60</risk:TermMonths>
        <risk:Purpose>Home improvement</risk:Purpose>
        <risk:AnnualIncome>85000.00</risk:AnnualIncome>
        <risk:CreditScoreProvided>720</risk:CreditScoreProvided>
      </risk:request>
    </risk:ScoreLoan>
  </soapenv:Body>
</soapenv:Envelope>
```

**ScoreLoan Response:**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:risk="http://zava.bank/wcf/risk/">
  <soapenv:Body>
    <risk:ScoreLoanResponse>
      <risk:ScoreLoanResult>
        <risk:ApplicationID>142</risk:ApplicationID>
        <risk:OverallRiskScore>28.50</risk:OverallRiskScore>
        <risk:RiskRating>B</risk:RiskRating>
        <risk:RiskLevel>Low</risk:RiskLevel>
        <risk:Recommendation>Approve</risk:Recommendation>
        <risk:DebtToIncomeRatio>0.32</risk:DebtToIncomeRatio>
        <risk:LoanToValueRatio>0.00</risk:LoanToValueRatio>
        <risk:FactorBreakdown>DTI=0.32|CREDIT=720|EMP_HISTORY=5|COLL_VALUE=0</risk:FactorBreakdown>
        <risk:MaxApprovedAmount>30000.00</risk:MaxApprovedAmount>
        <risk:AssessedDate>2026-05-12T10:30:05Z</risk:AssessedDate>
      </risk:ScoreLoanResult>
    </risk:ScoreLoanResponse>
  </soapenv:Body>
</soapenv:Envelope>
```

**ScoreLoan SOAP Fault (customer not found):**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Body>
    <soapenv:Fault>
      <faultcode>soapenv:Client</faultcode>
      <faultstring>Customer not found</faultstring>
      <detail>
        <RiskScoringFault xmlns="http://zava.bank/wcf/risk/">
          <ErrorCode>INVALID_CUSTOMER</ErrorCode>
          <ErrorMessage>Customer ID 99999 does not exist</ErrorMessage>
          <ApplicationID>143</ApplicationID>
          <Timestamp>2026-05-12T10:31:00Z</Timestamp>
        </RiskScoringFault>
      </detail>
    </soapenv:Fault>
  </soapenv:Body>
</soapenv:Envelope>
```

### 1.6 Database Mapping

| Operation | Tables Read | Tables Written | Stored Procedure |
|---|---|---|---|
| `ScoreLoan` | `CreditScores`, `RiskFactors`, `LoanApplications` | `RiskAssessments` | `sp_CalculateRisk` |
| `GetMaxApprovedAmount` | `RiskAssessments`, `LoanProducts`, `CreditScores` | — | `sp_CalculateRisk` (subset) |
| `GetRiskAssessment` | `RiskAssessments`, `RiskFactors` | — | — (direct query) |

### 1.7 RabbitMQ Integration

The Risk Engine also consumes from `q.loan.riskscore` (bound to `zava.loans` exchange, routing key `loan.submitted`). When a `LoanApplicationEvent` message arrives, the service deserializes the XML, maps it to a `LoanApplicationRequest`, calls `ScoreLoan` internally, and publishes a `LoanScoredEvent` back to the `zava.loans` exchange with routing key `loan.scored`.

---

## 2. ZavaCurrencyService

**Endpoint:** `http://zava-currency-service:8093/CurrencyService.svc`  
**WSDL:** `http://zava-currency-service:8093/CurrencyService.svc?wsdl`  
**Namespace:** `http://zava.bank/wcf/currency/`  
**Callers:** ZavaPayGateway, ZavaWireTransferService (synchronous SOAP)  
**Database:** `CurrencyPairs`, `ExchangeRates` tables  
**Notes:** Simplest service — good Mono/WCF canary for migration testing

### 2.1 Service Contract

```csharp
[ServiceContract(Namespace = "http://zava.bank/wcf/currency/")]
public interface IZavaCurrencyService
{
    [OperationContract]
    [FaultContract(typeof(CurrencyFault))]
    ExchangeRateResponse GetExchangeRate(ExchangeRateRequest request);

    [OperationContract]
    [FaultContract(typeof(CurrencyFault))]
    ConvertAmountResponse ConvertAmount(ConvertAmountRequest request);

    [OperationContract]
    [FaultContract(typeof(CurrencyFault))]
    SupportedCurrenciesResponse GetSupportedCurrencies();
}
```

### 2.2 Data Contracts — Requests

```csharp
[DataContract(Namespace = "http://zava.bank/wcf/currency/")]
public class ExchangeRateRequest
{
    [DataMember(Order = 1)]
    public string FromCurrency { get; set; }  // ISO 4217: USD, EUR, GBP

    [DataMember(Order = 2)]
    public string ToCurrency { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/currency/")]
public class ConvertAmountRequest
{
    [DataMember(Order = 1)]
    public decimal Amount { get; set; }

    [DataMember(Order = 2)]
    public string FromCurrency { get; set; }

    [DataMember(Order = 3)]
    public string ToCurrency { get; set; }
}
```

### 2.3 Data Contracts — Responses

```csharp
[DataContract(Namespace = "http://zava.bank/wcf/currency/")]
public class ExchangeRateResponse
{
    [DataMember(Order = 1)]
    public string FromCurrency { get; set; }

    [DataMember(Order = 2)]
    public string ToCurrency { get; set; }

    [DataMember(Order = 3)]
    public decimal BidRate { get; set; }

    [DataMember(Order = 4)]
    public decimal AskRate { get; set; }

    [DataMember(Order = 5)]
    public decimal MidRate { get; set; }

    [DataMember(Order = 6)]
    public DateTime EffectiveDate { get; set; }

    [DataMember(Order = 7)]
    public string Source { get; set; }  // e.g., "Reuters"
}

[DataContract(Namespace = "http://zava.bank/wcf/currency/")]
public class ConvertAmountResponse
{
    [DataMember(Order = 1)]
    public decimal OriginalAmount { get; set; }

    [DataMember(Order = 2)]
    public string FromCurrency { get; set; }

    [DataMember(Order = 3)]
    public decimal ConvertedAmount { get; set; }

    [DataMember(Order = 4)]
    public string ToCurrency { get; set; }

    [DataMember(Order = 5)]
    public decimal RateApplied { get; set; }  // mid rate used

    [DataMember(Order = 6)]
    public DateTime RateAsOf { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/currency/")]
public class SupportedCurrenciesResponse
{
    [DataMember(Order = 1)]
    public List<CurrencyInfo> Currencies { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/currency/")]
public class CurrencyInfo
{
    [DataMember(Order = 1)]
    public string CurrencyCode { get; set; }  // ISO 4217

    [DataMember(Order = 2)]
    public bool IsActive { get; set; }
}
```

### 2.4 Fault Contract

```csharp
[DataContract(Namespace = "http://zava.bank/wcf/currency/")]
public class CurrencyFault
{
    [DataMember]
    public string ErrorCode { get; set; }
    // UNSUPPORTED_CURRENCY, PAIR_NOT_FOUND, RATE_EXPIRED, INVALID_AMOUNT

    [DataMember]
    public string ErrorMessage { get; set; }

    [DataMember]
    public DateTime Timestamp { get; set; }
}
```

### 2.5 XML Examples

**GetExchangeRate Request:**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:cur="http://zava.bank/wcf/currency/">
  <soapenv:Body>
    <cur:GetExchangeRate>
      <cur:request>
        <cur:FromCurrency>USD</cur:FromCurrency>
        <cur:ToCurrency>EUR</cur:ToCurrency>
      </cur:request>
    </cur:GetExchangeRate>
  </soapenv:Body>
</soapenv:Envelope>
```

**GetExchangeRate Response:**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:cur="http://zava.bank/wcf/currency/">
  <soapenv:Body>
    <cur:GetExchangeRateResponse>
      <cur:GetExchangeRateResult>
        <cur:FromCurrency>USD</cur:FromCurrency>
        <cur:ToCurrency>EUR</cur:ToCurrency>
        <cur:BidRate>0.921500</cur:BidRate>
        <cur:AskRate>0.923100</cur:AskRate>
        <cur:MidRate>0.922300</cur:MidRate>
        <cur:EffectiveDate>2026-05-12T08:00:00Z</cur:EffectiveDate>
        <cur:Source>Reuters</cur:Source>
      </cur:GetExchangeRateResult>
    </cur:GetExchangeRateResponse>
  </soapenv:Body>
</soapenv:Envelope>
```

**ConvertAmount Request:**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:cur="http://zava.bank/wcf/currency/">
  <soapenv:Body>
    <cur:ConvertAmount>
      <cur:request>
        <cur:Amount>1500.00</cur:Amount>
        <cur:FromCurrency>USD</cur:FromCurrency>
        <cur:ToCurrency>GBP</cur:ToCurrency>
      </cur:request>
    </cur:ConvertAmount>
  </soapenv:Body>
</soapenv:Envelope>
```

**ConvertAmount Response:**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:cur="http://zava.bank/wcf/currency/">
  <soapenv:Body>
    <cur:ConvertAmountResponse>
      <cur:ConvertAmountResult>
        <cur:OriginalAmount>1500.00</cur:OriginalAmount>
        <cur:FromCurrency>USD</cur:FromCurrency>
        <cur:ConvertedAmount>1183.50</cur:ConvertedAmount>
        <cur:ToCurrency>GBP</cur:ToCurrency>
        <cur:RateApplied>0.789000</cur:RateApplied>
        <cur:RateAsOf>2026-05-12T08:00:00Z</cur:RateAsOf>
      </cur:ConvertAmountResult>
    </cur:ConvertAmountResponse>
  </soapenv:Body>
</soapenv:Envelope>
```

**SOAP Fault (unsupported currency):**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Body>
    <soapenv:Fault>
      <faultcode>soapenv:Client</faultcode>
      <faultstring>Unsupported currency</faultstring>
      <detail>
        <CurrencyFault xmlns="http://zava.bank/wcf/currency/">
          <ErrorCode>UNSUPPORTED_CURRENCY</ErrorCode>
          <ErrorMessage>Currency code 'XYZ' is not supported</ErrorMessage>
          <Timestamp>2026-05-12T10:32:00Z</Timestamp>
        </CurrencyFault>
      </detail>
    </soapenv:Fault>
  </soapenv:Body>
</soapenv:Envelope>
```

### 2.6 Database Mapping

| Operation | Tables Read | Stored Procedure |
|---|---|---|
| `GetExchangeRate` | `CurrencyPairs`, `ExchangeRates` | — (direct query, latest by `EffectiveDate`) |
| `ConvertAmount` | `CurrencyPairs`, `ExchangeRates` | — (direct query + arithmetic) |
| `GetSupportedCurrencies` | `CurrencyPairs` | — (direct query) |

---

## 3. ZavaStatementService

**Endpoint:** `http://zava-statement-service:8091/StatementService.svc`  
**WSDL:** `http://zava-statement-service:8091/StatementService.svc?wsdl`  
**Namespace:** `http://zava.bank/wcf/statements/`  
**Callers:** ZavaAccountManager (on-demand), ZavaBatchScheduler (periodic), RabbitMQ `q.statement.generate`  
**Database:** `Accounts`, `Transactions`, `StatementRequests`, `StatementArchive` tables; `sp_GenerateStatement` stored procedure

### 3.1 Service Contract

```csharp
[ServiceContract(Namespace = "http://zava.bank/wcf/statements/")]
public interface IZavaStatementService
{
    [OperationContract]
    [FaultContract(typeof(StatementFault))]
    GenerateStatementResponse GenerateStatement(GenerateStatementRequest request);

    [OperationContract]
    [FaultContract(typeof(StatementFault))]
    StatementHistoryResponse GetStatementHistory(StatementHistoryRequest request);

    [OperationContract]
    [FaultContract(typeof(StatementFault))]
    StatementStatusResponse GetStatementStatus(StatementStatusRequest request);
}
```

### 3.2 Data Contracts — Requests

```csharp
[DataContract(Namespace = "http://zava.bank/wcf/statements/")]
public class GenerateStatementRequest
{
    [DataMember(Order = 1)]
    public int AccountID { get; set; }

    [DataMember(Order = 2)]
    public int CustomerID { get; set; }

    [DataMember(Order = 3)]
    public DateTime PeriodStart { get; set; }

    [DataMember(Order = 4)]
    public DateTime PeriodEnd { get; set; }

    [DataMember(Order = 5)]
    public string StatementType { get; set; }  // Monthly, Quarterly, Annual, AdHoc

    [DataMember(Order = 6)]
    public string Format { get; set; }  // PDF, CSV
}

[DataContract(Namespace = "http://zava.bank/wcf/statements/")]
public class StatementHistoryRequest
{
    [DataMember(Order = 1)]
    public int AccountID { get; set; }

    [DataMember(Order = 2)]
    public int MaxResults { get; set; }  // default 12
}

[DataContract(Namespace = "http://zava.bank/wcf/statements/")]
public class StatementStatusRequest
{
    [DataMember(Order = 1)]
    public int RequestID { get; set; }
}
```

### 3.3 Data Contracts — Responses

```csharp
[DataContract(Namespace = "http://zava.bank/wcf/statements/")]
public class GenerateStatementResponse
{
    [DataMember(Order = 1)]
    public int RequestID { get; set; }

    [DataMember(Order = 2)]
    public string Status { get; set; }  // Requested, Generating, Ready, Failed

    [DataMember(Order = 3)]
    public StatementData StatementData { get; set; }  // populated when synchronous generation succeeds
}

[DataContract(Namespace = "http://zava.bank/wcf/statements/")]
public class StatementData
{
    [DataMember(Order = 1)]
    public int AccountID { get; set; }

    [DataMember(Order = 2)]
    public string AccountNumber { get; set; }

    [DataMember(Order = 3)]
    public DateTime PeriodStart { get; set; }

    [DataMember(Order = 4)]
    public DateTime PeriodEnd { get; set; }

    [DataMember(Order = 5)]
    public decimal OpeningBalance { get; set; }

    [DataMember(Order = 6)]
    public decimal ClosingBalance { get; set; }

    [DataMember(Order = 7)]
    public decimal TotalCredits { get; set; }

    [DataMember(Order = 8)]
    public decimal TotalDebits { get; set; }

    [DataMember(Order = 9)]
    public decimal InterestAccrued { get; set; }

    [DataMember(Order = 10)]
    public int TransactionCount { get; set; }

    [DataMember(Order = 11)]
    public List<StatementTransaction> Transactions { get; set; }

    [DataMember(Order = 12)]
    public string FileContentBase64 { get; set; }  // base64-encoded PDF/CSV when format is file-based
}

[DataContract(Namespace = "http://zava.bank/wcf/statements/")]
public class StatementTransaction
{
    [DataMember(Order = 1)]
    public long TransactionID { get; set; }

    [DataMember(Order = 2)]
    public DateTime TransactionDate { get; set; }

    [DataMember(Order = 3)]
    public DateTime PostDate { get; set; }

    [DataMember(Order = 4)]
    public string Description { get; set; }

    [DataMember(Order = 5)]
    public decimal Amount { get; set; }

    [DataMember(Order = 6)]
    public decimal BalanceAfter { get; set; }

    [DataMember(Order = 7)]
    public string ReferenceNumber { get; set; }

    [DataMember(Order = 8)]
    public string Channel { get; set; }  // Online, ATM, Branch, Mobile, Wire
}

[DataContract(Namespace = "http://zava.bank/wcf/statements/")]
public class StatementHistoryResponse
{
    [DataMember(Order = 1)]
    public int AccountID { get; set; }

    [DataMember(Order = 2)]
    public List<StatementSummary> Statements { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/statements/")]
public class StatementSummary
{
    [DataMember(Order = 1)]
    public int RequestID { get; set; }

    [DataMember(Order = 2)]
    public string StatementType { get; set; }

    [DataMember(Order = 3)]
    public DateTime PeriodStart { get; set; }

    [DataMember(Order = 4)]
    public DateTime PeriodEnd { get; set; }

    [DataMember(Order = 5)]
    public string Status { get; set; }

    [DataMember(Order = 6)]
    public DateTime RequestedDate { get; set; }

    [DataMember(Order = 7)]
    public DateTime CompletedDate { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/statements/")]
public class StatementStatusResponse
{
    [DataMember(Order = 1)]
    public int RequestID { get; set; }

    [DataMember(Order = 2)]
    public string Status { get; set; }  // Requested, Generating, Ready, Failed, Expired

    [DataMember(Order = 3)]
    public string FilePath { get; set; }  // UNC path when Ready

    [DataMember(Order = 4)]
    public DateTime CompletedDate { get; set; }
}
```

### 3.4 Fault Contract

```csharp
[DataContract(Namespace = "http://zava.bank/wcf/statements/")]
public class StatementFault
{
    [DataMember]
    public string ErrorCode { get; set; }
    // ACCOUNT_NOT_FOUND, INVALID_DATE_RANGE, GENERATION_FAILED,
    // REQUEST_NOT_FOUND, NO_TRANSACTIONS

    [DataMember]
    public string ErrorMessage { get; set; }

    [DataMember]
    public int AccountID { get; set; }

    [DataMember]
    public DateTime Timestamp { get; set; }
}
```

### 3.5 XML Examples

**GenerateStatement Request:**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:stmt="http://zava.bank/wcf/statements/">
  <soapenv:Body>
    <stmt:GenerateStatement>
      <stmt:request>
        <stmt:AccountID>10001</stmt:AccountID>
        <stmt:CustomerID>98765</stmt:CustomerID>
        <stmt:PeriodStart>2026-04-01T00:00:00Z</stmt:PeriodStart>
        <stmt:PeriodEnd>2026-04-30T23:59:59Z</stmt:PeriodEnd>
        <stmt:StatementType>Monthly</stmt:StatementType>
        <stmt:Format>PDF</stmt:Format>
      </stmt:request>
    </stmt:GenerateStatement>
  </soapenv:Body>
</soapenv:Envelope>
```

**GenerateStatement Response:**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:stmt="http://zava.bank/wcf/statements/">
  <soapenv:Body>
    <stmt:GenerateStatementResponse>
      <stmt:GenerateStatementResult>
        <stmt:RequestID>5042</stmt:RequestID>
        <stmt:Status>Ready</stmt:Status>
        <stmt:StatementData>
          <stmt:AccountID>10001</stmt:AccountID>
          <stmt:AccountNumber>1001-0001-2345</stmt:AccountNumber>
          <stmt:PeriodStart>2026-04-01T00:00:00Z</stmt:PeriodStart>
          <stmt:PeriodEnd>2026-04-30T23:59:59Z</stmt:PeriodEnd>
          <stmt:OpeningBalance>12500.00</stmt:OpeningBalance>
          <stmt:ClosingBalance>14230.75</stmt:ClosingBalance>
          <stmt:TotalCredits>5200.00</stmt:TotalCredits>
          <stmt:TotalDebits>3469.25</stmt:TotalDebits>
          <stmt:InterestAccrued>0.00</stmt:InterestAccrued>
          <stmt:TransactionCount>23</stmt:TransactionCount>
          <stmt:Transactions>
            <stmt:StatementTransaction>
              <stmt:TransactionID>990001</stmt:TransactionID>
              <stmt:TransactionDate>2026-04-02T09:15:00Z</stmt:TransactionDate>
              <stmt:PostDate>2026-04-02T09:15:00Z</stmt:PostDate>
              <stmt:Description>Direct Deposit — Employer</stmt:Description>
              <stmt:Amount>2600.00</stmt:Amount>
              <stmt:BalanceAfter>15100.00</stmt:BalanceAfter>
              <stmt:ReferenceNumber>REF-DD-20260402</stmt:ReferenceNumber>
              <stmt:Channel>Online</stmt:Channel>
            </stmt:StatementTransaction>
            <!-- additional transactions omitted for brevity -->
          </stmt:Transactions>
          <stmt:FileContentBase64>JVBERi0xLjQKJcOkw7zDtsOf...</stmt:FileContentBase64>
        </stmt:StatementData>
      </stmt:GenerateStatementResult>
    </stmt:GenerateStatementResponse>
  </soapenv:Body>
</soapenv:Envelope>
```

**GetStatementHistory Request:**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:stmt="http://zava.bank/wcf/statements/">
  <soapenv:Body>
    <stmt:GetStatementHistory>
      <stmt:request>
        <stmt:AccountID>10001</stmt:AccountID>
        <stmt:MaxResults>6</stmt:MaxResults>
      </stmt:request>
    </stmt:GetStatementHistory>
  </soapenv:Body>
</soapenv:Envelope>
```

**SOAP Fault (invalid date range):**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Body>
    <soapenv:Fault>
      <faultcode>soapenv:Client</faultcode>
      <faultstring>Invalid date range</faultstring>
      <detail>
        <StatementFault xmlns="http://zava.bank/wcf/statements/">
          <ErrorCode>INVALID_DATE_RANGE</ErrorCode>
          <ErrorMessage>PeriodStart must be before PeriodEnd</ErrorMessage>
          <AccountID>10001</AccountID>
          <Timestamp>2026-05-12T10:33:00Z</Timestamp>
        </StatementFault>
      </detail>
    </soapenv:Fault>
  </soapenv:Body>
</soapenv:Envelope>
```

### 3.6 Database Mapping

| Operation | Tables Read | Tables Written | Stored Procedure |
|---|---|---|---|
| `GenerateStatement` | `Accounts`, `Transactions` | `StatementRequests`, `StatementArchive` | `sp_GenerateStatement` |
| `GetStatementHistory` | `StatementRequests`, `StatementArchive` | — | — (direct query) |
| `GetStatementStatus` | `StatementRequests`, `StatementArchive` | — | — (direct query) |

### 3.7 RabbitMQ Integration

The Statement Service also consumes from `q.statement.generate` (bound to `zava.statements` exchange, routing key `statement.generate`). When a `StatementRequestEvent` message arrives, the service deserializes the XML, creates a `StatementRequests` record, generates the statement via `sp_GenerateStatement`, and stores the result in `StatementArchive`.

---

## 4. ZavaAlertService

**Endpoint:** `http://zava-alert-service:8092/AlertService.svc`  
**WSDL:** `http://zava-alert-service:8092/AlertService.svc?wsdl`  
**Namespace:** `http://zava.bank/wcf/alerts/`  
**Callers:** Timer/scheduler (periodic evaluation), transaction event triggers  
**Publishes to:** RabbitMQ `zava.notifications` exchange (fanout)  
**Database:** `AlertRules`, `AccountAlerts`, `AlertHistory` tables; `sp_EvaluateAlerts` stored procedure

### 4.1 Service Contract

```csharp
[ServiceContract(Namespace = "http://zava.bank/wcf/alerts/")]
public interface IZavaAlertService
{
    [OperationContract]
    [FaultContract(typeof(AlertFault))]
    EvaluateTransactionResponse EvaluateTransaction(EvaluateTransactionRequest request);

    [OperationContract]
    [FaultContract(typeof(AlertFault))]
    UpdateAlertRuleResponse UpdateAlertRule(UpdateAlertRuleRequest request);

    [OperationContract]
    [FaultContract(typeof(AlertFault))]
    GetAlertRulesResponse GetAlertRules(GetAlertRulesRequest request);

    [OperationContract]
    [FaultContract(typeof(AlertFault))]
    GetAlertHistoryResponse GetAlertHistory(GetAlertHistoryRequest request);
}
```

### 4.2 Data Contracts — Requests

```csharp
[DataContract(Namespace = "http://zava.bank/wcf/alerts/")]
public class EvaluateTransactionRequest
{
    [DataMember(Order = 1)]
    public long TransactionID { get; set; }

    [DataMember(Order = 2)]
    public int AccountID { get; set; }

    [DataMember(Order = 3)]
    public int CustomerID { get; set; }

    [DataMember(Order = 4)]
    public decimal Amount { get; set; }

    [DataMember(Order = 5)]
    public string TransactionType { get; set; }  // Deposit, Withdrawal, Transfer, Payment

    [DataMember(Order = 6)]
    public decimal BalanceAfter { get; set; }

    [DataMember(Order = 7)]
    public DateTime TransactionDate { get; set; }

    [DataMember(Order = 8)]
    public string Channel { get; set; }  // Online, ATM, Branch, Mobile, Wire
}

[DataContract(Namespace = "http://zava.bank/wcf/alerts/")]
public class UpdateAlertRuleRequest
{
    [DataMember(Order = 1)]
    public int AccountAlertID { get; set; }  // 0 = create new

    [DataMember(Order = 2)]
    public int CustomerID { get; set; }

    [DataMember(Order = 3)]
    public int AccountID { get; set; }

    [DataMember(Order = 4)]
    public int RuleID { get; set; }

    [DataMember(Order = 5)]
    public string Threshold { get; set; }  // customer override, e.g., "500.00"

    [DataMember(Order = 6)]
    public string NotificationChannel { get; set; }  // Email, SMS

    [DataMember(Order = 7)]
    public bool IsEnabled { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/alerts/")]
public class GetAlertRulesRequest
{
    [DataMember(Order = 1)]
    public int AccountID { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/alerts/")]
public class GetAlertHistoryRequest
{
    [DataMember(Order = 1)]
    public int AccountID { get; set; }

    [DataMember(Order = 2)]
    public int MaxResults { get; set; }  // default 50
}
```

### 4.3 Data Contracts — Responses

```csharp
[DataContract(Namespace = "http://zava.bank/wcf/alerts/")]
public class EvaluateTransactionResponse
{
    [DataMember(Order = 1)]
    public long TransactionID { get; set; }

    [DataMember(Order = 2)]
    public int AlertsTriggered { get; set; }

    [DataMember(Order = 3)]
    public List<TriggeredAlert> Alerts { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/alerts/")]
public class TriggeredAlert
{
    [DataMember(Order = 1)]
    public int AlertHistoryID { get; set; }

    [DataMember(Order = 2)]
    public string RuleCode { get; set; }  // LOW_BALANCE, LARGE_TXN, LOGIN_FAIL

    [DataMember(Order = 3)]
    public string RuleName { get; set; }

    [DataMember(Order = 4)]
    public string Category { get; set; }  // Balance, Security, Transaction

    [DataMember(Order = 5)]
    public string TriggerValue { get; set; }  // the value that breached the threshold

    [DataMember(Order = 6)]
    public string Threshold { get; set; }  // the configured threshold

    [DataMember(Order = 7)]
    public bool NotificationSent { get; set; }

    [DataMember(Order = 8)]
    public DateTime TriggeredDate { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/alerts/")]
public class UpdateAlertRuleResponse
{
    [DataMember(Order = 1)]
    public int AccountAlertID { get; set; }

    [DataMember(Order = 2)]
    public bool Success { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/alerts/")]
public class GetAlertRulesResponse
{
    [DataMember(Order = 1)]
    public int AccountID { get; set; }

    [DataMember(Order = 2)]
    public List<AlertRuleInfo> Rules { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/alerts/")]
public class AlertRuleInfo
{
    [DataMember(Order = 1)]
    public int AccountAlertID { get; set; }

    [DataMember(Order = 2)]
    public int RuleID { get; set; }

    [DataMember(Order = 3)]
    public string RuleCode { get; set; }

    [DataMember(Order = 4)]
    public string RuleName { get; set; }

    [DataMember(Order = 5)]
    public string Category { get; set; }

    [DataMember(Order = 6)]
    public string Threshold { get; set; }

    [DataMember(Order = 7)]
    public string NotificationChannel { get; set; }

    [DataMember(Order = 8)]
    public bool IsEnabled { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/alerts/")]
public class GetAlertHistoryResponse
{
    [DataMember(Order = 1)]
    public int AccountID { get; set; }

    [DataMember(Order = 2)]
    public List<AlertHistoryEntry> History { get; set; }
}

[DataContract(Namespace = "http://zava.bank/wcf/alerts/")]
public class AlertHistoryEntry
{
    [DataMember(Order = 1)]
    public int AlertHistoryID { get; set; }

    [DataMember(Order = 2)]
    public string RuleCode { get; set; }

    [DataMember(Order = 3)]
    public string RuleName { get; set; }

    [DataMember(Order = 4)]
    public string TriggerValue { get; set; }

    [DataMember(Order = 5)]
    public bool NotificationSent { get; set; }

    [DataMember(Order = 6)]
    public DateTime TriggeredDate { get; set; }

    [DataMember(Order = 7)]
    public string Details { get; set; }
}
```

### 4.4 Fault Contract

```csharp
[DataContract(Namespace = "http://zava.bank/wcf/alerts/")]
public class AlertFault
{
    [DataMember]
    public string ErrorCode { get; set; }
    // ACCOUNT_NOT_FOUND, RULE_NOT_FOUND, INVALID_THRESHOLD,
    // EVALUATION_FAILED, NOTIFICATION_FAILED

    [DataMember]
    public string ErrorMessage { get; set; }

    [DataMember]
    public DateTime Timestamp { get; set; }
}
```

### 4.5 XML Examples

**EvaluateTransaction Request:**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:alrt="http://zava.bank/wcf/alerts/">
  <soapenv:Body>
    <alrt:EvaluateTransaction>
      <alrt:request>
        <alrt:TransactionID>990042</alrt:TransactionID>
        <alrt:AccountID>10001</alrt:AccountID>
        <alrt:CustomerID>98765</alrt:CustomerID>
        <alrt:Amount>15000.00</alrt:Amount>
        <alrt:TransactionType>Withdrawal</alrt:TransactionType>
        <alrt:BalanceAfter>85.50</alrt:BalanceAfter>
        <alrt:TransactionDate>2026-05-12T10:40:00Z</alrt:TransactionDate>
        <alrt:Channel>Online</alrt:Channel>
      </alrt:request>
    </alrt:EvaluateTransaction>
  </soapenv:Body>
</soapenv:Envelope>
```

**EvaluateTransaction Response (2 alerts triggered):**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:alrt="http://zava.bank/wcf/alerts/">
  <soapenv:Body>
    <alrt:EvaluateTransactionResponse>
      <alrt:EvaluateTransactionResult>
        <alrt:TransactionID>990042</alrt:TransactionID>
        <alrt:AlertsTriggered>2</alrt:AlertsTriggered>
        <alrt:Alerts>
          <alrt:TriggeredAlert>
            <alrt:AlertHistoryID>7801</alrt:AlertHistoryID>
            <alrt:RuleCode>LOW_BALANCE</alrt:RuleCode>
            <alrt:RuleName>Low Balance Warning</alrt:RuleName>
            <alrt:Category>Balance</alrt:Category>
            <alrt:TriggerValue>85.50</alrt:TriggerValue>
            <alrt:Threshold>100.00</alrt:Threshold>
            <alrt:NotificationSent>true</alrt:NotificationSent>
            <alrt:TriggeredDate>2026-05-12T10:40:01Z</alrt:TriggeredDate>
          </alrt:TriggeredAlert>
          <alrt:TriggeredAlert>
            <alrt:AlertHistoryID>7802</alrt:AlertHistoryID>
            <alrt:RuleCode>LARGE_TXN</alrt:RuleCode>
            <alrt:RuleName>Large Transaction Alert</alrt:RuleName>
            <alrt:Category>Transaction</alrt:Category>
            <alrt:TriggerValue>15000.00</alrt:TriggerValue>
            <alrt:Threshold>10000.00</alrt:Threshold>
            <alrt:NotificationSent>true</alrt:NotificationSent>
            <alrt:TriggeredDate>2026-05-12T10:40:01Z</alrt:TriggeredDate>
          </alrt:TriggeredAlert>
        </alrt:Alerts>
      </alrt:EvaluateTransactionResult>
    </alrt:EvaluateTransactionResponse>
  </soapenv:Body>
</soapenv:Envelope>
```

**UpdateAlertRule Request:**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:alrt="http://zava.bank/wcf/alerts/">
  <soapenv:Body>
    <alrt:UpdateAlertRule>
      <alrt:request>
        <alrt:AccountAlertID>0</alrt:AccountAlertID>
        <alrt:CustomerID>98765</alrt:CustomerID>
        <alrt:AccountID>10001</alrt:AccountID>
        <alrt:RuleID>1</alrt:RuleID>
        <alrt:Threshold>500.00</alrt:Threshold>
        <alrt:NotificationChannel>Email</alrt:NotificationChannel>
        <alrt:IsEnabled>true</alrt:IsEnabled>
      </alrt:request>
    </alrt:UpdateAlertRule>
  </soapenv:Body>
</soapenv:Envelope>
```

**SOAP Fault (rule not found):**

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Body>
    <soapenv:Fault>
      <faultcode>soapenv:Client</faultcode>
      <faultstring>Alert rule not found</faultstring>
      <detail>
        <AlertFault xmlns="http://zava.bank/wcf/alerts/">
          <ErrorCode>RULE_NOT_FOUND</ErrorCode>
          <ErrorMessage>Alert rule ID 999 does not exist</ErrorMessage>
          <Timestamp>2026-05-12T10:41:00Z</Timestamp>
        </AlertFault>
      </detail>
    </soapenv:Fault>
  </soapenv:Body>
</soapenv:Envelope>
```

### 4.6 Database Mapping

| Operation | Tables Read | Tables Written | Stored Procedure |
|---|---|---|---|
| `EvaluateTransaction` | `AccountAlerts`, `AlertRules` | `AlertHistory` | `sp_EvaluateAlerts` |
| `UpdateAlertRule` | `AlertRules` | `AccountAlerts` | — (direct insert/update) |
| `GetAlertRules` | `AccountAlerts`, `AlertRules` | — | — (direct query) |
| `GetAlertHistory` | `AlertHistory`, `AccountAlerts`, `AlertRules` | — | — (direct query) |

### 4.7 RabbitMQ Integration

When `EvaluateTransaction` triggers alerts, the service publishes a `NotificationEvent` (XML) to the `zava.notifications` fanout exchange for each triggered alert. This broadcasts to `q.notify.email` and `q.notify.audit` for notification delivery and audit logging.

The Alert Service also consumes from `q.account.alerts` (bound to `zava.accounts` exchange, routing key `account.alert`) to evaluate alerts triggered by account activity events.

---

## 5. Shared Types

These types are used across multiple service contracts.

```csharp
// Common base for all fault contracts
[DataContract(Namespace = "http://zava.bank/wcf/common/")]
public class ZavaBaseFault
{
    [DataMember]
    public string ErrorCode { get; set; }

    [DataMember]
    public string ErrorMessage { get; set; }

    [DataMember]
    public DateTime Timestamp { get; set; }
}
```

All four services follow the same fault handling pattern from [error-handling-patterns.md](error-handling-patterns.md):
- Business logic errors → typed `FaultException<T>` with specific error codes
- Unexpected errors → generic `FaultException` with "Internal server error" message
- All exceptions are logged before being thrown as faults

---

## 6. Hosting & Endpoint Configuration

All four services are self-hosted via console applications on Mono 6.12. Each uses `BasicHttpBinding` only (no transport security in demoware).

**Typical App.config pattern:**

```xml
<system.serviceModel>
  <services>
    <service name="ZavaRiskEngine.Services.RiskEngineService"
             behaviorConfiguration="DefaultBehavior">
      <endpoint address=""
                binding="basicHttpBinding"
                contract="ZavaRiskEngine.Services.IZavaRiskEngine" />
      <endpoint address="mex"
                binding="mexHttpBinding"
                contract="IMetadataExchange" />
      <host>
        <baseAddresses>
          <add baseAddress="http://0.0.0.0:8090/RiskEngine.svc" />
        </baseAddresses>
      </host>
    </service>
  </services>
  <behaviors>
    <serviceBehaviors>
      <behavior name="DefaultBehavior">
        <serviceMetadata httpGetEnabled="true" />
        <serviceDebug includeExceptionDetailInFaults="true" />
      </behavior>
    </serviceBehaviors>
  </behaviors>
</system.serviceModel>
```

**Service endpoint summary:**

| Service | Port | Endpoint Path | Interface |
|---|---|---|---|
| ZavaRiskEngine | 8090 | `/RiskEngine.svc` | `IZavaRiskEngine` |
| ZavaStatementService | 8091 | `/StatementService.svc` | `IZavaStatementService` |
| ZavaAlertService | 8092 | `/AlertService.svc` | `IZavaAlertService` |
| ZavaCurrencyService | 8093 | `/CurrencyService.svc` | `IZavaCurrencyService` |
