# Project Decisions

## 2026-05-14

### 2026-05-14T06:27:47Z: User directives — Implementation philosophy
**By:** Brady (via Copilot)
**What:**
1. Optimize for parallel work — label issues so clones of the team can work simultaneously
2. Integration testing + Playwright UI tests over unit tests — this is demoware, not a unit-test showcase
3. Demoware quality: written like a junior coder would've written it in 2007. Realistic, not perfect/clean/artistic
4. Implementation should take hours, not days — only write code needed for end-to-end user scenarios
5. "This. Is. Demoware." — functionality over polish
**Why:** User directive — captured for team memory. These override any prior assumptions about code quality standards.

### 20260514T070124Z: User directive — Assembly Line human review scope
**By:** Brady (via Copilot)
**What:** Limit Human Review triggers to "agent uncertainty" only. Auto-merge everything else since we're building from the ground up — no existing code to break.
**Why:** User request — simplifies the Assembly Line ceremony for greenfield demoware build.

### 2026-05-14T08:28:48Z: User directive — Code constraint lifted
**By:** Brady (via Copilot)
**What:** "banana! 1000x! team, fan out and parallelize as much as possible. get it done" — The "NO CODE until Brady says banana" constraint is now LIFTED. All application code work is authorized.
**Why:** User request — captured for team memory. M1 core services and M5 workers are now greenlit.

### 2026-05-14T08:28:48Z: M1 Integration Test Conventions
**By:** qa_integration
**What:**
M1 integration tests use shell-script-based curl smoke tests (no test framework) stored in `tests/` at repo root. Tests validate HTTP status codes, response content type (XML/SOAP/JSON as appropriate), and cross-service flows.

**Key Conventions:**
1. Test data contract: Tests assume seed data includes user `jsmith` (Password1), customer 1001, accounts 100001/100002, and USD/EUR/GBP currency pairs
2. Health endpoints required: Every M1 service MUST expose `GET /health` returning HTTP 200 when ready
3. Era-appropriateness is a quality gate: Tests verify SOAP WSDL presence, XML content-types, and FormsAuth cookies
4. Response format expectations: ZavaLedger uses `application/xml`, ZavaCurrencyService uses SOAP XML, ZavaKYCService uses JSON, ZavaAuthGateway uses HTML for pages
5. Ledger POST `/api/transactions` should return HTTP 201 (Created) not 200

### 2026-05-14T08:28:48Z: expert_java_services — M1 Java Services Implementation Decision
**By:** expert_java_services
**What:** Added startup bootstrap in `ZavaKYCService` to create `KYCWatchlist` and `KYCVerification` tables when absent, because current SQL init scripts in-repo do not define those issue-required tables.
**Impact:** Issues #6, #9 closed; PR #39 merged.

### 2026-05-14T08:28:48Z: M1 .NET Services Implementation Decision
**By:** expert_dotnet_services
**What:**
Implement M1 .NET services as classic ASP.NET/WCF apps on Mono XSP4 with explicit legacy contracts:
1. Auth Gateway uses FormsAuthentication cookie `.ZAVAAUTH` + shared `<machineKey>` for cross-container validation
2. Cross-ecosystem SSO bridge remains SQL-backed `SessionTokens` with `/api/auth/validate` HTTP handler
3. Currency service is WCF `BasicHttpBinding` only, with `CurrencyService.svc` metadata and ADO.NET lookups
4. Runtime config reads DB settings from `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
5. Compose mapping: `zava-auth-gateway` on port 8003, `zava-currency-service` on port 8004
**Impact:** Issues #7, #8 closed; PR #42 merged.

### 2026-05-14T08:28:48Z: M5 Worker Compatibility Guardrails
**By:** expert_messaging
**What:**
For M5 worker implementation, keep all three workers as .NET Framework 4.8 console apps on Mono with legacy polling loops, but make runtime contracts tolerant of current infra drift:
1. Audit schema compatibility: ZavaAuditWorker detects and writes to both legacy and planned event columns
2. Queue/route compatibility: ZavaNotifyWorker defaults to `q.notify.email` and ZavaQueueBridge publishes to `filedrop.events`, both configurable via env vars
3. File drop path compatibility: ZavaQueueBridge prefers `/shared/filedrop` with fallback to `/data/filedrop`
**Rationale:** Allow workers to run immediately in current compose while staying aligned to target behavior
**Impact:** Issues #3, #5, #11 closed; PR #41 merged.

### 2026-05-15T00:04:51Z: WhoAmI.ashx Endpoint Pattern
**By:** expert_webforms
**What:** Created a lightweight `.ashx` HTTP handler (`WhoAmI.ashx`) that decrypts the FormsAuth cookie server-side and returns JSON with authentication status, username, display name, and roles.
**Key choices:**
1. Anonymous access required — Added `<location>` block in web.config since the endpoint is called before login is confirmed
2. Manual JSON construction — No JSON library available in this .NET 4.x/Mono stack; used StringBuilder with `JavaScriptStringEncode` for XSS safety
3. DBNull safety — FirstName/LastName may be NULL in Users table; handled with `IsDBNull` checks
4. Graceful degradation — Any error (bad cookie, expired ticket, locked user) returns `{"authenticated":false}` rather than an error
**Impact:** Portal JS can now call `/auth/WhoAmI.ashx` to get current user state. No new dependencies added. Follows existing `AuthRepository` + ashx handler pattern.

### 2026-05-15T00:04:51Z: Auth-Aware Portal with Role-Based Link Visibility
**By:** legacy_frontend
**What:** Portal calls `GET /auth/WhoAmI.ashx` on page load via XMLHttpRequest. Unauthenticated users see "Please log in"; authenticated users see "Welcome, {displayName} | Logout" and role-gated service links.
**Role-to-Link Mapping:**
- Loan Portal, Account Manager, Payment Gateway: Customer, Teller, LoanOfficer, Admin
- Reports Dashboard: Teller, LoanOfficer, Admin
- Fraud Detector, Compliance Reporter: FraudAnalyst, Admin
**Team Impact:** `expert_dotnet_services` implements `WhoAmI.ashx` + `Logout.aspx`; nginx proxies `/auth/` through existing location block. Client-side visibility only — backend services enforce authorization independently.
**Commits:** 444a256 (WhoAmI.ashx), d275f4e (auth-aware index.html).
