# .NET Workstream — Zava Bank

All 11 .NET Framework 4.8 nodes: 4 ASP.NET Web Forms frontends, 4 WCF SOAP services, and 3 background console-app workers. Shows synchronous calls (SOAP/HTTP) and async messaging through RabbitMQ.

```mermaid
---
config:
  theme: dark
  themeVariables:
    primaryColor: "#512bd4"
    primaryTextColor: "#ffffff"
    lineColor: "#4a7bb5"
    secondaryColor: "#3d1f9e"
    tertiaryColor: "#2a1570"
---
flowchart TB
    classDef dotnet fill:#512bd4,stroke:#4a7bb5,color:#ffffff
    classDef wcf fill:#3d1f9e,stroke:#4a7bb5,color:#ffffff
    classDef worker fill:#1e3a5f,stroke:#4a7bb5,color:#ffffff
    classDef database fill:#336791,stroke:#4a7bb5,color:#ffffff
    classDef messaging fill:#ff6600,stroke:#4a7bb5,color:#ffffff
    classDef infra fill:#6c3483,stroke:#4a7bb5,color:#ffffff

    Nginx["nginx :80"]:::infra

    subgraph FE[".NET Frontends — ASP.NET Web Forms / Mono XSP4"]
        LP["ZavaLoanPortal\n:8001"]:::dotnet
        AM["ZavaAccountManager\n:8002"]:::dotnet
        RD["ZavaReportDashboard\n:8006"]:::dotnet
        AG["ZavaAuthGateway\n:8003"]:::dotnet
    end

    subgraph SVC[".NET Services — WCF on Mono"]
        RE["ZavaRiskEngine\n:8005"]:::wcf
        SS["ZavaStatementService\n:8007"]:::wcf
        AS["ZavaAlertService\n:8008"]:::wcf
        CS["ZavaCurrencyService\n:8004"]:::wcf
    end

    subgraph WK[".NET Workers — Console Apps"]
        NW["ZavaNotifyWorker"]:::worker
        AW["ZavaAuditWorker"]:::worker
        QB["ZavaQueueBridge"]:::worker
    end

    SQL[("SQL Server\nZavaBankDB")]:::database
    RMQ{{"RabbitMQ"}}:::messaging
    Mail["MailHog SMTP"]:::infra

    Nginx --> LP & AM & RD
    LP & AM & RD -->|"Forms Auth"| AG
    LP -->|"HTTP POST XML"| RE
    AM -->|"SOAP/WCF"| SS
    RD -->|"SOAP/WCF"| SS
    RD -->|"HTTP GET XML"| RE

    AS -->|"alert.notifications"| RMQ
    RMQ -->|"consume alerts/events"| NW
    RMQ -->|"consume audit.events"| AW
    QB -->|"bridge.incoming"| RMQ

    AG & RE & SS & AS & CS --> SQL
    NW --> SQL
    AW --> SQL
    NW -->|"SMTP :1025"| Mail
```
