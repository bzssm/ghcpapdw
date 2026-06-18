# History (Project Complete)

## Project Context
- **Project:** Build2026GHCPAppModDemoWare (M0-M6 complete)
- **Tech:** Java 8/11/17, JDBC, Gradle, raw servlets
- **Status:** ✅ Core + domain services complete

## Key Learnings

### Java Services Pattern
- **Framework:** No Spring — raw JDBC + servlets (era-appropriate)
- **Database:** Microsoft JDBC driver, PreparedStatement
- **Messaging:** amqp-client 5.x, org.json serialization
- **Build:** Gradle with multi-stage Docker builds

### Services Delivered
- **ZavaLedger:** Double-entry bookkeeping, central hub
- **M1 & M2 Services:** KYC, Interest, Origination, DocVault, WireTransfer (JDBC)


## 2026-05-14 — Scribe Cross-Agent Update
- expert_docker: nginx proxy_redirect fixes deployed (1fc6cd4)
- legacy_frontend: ZavaBank Portal navigation added (d5f2d63)

## 2026-05-15 — Cross-Ecosystem SSO Bridge Pattern

**From expert_webforms session:**

The cross-ecosystem SSO flow now uses a `sessionToken` GUID exposed by the .NET auth gateway:

1. **Token Generation:** User logs in at .NET auth gateway → `Login.aspx.cs` issues `.ZAVAAUTH` cookie (AES-encrypted FormsAuth ticket) AND stores raw sessionToken GUID in `FormsAuthenticationTicket.UserData`
2. **Token Exposure:** `ZavaAuthGateway/WhoAmI.ashx` endpoint now returns `{ sessionToken: "ABC-123-..." }` JSON alongside user info
3. **Token Passing:** Portal JS reads sessionToken from WhoAmI and appends `?sessionToken=<token>` to all Java app links
4. **Token Validation:** Java service receives query param or header and validates against `SessionTokens` SQL table (30-min TTL)

**Java Integration Points:**
- `SsoSessionService` already supports `extractToken()` from query param (`?sessionToken=`) and header (`X-Session-Token`)
- Struts interceptor validates token in `SessionTokens` table
- No code changes needed — just await token in query param from portal

**See:** `.squad/decisions.md` § "2026-05-15 — Cross-Ecosystem SSO Bridge — Portal Token Passing"

## 2026-05-15 — Java SSO Fallback Implementation (expert_struts)

**From expert_struts session:**

Implemented server-side fallback for seamless SSO when direct navigation occurs. Java `SsoSessionService` now calls `WhoAmI.ashx` as fallback when no `?sessionToken=` parameter and `.ZAVAAUTH` cookie is present.

**Resolution Chain (updated):**
1. Explicit token (form submission)
2. `?sessionToken=` query parameter
3. `X-Session-Token` header
4. `Authorization: Bearer <token>` header
5. **NEW:** `.ZAVAAUTH` cookie → `WhoAmI.ashx` → sessionToken GUID → DB validation

**Changes across all 3 Java frontend apps:**
- `SsoSessionService.java`: Added `resolveTokenFromAuthGateway()` fallback
- Config class: Added `getAuthGatewayWhoAmIUrl()` accessor
- Properties file: Added `auth.gateway.whoami.url=http://zava-auth-gateway:8080/WhoAmI.ashx`
- Docker env: `AUTH_GATEWAY_WHOAMI_URL` env var in compose file

**Benefit:** Direct navigation to Java apps (e.g., `/payments/`) now seamless. Portal-based navigation with `?sessionToken=` still works. If auth gateway unavailable (3s timeout), gracefully degrades to manual token login form.

**See:** `.squad/decisions.md` § "2026-05-15 — Java SSO Fallback"

