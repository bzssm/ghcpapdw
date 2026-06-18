# Zava Bank — System Topology

> **Author:** lead_architect  
> **Date:** 2026-05-14  
> **Status:** Active  
> **Revision:** 1.1

## Overview

Zava Bank's legacy banking platform is a 23-node distributed system built between 2005–2015. It spans two technology ecosystems — Microsoft .NET Framework 4.x and Java (8/11/17) — connected through SOAP/WCF, REST-ish HTTP, message queues, shared databases, and file drops. The architecture reflects real enterprise banking patterns of that era: thick server-rendered frontends, XML-configured services, synchronous RPC calls, and background workers polling queues and file shares.

**Total Application Nodes:** 23  
**Infrastructure Containers:** 5 (including sqlserver-init sidecar)  
**Technology Split:** 11 .NET nodes, 12 Java nodes

---

## 1. Complete Node Inventory

### 1.1 .NET Workstream (11 Nodes)

| # | Node Name | Tech Stack | Node Type | Port | Description |
|---|-----------|-----------|-----------|------|-------------|
| 1 | **ZavaLoan Portal** | ASP.NET 4.x Web Forms, .NET Framework 4.8 | Frontend | 8080 | Customer-facing loan application portal. Multi-step loan wizard with GridView history, UpdatePanels, ViewState. Uses server controls (TextBox, DropDownList, GridView, Wizard) — Wingtip Toys style. |
| 2 | **ZavaAccount Manager** | ASP.NET 4.x Web Forms, .NET Framework 4.8 | Frontend | 8081 | Internal employee tool for managing customer accounts — open/close accounts, view balances, update customer details. Master-detail GridView with edit/delete commands. |
| 3 | **ZavaReport Dashboard** | ASP.NET 4.x Web Forms, .NET Framework 4.8 | Frontend | 8082 | Internal reporting portal. Crystal Reports-style RDLC report viewer embedded in Web Forms pages. Loan portfolio summaries, delinquency reports, daily transaction volumes. |
| 4 | **ZavaRisk Engine** | WCF Service, .NET Framework 4.8 | API/Service | 8090 | SOAP-based credit risk scoring engine. Accepts loan applications, runs scoring rules, returns risk rating (A–F) and max approved amount. Exposes `.svc` endpoints with WSDL. |
| 5 | **ZavaStatement Service** | WCF Service, .NET Framework 4.8 | API/Service | 8091 | Generates monthly account statements as PDF. Called by batch scheduler and on-demand by Account Manager. Returns base64-encoded PDF over SOAP. |
| 6 | **ZavaAlert Service** | WCF Service, .NET Framework 4.8 | API/Service | 8092 | Real-time alert rules engine. Monitors transactions for threshold breaches (large withdrawals, international transfers, low balance). Pushes alert messages to RabbitMQ for ZavaNotify to deliver. |
| 7 | **ZavaCurrency Service** | WCF Service, .NET Framework 4.8 | API/Service | 8093 | Foreign exchange rate lookup. Serves daily FX rates from a static table (updated by batch import). Used by ZavaPay Gateway and ZavaWire Transfer for currency conversion. |
| 8 | **ZavaAuth Gateway** | ASP.NET 4.x (HTTP Handlers + Forms Auth), .NET Framework 4.8 | API/Service | 8094 | Centralized authentication service. Issues FormsAuthentication tickets. All .NET frontends redirect here for login. Stores credentials in SQL Server with SHA-1 hashing (era-appropriate). |
| 9 | **ZavaNotify** | .NET Framework 4.8 Console App | Background Worker | — | Polls RabbitMQ for notification messages. Sends email via SMTP and formats SMS payloads. Runs in a `while(true)` loop with `Thread.Sleep`. No modern hosting — raw `Program.Main`. |
| 10 | **ZavaAudit Worker** | .NET Framework 4.8 Console App | Queue Processor | — | Consumes audit events from RabbitMQ. Writes immutable audit trail records to a dedicated `AuditLog` table in SQL Server. Every service publishes audit events for compliance. |
| 11 | **ZavaQueue Bridge** | .NET Framework 4.8 Console App | Queue Processor | — | Legacy integration bridge. Reads messages from a file-drop folder (simulating MSMQ/mainframe output) and republishes them to RabbitMQ for consumption by Java services. Bridges the .NET-to-Java messaging gap. |

### 1.2 Java Workstream (12 Nodes)

| # | Node Name | Tech Stack | Node Type | Port | Description |
|---|-----------|-----------|-----------|------|-------------|
| 12 | **ZavaPay Gateway** | Java 8, Struts 1.x, JSP, Gradle | Frontend | 8180 | Payment processing portal. Struts 1.x with `ActionForm` classes, `struts-config.xml`, and JSP views using Struts tag libraries. Processes credit card payments, ACH debits, and bill pay. |
| 13 | **ZavaFraud Detector** | Java 11, Struts 2.x, JSP, Gradle | Frontend | 8181 | Fraud analysis dashboard and rule engine. Struts 2.x with `ActionSupport` classes, interceptor stacks, and OGNL expressions. Analysts review flagged transactions and manage fraud rules. |
| 14 | **ZavaCompliance Reporter** | Java 8, JSP/Servlet, Gradle | Frontend | 8182 | Regulatory compliance reporting portal. Generates CTR (Currency Transaction Reports) and SAR (Suspicious Activity Reports) for FinCEN filing. JSP pages with JSTL tags, raw Servlet controllers. |
| 15 | **ZavaLedger** | Java 17, Servlet, Gradle | API/Service | 8190 | Core banking ledger — the converted mainframe engine. Double-entry bookkeeping, account balances, transaction posting. Exposes REST-ish HTTP endpoints (but with XML request/response bodies, not JSON). |
| 16 | **ZavaKYC Service** | Java 8, Servlet, Gradle | API/Service | 8191 | Know Your Customer identity verification. Validates customer identity documents against watchlists. Synchronous HTTP API called during account opening and loan origination. |
| 17 | **ZavaInterest Calculator** | Java 8, Servlet, Gradle | API/Service | 8192 | Calculates accrued interest for all account types (savings, loans, CDs). Called nightly by ZavaBatch Scheduler and on-demand by ZavaLedger. Supports simple, compound, and amortized interest. |
| 18 | **ZavaLoan Origination API** | Java 11, Servlet, Gradle | API/Service | 8193 | Backend loan origination workflow. Receives loan applications from ZavaLoan Portal (via HTTP), orchestrates KYC check, risk scoring, and ledger account creation. Returns approval/denial. |
| 19 | **ZavaDoc Vault** | Java 8, JSP/Servlet, Gradle | API/Service | 8194 | Document management system. Stores and retrieves scanned documents (IDs, pay stubs, signed agreements) as BLOBs in SQL Server. JSP upload form + Servlet download endpoint. |
| 20 | **ZavaWire Transfer Service** | Java 11, Servlet, Gradle | API/Service | 8195 | Processes domestic and international wire transfers. Validates routing numbers, applies FX conversion (calls ZavaCurrency Service), posts to ZavaLedger. Publishes transfer events to RabbitMQ. |
| 21 | **ZavaACH Processor** | Java 8, Console (plain `main()`), Gradle | Queue Processor | — | Processes ACH (Automated Clearing House) batch files. Reads NACHA-formatted files from the shared file-drop volume, parses transactions, posts each to ZavaLedger, publishes results to RabbitMQ. |
| 22 | **ZavaBatch Scheduler** | Java 8, Console (plain `main()`), Gradle | Background Worker | — | Nightly batch orchestrator. Triggers end-of-day processing: interest accrual (calls ZavaInterest Calculator), statement generation (calls ZavaStatement Service via HTTP), and daily reconciliation against ZavaLedger. Runs on a `ScheduledExecutorService` timer. |
| 23 | **ZavaFile Ingestion** | Java 8, Console (plain `main()`), Gradle | Background Worker | — | Monitors a shared file-drop directory for incoming data files (check images, wire confirmations, regulatory feeds). Parses CSV/fixed-width files and inserts records into SQL Server staging tables. |

