# History (Project Complete)

## Project Context
- **Project:** Build2026GHCPAppModDemoWare — Zava Bank legacy demoware (M0-M6 complete)
- **Tech:** .NET Framework 4.x/WCF on Mono 6.12, SQL Server, ADO.NET, BasicHttpBinding
- **Status:** ✅ All milestones complete

## Key Learnings

### .NET WCF Service Pattern
- **Framework:** .NET Framework 4.x on Mono 6.12 with XSP4 web host
- **Binding:** BasicHttpBinding only (Mono limitation)
- **Architecture:** ServiceContract interface + DataContract DTOs
- **Configuration:** web.config with <system.serviceModel>
- **Data access:** ADO.NET SqlCommand/SqlDataAdapter
- **Health check:** HTTP GET handler returns service status
- **Error handling:** FaultException for SOAP faults

### Services Delivered
- **ZavaAuthGateway:** FormsAuthentication, SessionTokens bridge
- **ZavaCurrencyService:** WCF BasicHttpBinding exchange rates
- **M2 Services:** RiskEngine, StatementService, AlertService (WCF)

### Dockerfile
- Base: mono:6.12
- Host: XSP4 on port 8080
- Env vars: DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, RABBITMQ_HOST

### Debugging Configuration (2026-05-14)
- Added `<customErrors mode="Off"/>` to all 8 web.config files to surface full stack traces
- Web apps (AuthGateway, LoanPortal, AccountManager, ReportDashboard) and WCF services (RiskEngine, StatementService, AlertService, CurrencyService)
- Some configs are single-line/minified — edits must preserve that format

### Deployment Debugging (2026-05-14T14:22:29-07:00)
- **Decision:** Enable detailed error messages for debugging by disabling custom error handling
- **Applied:** Commit bbc80df
- **Impact:** Full stack traces now visible in all 8 .NET applications; accelerates debugging cycle
- **Note:** Must revert to `RemoteOnly` or `On` before production exposure to prevent information leakage



## 2026-05-14 — Scribe Cross-Agent Update
- expert_docker: nginx proxy_redirect fixes deployed (1fc6cd4)
- legacy_frontend: ZavaBank Portal navigation added (d5f2d63)

