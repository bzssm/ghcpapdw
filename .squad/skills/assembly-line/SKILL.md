# The Zava Assembly Line

> **Confidence:** high (approved by Brady, 2026-05-14)

The Assembly Line is a continuous implementation ceremony where Ralph drives a queue of GitHub issues through branch → implement → PR → merge cycles with maximum parallelism and minimal human friction.

## Core Rule: Auto-Merge by Default

**ALL changes auto-merge when CI passes** — single-node, cross-node, docker topology, shared schema, messaging, everything.

**The ONLY trigger for human review is agent uncertainty.** If the implementing agent flags that it is uncertain about its implementation, lead_architect reviews. Otherwise, squash-merge proceeds automatically.

---

## Conventions

### Branch Naming

```
issue/{issue-number}-{short-slug}
```

Always branch from `main`.

### Commit Format

```
{type}: {short description} (#{issue-number})

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

Types: `feat`, `fix`, `infra`, `docs`, `test`, `refactor`

### PR Format

**Title:** `[M{milestone}] {Issue title} (#issue-number)`

**Body must include:** `Closes #{issue-number}`

### Merge Strategy

- Squash merge
- Delete branch after merge

---

## Milestone Gating

```
M0 → M1 → M2 → (M3 | M4 | M5 parallel) → M6
```

- **M0: Infrastructure** — Docker Compose, SQL init, RabbitMQ, Nginx, scaffolds
- **M1: Core Services** — ZavaLedger, ZavaAuthGateway, ZavaCurrencyService, ZavaKYCService
- **M2: Domain Services** — RiskEngine, InterestCalc, StatementSvc, AlertSvc, LoanOrigAPI, DocVault, WireTransfer
- **M3: .NET Frontends** — LoanPortal, AccountManager, ReportDashboard
- **M4: Java Frontends** — PayGateway, FraudDetector, ComplianceReporter
- **M5: Workers** — Notify, Audit, QueueBridge, ACHProcessor, BatchScheduler, FileIngestion
- **M6: Integration & Polish** — Cross-ecosystem SSO, seed data, Nginx routing, demo script

## Parallelism

- **M0:** 3–4 agents working in parallel
- **M1–M2:** 4–6 agents (sequential milestone gating, parallel within milestone)
- **M3/M4/M5:** 6–8 agents (three milestones run simultaneously)
- **M6:** converge, 3–4 agents

---

## Ralph Drives the Queue

Ralph (coordinator) is responsible for:

1. Scanning the board for unblocked issues
2. Assigning work to the appropriate agent via `squad:{member}` label + `routing.md`
3. Removing `blocked-by:M{N}` labels when a milestone completes
4. Ensuring continuous flow — no idle agents, no stalled issues

---

## Testing Strategy

- **Integration tests:** Container starts, endpoints respond, `docker compose up` stays green
- **Playwright UI tests:** For frontends (M3/M4)
- **No unit tests** unless truly needed for complex logic
- CI validates: build succeeds, container health checks pass, integration tests green

---

## Lifecycle Steps

1. **Ralph scans** board for next unblocked issue
2. **Ralph assigns** to appropriate agent (via `squad:{member}` label + `routing.md`)
3. **Agent creates branch** `issue/{N}-{slug}` from `main`
4. **Agent implements** — code, Dockerfile, tests, config
5. **Agent commits** with format, pushes to origin
6. **Agent opens PR** via `gh pr create` with `Closes #{N}` in body
7. **CI runs** — docker compose up, integration tests, health checks
8. **If agent flagged uncertainty** → lead_architect reviews → approve or request changes
9. **If no uncertainty** → auto-merge (squash) when CI passes
10. **Branch deleted**, issue closed automatically via `Closes #` reference
11. **Ralph checks** if milestone complete → removes `blocked-by` labels on next milestone → next cycle

---

## Auto-Merge Decision Tree

```
CI passes?
├── NO → Agent fixes, re-pushes, CI re-runs
└── YES
    └── Agent flagged uncertainty?
        ├── YES → lead_architect reviews
        │         ├── Approved → squash merge
        │         └── Changes requested → agent fixes → re-run
        └── NO → auto-merge (squash), delete branch
```

---

## How Agents Flag Uncertainty

When an implementing agent is unsure about:
- Architectural decisions not covered by existing docs
- Ambiguous requirements
- Cross-node integration behavior
- Schema changes that might affect other nodes

The agent adds a PR comment: `@lead_architect — flagging for review: {reason}` and applies the `needs-review` label. This is the ONLY path to human review.
