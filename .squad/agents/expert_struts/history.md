# History (Project Complete)

## Project Context
- **Project:** Build2026GHCPAppModDemoWare — Zava Bank legacy demoware (M0-M6 complete)
- **Tech:** Java Struts 1.x/2.x, JSP, SQL Server JDBC, Gradle, Tomcat
- **Status:** ✅ M4 frontends complete

## Key Learnings

### Struts 1.x Pattern (ZavaPay Gateway)
- **Config:** struts-config.xml with action mappings
- **Views:** JSP with form beans
- **Auth:** SessionTokens table validation
- **JDBC:** Microsoft JDBC driver + PreparedStatement

### Struts 2.x Pattern (ZavaFraud Detector)
- **Framework:** Struts 2.x with OGNL + interceptor stack
- **Views:** JSP with JSTL custom tags
- **Actions:** POJO action classes
- **Auth:** SessionTokens interceptor

### Deployment
- **Build:** Multi-stage Gradle builds in Docker
- **Container:** Tomcat 9, openjdk:8-jre
- **Port:** 8080 → host 9001/9003


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

**Struts Integration:**
- ZavaPay (Struts 1.x) and ZavaFraud (Struts 2.x) both have `SessionTokens` interceptor/filter already in place
- Interceptor calls `SsoSessionService.extractToken()` which checks query param (`?sessionToken=`), header (`X-Session-Token`), and cookie
- Query param support is already coded — portal will start passing token this way
- No new code needed in Struts actions/interceptors

**See:** `.squad/decisions.md` § "2026-05-15 — Cross-Ecosystem SSO Bridge — Portal Token Passing"

## 2026-05-15 — WhoAmI.ashx Fallback SSO for Java Apps

**Problem:** Direct navigation to Java app URLs (e.g., `/payments/`, `/fraud/`, `/compliance/`) showed a manual "Session Token" login form even when the user had a valid `.ZAVAAUTH` cookie from prior .NET auth gateway login.

**Root Cause:** The portal's `?sessionToken=` approach only works when navigating FROM the portal. Direct URL navigation carries the `.ZAVAAUTH` cookie but no query param. Java apps can't decrypt the .NET FormsAuth cookie (AES encrypted, different crypto stack).

**Solution — Java calls WhoAmI.ashx directly:**
- When `SsoSessionService.extractToken()` finds no token from query params, headers, or bearer auth, it checks for the `.ZAVAAUTH` cookie
- If the cookie exists, it makes an HTTP GET to `WhoAmI.ashx` on the .NET auth gateway, forwarding the cookie
- WhoAmI.ashx decrypts the cookie (server-side .NET can do this) and returns `{ sessionToken: "GUID" }`
- Java extracts the GUID and validates it against the `SessionTokens` DB table as usual
- 3-second connect/read timeout prevents blocking if auth gateway is unavailable

**Why this approach over alternatives:**
- nginx-level fix would require Lua scripting or auth_request module (complex, fragile)
- Redirect-based approach would cause visible page bouncing
- Direct WhoAmI call is invisible to the user and uses only built-in Java `HttpURLConnection`

**Files Changed (all 3 Java frontend apps):**
- `SsoSessionService.java`: Added `resolveTokenFromAuthGateway()` + `extractSessionTokenFromJson()`
- Config classes: Added `getAuthGatewayWhoAmIUrl()` accessor
- Properties files: Added `auth.gateway.whoami.url` default
- `docker-compose.yml`: Added `AUTH_GATEWAY_WHOAMI_URL` env var to all 3 services

**Verified:** All 3 Java apps (PayGateway, FraudDetector, ComplianceReporter) authenticate seamlessly with just the `.ZAVAAUTH` cookie — no login form shown.

