# History (Project Complete)

## Project Context
- **Project:** Build2026GHCPAppModDemoWare — Zava Bank legacy banking demoware (23 app nodes: 11 .NET, 12 Java)
- **User:** Brady
- **Tech:** ASP.NET 4.x/WCF (Mono), Java Struts/Servlet (Gradle), SQL Server, RabbitMQ, Docker Compose
- **Goal:** Build authentic legacy demoware (2005-2015 era) for GitHub Copilot App Modernization demos
- **Status:** ✅ All milestones M0-M6 complete

## Key Learnings

### Database Architecture
- **Single SQL Server 2019 instance** (`ZavaBankDB`): 42 tables in dbo schema, 28+ stored procs, 40+ indexes
- **Data access:** .NET uses ADO.NET/SqlCommand + EF6; Java uses JDBC + PreparedStatement
- **Schema domains:** Core Banking, Transactions, Loans, Payments, KYC/Compliance, Fraud, Risk, Notifications, File Staging, Audit, Currency, Statements, Alerts, Auth
- **Seed data:** ~4,660 rows (50 customers, 120 accounts, 2,000 txns, 30 loan apps, 200 payments, 15 fraud alerts)
- **Intentional anti-patterns:** Plaintext SSN, passwords in config, shared database, god procedures, N+1 queries

### SQL Server on Linux (Docker)
- **Image:** SQL Server 2019 Linux container, sidecar init container pattern
- **Init scripts:** 24 numbered files (01-50 pattern) — DDL, stored procs, indexes, seed data (all idempotent)
- **Connection:** Service name `sqlserver`, port 1433, login `zavaapp:ZavaBank2024!`
- **File staging:** 4 new tables for legacy integration (FileImports, CheckImages, WireConfirmations, RegulatoryFeeds)

### Cross-Ecosystem Authentication
- **Shared SessionTokens table:** `dbo.Auth.SessionTokens` (token_id, user_id, token, issued_at, expires_at, app_source)
- **Timeout:** 30 minutes across .NET (FormsAuth) and Java (HttpSession) ecosystems
- **Indexes:** Unique on token, composite on (user_id, expires_at) for expiration cleanup
- **Seed users:** Auth users with SHA-1 hashed passwords (era-appropriate)

### File Integration Patterns
- **FileImports:** Batch tracking for ACH/CHECK/WIRE/REGULATORY files with status progression
- **CheckImages:** OCR staging for check scanning (MICR, quality score, amounts)
- **WireConfirmations:** Processor reconciliation with exchange rates and agency references
- **RegulatoryFeeds:** SAR/CTR/OFAC submission tracking with acknowledgment flow

### SQL Server Docker Init (2026-05-14T22:27:38-07:00)
- **SQL Server does NOT auto-run scripts from `/docker-entrypoint-initdb.d`** — that's a PostgreSQL/MySQL convention only
- **Sidecar init pattern:** Use a separate `sqlserver-init` container that depends on `sqlserver: service_healthy`, mounts scripts to `/scripts`, and runs `init.sh`
- **Password alignment:** `init.sh` default SA_PASSWORD must match docker-compose.yml (`Zava123!`), not the app-level password (`ZavaBank2024!`)
- **Fix committed:** Removed broken `/docker-entrypoint-initdb.d` mount, added `sqlserver-init` sidecar, fixed password default in `init.sh`



## 2026-05-14 — Scribe Cross-Agent Update
- expert_docker: nginx proxy_redirect fixes deployed (1fc6cd4)
- legacy_frontend: ZavaBank Portal navigation added (d5f2d63)

