# Archived Decisions — July 2025

This file contains decisions archived after 2026-05-14 for decisions.md maintenance. All entries are older than 30 days and were moved to archive storage.

---

# Decision: Auth Schema DDL Added to database-topology.md

**Author:** expert_database (Livingston)
**Date:** 2025-07-17
**Status:** Implemented

## Context

The `Auth.Users` table was referenced throughout the architecture (ZavaAuth Gateway, cross-ecosystem SSO, role-based access) but never had a CREATE TABLE definition in `docs/architecture/database-topology.md`. Both expert_dotnet_services and expert_database flagged this as a BLOCKING gap — downstream apps couldn't implement auth flows without knowing the schema.

## Decision

Added the complete Auth & Sessions schema DDL to `docs/architecture/database-topology.md`:

### Tables Added (Section 2.14)
1. **Users** — UserID (int PK identity), Username, PasswordHash (SHA-1), Salt, Email, FirstName, LastName, IsActive, FailedLoginAttempts, IsLockedOut, LastLoginDate, CreatedDate, ModifiedDate
2. **Roles** — RoleID (int PK identity), RoleName (Customer, Teller, LoanOfficer, FraudAnalyst, Admin)
3. **UserRoles** — junction table (UserID, RoleID composite PK)
4. **SessionTokens** — TokenID, UserID, Token (GUID), CreatedAt, ExpiresAt, SourceSystem ('DotNet'/'Java'), IsActive, IPAddress, UserAgent

### Stored Procedures Added (Section 3.8)
- `sp_ValidateUser` — login validation with SHA-1 hash comparison, lockout after 5 failures
- `sp_CreateSession` — creates SSO token for .NET or Java caller
- `sp_ValidateSessionToken` — validates token on every request (cross-ecosystem SSO)
- `sp_ExpireSession` — logout / force-expire

### Seed Data Added (Section 5.11)
- 5 roles, 10 test users with known passwords, role assignments
- Users linked to existing demo customers (Maria Rodriguez, James Chen, etc.)
- Mix of active/expired sessions across DotNet and Java source systems

### Anti-Patterns Documented (Section 8)
- SHA-1 password hashing (no bcrypt/PBKDF2)
- Database-polled session tokens for SSO (no token service)

## Design Choices

- **INT IDENTITY PKs** — era-appropriate (no UUIDs)
- **SHA-1 hashing** — matches FormsAuthentication era (intentional anti-pattern)
- **dbo schema** — consistent with all other tables (no custom schemas)
- **SessionTokens shared table** — the .NET ↔ Java SSO bridge, validated by both ecosystems on every request
- **Account lockout at 5 attempts** — simple counter, no time-based unlock (another legacy pain point)

## Impact

- Unblocks ZavaAuth Gateway implementation
- Unblocks cross-ecosystem SSO implementation in Java services
- Table summary updated: 38 → 42 tables, ~4,600 → ~4,660 seed rows


# Decision: WCF Service Contracts Defined

**Author:** expert_dotnet_services  
**Date:** 2025-07-14  
**Status:** Complete  
**Artifact:** `docs/architecture/service-contracts.md`

## What

Defined formal WCF service contracts for all 4 .NET WCF services in Zava Bank:

1. **ZavaRiskEngine** (`:8090/RiskEngine.svc`) — 3 operations: `ScoreLoan`, `GetMaxApprovedAmount`, `GetRiskAssessment`
2. **ZavaCurrencyService** (`:8093/CurrencyService.svc`) — 3 operations: `GetExchangeRate`, `ConvertAmount`, `GetSupportedCurrencies`
3. **ZavaStatementService** (`:8091/StatementService.svc`) — 3 operations: `GenerateStatement`, `GetStatementHistory`, `GetStatementStatus`
4. **ZavaAlertService** (`:8092/AlertService.svc`) — 4 operations: `EvaluateTransaction`, `UpdateAlertRule`, `GetAlertRules`, `GetAlertHistory`

## Why

These contracts were undefined — only method signatures existed in system-topology.md. Formal contracts are needed before any implementation or migration planning can proceed. The contracts document the exact SOAP interface shape, data types, fault contracts, and database dependencies.

## Key Decisions

