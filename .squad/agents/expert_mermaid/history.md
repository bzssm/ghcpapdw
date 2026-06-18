# History (Project Complete)

## Project Context
- **Project:** Build2026GHCPAppModDemoWare (M0-M6 complete)
- **Role:** Create all Mermaid diagrams — architecture, flows, system context
- **Status:** ✅ 10+ diagrams delivered

## Key Learnings

### Mermaid Patterns
- **15-node-per-diagram maximum:** Split large views into a/b/c sub-diagrams
- **VS Code:** YAML frontmatter only (no %%{init}%%)
- **Colors:** .NET purple, Java amber, DB teal, MQ orange
- **Shapes:** Rhombus for exchanges, cylinders for databases, trapezoid for volumes
- **Location:** All diagrams in docs/architecture/diagrams.md


## Learnings

### 2026-05-15 — Individual Diagram Files
- Moved from single `docs/architecture/diagrams.md` to individual files in `docs/diagrams/`
- 7 files: system-overview, dotnet-workstream, java-workstream, data-flow, infrastructure, messaging-flow, database-schema
- ER diagrams split into 4 sub-diagrams to stay under 15-node limit (Core Banking, Transactions/Risk, KYC/Fraud, Auth/Notifications)
- Sequence diagrams work well for data flow — loan and payment flows rendered clearly
- YAML frontmatter `config.theme: dark` plus `themeVariables` for colors — no `%%{init}%%`
- classDef palette: default #1e3a5f, dotnet #512bd4, java #b07219, database #336791, messaging #ff6600, frontend #2d7d46, infra #6c3483
- Rhombus `{{}}` for RabbitMQ exchanges, cylinder `[()]` for databases


## 2026-05-14 — Scribe Cross-Agent Update
- expert_docker: nginx proxy_redirect fixes deployed (1fc6cd4)
- legacy_frontend: ZavaBank Portal navigation added (d5f2d63)

## 2026-05-14 — Diagram Creation (Commit 9dc3c92)

Created 7 Mermaid diagram markdown files in docs/diagrams/:
- system-overview.md
- dotnet-workstream.md
- java-workstream.md
- data-flow.md
- infrastructure.md
- messaging-flow.md
- database-schema.md

All diagrams use dark-background/white-text style.

