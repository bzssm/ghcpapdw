# Squad Decisions Archive

Archived decisions from before 2026-05-14. Reference for architectural context and historical decision-making.

---

## 2026-05-12 — Architecture Design Phase

### Decision: All-Linux Container Strategy (Mono for .NET Framework)
- **Status:** Implemented
- **Key Point:** All 24 containers use Linux (Mono for .NET, standard Tomcat for Java)
- **Mono constraints:** Web Forms standard controls only, WCF BasicHttpBinding only, no Windows APIs
- **Reference:** See decisions.md for full context when needed

### Decision: Messaging Topology
- **Status:** Implemented
- **Key Point:** RabbitMQ 3.12 as MSMQ replacement; 7 topic/fanout/direct exchanges; polling consumers
- **Serialization:** .NET→XML, Java→JSON (intentionally inconsistent for demo authenticity)
- **Node contribution:** 11 nodes (RabbitMQ + workers)

### Decision: Zava Bank System Topology — 23 Nodes
- **Status:** Implemented
- **Architecture:** 23 apps (11 .NET, 12 Java) + 5 infrastructure
- **Key pattern:** Repo-per-app folder structure (PascalCase), ZavaLedger as central hub
- **Networks:** 4 Docker networks (frontend, backend, db, mq)

### Decision: Database Topology — Shared Single-Instance SQL Server
- **Status:** Implemented
- **Architecture:** Single ZavaBankDB, dbo schema, 38+ tables, all services connect with zavaapp login
- **Anti-patterns:** Intentional (plaintext SSN, passwords in config, shared database, god procs)
- **Folder layout:** `infrastructure/sql/` contains all schema, procs, seed data

### User Directives (2026-05-12)
- No language-based folder organization — flat repo root with PascalCase app folders
- All Mono compatibility presumptions approved by Brady
- No ASCII art in markdown — use Mermaid diagrams only

---

## 2026-05-13 — Topology Reconciliation Phase

### Decision: Diagram Splitting Strategy
- **Status:** Implemented
- **Pattern:** 15-node-per-diagram maximum; layered a/b/c sub-diagrams for large views
- **Result:** 13 total diagrams in docs/architecture/diagrams.md

### User Directives (2026-05-13)
- Brady said "no actual demo code" until "banana" — focus on topology docs only
- Prefer Mermaid diagrams over prose in messaging topology doc

### Decision: Topology Review — Critical Issues
- **3 Critical Blockers Identified:** Node count mismatch, port range conflict, network topology mismatch
- **Status:** All resolved by lead_architect reconciliation
- **Result:** Clear path to code scaffolding

### Decision: Node Count Reconciliation & Port Mapping Strategy
- **Status:** Resolved
- **Container-Internal Ports:** All apps listen on 8080 (inside Docker network)
- **Host-Mapped Ports:** .NET 8001–8010, Java 9001–9015 (debug access only)
- **Total Inventory:** 28 containers (27 before, +1 for infrastructure clarity)

### Decision: Cross-Ecosystem Authentication Strategy
- **Status:** Implemented
- **Pattern:** Shared `SessionTokens` SQL Server table, 30-min timeout across stacks
- **.NET:** FormsAuth + SessionTokens bridge
- **Java:** HttpSession + SessionTokens bridge

### Decision: Architecture Documentation READY for Implementation
- **Status:** Approved
- **Finding:** All critical/high/medium decisions resolved; diagram TODOs are non-blocking
- **Milestone structure:** M0-M6 defined and ready for team execution

---

## 2026-05-14 — Implementation Completion Phase

### Decision: Network Naming & Missing Service Resolution
- **Status:** Implemented
- **Network Names:** Short-form (frontend-net, backend-net, db-net, mq-net)
- **Missing Services Added:** ZavaReportDashboard, ZavaStatementService, ZavaAlertService, ZavaCurrencyService (4 .NET)

### User Directive: Auto-Merge Approved PRs
- **Status:** Approved by Brady
- **Rationale:** Greenfield demoware, minimal legacy code risk, keep pipeline moving

### Status: M0-M6 All Milestones Complete
- **Date:** 2026-05-14
- **Final State:** 28 containers, 23 app nodes, all services integrated, Playwright e2e tests passing, cross-ecosystem SSO verified
- **PRs Merged:** #34–#49 (16 total)
- **Ready for:** Production delivery or demo execution