### 1.3 Infrastructure Nodes (5)

| Node Name | Technology | Port(s) | Description |
|-----------|-----------|---------|-------------|
| **sqlserver** | SQL Server 2022 (Linux container) | 1433 | Shared relational database (`ZavaBankDB`). All services read/write here. Multiple schemas partition the data by domain (see §5). |
| **sqlserver-init** | SQL Server 2022 (init sidecar) | — | One-shot init container. Runs `infrastructure/sql/init.sh` to create the database schema, stored procedures, and seed data. Exits after completion (`restart: "no"`). |
| **rabbitmq** | RabbitMQ 3.12 (Management Plugin) | 5672, 15672 | Message broker. Replaces what would have been MSMQ in the real system. Used for async event distribution between services. |
| **mailhog** | MailHog | 1025, 8025 | Dev SMTP server. ZavaNotify sends email here. Web UI on 8025 lets demo operators see sent emails. |
| **nginx-proxy** | Nginx 1.25 Alpine | 80 | Reverse proxy / API gateway. Routes external traffic to frontends by path prefix. Serves as the single entry point. |

> [!NOTE]
> The `shared-filedrop` Docker volume (not a container) is mounted into ZavaQueue Bridge, ZavaACH Processor, ZavaFile Ingestion, ZavaDoc Vault, ZavaStatement Service, and ZavaBatch Scheduler to simulate legacy file-based integration.

---

## 2. Inter-Service Communication Map

### 2.1 Synchronous Calls (SOAP/WCF & REST HTTP)

| Caller | Callee | Protocol | Data Flow |
|--------|--------|----------|-----------|
| ZavaLoan Portal | ZavaAuth Gateway | HTTP (Forms Auth) | Login credentials → auth ticket |
| ZavaLoan Portal | ZavaLoan Origination API | HTTP POST (XML) | Loan application form data → origination request |
| ZavaLoan Portal | ZavaDoc Vault | HTTP POST (multipart) | Upload supporting documents (IDs, pay stubs) |
| ZavaAccount Manager | ZavaAuth Gateway | HTTP (Forms Auth) | Employee login → auth ticket |
| ZavaAccount Manager | ZavaLedger | HTTP GET/POST (XML) | Account CRUD, balance inquiries |
| ZavaAccount Manager | ZavaStatement Service | SOAP/WCF | Request statement generation → PDF (base64) |
| ZavaReport Dashboard | ZavaAuth Gateway | HTTP (Forms Auth) | Employee login → auth ticket |
| ZavaReport Dashboard | ZavaLedger | HTTP GET (XML) | Query aggregate transaction data for reports |
| ZavaReport Dashboard | ZavaStatement Service | SOAP/WCF | Pull historical statement metadata |
| ZavaRisk Engine | SQL Server | Shared DB | Reads customer credit history, writes risk scores |
| ZavaLoan Origination API | ZavaRisk Engine | SOAP/WCF | Loan application → risk score (A–F) + max amount |
| ZavaLoan Origination API | ZavaKYC Service | HTTP POST (XML) | Customer identity data → KYC pass/fail |
| ZavaLoan Origination API | ZavaLedger | HTTP POST (XML) | Create loan account, post initial disbursement |
| ZavaLoan Origination API | ZavaFraud Detector | HTTP POST (XML) | Application data → fraud risk flag |
| ZavaPay Gateway | ZavaLedger | HTTP POST (XML) | Payment transactions → ledger postings |
| ZavaPay Gateway | ZavaCurrency Service | SOAP/WCF | Currency code → exchange rate |
| ZavaPay Gateway | ZavaFraud Detector | HTTP POST (XML) | Transaction data → fraud check result |
| ZavaFraud Detector | ZavaLedger | HTTP GET (XML) | Query recent transaction history for pattern analysis |
| ZavaFraud Detector | ZavaKYC Service | HTTP GET (XML) | Retrieve customer KYC status for risk correlation |
| ZavaWire Transfer Service | ZavaLedger | HTTP POST (XML) | Wire debit/credit → ledger postings |
| ZavaWire Transfer Service | ZavaCurrency Service | SOAP/WCF | FX rate lookup for international wires |
| ZavaWire Transfer Service | ZavaKYC Service | HTTP GET (XML) | Verify beneficiary identity for compliance |
| ZavaCompliance Reporter | ZavaLedger | HTTP GET (XML) | Query transactions over reporting thresholds |
| ZavaCompliance Reporter | ZavaKYC Service | HTTP GET (XML) | Pull KYC records for SAR/CTR filing |
| ZavaBatch Scheduler | ZavaInterest Calculator | HTTP POST (XML) | Account list → calculated interest amounts |
| ZavaBatch Scheduler | ZavaStatement Service | HTTP POST (XML) | Trigger monthly statement generation |
| ZavaBatch Scheduler | ZavaLedger | HTTP POST (XML) | Post interest accrual entries, daily reconciliation |
| ZavaAlert Service | SQL Server | Shared DB | Reads alert rules, writes triggered alerts |

### 2.2 Asynchronous Messaging (RabbitMQ)

> [!NOTE]
> **Dead-Letter Queue Pattern:** All queues in this table are bound to the `zava.dlx` dead-letter exchange. When messages fail processing or are rejected, they are automatically routed to `q.deadletter` for inspection and manual retry. See **messaging-topology.md §1.2** for DLQ exchange configuration and retry policies.

| Publisher | Queue/Exchange | Consumer | Message Content |
|-----------|---------------|----------|-----------------|
| ZavaLoan Origination API | `loan.events` | ZavaNotify | Loan approval/denial notifications |
| ZavaLoan Origination API | `audit.events` | ZavaAudit Worker | Loan origination audit records |
| ZavaPay Gateway | `payment.events` | ZavaNotify | Payment confirmation notifications |
| ZavaPay Gateway | `audit.events` | ZavaAudit Worker | Payment transaction audit records |
| ZavaWire Transfer Service | `wire.events` | ZavaNotify | Wire transfer confirmation/failure |
| ZavaWire Transfer Service | `audit.events` | ZavaAudit Worker | Wire transfer audit records |
| ZavaFraud Detector | `fraud.alerts` | ZavaNotify | Fraud alert notifications to customer/ops |
| ZavaFraud Detector | `fraud.alerts` | ZavaAlert Service | Fraud events for real-time alert evaluation |
| ZavaAlert Service | `alert.notifications` | ZavaNotify | Triggered alert messages for delivery |
| ZavaACH Processor | `ach.results` | ZavaNotify | ACH processing confirmations/failures |
| ZavaACH Processor | `audit.events` | ZavaAudit Worker | ACH processing audit records |
| ZavaLedger | `ledger.events` | ZavaAlert Service | Transaction posted events for threshold monitoring |
| ZavaQueue Bridge | `bridge.incoming` | ZavaLedger | Re-published messages from file drops (legacy bridge) |

