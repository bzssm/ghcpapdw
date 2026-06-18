# Messaging Flow — Zava Bank RabbitMQ Topology

All asynchronous messaging routes through RabbitMQ (/zavabank vhost). Services publish domain events to topic queues; workers consume them. All queues are bound to the `zava.dlx` dead-letter exchange for failed message handling.

## Publishers and Consumers

```mermaid
---
config:
  theme: dark
  themeVariables:
    primaryColor: "#1e3a5f"
    primaryTextColor: "#ffffff"
    lineColor: "#4a7bb5"
---
flowchart LR
    classDef publisher fill:#b07219,stroke:#4a7bb5,color:#ffffff
    classDef dotpub fill:#512bd4,stroke:#4a7bb5,color:#ffffff
    classDef queue fill:#ff6600,stroke:#4a7bb5,color:#ffffff
    classDef consumer fill:#2d7d46,stroke:#4a7bb5,color:#ffffff
    classDef dlx fill:#8b0000,stroke:#4a7bb5,color:#ffffff

    ORI["LoanOriginationAPI\n(Java)"]:::publisher
    PG["PayGateway\n(Java)"]:::publisher
    WTS["WireTransfer\n(Java)"]:::publisher
    FD["FraudDetector\n(Java)"]:::publisher
    ACH["ACHProcessor\n(Java)"]:::publisher
    LED["Ledger\n(Java)"]:::publisher
    AS["AlertService\n(.NET)"]:::dotpub
    QB["QueueBridge\n(.NET)"]:::dotpub

    LQ{{"loan.events"}}:::queue
    PQ{{"payment.events"}}:::queue
    WQ{{"wire.events"}}:::queue
    FQ{{"fraud.alerts"}}:::queue
    AQ{{"audit.events"}}:::queue
    ACHQ{{"ach.results"}}:::queue
    LEQ{{"ledger.events"}}:::queue
    ALQ{{"alert.notifications"}}:::queue
    BQ{{"bridge.incoming"}}:::queue
    DLQ{{"q.deadletter\n(DLX)"}}:::dlx

    NW["NotifyWorker\n(.NET)"]:::consumer
    AW["AuditWorker\n(.NET)"]:::consumer
    LEDC["Ledger\n(consumer)"]:::consumer
    ASC["AlertService\n(consumer)"]:::consumer

    ORI --> LQ & AQ
    PG --> PQ & AQ
    WTS --> WQ & AQ
    FD --> FQ
    ACH --> ACHQ & AQ
    LED --> LEQ
    AS --> ALQ
    QB --> BQ

    LQ --> NW
    PQ --> NW
    WQ --> NW
    FQ --> NW
    FQ --> ASC
    ACHQ --> NW
    ALQ --> NW
    AQ --> AW
    LEQ --> ASC
    BQ --> LEDC

    LQ -.->|"on failure"| DLQ
    PQ -.->|"on failure"| DLQ
    AQ -.->|"on failure"| DLQ
```

## Message Flow Summary

| Queue | Publishers | Consumers | Content |
|-------|-----------|-----------|---------|
| `loan.events` | LoanOriginationAPI | NotifyWorker | Loan approval/denial notifications |
| `payment.events` | PayGateway | NotifyWorker | Payment confirmations |
| `wire.events` | WireTransfer | NotifyWorker | Wire transfer confirmations |
| `fraud.alerts` | FraudDetector | NotifyWorker, AlertService | Fraud alert notifications |
| `audit.events` | OriginationAPI, PayGateway, WireTransfer, ACHProcessor | AuditWorker | Immutable audit trail records |
| `ach.results` | ACHProcessor | NotifyWorker | ACH batch processing results |
| `ledger.events` | Ledger | AlertService | Transaction threshold monitoring |
| `alert.notifications` | AlertService | NotifyWorker | Triggered alert delivery |
| `bridge.incoming` | QueueBridge | Ledger | Re-published file-drop messages |