- **Synchronous only** — all operations are synchronous (no `Task`, no `async/await`), consistent with the 2005–2015 era and `BasicHttpBinding` constraints
- **Typed fault contracts per service** — `RiskScoringFault`, `CurrencyFault`, `StatementFault`, `AlertFault`, each with `ErrorCode` + `ErrorMessage` + `Timestamp` (pattern from error-handling-patterns.md)
- **Request/Response envelope pattern** — every operation uses explicit request and response DataContract types (not primitive parameters), making WSDL generation clean
- **RabbitMQ integration documented** — noted which services also consume from queues (RiskEngine from `q.loan.riskscore`, StatementService from `q.statement.generate`, AlertService from `q.account.alerts`) and which publish (AlertService to `zava.notifications`)
- **Database mappings included** — each operation documents which tables it reads/writes and which stored procedures it calls, cross-referenced with database-topology.md

## Sources Referenced

- `docs/architecture/system-topology.md` — service descriptions, ports, endpoint paths
- `docs/architecture/database-topology.md` — table schemas, stored procedure catalog
- `docs/architecture/error-handling-patterns.md` — FaultException patterns, error code conventions
- `docs/architecture/messaging-topology.md` — exchange/queue bindings, message formats


# Decision: Cross-Container FormsAuthentication Cookie Strategy

**Author:** lead_architect
**Date:** 2025-07-22
**Status:** Decided
**Impact:** expert_dotnet, expert_docker (all .NET frontend web.config files + ZavaAuth Gateway)

## Context

Zava Bank has 3 .NET Web Forms frontends (ZavaLoan Portal, ZavaAccount Manager, ZavaReport Dashboard) plus ZavaAuth Gateway, each running in separate Docker containers on Mono 6.12 / XSP4. ZavaAuth Gateway issues FormsAuthentication tickets as `.ASPXAUTH` cookies.

**The problem:** FormsAuth tickets are encrypted and signed using the application's `<machineKey>`. When each container auto-generates its own machineKey, a cookie issued by ZavaAuth Gateway cannot be decrypted by ZavaLoan Portal — the keys don't match. This breaks the login redirect flow entirely.

## Decision

**Option A: Shared explicit `<machineKey>` in web.config** — all four .NET apps use the same hardcoded `<machineKey>` with SHA1 validation and AES decryption. Combined with the existing Nginx reverse proxy routing all apps under one domain (`zava-bank.local`), this makes FormsAuth cookies fully portable across containers.

```xml
<machineKey
  validationKey="CB2721ABDAF8E9DC516D621D8B8BF13A2C9E8689A25303BF"
  decryptionKey="E9D2490BD0075B51D1BA5288514514AF"
  validation="SHA1"
  decryption="AES" />
```

## Why This Option

1. **Era-appropriate:** Explicit `<machineKey>` was the standard .NET web farm strategy from ASP.NET 1.1 through 4.5 (2003–2015). This is exactly how real enterprises solved this problem in the Zava Bank era.
2. **Mono-compatible:** Mono 6.12 fully supports `<machineKey>` with SHA1 and AES. No Mono-specific workarounds needed.
3. **Simplest implementation:** One XML element added to four web.config files. No new code, no new infrastructure, no new database queries.
4. **Works with existing Nginx routing:** §4.4 already routes all frontends under `zava-bank.local` with path-based routing (`/loans/`, `/accounts/`, `/reports/`, `/auth/`). This means the browser sends the `.ASPXAUTH` cookie to all paths — no cookie domain issues.

## Alternatives Rejected

| Option | Why Rejected |
|--------|-------------|
| **B) Token-based redirect flow** (query string tokens validated against SessionTokens DB) | Unnecessary complexity — Nginx already unifies the domain so cookie sharing works. Adding token redirect logic to every frontend is more code for no benefit. |
| **C) Database-only session validation** (check SessionTokens table on every request) | Adds a DB round-trip per request, defeating the purpose of cookie-based auth. Higher latency, more load on SQL Server. Overkill for .NET-to-.NET auth. |

**Note:** The existing SessionTokens table approach (§6.1.3) remains the correct strategy for **cross-ecosystem** auth (.NET ↔ Java). This decision only addresses .NET-to-.NET FormsAuth cookie sharing.

## What Changes

- **Documentation:** Updated system-topology.md §6.1.1 and configuration-management.md §4-5 with machineKey requirements
- **Implementation (for expert_dotnet):** Add the shared `<machineKey>` element to all four .NET web.config files
- **No Java impact:** Java apps continue using SessionTokens table for cross-ecosystem auth

## Constraints

- Do NOT use `AutoGenerate` or `IsolateApps` modifiers on the machineKey — these generate per-app keys and break ticket sharing
- All four web.config files must have byte-for-byte identical `validationKey` and `decryptionKey` values
- For demoware, keys are committed to source; production would use environment variable injection