### 2.3 File-Based Integration (Shared Volume)

| Writer | Reader | File Pattern | Content |
|--------|--------|-------------|---------|
| External (simulated) | ZavaACH Processor | `ach_batch_*.nacha` | NACHA-formatted ACH batch files |
| External (simulated) | ZavaFile Ingestion | `check_images_*.csv`, `wire_confirm_*.dat` | Check image metadata, wire confirmations |
| ZavaQueue Bridge | (reads from volume) | `msmq_export_*.xml` | Simulated MSMQ message exports for Java consumption |
| ZavaBatch Scheduler | ZavaFile Ingestion | `daily_recon_*.csv` | Daily reconciliation output files |

### 2.4 Shared Database Access

All services connect to the single SQL Server instance (`zava-sqlserver`). Data is partitioned by schema:

| Schema | Tables (Key) | Primary Readers/Writers |
|--------|-------------|------------------------|
| `dbo.Accounts` | Customers, Accounts, AccountTypes | ZavaAccount Manager, ZavaLedger |
| `dbo.Loans` | LoanApplications, LoanProducts, LoanPayments | ZavaLoan Portal, ZavaLoan Origination API, ZavaRisk Engine |
| `dbo.Transactions` | Transactions, TransactionTypes | ZavaLedger, ZavaPay Gateway, ZavaWire Transfer |
| `dbo.Fraud` | FraudRules, FlaggedTransactions, FraudCases | ZavaFraud Detector |
| `dbo.KYC` | CustomerIdentity, Watchlists, VerificationLog | ZavaKYC Service |
| `dbo.Compliance` | CTRReports, SARReports, RegulatoryFilings | ZavaCompliance Reporter |
| `dbo.Documents` | Documents, DocumentTypes | ZavaDoc Vault |
| `dbo.Notifications` | NotificationTemplates, NotificationLog | ZavaNotify |
| `dbo.Alerts` | AlertRules, AlertHistory | ZavaAlert Service |
| `dbo.Audit` | AuditLog | ZavaAudit Worker |
| `dbo.Currency` | ExchangeRates, CurrencyPairs | ZavaCurrency Service |
| `dbo.Auth` | Users, Roles, Sessions | ZavaAuth Gateway |
| `dbo.Statements` | StatementRuns, StatementArchive | ZavaStatement Service |
| `dbo.Batch` | BatchJobs, BatchResults | ZavaBatch Scheduler |

---

## 3. Workstream Decomposition

### 3.1 .NET Workstream

**Build System:** MSBuild (`.csproj` / `.sln` files)  
**Runtime:** .NET Framework 4.8  
**IDE:** Visual Studio (solution file)

| Category | Nodes |
|----------|-------|
| **Frontends** (ASP.NET 4.x Web Forms) | ZavaLoan Portal, ZavaAccount Manager, ZavaReport Dashboard |
| **API/Services** (WCF) | ZavaRisk Engine, ZavaStatement Service, ZavaAlert Service, ZavaCurrency Service |
| **API/Services** (ASP.NET HTTP Handlers) | ZavaAuth Gateway |
| **Background Workers** (Console Apps) | ZavaNotify, ZavaAudit Worker, ZavaQueue Bridge |

**Folder Layout:** Each .NET app lives in its own root-level folder (see §3.4). Each folder contains its own `.csproj` and `Dockerfile`. A root-level `ZavaBank.sln` references all projects for local dev convenience, but each folder is designed to become its own standalone repo.

### 3.2 Java Workstream

**Build System:** Gradle (multi-project build)  
**Runtime:** Java 8, 11, or 17 (varies by node — see inventory)  
**IDE:** VS Code (Gradle project)

| Category | Nodes |
|----------|-------|
| **Frontends** (Struts 1.x) | ZavaPay Gateway |
| **Frontends** (Struts 2.x) | ZavaFraud Detector |
| **Frontends** (JSP/Servlet) | ZavaCompliance Reporter |
| **API/Services** (Servlet) | ZavaLedger, ZavaKYC Service, ZavaInterest Calculator, ZavaLoan Origination API, ZavaWire Transfer Service |
| **API/Services** (JSP/Servlet) | ZavaDoc Vault |
| **Background Workers** (Console) | ZavaACH Processor, ZavaBatch Scheduler, ZavaFile Ingestion |

**Folder Layout:** Each Java app lives in its own root-level folder (see §3.4). Each folder contains its own `build.gradle`, `settings.gradle`, and `Dockerfile`. Each folder is self-contained with its own Gradle build — no shared multi-project build. Each is designed to become its own standalone repo.

### 3.3 Infrastructure

| Node | Purpose | Owned By |
|------|---------|----------|
| zava-sqlserver | Relational data store for all services | expert_docker |
| zava-rabbitmq | Async messaging broker | expert_docker |
| zava-nginx | Reverse proxy / unified entry point | expert_docker |
| zava-mailhog | Dev SMTP server for notification testing | expert_docker |
| zava-filedrop | Shared volume for file-based integration | expert_docker |

### 3.4 Folder Structure (Repo-per-App Layout)

Each of the 23 application nodes lives in its own **root-level folder**. Each folder is self-contained with its own build files, source code, and Dockerfile — designed to eventually become its own GitHub repository for the at-scale modernization demo.

Infrastructure config (SQL Server, RabbitMQ, Nginx, MailHog) shares a single `infrastructure/` folder since those won't become separate repos.

