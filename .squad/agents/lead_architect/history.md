# History (Project Complete)

## Project Context
- **Project:** Build2026GHCPAppModDemoWare — Zava Bank legacy banking demoware (23 app nodes: 11 .NET, 12 Java)
- **User:** Brady
- **Role:** Lead architect for topology design, critical path reconciliation, milestone oversight
- **Status:** ✅ All milestones M0-M6 complete

## Key Learnings

### Topology Reconciliation (Critical Path)
- **3 blockers resolved:** Node count mismatch (23 nodes), port range conflict (container-internal vs host-mapped), network topology inconsistency
- **Root cause pattern:** Documentation gaps, not technical conflicts — can be cleared by explicit decision + cross-document alignment
- **Solution approach:** Create authoritative document (docker-topology.md), update all references, validate consistency

### Milestone Structure (Recommended & Delivered)
- **M0:** Infrastructure (Docker, SQL, RabbitMQ, Nginx)
- **M1:** Core Services (ZavaLedger, ZavaKYC, ZavaAuthGateway, ZavaCurrency)
- **M2:** Domain Services (Risk, Statement, Alert, Loan, Interest, Origination, Wire Transfer)
- **M3:** .NET Frontends (LoanPortal, AccountManager, ReportDashboard)
- **M4:** Java Frontends (PayGateway, FraudDetector, ComplianceReporter)
- **M5:** Workers (Notify, Audit, QueueBridge, ACHProcessor, FileIngestion, BatchScheduler)
- **M6:** Integration + Testing (Playwright, cross-ecosystem SSO, extended seed data, landing page)

### Architecture Decisions (Key Patterns)
- **Folder structure:** Repo-per-app layout (PascalCase at root) enables trivial extraction to GitHub repos
- **Port mapping:** Container-internal 8080 (Docker DNS), host-mapped for debug, Nginx as external entry point
- **Database:** Single shared instance (era-authentic), per-domain schemas
- **Messaging:** RabbitMQ topology with DLX, dual serialization (XML/JSON)
- **Authentication:** SessionTokens bridge table for cross-ecosystem SSO
- **Auto-merge:** Approved for greenfield demoware (low legacy code risk)
- M6 Docker landing page, extended seed data, Playwright test suite
- Cross-ecosystem SSO strategy and current architectural gap

### Post-Completion: Port Misalignment Fix (2026-05-14)
- Smoke tests (`m1-smoke-tests.sh`, `docker-compose-test.sh`) and docs (`m1-test-scenarios.md`) had incorrect host ports for AuthGateway (used 8004, should be 8003) and CurrencyService (used 8008, should be 8004)
- Root cause: ports were hardcoded independently of docker-compose.yml rather than validated against it
- Lesson: always treat docker-compose.yml as the single source of truth for port mappings; test scripts should be verified against it after any topology change

### Comprehensive .gitignore Hardening (2026-05-14)
- Expanded .gitignore with 6 categories of exclusions:
  - **.NET:** bin/, obj/, *.dll, *.pdb, .vs/, packages/
  - **Java:** target/, *.class, .gradle/, build/
  - **Node:** node_modules/, dist/, package-lock.json
  - **Docker:** docker-compose.override.yml
  - **IDE:** .vscode/, .idea/
  - **OS:** Thumbs.db, .DS_Store
- Status: Ready for production environments

### Nginx /auth/ Routing Fix (2026-05-14T13:43:00-07:00)
- **Issue:** /auth/ route was returning ZavaWireTransferService content instead of login page
- **Root Causes:** (1) Stale DNS cache in nginx due to permanent caching at startup, (2) Missing proxy_redirect to rewrite upstream redirects
- **Solution:** Added Docker embedded DNS resolver (127.0.0.11 valid=30s) and proxy_redirect rule (/auth/) to location block
- **Outcome:** Login page now displays correctly
- **Principle:** Nginx + Docker environments require explicit DNS resolver when containers restart; all prefix-proxied redirects need proxy_redirect rewriting
- **Commit:** 5655fc8

