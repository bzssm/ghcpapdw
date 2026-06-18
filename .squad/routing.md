# Work Routing

How to decide who handles what.

## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Architecture, system design, markitechture | lead_architect | Design node inventory, Docker Compose topology, integration patterns |
| ASP.NET Web Forms, .aspx pages, server controls | expert_webforms | ZavaLoan Portal, ZavaAccount Manager, Web Forms components |
| WCF, .NET console apps, .NET services | expert_dotnet_services | ZavaRisk Engine, ZavaNotify, ZavaAudit, ZavaInterest, ZavaAuth |
| Java Struts (1.x/2.x), action classes | expert_struts | ZavaPay Gateway, ZavaFraud Detector |
| Java servlets, JSP, Java workers | expert_java_services | ZavaKYC, ZavaLedger, ZavaCurrency, ZavaCompliance, ZavaTransaction, ZavaAlert |
| HTML/CSS, jQuery, frontend styling, visual design | legacy_frontend | 2005-era UI, table layouts, master page styling, JSP view styling |
| Database, SQL Server, schemas, stored procs, seed data | expert_database | Schema design, seed data, ADO.NET/JDBC patterns |
| Docker, Dockerfiles, docker-compose, infrastructure | expert_docker | Containerization, Docker Compose orchestration, reverse proxy |
| Messaging, queues, workers, batch jobs | expert_messaging | ZavaStatement, ZavaReport, ZavaEmail, RabbitMQ setup |
| Technical documentation, READMEs, service catalogs, ADRs | expert_docs | Architecture docs, onboarding guides, domain glossary |
| Mermaid diagrams, architecture visualization, flow diagrams | expert_mermaid | System topology, data flows, sequence diagrams, deployment diagrams |
| Git operations, branching, merging, rebasing, .gitignore | expert_git | Conflict resolution, history cleanup, worktrees, hooks |
| GitHub Actions, Copilot agent, GitHub Models, repo config | expert_github | CI/CD workflows, labels, templates, branch protection |
| Code review, integration testing, era-appropriateness | qa_integration | End-to-end tests, Docker Compose validation, demo scenario |
| Scope & priorities | lead_architect | What to build next, trade-offs, decisions |
| Session logging | Scribe | Automatic — never needs routing |

## Issue Routing

| Label | Action | Who |
|-------|--------|-----|
| `squad` | Triage: analyze issue, assign `squad:{member}` label | Lead |
| `squad:{name}` | Pick up issue and complete the work | Named member |

### How Issue Assignment Works

1. When a GitHub issue gets the `squad` label, the **Lead** triages it — analyzing content, assigning the right `squad:{member}` label, and commenting with triage notes.
2. When a `squad:{member}` label is applied, that member picks up the issue in their next session.
3. Members can reassign by removing their label and adding another member's label.
4. The `squad` label is the "inbox" — untriaged issues waiting for Lead review.

## Rules

1. **Eager by default** — spawn all agents who could usefully start work, including anticipatory downstream work.
2. **Scribe always runs** after substantial work, always as `mode: "background"`. Never blocks.
3. **Quick facts → coordinator answers directly.** Don't spawn an agent for "what port does the server run on?"
4. **When two agents could handle it**, pick the one whose domain is the primary concern.
5. **"Team, ..." → fan-out.** Spawn all relevant agents in parallel as `mode: "background"`.
6. **Anticipate downstream work.** If a feature is being built, spawn the tester to write test cases from requirements simultaneously.
7. **Issue-labeled work** — when a `squad:{member}` label is applied to an issue, route to that member. The Lead handles all `squad` (base label) triage.
