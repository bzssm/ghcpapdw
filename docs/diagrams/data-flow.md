# Data Flow — Zava Bank

Two key business flows: a loan application lifecycle and a payment/wire transfer flow. These show how requests traverse the .NET and Java workstreams end-to-end.

## Loan Application Flow

```mermaid
---
config:
  theme: dark
  themeVariables:
    primaryColor: "#1e3a5f"
    primaryTextColor: "#ffffff"
    lineColor: "#4a7bb5"
---
sequenceDiagram
    participant User as 🌐 Browser
    participant Nginx as nginx
    participant LP as LoanPortal<br/>(.NET)
    participant AG as AuthGateway<br/>(.NET)
    participant ORI as OriginationAPI<br/>(Java)
    participant KYC as KYCService<br/>(Java)
    participant RE as RiskEngine<br/>(.NET WCF)
    participant LED as Ledger<br/>(Java)
    participant SQL as SQL Server
    participant RMQ as RabbitMQ
    participant NW as NotifyWorker
    participant AW as AuditWorker

    User->>Nginx: POST /loans/apply
    Nginx->>LP: route to LoanPortal
    LP->>AG: authenticate (Forms Auth)
    AG->>SQL: validate credentials
    AG-->>LP: auth ticket
    LP->>ORI: HTTP POST XML (loan application)
    ORI->>KYC: HTTP POST (identity check)
    KYC->>SQL: query KYCRecords
    KYC-->>ORI: KYC pass/fail
    ORI->>RE: SOAP ScoreLoan()
    RE->>SQL: read CreditScores, RiskFactors
    RE-->>ORI: risk rating (A-F) + max amount
    ORI->>LED: HTTP POST (create loan account)
    LED->>SQL: INSERT Accounts + Transactions
    LED-->>ORI: account created
    ORI->>RMQ: publish loan.events
    ORI->>RMQ: publish audit.events
    RMQ-->>NW: loan approval notification
    RMQ-->>AW: audit record
    NW->>SQL: log notification
    AW->>SQL: write AuditLog
    ORI-->>LP: approval response
    LP-->>Nginx: render result page
    Nginx-->>User: loan decision
```

## Payment and Wire Transfer Flow

```mermaid
---
config:
  theme: dark
  themeVariables:
    primaryColor: "#1e3a5f"
    primaryTextColor: "#ffffff"
    lineColor: "#4a7bb5"
---
sequenceDiagram
    participant User as 🌐 Browser
    participant Nginx as nginx
    participant PG as PayGateway<br/>(Java Struts)
    participant FD as FraudDetector<br/>(Java)
    participant CS as CurrencyService<br/>(.NET WCF)
    participant WTS as WireTransfer<br/>(Java)
    participant LED as Ledger<br/>(Java)
    participant SQL as SQL Server
    participant RMQ as RabbitMQ
    participant AS as AlertService
    participant NW as NotifyWorker

    User->>Nginx: POST /payments/submit
    Nginx->>PG: route to PayGateway
    PG->>FD: HTTP POST (fraud check)
    FD->>SQL: query FraudRules + history
    FD-->>PG: fraud score (pass)
    PG->>CS: SOAP GetExchangeRate()
    CS-->>PG: FX rate
    PG->>LED: HTTP POST XML (payment)
    LED->>SQL: INSERT Transactions
    LED->>RMQ: publish ledger.events
    RMQ-->>AS: threshold monitoring
    PG->>RMQ: publish payment.events
    RMQ-->>NW: payment confirmation
    PG-->>Nginx: payment result
    Nginx-->>User: confirmation page

    Note over User,NW: Wire Transfer (international)

    User->>Nginx: POST /transfers/wire
    Nginx->>WTS: route to WireTransfer
    WTS->>CS: SOAP GetExchangeRate()
    CS-->>WTS: FX rate
    WTS->>LED: HTTP POST XML (debit + credit)
    LED->>SQL: double-entry posting
    WTS->>RMQ: publish wire.events + audit.events
    RMQ-->>NW: wire confirmation
    WTS-->>Nginx: transfer result
    Nginx-->>User: wire confirmation
```