| Folder | Tech Stack | Port |
|--------|-----------|------|
| `docker-compose.yml` | orchestrates all 28 containers | — |
| `ZavaAccountManager/` | ASP.NET 4.x Web Forms | :8081 |
| `ZavaAchProcessor/` | Java 8 Console | (no port) |
| `ZavaAlertService/` | WCF Service (.NET 4.8) | :8092 |
| `ZavaAuditWorker/` | .NET Console App | (no port) |
| `ZavaAuthGateway/` | ASP.NET HTTP Handlers | :8094 |
| `ZavaBatchScheduler/` | Java 8 Console | (no port) |
| `ZavaComplianceReporter/` | JSP/Servlet, Java 8 | :8182 |
| `ZavaCurrencyService/` | WCF Service (.NET 4.8) | :8093 |
| `ZavaDocVault/` | JSP/Servlet, Java 8 | :8194 |
| `ZavaFileIngestion/` | Java 8 Console | (no port) |
| `ZavaFraudDetector/` | Struts 2.x, Java 11 | :8181 |
| `ZavaInterestCalculator/` | Servlet, Java 8 | :8192 |
| `ZavaKycService/` | Servlet, Java 8 | :8191 |
| `ZavaLedger/` | Servlet, Java 17 | :8190 |
| `ZavaLoanOriginationApi/` | Servlet, Java 11 | :8193 |
| `ZavaLoanPortal/` | ASP.NET 4.x Web Forms | :8080 |
| `ZavaNotify/` | .NET Console App | (no port) |
| `ZavaPayGateway/` | Struts 1.x, Java 8 | :8180 |
| `ZavaQueueBridge/` | .NET Console App | (no port) |
| `ZavaReportDashboard/` | ASP.NET 4.x Web Forms | :8082 |
| `ZavaRiskEngine/` | WCF Service (.NET 4.8) | :8090 |
| `ZavaStatementService/` | WCF Service (.NET 4.8) | :8091 |
| `ZavaWireTransferService/` | Servlet, Java 11 | :8195 |
| `infrastructure/sqlserver/` | SQL Server init scripts, seed data | — |
| `infrastructure/rabbitmq/` | RabbitMQ config, queue definitions | — |
| `infrastructure/nginx/` | nginx.conf, reverse proxy routes | — |
| `infrastructure/mailhog/` | MailHog config | — |
| `docs/` | Architecture docs (this file) | — |

**Folder naming convention:** PascalCase matching the app name with spaces removed (e.g., "ZavaLoan Portal" → `ZavaLoanPortal/`, "ZavaKYC Service" → `ZavaKycService/`).

**Each app folder contains (at minimum):**

| .NET Apps | Java Apps |
|-----------|-----------|
| `*.csproj` | `build.gradle` + `settings.gradle` |
| `*.sln` (single-project solution) | `src/main/java/...` + `src/main/webapp/...` |
| `Web.config` or `App.config` | `src/main/resources/` (properties, XML config) |
| `Dockerfile` | `Dockerfile` |
| `README.md` | `README.md` |

**Why root-level folders?** Each folder will eventually be extracted into its own GitHub repository. The at-scale modernization demo runs the Modernize CLI against a `repos.json` manifest pointing to all 23 repos. Having them at root level now makes that extraction trivial — each folder is already a self-contained project.

---

## 4. Docker Compose Topology

### 4.1 Network Architecture

<!-- TODO: expert_mermaid will add network topology diagram here -->

**Network membership:**

- **zava-frontend-net:** ZavaLoanPortal, ZavaAccountManager, ZavaReportDashboard, ZavaPayGateway, ZavaFraudDetector, ZavaComplianceReporter, Nginx
- **zava-services-net:** ZavaRiskEngine, ZavaStatementService, ZavaAlertService, ZavaCurrencyService, ZavaAuthGateway, ZavaLedger, ZavaKycService, ZavaInterestCalculator, ZavaLoanOriginationApi, ZavaDocVault, ZavaWireTransferService (frontends also join this network)
- **zava-worker-net:** ZavaNotify, ZavaAuditWorker, ZavaQueueBridge, ZavaAchProcessor, ZavaBatchScheduler, ZavaFileIngestion (workers also join zava-services-net)
- **zava-infra-net:** SQL Server (:1433), RabbitMQ (:5672/:15672), MailHog (:1025/:8025), File Drop volume (all other networks bridge into this)

**Network Rules:**
- `zava-frontend-net` — all frontend containers + nginx. Nginx is the external entry point.
- `zava-services-net` — all API/service containers. Frontends also join this network to call services.
- `zava-worker-net` — all background workers/queue processors. Workers also join `zava-services-net` to call APIs.
- `zava-infra-net` — infrastructure (SQL Server, RabbitMQ, MailHog). All other networks bridge into this.

### 4.2 Startup Ordering & Dependencies

Services start in layers. Docker Compose `depends_on` with health checks enforces ordering:

**Layer 0 — Infrastructure** (must be healthy first): zava-sqlserver (healthcheck: sqlcmd SELECT 1), zava-rabbitmq (healthcheck: rabbitmqctl status), zava-mailhog (no dependency)

**Layer 1 — Core Services** (depend on infra): ZavaAuthGateway (depends: sqlserver), ZavaLedger (depends: sqlserver, rabbitmq), ZavaCurrencyService (depends: sqlserver), ZavaKycService (depends: sqlserver)

**Layer 2 — Domain Services** (depend on core): ZavaRiskEngine (depends: sqlserver), ZavaInterestCalculator (depends: sqlserver), ZavaStatementService (depends: sqlserver), ZavaDocVault (depends: sqlserver), ZavaAlertService (depends: sqlserver, rabbitmq), ZavaLoanOriginationApi (depends: ledger, risk-engine, kyc-service), ZavaFraudDetector (depends: ledger, kyc-service), ZavaWireTransferService (depends: ledger, currency-service, kyc-service)

**Layer 3 — Frontends** (depend on services): ZavaLoanPortal (depends: auth-gateway, loan-origination-api, doc-vault), ZavaAccountManager (depends: auth-gateway, ledger, statement-service), ZavaReportDashboard (depends: auth-gateway, ledger, statement-service), ZavaPayGateway (depends: ledger, currency-service, fraud-detector), ZavaComplianceReporter (depends: ledger, kyc-service)

**Layer 4 — Workers** (depend on messaging + services): ZavaNotify (depends: rabbitmq, mailhog), ZavaAuditWorker (depends: rabbitmq, sqlserver), ZavaQueueBridge (depends: rabbitmq, filedrop volume), ZavaAchProcessor (depends: ledger, rabbitmq, filedrop volume), ZavaBatchScheduler (depends: ledger, interest-calculator, statement-service), ZavaFileIngestion (depends: sqlserver, filedrop volume)

**Layer 5 — Reverse Proxy** (last): Nginx (depends: all frontends)

### 4.3 Port Mapping Summary

> **⚠️ IMPORTANT:** All port numbers below (8080, 8090, 8180, etc.) refer to **container-internal ports** — the port each application listens on inside its container. For external/debug access via the Docker host, see `docker-topology.md §4.1a` for host-mapped ports (8001+, 9001+). For inter-container communication within the Docker network, use service name + container-internal port (e.g., `http://zavaloan-portal:8080`).

| Port Range | Purpose | Nodes |
|-----------|---------|-------|
| 80, 443 | Nginx reverse proxy (external entry point) | zava-nginx |
| 8080–8082 | .NET Frontends (container-internal) | ZavaLoan Portal, ZavaAccount Manager, ZavaReport Dashboard |
| 8090–8094 | .NET WCF/API Services (container-internal) | ZavaRisk Engine, ZavaStatement, ZavaAlert, ZavaCurrency, ZavaAuth |
| 8180–8182 | Java Frontends (container-internal) | ZavaPay Gateway, ZavaFraud Detector, ZavaCompliance Reporter |
| 8190–8195 | Java API/Services | ZavaLedger, ZavaKYC, ZavaInterest, ZavaLoanOrig, ZavaDocVault, ZavaWire |
| 1433 | SQL Server | zava-sqlserver |
| 5672, 15672 | RabbitMQ (AMQP + Management UI) | zava-rabbitmq |
| 1025, 8025 | MailHog (SMTP + Web UI) | zava-mailhog |

### 4.4 Nginx Routing