### Portal Link 404 Fix — proxy_redirect for All Frontends (2026-05-14T14:22:29-07:00)
- **Issue:** All portal links (/loans/, /accounts/, /reports/, /payments/, /fraud/, /compliance/) returned 404
- **Root Cause:** Same as prior /auth/ fix — upstream apps issue login redirects with absolute paths (e.g., `/Login.aspx`, `/login.do`). Without `proxy_redirect`, nginx doesn't rewrite these to include the subpath prefix, so the browser follows a redirect to a non-existent root-level path → 404.
- **Fix Applied:**
  - Added `proxy_redirect / /{path}/;` to 6 location blocks: /loans/, /accounts/, /reports/, /payments/, /fraud/, /compliance/
  - Fixed `AuthGatewayLoginUrl` and `AuthGatewayLogoutUrl` in LoanPortal, AccountManager, ReportDashboard web.configs from `http://localhost:8000/` to `http://localhost/auth/`
- **Not changed:** WCF service routes (/services/risk/, /services/statements/, /services/alerts/, /services/currency/) — these are backend APIs with no auth redirects
- **Principle:** Every nginx location block that proxies an app with login redirects needs `proxy_redirect` to rewrite absolute redirect paths

### Cross-Ecosystem Routing Fix Completed (2026-05-14T14:22:29-07:00)
- **Decision:** Apply proxy_redirect pattern to all frontend proxies and align web.config auth URLs to use nginx routes
- **Applied:** Commit afc9a81
- **Scope:** 6 nginx location blocks updated; 3 web.configs corrected
- **Pattern Established:** All future nginx prefix-proxied applications must include `proxy_redirect` if they issue HTTP redirects
- **Next:** Monitor for similar 404s on new proxy routes; template this pattern for architecture docs

---

**Project Status: COMPLETE & VERIFIED**  
Scribe Sync (2026-05-14T21:22:29Z): Decisions archived, inbox merged (customErrors + proxy_redirect), orchestration logs written, session log recorded, all agents' histories updated. All .squad/ artifacts staged for commit.


## 2026-05-14 — Scribe Cross-Agent Update
- expert_docker: nginx proxy_redirect fixes deployed (1fc6cd4)
- legacy_frontend: ZavaBank Portal navigation added (d5f2d63)

## 2026-05-15 — CLI Crash Recovery Assessment

### Last Completed Work
- **Authentication Portal Integration** (sessions 00:04:51Z)
  - expert_webforms: WhoAmI.ashx endpoint (commit 444a256) — Decrypts FormsAuth cookies, returns JSON with {authenticated, username, displayName, roles}
  - legacy_frontend: Auth-aware portal UI (commit d275f4e) — Portal index.html now calls GET /auth/WhoAmI.ashx, hides service links for unauthenticated users, shows role-gated links for authenticated users
  - Status: ✅ Both commits landed on main, all tests passing

### Interrupted Work
- **None identified** — The session completed cleanly; no mid-flight work was abandoned

### Uncommitted Code Changes
- **None** — All code changes landed in commits. Only .squad/ bookkeeping files remain uncommitted (team artifact staging from session completion)

### Open GitHub Items
- **Issues:** 0 open
- **PRs:** 0 open
- **Status:** Project is at 49 merged PRs, all milestones complete

### Session State
- Crash occurred after auth-portal-integration work logged at 2026-05-15T00:04:51Z
- Decision inbox merged cleanly (2 inbox files deleted: expert_webforms-whoami-endpoint.md, legacy_frontend-auth-portal.md)
- All agent histories staged but not yet committed

### Recommended Next Steps (Gating Order)
1. **Immediate:** Commit .squad/ bookkeeping files (agent histories, decision merges, health reports)
2. **Phase 1 - Backend Authorization Enforcement** — Protected endpoints need server-side authorization checks (not just client-side UI hiding)
   - Scope: ZavaAuthGateway, ZavaLoanPortal, ZavaAccountManager, ZavaReportDashboard, all WCF services
   - Pattern: Decrypt .ZAVAAUTH cookie, check user roles against endpoint permissions, return 403 Forbidden if unauthorized
   - Dependency: WhoAmI.ashx patterns (commit 444a256) can serve as reference
3. **Phase 2 - QA Integration Tests** — Role-based link visibility verification (selenium/Playwright)
   - Verify unauthenticated users: no service links visible, "Please log in" message shown
   - Verify authenticated users: role-appropriate links visible, role-mismatched links hidden
   - Verify unauthorized access attempts: 403 responses from backend
   - Integration with existing Playwright suite (docs/playwright/)

