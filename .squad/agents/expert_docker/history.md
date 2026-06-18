# History (Project Complete)

## Project Context
- **Project:** Build2026GHCPAppModDemoWare — Zava Bank legacy banking demoware (23 app nodes: 11 .NET, 12 Java)
- **User:** Brady
- **Tech:** ASP.NET 4.x/WCF (Mono), Java Struts/Servlet (Gradle), SQL Server, RabbitMQ, Docker Compose
- **Goal:** Build authentic legacy demoware (2005-2015 era) for GitHub Copilot App Modernization demos
- **Status:** ✅ All milestones M0-M6 complete

## Key Learnings

### Docker Orchestration Architecture
- **28 containers:** 7 .NET (Mono), 13 Java, 4 infra (Nginx, SQL, RabbitMQ, MailHog)
- **Port mapping:** Container-internal 8080 for all apps; host-mapped .NET 8001-8010, Java 9001-9015
- **Networks:** 4 bridge networks (`frontend-net`, `backend-net`, `db-net`, `mq-net`) for service isolation
- **Startup ordering:** 5 levels with health checks — infra → core → apps → workers → nginx

### Service Naming Convention (5-Layer Hierarchy)
- **Folders:** PascalCase (`ZavaLoanPortal/`) — ready for repo split
- **Docker services:** kebab-case (`zava-loan-portal`) — container DNS
- **Container names:** `zavabank-zava-loan-portal` — docker exec commands
- **Image names:** `zavabank/zava-loan-portal` — registry-ready
- **Internal hostname:** Service name for Docker DNS resolution

### Docker Compose Patterns
- **All-Linux strategy:** Mono 6.12 for .NET Framework (XSP4 web host), standard Tomcat/JRE for Java
- **Multi-stage Gradle builds:** Java apps use docker multi-stage for reproducible builds
- **Health checks:** All services report healthy before dependents start
- **Dockerfile templates:** 5 patterns (Web Forms/XSP4, WCF self-hosted, .NET worker, Tomcat WAR, Java JAR worker)

### File Path Knowledge
- **Infrastructure folder:** `infrastructure/` contains sql/, rabbitmq/, nginx/ subdirectories
- **Build contexts:** `build: ./ZavaLoanPortal` (root-level app folders)
- **Volumes:** Named volumes for sql-data, rabbitmq-data; bind mounts for nginx-conf, filedrop staging
- **.NET publish folders:** Pre-built publish/ (compiled locally or in CI)

### RabbitMQ Configuration
- **8 exchanges:** topic (loans/payments/fraud/accounts), fanout (notifications), direct (compliance/statements), DLX
- **15 application queues + 1 DLX:** All durable with error routing
- **Serialization:** .NET→XML, Java→JSON (intentional dual-format for demo authenticity)
- **Worker pattern:** Polling with 5-second intervals, new connection per poll (intentionally wasteful legacy style)

## Learnings

### 2026-05-14 — First Full Stack Integration Test
- **Result:** 27 of 28 services healthy (zava-report-worker disabled — directory never created)
- **All 5 key endpoints responding HTTP 200:** Nginx :80, AuthGateway :8003, CurrencyService :8004, Ledger :9004, KYCService :9005

#### Issues Found & Fixed
1. **Build context mismatches in docker-compose.yml:** `ZavaTransferService` → `ZavaWireTransferService`, `ZavaLedgerCore` → `ZavaLedger`, `ZavaReportWorker` disabled (no directory)
2. **Debian Buster EOL (mono:6.12):** Added `archive.debian.org` redirect in all 11 Mono Dockerfiles
3. **openjdk:8-jre removed from Docker Hub:** Switched 3 JAR workers to `eclipse-temurin:8-jre`
4. **RabbitMQ.Client 6.8.1 → 5.2.0:** No net461 TFM caused Mono GAC fallback. Downgraded to 5.2.0
5. **Mono XSP4 apps not compiled:** Added `mcs` compile step to all 8 XSP4 Dockerfiles
6. **Health check fixes:** MailHog (curl→wget), workers (pgrep→pidof), PayGateway (/health→/health.do)
7. **Nginx upstream:** `zava-auth-service` → `zava-auth-gateway`

### 2026-05-14 — Post-Integration Verification
- **Port alignment validated:** test scripts now match docker-compose.yml authoritative source
- **Comprehensive .gitignore:** 6 categories (Node, .NET, Java, Docker, IDE, OS) added for production readiness
- **Stack status:** Operational and ready for Copilot App Modernization demos

---

**Project Status: COMPLETE & OPERATIONAL**  
Scribe Sync (2026-05-14T20:17:25Z): Stack validation complete, orchestration logs written, team history synchronized.

## 2026-05-14 — Scribe Cross-Agent Update
- expert_docker: nginx proxy_redirect fixes deployed (1fc6cd4)
- legacy_frontend: ZavaBank Portal navigation added (d5f2d63)

## 2026-05-15 — Infrastructure State Assessment (CLI Recovery)
**Docker Status:** ✅ Running (Docker Desktop client v28.4.0, context: desktop-linux)
**Containers Running:** None currently (clean state after CLI crash recovery)
**Compose Definition:** ✅ 228 service lines in docker-compose.yml — fully intact with Level 0-4 orchestration
**Dockerfiles:** 24 total — all 23 app nodes + 1 nginx infrastructure image
**Nginx Config:** ✅ Complete with 18 upstreams, 17 proxy locations, Docker embedded DNS resolver
**SQL Initialization:** ✅ 25 init scripts present (01-create-database.sql through 99-extended-seed-data.sql, plus init.sh orchestrator)
**RabbitMQ Config:** ✅ infrastructure/rabbitmq/rabbitmq.conf in place

### 2026-05-15 — Docker Stack Verification & Integration Test Completion

**Status:** ✅ COMPLETE — Stack operational and demo-ready  
**Session Timestamp:** 2026-05-15T08:10:53Z

**Work Summary:**
- Verified 27/27 Docker containers healthy on boot
- Confirmed all connectivity checks pass
- RabbitMQ messaging functional, SQL initialization via sidecar complete
- Stack ready for backend authorization enforcement phase

**Current Focus:** Backend authorization enforcement on protected endpoints per gating order. WhoAmI.ashx serves as pattern reference for role-based endpoint protection.