```nginx
# .NET Frontends
/loans/          → ZavaLoan Portal :8080
/accounts/       → ZavaAccount Manager :8081
/reports/        → ZavaReport Dashboard :8082
/auth/           → ZavaAuth Gateway :8094

# Java Frontends
/payments/       → ZavaPay Gateway :8180
/fraud/          → ZavaFraud Detector :8181
/compliance/     → ZavaCompliance Reporter :8182

# Direct service access (internal, but exposed for demo)
/api/ledger/     → ZavaLedger :8190
/api/kyc/        → ZavaKYC Service :8191
```

---

## 5. Banking Domain Mapping

| Banking Domain | Primary Service(s) | Supporting Service(s) |
|---------------|--------------------|-----------------------|
| **Loans** | ZavaLoan Portal, ZavaLoan Origination API | ZavaRisk Engine, ZavaDoc Vault, ZavaNotify |
| **Payments** | ZavaPay Gateway | ZavaLedger, ZavaCurrency Service, ZavaFraud Detector |
| **Accounts** | ZavaAccount Manager | ZavaLedger, ZavaAuth Gateway |
| **Fraud** | ZavaFraud Detector | ZavaKYC Service, ZavaLedger, ZavaAlert Service |
| **KYC / Compliance** | ZavaKYC Service, ZavaCompliance Reporter | ZavaLedger |
| **Notifications** | ZavaNotify | ZavaAlert Service (upstream), MailHog (downstream) |
| **Reporting** | ZavaReport Dashboard, ZavaCompliance Reporter | ZavaLedger, ZavaStatement Service |
| **Audit** | ZavaAudit Worker | All services (publish audit events) |
| **Currency / FX** | ZavaCurrency Service | ZavaPay Gateway, ZavaWire Transfer (consumers) |
| **Risk** | ZavaRisk Engine | ZavaLoan Origination API (consumer) |
| **Ledger** | ZavaLedger | Nearly all services (central transaction store) |
| **Statements** | ZavaStatement Service | ZavaAccount Manager, ZavaBatch Scheduler |
| **Alerts** | ZavaAlert Service | ZavaFraud Detector (upstream), ZavaNotify (downstream) |
| **Wire Transfers** | ZavaWire Transfer Service | ZavaLedger, ZavaCurrency Service, ZavaKYC Service |
| **ACH Processing** | ZavaACH Processor | ZavaLedger, File Drop volume |
| **Document Management** | ZavaDoc Vault | ZavaLoan Portal, ZavaLoan Origination API |
| **Batch Operations** | ZavaBatch Scheduler | ZavaInterest Calculator, ZavaStatement Service, ZavaLedger |
| **File Integration** | ZavaFile Ingestion, ZavaQueue Bridge | File Drop volume, RabbitMQ |

---

## 6. Era-Authenticity Guidelines

To ensure the apps look genuinely 2005–2015, every node must follow these constraints:

---

### 6.1 Cross-Ecosystem Authentication

The Zava Bank system spans two isolated technology ecosystems — .NET (Windows/IIS) and Java (Linux/Tomcat) — each with its own native authentication model. A shared demoware strategy bridges them via a database-backed token exchange, allowing single sign-on across both stacks.

#### 6.1.1 ASP.NET Forms Authentication (.NET Frontends)

**Affected Applications:**
- ZavaLoan Portal (8080)
- ZavaAccount Manager (8081)
- ZavaReport Dashboard (8082)

**.NET frontends use traditional `FormsAuthentication`:**

1. **Login Flow:**
   - User submits credentials to ZavaAuth Gateway (:8094)
   - ZavaAuth Gateway validates username/password against `dbo.Auth.Users` table (SHA-1 hashed passwords — era-appropriate)
   - On success, creates `FormsAuthenticationTicket` with `Expires = DateTime.Now.AddMinutes(30)`
   - Ticket is encrypted/signed and set as HTTP cookie named `.ASPXAUTH`
   - Client redirected back to requesting frontend with `.ASPXAUTH` cookie

2. **Session Maintenance:**
   - All subsequent requests include `.ASPXAUTH` cookie
   - ASP.NET runtime validates ticket signature and expiration on each request
   - Request context populates `HttpContext.Current.User.Identity`
   - Code-behind uses `Page.User.Identity.IsAuthenticated` and `Page.User.Identity.Name`

3. **Web.config Configuration:**
   ```xml
   <authentication mode="Forms">
     <forms loginUrl="~/login.aspx" timeout="30" name=".ASPXAUTH"
            path="/" protection="All" />
   </authentication>
   <authorization>
     <deny users="?" /> <!-- Deny anonymous -->
   </authorization>
   ```

5. **Cross-Container Cookie Strategy (Shared machineKey):**

   **Problem:** FormsAuthentication tickets are encrypted and signed using the application's `<machineKey>`. When each .NET frontend runs in a separate Docker container, each container auto-generates its own machineKey at startup. A `.ASPXAUTH` cookie issued by ZavaAuth Gateway (container A) cannot be decrypted by ZavaLoan Portal (container B) — the keys don't match.

   **Solution:** All .NET frontends and ZavaAuth Gateway share an identical explicit `<machineKey>` in their `web.config`. Combined with the Nginx reverse proxy routing all apps under a single domain (`zava-bank.local`), this ensures:
   - **Same domain** → browser sends `.ASPXAUTH` cookie to all `/loans/`, `/accounts/`, `/reports/`, `/auth/` paths
   - **Same machineKey** → any .NET app can decrypt/validate the FormsAuth ticket issued by any other

   This is the standard pre-.NET 4.5 approach for web farms and is fully supported by Mono 6.12.

   ```xml
   <!-- REQUIRED: Identical in ALL .NET frontend web.config files -->
   <!-- ZavaAuth Gateway, ZavaLoan Portal, ZavaAccount Manager, ZavaReport Dashboard -->
   <system.web>
     <machineKey
       validationKey="CB2721ABDAF8E9DC516D621D8B8BF13A2C9E8689A25303BF"
       decryptionKey="E9D2490BD0075B51D1BA5288514514AF"
       validation="SHA1"
       decryption="AES" />
   </system.web>
   ```

   **Why this works for demoware:**
   - Era-appropriate: explicit `<machineKey>` was the standard .NET web farm strategy from 2005–2015
   - Mono 6.12 supports `<machineKey>` with SHA1 validation and AES decryption
   - No additional infrastructure (no token exchange needed for .NET-to-.NET auth)
   - The Nginx single-domain routing (§4.4) handles the cookie domain/path scope

   **Alternatives considered and rejected:**
   - Token-based redirect flow (query string tokens): More complex, unnecessary when Nginx already unifies the domain
   - Database-only session validation: Higher latency per request, defeats the purpose of cookie-based auth

4. **Cross-Ecosystem Token Propagation:**
   - When .NET app issues `.ASPXAUTH` cookie, it also writes a row to `dbo.Auth.SessionTokens`:
     - `user_id` (foreign key to Users)
     - `token` (GUID or encrypted ticket value)
     - `issued_at` (2026-05-13T00:42:27.599-07:00)
     - `expires_at` (30 minutes later)
     - `app_source` ('dotnet' string literal)
   - This token becomes the shared artifact for Java apps to validate .NET session authenticity

