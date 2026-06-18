# System Overview — Zava Bank

The 30,000-foot view of Zava Bank's legacy banking platform. All external traffic enters through nginx on port 80 and is routed to 7 frontend applications, which call backend services backed by a shared SQL Server database and RabbitMQ message broker.

```mermaid
---
config:
  theme: dark
  themeVariables:
    primaryColor: "#1e3a5f"
    primaryTextColor: "#ffffff"
    lineColor: "#4a7bb5"
    secondaryColor: "#2d4a6f"
    tertiaryColor: "#1a2e4a"
---
flowchart TB
    classDef default fill:#1e3a5f,stroke:#4a7bb5,color:#ffffff
    classDef frontend fill:#2d7d46,stroke:#4a7bb5,color:#ffffff
    classDef infra fill:#6c3483,stroke:#4a7bb5,color:#ffffff
    classDef database fill:#336791,stroke:#4a7bb5,color:#ffffff
    classDef messaging fill:#ff6600,stroke:#4a7bb5,color:#ffffff

    Browser["🌐 Browser Clients"]:::default

    subgraph PROXY["Reverse Proxy"]
        Nginx["nginx :80"]:::infra
    end

    subgraph FRONTENDS["Frontend Applications (7 nodes)"]
        direction LR
        DotNetFE[".NET Web Forms (4)\nLoanPortal · AccountMgr\nReportDashboard · AuthGateway"]:::frontend
        JavaFE["Java Struts/JSP (3)\nPayGateway · FraudDetector\nComplianceReporter"]:::frontend
    end

    subgraph SERVICES["Backend Services (9 nodes)"]
        direction LR
        DotNetSvc[".NET WCF Services (4)\nRiskEngine · StatementSvc\nAlertService · CurrencySvc"]:::frontend
        JavaSvc["Java Servlet APIs (6)\nLedger · KYC · Interest\nOrigination · DocVault · WireTransfer"]:::frontend
    end

    subgraph WORKERS["Background Workers (7 nodes)"]
        direction LR
        DotNetWk[".NET Workers (3)\nNotifyWorker · AuditWorker\nQueueBridge"]:::frontend
        JavaWk["Java Workers (4)\nACHProcessor · BatchScheduler\nFileIngestion · (unused slot)"]:::frontend
    end

    subgraph DATA["Data Layer"]
        direction LR
        SQL[("SQL Server\nZavaBankDB :1433")]:::database
        RMQ{{"RabbitMQ\n:5672 / :15672"}}:::messaging
        FileDrop["Shared FileDrop\nVolume"]:::database
    end

    Browser -->|"HTTP :80"| Nginx
    Nginx -->|"path routing"| FRONTENDS
    FRONTENDS -->|"SOAP/WCF & HTTP/XML"| SERVICES
    SERVICES -->|"publish events"| RMQ
    RMQ -->|"consume queues"| WORKERS
    FRONTENDS -->|"ADO.NET / JDBC"| SQL
    SERVICES -->|"ADO.NET / JDBC"| SQL
    WORKERS -->|"read/write"| SQL
    WORKERS -.->|"file I/O"| FileDrop
```
