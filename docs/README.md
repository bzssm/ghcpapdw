# Zava Bank Documentation

> **Zava Bank** is a 28-service Docker Compose legacy banking demoware system built to simulate enterprise banking architecture from the 2005–2015 era. It spans 23 application services (11 .NET, 12 Java) and 5 infrastructure containers, all orchestrated through Docker Compose and routed via an nginx reverse proxy.

> [!TIP]
> Use this page as your starting point for navigating all Zava Bank documentation — architecture, diagrams, service catalog, and demo guides.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Architecture Diagrams](#architecture-diagrams)
- [Architecture Documentation](#architecture-documentation)
- [Demo & Guides](#demo--guides)
- [Service Catalog](#service-catalog)
- [Infrastructure](#infrastructure)

---

## Quick Start

```bash
# Build and start all 28 containers
docker compose up --build

# Wait for SQL init to complete and health checks to pass (~60s)
```

| Item | Value |
|------|-------|
| **Entry point** | [http://localhost/](http://localhost/) |
| **Login page** | [http://localhost/auth/](http://localhost/auth/) |
| **Username** | `admin` |
| **Password** | `Password1!` |
| **RabbitMQ UI** | [http://localhost:15672](http://localhost:15672) (`zava_app` / `zava_pass`) |
| **MailHog UI** | [http://localhost:8025](http://localhost:8025) |

> [!NOTE]
> All application traffic flows through nginx on port 80. Individual service ports (8001–9010) are also exposed for direct access during development.

---

## Architecture Diagrams

Visual overviews of the Zava Bank system rendered as Mermaid diagrams.

| Diagram | Description |
|---------|-------------|
| [System Overview](diagrams/system-overview.md) | High-level system context — all 28 containers at a glance |
| [.NET Workstream](diagrams/dotnet-workstream.md) | 11 .NET nodes and their relationships |
| [Java Workstream](diagrams/java-workstream.md) | 12 Java nodes and their relationships |
| [Data Flow](diagrams/data-flow.md) | Loan and payment flow sequence diagrams |
| [Infrastructure](diagrams/infrastructure.md) | Docker Compose infrastructure and networking |
| [Messaging Flow](diagrams/messaging-flow.md) | RabbitMQ exchanges, queues, and routing topology |
| [Database Schema](diagrams/database-schema.md) | ER diagram of the main ZavaBankDB tables |

---

## Architecture Documentation

Deep-dive reference docs for each architectural concern.

| Document | Description |
|----------|-------------|
| [System Topology](architecture/system-topology.md) | Complete 28-service inventory, inter-service communication map, network layout |
| [Service Contracts](architecture/service-contracts.md) | WCF ServiceContract definitions, SOAP data contracts, endpoint configuration |
| [Database Topology](architecture/database-topology.md) | ZavaBankDB schema — 42 tables, 28+ stored procedures, seed data strategy |
| [Configuration Management](architecture/configuration-management.md) | web.config / app.config / properties files, env var injection, secrets strategy |

---

## Demo & Guides

| Guide | Description |
|-------|-------------|
| [10-Minute Demo Scenario](demo-scenario.md) | Step-by-step walkthrough: login, accounts, loans, payments, fraud, reports, compliance, and cross-ecosystem SSO |

---

## Service Catalog

### .NET Services (11)

| Service | Type | Tech Stack | nginx Route | Description |
|---------|------|------------|-------------|-------------|
| **ZavaAuth Gateway** | Service | ASP.NET 4.x (HTTP Handlers + Forms Auth) | `/auth/` | Centralized authentication — issues FormsAuth tickets, session tokens shared across ecosystems |
| **ZavaRisk Engine** | Service | WCF, .NET Framework 4.8 | `/services/risk/` | SOAP-based credit risk scoring — accepts loan apps, returns risk rating (A–F) |
| **ZavaStatement Service** | Service | WCF, .NET Framework 4.8 | `/services/statements/` | Generates monthly PDF account statements over SOAP |
| **ZavaAlert Service** | Service | WCF, .NET Framework 4.8 | `/services/alerts/` | Real-time alert rules engine — monitors transactions, pushes to RabbitMQ |
| **ZavaCurrency Service** | Service | WCF, .NET Framework 4.8 | `/services/currency/` | Foreign exchange rate lookup from static rate table |
| **ZavaLoan Portal** | Frontend | ASP.NET 4.x Web Forms | `/loans/` | Customer-facing loan application wizard with GridView history |
| **ZavaAccount Manager** | Frontend | ASP.NET 4.x Web Forms | `/accounts/` | Internal employee tool — manage accounts, view balances, update customer details |
| **ZavaReport Dashboard** | Frontend | ASP.NET 4.x Web Forms | `/reports/` | Internal reporting portal — RDLC report viewer for loan and transaction summaries |
| **ZavaNotify Worker** | Worker | .NET Framework 4.8 Console (Mono) | — | Polls RabbitMQ for notifications, sends email via SMTP |
| **ZavaAudit Worker** | Worker | .NET Framework 4.8 Console (Mono) | — | Consumes audit events from RabbitMQ, writes to immutable AuditLog table |
| **ZavaQueue Bridge** | Worker | .NET Framework 4.8 Console (Mono) | — | Reads file-drop messages and republishes to RabbitMQ — bridges .NET-to-Java messaging |

### Java Services (12)

| Service | Type | Tech Stack | nginx Route | Description |
|---------|------|------------|-------------|-------------|
| **ZavaPay Gateway** | Frontend | Java 8, Struts 1.x, JSP | `/payments/` | Payment processing — credit card, ACH, and bill pay via Struts ActionForms |
| **ZavaFraud Detector** | Frontend | Java 11, Struts 2.x, JSP | `/fraud/` | Fraud analysis dashboard — analysts review flagged transactions, manage rules |
| **ZavaCompliance Reporter** | Frontend | Java 8, JSP/Servlet | `/compliance/` | Regulatory reporting — CTR and SAR generation for FinCEN filing |
| **ZavaLedger** | Service | Java 17, Servlet | `/ledger/` | Core banking ledger — double-entry bookkeeping, transaction posting (XML over HTTP) |
| **ZavaKYC Service** | Service | Java 8, Servlet | `/kyc/` | Know Your Customer identity verification against watchlists |
| **ZavaInterest Calculator** | Service | Java 8, Servlet | `/interest/` | Interest accrual for savings, loans, and CDs — simple, compound, amortized |
| **ZavaLoan Origination API** | Service | Java 11, Servlet | `/origination/` | Backend loan workflow — orchestrates KYC, risk scoring, ledger account creation |
| **ZavaDoc Vault** | Service | Java 8, JSP/Servlet | `/documents/` | Document management — stores scanned docs as BLOBs in SQL Server |
| **ZavaWire Transfer Service** | Service | Java 11, Servlet | `/transfers/` | Domestic and international wire transfers with FX conversion |
| **ZavaACH Processor** | Worker | Java 8, Console | — | Processes NACHA-formatted ACH batch files from file-drop volume |
| **ZavaBatch Scheduler** | Worker | Java 8, Console | — | Nightly batch orchestrator — interest accrual, statement generation, reconciliation |
| **ZavaFile Ingestion** | Worker | Java 8, Console | — | Monitors file-drop for incoming data files, parses CSV/fixed-width into staging tables |

---

## Infrastructure

| Component | Technology | Port(s) | Description |
|-----------|-----------|---------|-------------|
| **sqlserver** | SQL Server 2022 (Linux) | 1433 | Shared `ZavaBankDB` database — all 23 services connect here |
| **sqlserver-init** | SQL Server 2022 (init sidecar) | — | Runs `infrastructure/sql/init.sh` on startup to create schema, stored procs, and seed data. Exits after completion. |
| **rabbitmq** | RabbitMQ 3.12 Management | 5672, 15672 | Message broker — 8 exchanges, 15 queues, DLX support |
| **mailhog** | MailHog | 1025, 8025 | Dev SMTP trap — captures all outbound email from ZavaNotify |
| **nginx-proxy** | Nginx 1.25 Alpine | 80 | Reverse proxy — routes all traffic by path prefix to backend services |

### Docker Networks

| Network | Purpose |
|---------|---------|
| `frontend-net` | Connects nginx to web-facing frontends |
| `backend-net` | Internal service-to-service communication |
| `db-net` | SQL Server access |
| `mq-net` | RabbitMQ access |

### Shared Volumes

| Volume | Purpose |
|--------|---------|
| `sql-data` | SQL Server data persistence |
| `rabbitmq-data` | RabbitMQ queue persistence |
| `nginx-logs` | Nginx access and error logs |
| `shared-filedrop` | File-based integration — ACH files, check images, wire confirmations |