#### 6.1.2 Java Session Management (Java Frontends)

**Affected Applications:**
- ZavaPay Gateway (8180) — Struts 1.x
- ZavaFraud Detector (8181) — Struts 2.x
- ZavaCompliance Reporter (8182) — JSP/Servlet

**Java frontends use `HttpSession` for state:**

1. **Login Flow:**
   - User submits credentials to a local Servlet login handler or JSP form post
   - Handler queries `dbo.Auth.Users` table via JDBC (validates password)
   - On success, creates `HttpSession` via `request.getSession(true)`
   - Session ID is `JSESSIONID` cookie (managed automatically by Servlet container/Tomcat)
   - Session attributes set: `session.setAttribute("user_id", userId)`, `session.setAttribute("username", username)`

2. **Session Maintenance:**
   - Tomcat manages `JSESSIONID` cookie lifecycle (default 30-minute timeout in `context.xml`)
   - On each request, Tomcat deserializes session from memory or session store
   - Application code accesses via `request.getSession().getAttribute("user_id")`
   - Struts 1.x: Store in `ActionForm` or session; Struts 2.x: Store in `ActionSupport` or via `SessionAware` interceptor

3. **Session Configuration (context.xml):**
   ```xml
   <Context sessionCookiePath="/" sessionCookieSecure="false" sessionCookieHttpOnly="true">
     <SessionCookieConfig sessionTimeout="1800" /> <!-- 30 minutes -->
   </Context>
   ```

4. **Cross-Ecosystem Token Propagation:**
   - When Java app creates HttpSession, it writes to `dbo.Auth.SessionTokens`:
     - `user_id` (from Users table)
     - `token` (GUID generated by application)
     - `issued_at` (server timestamp)
     - `expires_at` (30 minutes hence)
     - `app_source` ('java' string literal)
   - Token is shared via query parameter, custom header, or POST data to other ecosystems

#### 6.1.3 Cross-Ecosystem SSO Strategy (Shared Token Approach)

**Architecture:**

```
┌─────────────────────────────────────────────────────────────┐
│                     Nginx Reverse Proxy                      │
│                   (Single External Entry Point)              │
│                        Port 80 / 443                         │
└──────────┬─────────────────────────────┬────────────────────┘
           │                             │
       ┌───▼──────────────┐         ┌────▼──────────────┐
       │  .NET Frontend   │         │   Java Frontend   │
       │ (ZavaLoan, etc.) │         │ (ZavaPay, etc.)   │
       │   :8080–8082     │         │   :8180–8182      │
       └────┬──────────────┘         └────┬──────────────┘
            │                             │
       ┌────▼─────────────────────────────▼───┐
       │   Shared SessionTokens Table (SQL)   │
       │  user_id | token | expires_at | ... │
       └────┬─────────────────────────────────┘
            │
       ┌────▼──────────────────────────────────┐
       │  dbo.Auth.SessionTokens               │
       │  - user_id (FK to Users)              │
       │  - token (GUID, unique)               │
       │  - issued_at (timestamp)              │
       │  - expires_at (timestamp)             │
       │  - app_source ('dotnet'|'java')       │
       └───────────────────────────────────────┘
```

**How It Works:**

1. **Initial Authentication (either ecosystem):**
   - User authenticates via **ZavaAuth Gateway** (centralized login service, :8094)
   - On successful password validation, **both** .NET and Java tokens are issued:
     - .NET: `FormsAuthenticationTicket` → `.ASPXAUTH` cookie
     - Java: `HttpSession` token → `JSESSIONID` cookie (or shared token via header)
     - Shared: `SessionTokens` table row with `user_id`, `token`, `app_source='initial'`, `expires_at`

2. **Cross-Ecosystem Navigation (browser):**
   - Browser makes request to Nginx with current ecosystem's auth cookie (`.ASPXAUTH` or `JSESSIONID`)
   - Nginx routes to target frontend (different ecosystem)
   - Target frontend intercepts request, finds NO local session
   - Frontend queries `dbo.Auth.SessionTokens WHERE token = <cookie_value> AND expires_at > NOW()`
   - If found, frontend trusts the token and creates a **local session in its own ecosystem**:
     - .NET: Issues new `.ASPXAUTH` ticket
     - Java: Creates new `HttpSession`
   - User is seamlessly authenticated in new ecosystem

3. **Token Validation Query (pseudo-code):**
   ```sql
   SELECT user_id FROM dbo.Auth.SessionTokens 
   WHERE token = @token 
     AND expires_at > GETUTCDATE()
     AND app_source IN ('dotnet', 'java', 'initial')
   ```

4. **Nginx Routing (for SSO cookie propagation):**
   ```nginx
   # All frontends under one hostname; cookies automatically shared in browser
   server_name zava-bank.local;
   
   location /loans {
     proxy_pass http://zavaloanportal:8080;
     proxy_cookie_path / /loans;
   }
   
   location /payments {
     proxy_pass http://zavapaygateway:8180;
     proxy_cookie_path / /payments;
   }
   # Browser maintains cookie context across paths
   ```

**Important Notes:**
- **Not Full OAuth/OIDC:** This is a pragmatic demoware approach, not production-grade.
- **Session Timeout:** All tokens expire at 30 minutes. No silent refresh.
- **Cross-Domain Cookie Consideration:** If .NET and Java apps are on different subdomains or ports, cookies won't auto-share. In demoware, Nginx routes all via same domain (zava-bank.local).
- **Token Leakage:** In production, the shared `SessionTokens` table would be restricted to specific columns/roles. Here it's accessible by all services for simplicity.

#### 6.1.4 Service-to-Service Authentication

**Internal Services (Docker network calls — no auth required):**

All inter-service HTTP calls within the Docker network (service-to-service, service-to-database) occur over `zava-services-net`. These are **trusted network calls**; no authentication tokens are required.

```
ZavaLoan Origination API → ZavaLedger (HTTP POST)
ZavaFraud Detector → ZavaLedger (HTTP GET)
ZavaBatch Scheduler → ZavaInterest Calculator (HTTP POST)
```

**RabbitMQ Connections (shared credentials):**

Message producers and consumers authenticate to RabbitMQ using credentials defined in `docker-compose.yml` environment variables:
- `RABBITMQ_DEFAULT_USER=guest`
- `RABBITMQ_DEFAULT_PASS=guest`

All services use the same credentials (era-appropriate; no per-service tokens). Each service reads these from config and passes them when opening connections:

```csharp
// .NET
var factory = new ConnectionFactory { HostName = "zava-rabbitmq", UserName = "guest", Password = "guest" };
```

```java
// Java
ConnectionFactory factory = new ConnectionFactory();
factory.setHost("zava-rabbitmq");
factory.setUsername("guest");
factory.setPassword("guest");
```

**Database Connections (per-app SQL logins):**

Each application has a dedicated SQL Server login with minimal privileges for its schema:

