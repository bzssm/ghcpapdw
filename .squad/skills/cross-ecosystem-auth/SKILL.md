# Cross-Ecosystem Authentication Bridge Pattern

Confidence: high
Last validated: 2026-05-14

## Pattern

Implement single sign-on (SSO) across .NET (FormsAuthentication) and Java (HttpSession) ecosystems using a shared database bridge table containing authentication tokens, without requiring a separate identity provider.

## When to Use

- Legacy monoliths with mixed .NET and Java frontends requiring unified login experience
- Absence of external identity providers (OAuth/OIDC not available or not desired)
- Need to preserve native .NET/Java authentication mechanisms while enabling cross-ecosystem navigation

## Implementation

### Shared SessionTokens Table

```sql
CREATE TABLE dbo.Auth.SessionTokens (
    token_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL FOREIGN KEY REFERENCES dbo.Auth.Users(user_id),
    token NVARCHAR(256) NOT NULL UNIQUE,
    issued_at DATETIME NOT NULL DEFAULT GETUTCDATE(),
    expires_at DATETIME NOT NULL,
    app_source NVARCHAR(20) NOT NULL DEFAULT 'initial',  -- 'dotnet', 'java', 'initial'
    created_at DATETIME NOT NULL DEFAULT GETUTCDATE()
);

CREATE UNIQUE INDEX IX_SessionTokens_Token ON dbo.Auth.SessionTokens(token);
CREATE INDEX IX_SessionTokens_UserExpiry ON dbo.Auth.SessionTokens(user_id, expires_at);
```

### Authentication Flow

1. **User logs in** to ZavaAuth Gateway (:8094)
2. **Validate credentials** against `dbo.Auth.Users` (SHA-1 hashed for era-appropriateness)
3. **On success:**
   - .NET frontends: Issue `.ZAVAAUTH` cookie (FormsAuthenticationTicket with shared machineKey)
   - Java frontends: Create `HttpSession` and store user_id
   - **Both:** Insert row into `SessionTokens` with random token UUID

4. **User navigates** between ecosystems
5. **New frontend** detects missing local session, queries `SessionTokens`:
   ```sql
   SELECT user_id WHERE token = <cookie_value> AND expires_at > NOW()
   ```
6. **If found:** Create new local session in destination ecosystem

### Session Timeout

- **30 minutes** across all ecosystems
- `.NET:` `<forms timeout="30" />`
- **Java:** `sessionTimeout="1800"` (seconds) in Tomcat
- **SessionTokens:** `expires_at = issued_at + 30 minutes`

### .NET Implementation

```csharp
// On login success
var token = Guid.NewGuid().ToString("N");
var sessionToken = new {
    user_id = user.UserId,
    token = token,
    app_source = "dotnet"
};
// Insert into SessionTokens table
// Issue FormsAuth cookie
FormsAuthentication.SetAuthCookie(user.Username, false);
```

### Java Implementation

```java
// On login success
String token = UUID.randomUUID().toString().replaceAll("-", "");
// INSERT INTO SessionTokens (user_id, token, app_source) VALUES (?, ?, 'java')
// Create HttpSession
HttpSession session = request.getSession(true);
session.setAttribute("user_id", user.getId());
```

## Gotchas

1. **Token leakage:** In demoware, SessionTokens table is readable by all services. In production, restrict via SQL Server roles.
2. **No token refresh:** 30-minute timeout is short-lived. Document that this is NOT suitable for production.
3. **Token collision:** Use cryptographically random UUIDs; GUID collision is negligible.
4. **Clock skew:** All apps must run in same Docker network with synchronized NTP. If clocks drift significantly, gracefully deny auth and force re-login.
5. **Cross-domain cookies:** If serving .NET and Java apps on different subdomains, cookie sharing via SessionTokens still works, but FormsAuth cookies won't transfer. Mitigate with URL query parameter `?sessionToken=<guid>` as fallback.
