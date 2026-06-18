# History (Project Complete)

## Project Context
- **Project:** Build2026GHCPAppModDemoWare (M0-M6 complete)
- **Tech:** ASP.NET 4.x Web Forms on Mono 6.12, Wingtip Toys styling
- **Status:** ✅ M3 frontends complete

## Key Learnings

### Web Forms Pattern
- **Controls:** GridView, FormView, Repeater, TextBox, Button (Mono-compatible)
- **ViewState:** Heavy use for state management (intentional anti-pattern)
- **Master pages:** Consistent headers/footers
- **SqlDataSource:** Direct ADO.NET binding
- **Auth:** FormsAuthentication, shared machineKey

### Frontends Delivered
- **ZavaLoan Portal:** Accounts, loan applications
- **ZavaAccount Manager:** Account details, transactions, transfers
- **ZavaReport Dashboard:** Fraud/compliance reports


## 2026-05-15 — WhoAmI.ashx Endpoint Added

- Created `WhoAmI.ashx` + `WhoAmI.ashx.cs` — JSON endpoint that decrypts the `.ZAVAAUTH` FormsAuth cookie and returns username, displayName, and roles
- Added `GetUserRoles(int userId)` to `AuthRepository.cs` — queries Roles/UserRoles join
- Updated `GetUserByUsername` query to include FirstName, LastName (with DBNull safety)
- Added FirstName/LastName properties to `AuthUser` class
- Registered anonymous access for `WhoAmI.ashx` in `web.config` (`<location>` block)
- Added files to `ZavaAuthGateway.csproj`
- All string values encoded with `HttpUtility.JavaScriptStringEncode` for XSS safety
- CORS header `Access-Control-Allow-Origin: *` included

## Learnings
- **Credential mismatch was the root cause of Brady's login failures** — the task brief listed `admin/admin123`, `teller1/teller123`, `jsmith/customer123`, `fanalyst/fraud123` but seed data (44-seed-auth.sql) uses completely different usernames/passwords: `admin/Password1!`, `teller.jones/Teller2024`, `fraud.analyst.chen/Fraud2024`, `maria.rodriguez/Customer1`
- Login.aspx.cs uses `SHA1(salt + password)` — no membership provider, no bcrypt, just plain SHA1 hex comparison (uppercase). Salt is per-user from the Users table.
- FormsAuth cookie name `.ZAVAAUTH` is set at `path="/"`, so it's available to all endpoints including ashx handlers
- `AuthRepository` is `internal sealed` — ashx handler class must be `public` for ASP.NET to instantiate it, but repo access works fine from within the same assembly
- FirstName/LastName may be NULL in the Users table — always use `IsDBNull` checks with ordinal reader access

## 2026-05-15 — Cross-Ecosystem SSO Bridge Fix

- **Root cause:** Java apps read `.ZAVAAUTH` cookie value as a raw token, but it's an encrypted FormsAuth ticket. DB lookup against SessionTokens always fails → Java shows manual token login form.
- **Fix:** WhoAmI.ashx now returns `sessionToken` (raw GUID from `ticket.UserData`). Portal JS appends `?sessionToken=` to Java app links (`/payments/`, `/fraud/`, `/compliance/`).
- **Affected files:** WhoAmI.ashx.cs, index.html, whoami-endpoint.spec.ts, cross-ecosystem-sso.spec.ts
- **Key insight:** The Java SsoSessionService was already correct — it accepts tokens from query param, header, bearer, and cookie. The problem was that nobody was passing the raw token to it.

## 2026-05-15 — Credential Verification & Test Helper Update

- Verified ALL 10 seed user password hashes via SHA1(salt+password) — every hash in 44-seed-auth.sql is correct
- Added `LOAN_OFFICER_USER` export to `tests/helpers/auth.ts` (was missing)
- Cleaned up stale comment referencing `ZavaBank2007!`
- Docker stack was not running, so verification was done against seed SQL + hash computation
- expert_docker: nginx proxy_redirect fixes deployed (1fc6cd4)
- legacy_frontend: ZavaBank Portal navigation added (d5f2d63)

## 2026-05-15 — WhoAmI.ashx E2E Test Coverage Added

**Status:** ✅ WhoAmI endpoint is now covered by qa_integration's E2E test suite (6 tests for WhoAmI.ashx API + 7 tests for portal role-based link visibility).

**Test Files Created:**
- `tests/e2e/whoami-endpoint.spec.ts` — API contract validation
- `tests/e2e/portal-role-visibility.spec.ts` — Portal UI rendering by role

**Impact:** WhoAmI.ashx endpoint is now validated end-to-end across all user roles and error conditions. Portal role-filtering implemented in M3 frontend is now covered by regression tests.

## 2026-05-15 — Java SSO Fallback Pattern (expert_struts)

**Cross-Agent Update from expert_struts session:**

Java frontend apps (PayGateway, FraudDetector, ComplianceReporter) now implement server-side fallback for seamless SSO. When no `?sessionToken=` parameter is present but `.ZAVAAUTH` cookie is available, the Java `SsoSessionService` calls `WhoAmI.ashx` directly to resolve the raw sessionToken GUID.

**Flow:**
1. User navigates directly to `/payments/` (no `?sessionToken=` param)
2. Request carries `.ZAVAAUTH` cookie from .NET auth
3. Java `SsoSessionService.extractToken()` finds no query param/header
4. Fallback calls `WhoAmI.ashx`, forwarding `.ZAVAAUTH` cookie
5. WhoAmI decrypts ticket and returns `{ sessionToken: "GUID..." }`
6. Java validates token against `SessionTokens` DB → seamless auth

**Implementation:**
- Added `resolveTokenFromAuthGateway()` to `SsoSessionService.java` (all 3 Java apps)
- Added `auth.gateway.whoami.url` config property
- Docker env var: `AUTH_GATEWAY_WHOAMI_URL=http://zava-auth-gateway:8080/WhoAmI.ashx`
- 3-second timeout; gracefully degrades if auth gateway unavailable

**Result:** Direct navigation to Java apps now works seamlessly without `?sessionToken=` in URL. Portal-based navigation still works (already had token in URL).


