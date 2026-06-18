# Decisions

## M0–M6 Complete

### M1 .NET Services Implementation
- **Date:** 2026-05-14T08:28:48Z
- **Author:** expert_dotnet_services
- **Scope:** Issues #7 and #8 (ZavaAuthGateway, ZavaCurrencyService)

Auth Gateway uses FormsAuthentication cookie `.ZAVAAUTH` + shared `<machineKey>` for cross-container validation. Cross-ecosystem SSO bridge uses SQL-backed `SessionTokens` with HTTP handler `/api/auth/validate`. Currency service is WCF `BasicHttpBinding` with metadata. Compose mapping: zava-auth-gateway on 8003, zava-currency-service on 8004.

---

### M2 WCF Services
- **Date:** 2026-05-14
- **Author:** expert_dotnet_services
- **Scope:** Issues #22, #25, #26 (ZavaRiskEngine, ZavaStatementService, ZavaAlertService)

All three are .NET Framework 4.8 WCF over `basicHttpBinding` hosted with `mono:6.12` + `xsp4`. Configuration reads from `DB_HOST/DB_PORT/DB_NAME/DB_USER/DB_PASSWORD`. Docker-compose ports: Risk 8005, Statement 8007, Alert 8008. Risk engine writes to `RiskAssessments/RiskModelParameters`. Statement service persists HTML to `GeneratedStatements` + logs to `StatementRequests/StatementArchive`. Alert service uses `AlertRules/AccountAlerts/AlertHistory` and publishes to RabbitMQ `zava.notifications` (fanout).

---

### M2 Java Domain Services
- **Date:** 2026-05-14
- **Author:** expert_java_services
- **Scope:** Issues #23, #27, #28, #29

Added servlet-level bootstrap for missing tables (`Documents`, `WireTransfers`, `InterestAccruals`) with `IF OBJECT_ID` checks. External orchestration calls use resilient HTTP fallbacks with bounded timeouts and statuses (`KYC_REVIEW`, `APPROVED_PENDING_LEDGER`, `PENDING_LEDGER`).

---

### M3 WebForms Frontends
- **Date:** 2026-05-14
- **Author:** expert_webforms
- **Scope:** Issues #12, #13, #14 (ZavaLoanPortal, ZavaAccountManager, ZavaReportDashboard)

All three use Web Forms + .NET Framework 4.8 + legacy csproj/packages.config. 2005-era styling (table layouts, blue gradients, gray backgrounds), server controls, ViewState, UpdatePanel. LoanPortal uses Wizard flow + history grid + ZavaLoanOriginationAPI call. AccountManager has master-detail GridView + FormView insert + close account + ledger queries. ReportDashboard has date-range filtered portfolio HTML + delinquency + transaction volume. Report dashboard maps to host 8006, statement service to 8007.

---

### M4 Java Frontends Port Alignment
- **Date:** 2026-05-14
- **Author:** expert_struts
- **Scope:** Issues #11, #19, #21

Updated `docker-compose.yml` to map: ZavaPayGateway → 9001, ZavaFraudDetector → 9003, ZavaComplianceReporter → 9008. Moved zava-doc-vault from 9008 to 9010 to avoid duplicate bindings.

---

### M5 Java Workers (Messaging)
- **Date:** 2026-05-14
- **Author:** expert_messaging
- **Scope:** Issues #17, #20, #24

Java 8 console workers with `Thread.sleep` loops (ACH, file ingestion) and `ScheduledExecutorService` (scheduler). Legacy `HttpURLConnection` for inter-service calls. Success events to `zava.events` topic; failures to `zava.dlx`. File workers move processed files to `processed/` and failures to `error/` under shared mounts. Config model: classpath properties + environment override.

---

### M6 Docker/SQL & QA
- **Date:** 2026-05-14

#### Nginx Landing Page (expert_docker, Issue #33)
Exact-match `location = /` serves `index.html` from `/usr/share/nginx/html`. Replaced catch-all with static-file fallback. Kept `/health` and app routes. Updated Dockerfile to `COPY html/` so landing page persists outside Compose mounts.

#### Extended Seed Data (expert_database, Issue #31)
Idempotent seed model with natural keys (`Email`, `AccountNumber`, `ReferenceNumber`, `RuleCode`, `FileName`) + `NOT EXISTS` checks. Bootstrap `dbo.Documents` if missing. Demo customers use `extended.demo##@zavabank.com` namespace, accounts use `2002-####-####`, transaction references use `EXT-*`. Added fraud rules, alert rules (high amount, unusual location, rapid transactions), fraud cases (**Pending**, **Escalated**, **Cleared**), and compliance filings (**CTR/SAR**).

#### Playwright Test Suite (qa_integration, Issues #30, #32)
7 e2e specs covering SSO flow. Seed user password is `Password1!` (per `44-seed-auth.sql`). Cross-ecosystem SSO uses workaround: Java apps accept raw session token via `?sessionToken=<guid>` query or form field. Seed token: `C3D4E5F6-A7B8-9012-CDEF-123456789012` (TokenID 3, admin, Source=Java, expires 2026-05-14 16:00:00 UTC). WebForms control IDs rendered as `ctl00_<ContentPlaceHolderID>_<WizardID>_<ControlID>`.

---

## Archive
(None — no entries older than 30 days)
