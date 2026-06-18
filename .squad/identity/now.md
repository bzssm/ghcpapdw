---
updated_at: 2026-05-14T08:22:11-07:00
focus_area: ALL MILESTONES COMPLETE
active_issues: []
---

# What We're Focused On

**Phase:** ALL MILESTONES COMPLETE — M0 through M6 DONE 🎉

## Status (Save Point — 2026-05-14)

### ✅ M0: INFRASTRUCTURE — DONE
All 5 PRs merged to main:
- **PR #34** — RabbitMQ definitions (8 exchanges, 15 queues, 16 bindings, DLX pattern)
- **PR #35** — Docker Compose orchestration (28 containers, healthchecks, depends_on, 4 networks)
- **PR #36** — All 23 app folder scaffolds (11 .NET Mono 6.12 + 12 Java Gradle/Tomcat)
- **PR #37** — Nginx reverse proxy (17 path-based routes, port 80 entry point)
- **PR #38** — SQL Server init scripts (43 tables, 31 stored procs, 30+ indexes, ~4,600 seed rows)

M0 Issues closed: #1, #2, #4, #10, #19, #21

### ✅ M1: CORE SERVICES — DONE
All 4 core services implemented and merged:
- **PR #39** — ZavaLedger (Java 17, double-entry bookkeeping, XML) + ZavaKYCService (Java 8, JSON, org.json). Closed #6, #9.
- **PR #41** — ZavaAuthGateway (.NET, FormsAuth, .ZAVAAUTH cookie, SessionTokens SSO) + ZavaCurrencyService (.NET, WCF BasicHttpBinding, FaultException). Closed #7, #8 (via PR #42 duplicate merge).
- **PR #42** — Duplicate of #41's .NET services (expert_dotnet_services). Merged cleanly as no-op. Closed #7, #8.

### ✅ M5: WORKERS — DONE (6/6)
.NET workers (PR #41):
- **ZavaNotifyWorker** (#3) — RabbitMQ BasicGet + SmtpClient→MailHog, DLX nack
- **ZavaAuditWorker** (#5) — RabbitMQ consumer + ADO.NET audit persistence
- **ZavaQueueBridge** (#11) — FileSystemWatcher + RabbitMQ publishing (.NET Mono)

Java workers (PR #43):
- **ZavaACHProcessor** (#17) — NACHA file parser, HTTP→Ledger, RabbitMQ events/dlx
- **ZavaBatchScheduler** (#20) — ScheduledExecutorService, 3-job nightly orchestrator, JDBC logging
- **ZavaFileIngestion** (#24) — File drop monitor (check/wire/reg), Staging* tables, RabbitMQ events

### ✅ QA: SMOKE TESTS — LANDED
- **PR #40** — 40+ assertions, 7 test sections, Docker Compose test runner
- **Known issue:** Test ports hardcode AUTH=8004, CURRENCY=8008 but PR #41 remapped to 8003/8004. Follow-up alignment needed.

### ✅ M2: DOMAIN SERVICES — DONE (7/7)
- **PR #44** — ZavaRiskEngine + ZavaStatementService + ZavaAlertService (WCF). Closed #22, #25, #26. ✅
- **PR #45** — ZavaInterestCalculator + ZavaLoanOriginationAPI + ZavaDocVault + ZavaWireTransferService (Java). Closed #23, #27, #28, #29. ✅

### ✅ M3: .NET FRONTENDS — DONE (3/3)
- **PR #46** — ZavaLoanPortal (Wizard 5-step loan app) + ZavaAccountManager (customer/account CRUD) + ZavaReportDashboard (portfolio/delinquency/volume reports). Closed #12, #13, #14. ✅
- All WebForms with FormsAuth, .ZAVAAUTH cookie, shared machineKey, ADO.NET, Site.Master

### ✅ M4: JAVA FRONTENDS — DONE (3/3)
- PayGateway, FraudDetector, ComplianceReporter — code landed via M4 PR merge-forward

### ✅ M6: INTEGRATION & POLISH — DONE
- **PR #47** — Nginx landing page + root routing (2007-era ZavaBank portal, static HTML at `/`). Closed #33. ✅
- **PR #48** — Extended seed data (20+ customers, 50+ accounts, 200+ transactions, loan apps, fraud cases) + 10-min demo scenario script. Closed #31. ✅
- **PR #49** — Playwright integration tests (7 spec files, shared auth helper, full E2E coverage) + SSO flow documentation. Closed #30, #32. ✅
- **Known limitation:** Java apps can't decrypt .NET FormsAuth cookies — workaround uses sessionToken query param (documented, not a blocker for demoware)

### 🎯 Milestone Structure — ALL COMPLETE
- **M0: Infrastructure** ✅ DONE
- **M1: Core Services** ✅ DONE
- **M2: Domain Services** ✅ DONE (7/7)
- **M3: .NET Frontends** ✅ DONE (3/3)
- **M4: Java Frontends** ✅ DONE (3/3)
- **M5: Workers** ✅ DONE (6/6)
- **M6: Integration & Polish** ✅ DONE

Gating: ~~M0~~ → ~~M1~~ → ~~M2~~ → (~~M3~~ | ~~M4~~ parallel) → ~~M6~~   [~~M5~~ ✅]

## Architecture Summary
- 23 app nodes: 11 .NET (Mono 6.12) + 12 Java (Tomcat/JRE)
- Single shared SQL Server, RabbitMQ as MSMQ stand-in
- Dual serialization: .NET→XML, Java→JSON (intentional pain point)
- Cross-ecosystem auth via shared SessionTokens DB table + machineKey
- Port convention: all apps on container-internal 8080, host-mapped 8001-8010/.NET, 9001-9015/Java
- 4 Docker networks: frontend-net, backend-net, db-net, mq-net
- PascalCase per-app folders at repo root (future repo-per-app split)

## Architecture Docs
- `docs/architecture/system-topology.md` — Master node inventory
- `docs/architecture/docker-topology.md` — Docker Compose design
- `docs/architecture/database-topology.md` — 42 tables, 28+ stored procs, seed data
- `docs/architecture/messaging-topology.md` — 8 exchanges, 15 queues, 10 workers
- `docs/architecture/service-contracts.md` — WCF contracts (4 services, 13 ops)
- `docs/architecture/error-handling-patterns.md` — .NET/Java/cross-stack conventions
- `docs/architecture/observability.md` — Logging, tracing, health checks
- `docs/architecture/configuration-management.md` — Config files, env strategy, machineKey
- `docs/architecture/diagrams.md` — Mermaid diagrams
- `docs/architecture/topology-review.md` — 18-issue review findings