| App | SQL Login | Default Database | Schema Permissions |
|-----|-----------|------------------|--------------------|
| ZavaLoan Portal | `app_zavaloanportal` | `ZavaBank` | SELECT, INSERT, UPDATE on `dbo.Loans`, `dbo.Accounts` |
| ZavaLedger | `app_zavalledger` | `ZavaBank` | SELECT, INSERT, UPDATE, DELETE on `dbo.Transactions`, `dbo.Accounts` |
| ZavaAuth Gateway | `app_zavaauth` | `ZavaBank` | SELECT on `dbo.Auth.Users`, `dbo.Auth.SessionTokens`; INSERT on `dbo.Auth.SessionTokens` |
| ZavaNotify | `app_zavanotify` | `ZavaBank` | SELECT on `dbo.Notifications.NotificationLog` |
| (etc. — one per app) | | | |

Connection strings are stored in each app's config file (Web.config, properties, env vars) and never shared. Each service authenticates independently to the database.

#### 6.1.5 Auth Flow Diagram (TODO)

<!-- TODO: expert_mermaid will add a sequence diagram showing:
1. User login at ZavaAuth Gateway (centralized)
2. FormsAuthenticationTicket issued to .NET frontend
3. HttpSession + SessionTokens row created
4. Browser navigates to Java frontend with cookie
5. Java frontend validates token against SessionTokens table
6. New HttpSession created for Java app
7. User is authenticated in both ecosystems
-->

---

### 6.2 API Contract Definitions

This section documents the contract interfaces, servlet mappings, and endpoint patterns for all WCF services and Java Servlet-based applications in the Zava Bank system.

#### 6.2.1 .NET WCF Service Contracts

All .NET WCF services expose SOAP/XML interfaces via `basicHttpBinding` (no transport security in demoware). Each service includes a `.svc` file and corresponding `[ServiceContract]` interface.

| Service | Contract Interface | Location | Binding | Endpoint URL | Description |
|---------|-------------------|----------|---------|--------------|-------------|
| **ZavaRisk Engine** | `IZavaRiskEngine` | `ZavaRiskEngine/Services/IZavaRiskEngine.cs` | `basicHttpBinding` | `/RiskEngine.svc` | Credit risk scoring. Methods: `ScoreLoan(LoanApplication) → RiskScore`, `GetMaxApprovedAmount(score) → decimal` |
| **ZavaStatement Service** | `IZavaStatementService` | `ZavaStatementService/Services/IZavaStatementService.cs` | `basicHttpBinding` | `/StatementService.svc` | Statement generation. Methods: `GenerateStatement(accountId, month) → base64 PDF`, `GetStatementHistory(accountId) → List<Statement>` |
| **ZavaAlert Service** | `IZavaAlertService` | `ZavaAlertService/Services/IZavaAlertService.cs` | `basicHttpBinding` | `/AlertService.svc` | Alert rules engine. Methods: `EvaluateTransaction(txn) → Alert[]`, `UpdateAlertRule(rule) → bool` |
| **ZavaCurrency Service** | `IZavaCurrencyService` | `ZavaCurrencyService/Services/IZavaCurrencyService.cs` | `basicHttpBinding` | `/CurrencyService.svc` | FX rate lookups. Methods: `GetExchangeRate(fromCurrency, toCurrency) → decimal`, `ConvertAmount(amount, fromCur, toCur) → decimal` |

**WCF Configuration (Web.config pattern):**
```xml
<system.serviceModel>
  <services>
    <service name="ZavaBank.Services.RiskEngine" behaviorConfiguration="ServiceBehavior">
      <endpoint address="" binding="basicHttpBinding" contract="ZavaBank.Services.IZavaRiskEngine" />
      <endpoint address="mex" binding="mexHttpBinding" contract="IMetadataExchange" />
    </service>
  </services>
  <behaviors>
    <serviceBehaviors>
      <behavior name="ServiceBehavior">
        <serviceMetadata httpGetEnabled="true" />
        <serviceDebug includeExceptionDetailInFaults="false" />
      </behavior>
    </serviceBehaviors>
  </behaviors>
</system.serviceModel>
```

**WSDL Access:** Each service publishes WSDL at `http://<service>:8080/<ServiceName>.svc?wsdl`. Example: `http://zava-risk-engine:8080/RiskEngine.svc?wsdl`

---

#### 6.2.2 Java Servlet Mappings

All Java web applications (Servlets and Struts) define request mappings in either `web.xml` (servlet) or `struts-config.xml`/`struts.xml` (Struts framework).

| App | Mapping Type | Config File | URL Pattern | Handler |
|-----|--------------|-------------|-------------|---------|
| **ZavaPayGateway (Struts 1.x)** | Struts ActionForm | `ZavaPayGateway/src/main/resources/struts-config.xml` | `/payment.do?action=*` | `com.zavaint.payments.actions.PaymentAction`, `com.zavaint.payments.actions.ProcessPaymentAction` |
| | | | `/api/payments/submit` | POST: process credit card/ACH, returns JSON status |
| **ZavaFraudDetector (Struts 2.x)** | Struts ActionSupport | `ZavaFraudDetector/src/main/resources/struts.xml` | `/fraud!*` | `com.zavaint.fraud.actions.FraudAnalysisAction`, `com.zavaint.fraud.actions.RuleEditorAction` |
| | | | `/api/fraud/review` | POST: retrieve flagged transactions |
| **ZavaCompliance Reporter (Servlet)** | Web Servlet | `ZavaComplianceReporter/src/main/webapp/WEB-INF/web.xml` | `/reports/*` | `com.zavaint.compliance.ComplianceReportServlet` |
| | | | `/api/compliance/ctr` | GET: generate CTR report |
| | | | `/api/compliance/sar` | GET: generate SAR report |
| **ZavaLedger (Servlet)** | Web Servlet | `ZavaLedgerCore/src/main/webapp/WEB-INF/web.xml` | `/api/ledger/*` | `com.zavaint.ledger.LedgerServlet` |
| | | | `/api/accounts` | GET: query account balances |
| | | | `/api/transactions` | POST: post transaction |
| | | | `/api/reconcile` | POST: reconciliation |
| **ZavaKYC Service (Servlet)** | Web Servlet | `ZavaKYCService/src/main/webapp/WEB-INF/web.xml` | `/api/kyc/*` | `com.zavaint.kyc.KYCServlet` |
| | | | `/api/kyc/verify` | POST: verify customer identity |
| **ZavaInterest Calculator (Servlet)** | Web Servlet | `ZavaInterestCalculator/src/main/webapp/WEB-INF/web.xml` | `/api/interest/*` | `com.zavaint.interest.InterestCalcServlet` |
| | | | `/api/interest/calculate` | POST: calculate accrued interest |
| **ZavaLoan Origination API (Servlet)** | Web Servlet | `ZavaLoanOriginationAPI/src/main/webapp/WEB-INF/web.xml` | `/api/origination/*` | `com.zavaint.origination.OriginationServlet` |
| | | | `/api/origination/apply` | POST: submit loan application |
| | | | `/api/origination/status` | GET: check application status |
| **ZavaDocVault (Servlet)** | Web Servlet | `ZavaDocVault/src/main/webapp/WEB-INF/web.xml` | `/api/docs/*` | `com.zavaint.vault.DocumentServlet` |
| | | | `/api/docs/upload` | POST (multipart): upload document |
| | | | `/api/docs/download` | GET: download document by ID |
| **ZavaWire Transfer Service (Servlet)** | Web Servlet | `ZavaWireTransferService/src/main/webapp/WEB-INF/web.xml` | `/api/wire/*` | `com.zavaint.wire.WireTransferServlet` |
| | | | `/api/wire/submit` | POST: submit wire transfer |
| | | | `/api/wire/validate` | POST: validate routing info |

