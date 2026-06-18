# Infrastructure — Zava Bank Docker Compose

The Docker Compose topology showing 28 containers across 4 networks, 3 volumes, and the dependency layers from infrastructure up through workers.

```mermaid
---
config:
  theme: dark
  themeVariables:
    primaryColor: "#1e3a5f"
    primaryTextColor: "#ffffff"
    lineColor: "#4a7bb5"
---
flowchart TB
    classDef infra fill:#6c3483,stroke:#4a7bb5,color:#ffffff
    classDef dotnet fill:#512bd4,stroke:#4a7bb5,color:#ffffff
    classDef java fill:#b07219,stroke:#4a7bb5,color:#ffffff
    classDef database fill:#336791,stroke:#4a7bb5,color:#ffffff
    classDef messaging fill:#ff6600,stroke:#4a7bb5,color:#ffffff
    classDef network fill:#1e3a5f,stroke:#4a7bb5,color:#ffffff,stroke-dasharray:5

    subgraph L0["Level 0 — Infrastructure"]
        SQL[("SQL Server 2022\n:1433")]:::database
        INIT["sqlserver-init\n(sidecar — runs once)"]:::infra
        RMQ{{"RabbitMQ 3.12\n:5672 / :15672"}}:::messaging
        MAIL["MailHog\n:1025 / :8025"]:::infra
    end

    subgraph L1["Level 1 — Core Services"]
        AG["AuthGateway .NET\n:8003"]:::dotnet
        RE["RiskEngine .NET\n:8005"]:::dotnet
        SS["StatementSvc .NET\n:8007"]:::dotnet
        AS["AlertService .NET\n:8008"]:::dotnet
        CS["CurrencySvc .NET\n:8004"]:::dotnet
        LED["Ledger Java\n:9004"]:::java
        KYC["KYC Java\n:9005"]:::java
        INT["Interest Java\n:9006"]:::java
        ORI["Origination Java\n:9007"]:::java
        DOC["DocVault Java\n:9010"]:::java
        WTS["WireTransfer Java\n:9009"]:::java
    end

    subgraph L2["Level 2 — Frontend Web Apps"]
        LP["LoanPortal .NET\n:8001"]:::dotnet
        AM["AccountMgr .NET\n:8002"]:::dotnet
        RD["ReportDash .NET\n:8006"]:::dotnet
        PG["PayGateway Java\n:9001"]:::java
        FD["FraudDetector Java\n:9003"]:::java
        CR["Compliance Java\n:9008"]:::java
    end

    subgraph L3["Level 3 — Workers"]
        NW["NotifyWorker .NET"]:::dotnet
        AW["AuditWorker .NET"]:::dotnet
        QB["QueueBridge .NET"]:::dotnet
        ACH["ACHProcessor Java"]:::java
        BS["BatchScheduler Java"]:::java
        FI["FileIngestion Java"]:::java
    end

    subgraph L4["Level 4 — Reverse Proxy"]
        NGX["nginx 1.25\n:80"]:::infra
    end

    INIT -->|"init.sh on startup"| SQL
    L1 -->|"depends_on healthy"| SQL
    L1 -->|"depends_on healthy"| RMQ
    L2 -->|"depends_on"| AG
    L2 -->|"depends_on healthy"| SQL
    L3 -->|"depends_on healthy"| SQL & RMQ
    NGX -->|"depends_on healthy"| L2
```

## Network Topology

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
    classDef network fill:#1e3a5f,stroke:#4a7bb5,color:#ffffff
    classDef volume fill:#336791,stroke:#4a7bb5,color:#ffffff

    subgraph Networks
        FN["frontend-net\nnginx, frontends"]:::network
        BN["backend-net\nall services + workers"]:::network
        DN["db-net\nSQL Server + all DB clients"]:::network
        MN["mq-net\nRabbitMQ + all MQ clients"]:::network
    end

    subgraph Volumes
        SQLV["sql-data\nSQL Server persistence"]:::volume
        RMQV["rabbitmq-data\nRabbitMQ persistence"]:::volume
        FDV["shared-filedrop\nFile-based integration"]:::volume
        NLV["nginx-logs\nAccess/error logs"]:::volume
    end

    FN --- BN
    BN --- DN
    BN --- MN
```