**Servlet Configuration (web.xml pattern):**
```xml
<web-app>
  <servlet>
    <servlet-name>LedgerServlet</servlet-name>
    <servlet-class>com.zavaint.ledger.LedgerServlet</servlet-class>
  </servlet>
  <servlet-mapping>
    <servlet-name>LedgerServlet</servlet-name>
    <url-pattern>/api/ledger/*</url-pattern>
  </servlet-mapping>
</web-app>
```

**Struts 1.x Configuration (struts-config.xml pattern):**
```xml
<struts-config>
  <form-beans>
    <form-bean name="paymentForm" type="com.zavaint.payments.forms.PaymentForm" />
  </form-beans>
  <action-mappings>
    <action path="/payment" type="com.zavaint.payments.actions.PaymentAction" name="paymentForm">
      <forward name="success" path="/confirmPayment.jsp" />
    </action>
  </action-mappings>
</struts-config>
```

**Struts 2.x Configuration (struts.xml pattern):**
```xml
<struts>
  <package name="fraud" namespace="/fraud" extends="struts-default">
    <action name="review" class="com.zavaint.fraud.actions.FraudAnalysisAction">
      <result name="success">/fraud/review.jsp</result>
    </action>
  </package>
</struts>
```

---

#### 6.2.3 REST-Style HTTP Endpoints

While the system mixes SOAP (WCF) and Servlet-based APIs, some services expose REST-like patterns (XML/form-encoded, not JSON):

| Service | Method | Endpoint | Request Format | Response Format |
|---------|--------|----------|-----------------|-----------------|
| **ZavaLedger** | POST | `/api/ledger/transaction` | XML or form-urlencoded | XML with `<transaction>` element |
| | GET | `/api/ledger/account/{id}` | URL path parameter | XML with `<account>` element |
| **ZavaKYC Service** | POST | `/api/kyc/verify` | XML | XML with `<verificationResult>` |
| **ZavaInterest Calculator** | POST | `/api/interest/batch` | XML list | XML list with results |
| **ZavaDoc Vault** | POST | `/api/docs/upload` | multipart/form-data | XML with document ID |
| | GET | `/api/docs/{id}` | URL path parameter | Binary (PDF/image) |

---

#### 6.2.4 Message Queue Interfaces (RabbitMQ)

**AMQP Queue/Exchange Bindings:**

| Exchange | Queue | Binding Key | Publisher | Consumers | Message Format |
|----------|-------|-------------|-----------|-----------|-----------------|
| `zava.loans` | `loan.events` | `loan.*` | ZavaLoan Origination API | ZavaNotify, ZavaAudit Worker | XML (SOAP-encoded or plain) |
| `zava.payments` | `payment.events` | `payment.*` | ZavaPay Gateway | ZavaNotify, ZavaAudit Worker | XML |
| `zava.fraud` | `fraud.alerts` | `fraud.*` | ZavaFraud Detector | ZavaAlert Service, ZavaNotify | XML |
| `zava.audit` | `audit.events` | `audit.*` | All services | ZavaAudit Worker | XML with audit context |
| `zava.wire` | `wire.events` | `wire.*` | ZavaWire Transfer Service | ZavaNotify, ZavaAudit Worker | XML |
| `zava.ach` | `ach.results` | `ach.*` | ZavaACH Processor | ZavaNotify, ZavaAudit Worker | XML |

---

### 6.3 .NET Nodes

- **Web Forms:** Use `<asp:GridView>`, `<asp:FormView>`, `<asp:Wizard>`, `<asp:UpdatePanel>`, `<asp:ObjectDataSource>`. Code-behind (`*.aspx.cs`) with `Page_Load`, `ViewState`, `IsPostBack` checks.
- **WCF Services:** `[ServiceContract]` / `[OperationContract]` attributes, `Web.config` with `<system.serviceModel>`, `basicHttpBinding`, `.svc` files.
- **Console Workers:** Raw `static void Main(string[] args)`, `while(true)` polling loops, `Thread.Sleep()`, `ConfigurationManager.AppSettings[]`.
- **Data Access:** ADO.NET `SqlConnection`/`SqlCommand` or typed DataSets. No Entity Framework Code First, no Dapper.
- **Config:** `Web.config` / `App.config` with `<appSettings>` and `<connectionStrings>`. No JSON config.
- **Logging:** `System.Diagnostics.Trace` / `log4net`. No Serilog, no structured logging.
- **Auth:** `FormsAuthentication` with `FormsAuthenticationTicket`. No OWIN, no Identity.

### 6.4 Java Nodes

---

## 7. Containerization Strategy

Even though these apps "wouldn't have had Dockerfiles" in their era, we add them for the demo environment:

- **.NET Web Forms / WCF:** Use `mcr.microsoft.com/dotnet/framework/aspnet:4.8` base image. Copy published output. IIS hosted.
- **.NET Console Apps:** Use `mcr.microsoft.com/dotnet/framework/runtime:4.8` base image. `ENTRYPOINT` runs the console exe.
- **Java WAR Apps:** Use `tomcat:8.5-jdk8` (or `jdk11`/`jdk17` for newer nodes). Copy WAR to `/usr/local/tomcat/webapps/`.
- **Java Console Apps:** Use `eclipse-temurin:8-jre` (or `11-jre`). Copy shadow JAR. `ENTRYPOINT ["java", "-jar", "app.jar"]`.

---

## Appendix A: Node Quick Reference

| Category | Node | Port |
|----------|------|------|
| **Frontends (6)** | ZavaLoanPortal | :8080 |
| | ZavaAccountManager | :8081 |
| | ZavaReportDashboard | :8082 |
| | ZavaPayGateway | :8180 |
| | ZavaFraudDetector | :8181 |
| | ZavaComplianceReporter | :8182 |
| **Services (11)** | ZavaRiskEngine | :8090 |
| | ZavaStatementService | :8091 |
| | ZavaAlertService | :8092 |
| | ZavaCurrencyService | :8093 |
| | ZavaAuthGateway | :8094 |
| | ZavaLedger | :8190 |
| | ZavaKycService | :8191 |
| | ZavaInterestCalculator | :8192 |
| | ZavaLoanOriginationApi | :8193 |
| | ZavaDocVault | :8194 |
| | ZavaWireTransferService | :8195 |
| **Workers (6)** | ZavaNotify | — |
| | ZavaAuditWorker | — |
| | ZavaQueueBridge | — |
| | ZavaAchProcessor | — |
| | ZavaBatchScheduler | — |
| | ZavaFileIngestion | — |
| **Infrastructure (5)** | SQL Server | :1433 |
| | RabbitMQ | :5672/:15672 |
| | Nginx | :80/:443 |
| | MailHog | :1025/:8025 |
| | File Drop | (volume) |
