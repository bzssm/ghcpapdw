# Zava Bank: The Modernization Journey

**Premise:** Zava Bank is a 30-year-old regional bank facing regulatory pressure, rising maintenance costs, and customer demand for digital banking. Their tech stack is a time capsule — COBOL on mainframes, legacy Java services, ASP.NET Web Forms apps, and everything running on-prem.

**The CEO's mandate:** *"Modernize everything. We need to be cloud-native in 6 months or we lose our competitive edge."*

---

## Act 1: Mainframe Modernization 🏗️

> *"The core banking engine runs on COBOL. Nobody wants to touch it, and the two people who understand it are retiring."*

Zava Bank's **loan processing system** — written in COBOL in the 1990s — handles 50K transactions/day. The team has already modernized the COBOL loan-processing modules into a **Java application** — preserving the business logic that took decades to refine, now running as a modern, maintainable codebase.

But that's just one app. The mainframe migration produced a Java service — and now it sits alongside **hundreds of other apps** across the organization, all in varying states of tech debt.

> *"Great, we modernized the mainframe. But we have 200+ other apps. How do we modernize at scale?"*

---

## Act 2: Modernize at Scale

Now the converted mainframe app has joined the portfolio. It's time to modernize everything — systematically, with governance, and across both Java and .NET ecosystems.

But first — we need to **understand** what we have.

---

### 2.1 — Meet the Apps: Zava Bank's Portfolio 🏦
**Persona:** Developer | **DEMO: Show app portfolios in VS & VS Code**

> *"This is what 30 years of building software looks like."*

We open by showing two groups of apps that keep Zava Bank running:

**In Visual Studio — the .NET portfolio:**
- **ZavaLoan Portal** — the customer-facing loan application (ASP.NET Web Forms)
- **ZavaAccount Manager** — internal account administration tool (.NET Framework)
- **ZavaRisk Engine** — credit risk scoring service (WCF)
- **ZavaNotify** — customer notification service (legacy .NET console app)

**In VS Code — the Java portfolio:**
- **ZavaPay Gateway** — payment processing service (Struts 1.x, Java 8)
- **ZavaLedger** — the converted mainframe core banking engine (Java 17) //todo use same app that was modenized from mainframe earlier
- **ZavaFraud Detector** — real-time fraud analysis (Struts 2.x, Java 11)
- **ZavaKYC Service** — Know Your Customer compliance checks (Java 8, legacy servlets)

> *"Now, I could go into each one of these apps, run the Copilot Modernization agent, get an assessment, and repeat for the next one. But that's 8 apps here — and we have 200+ across the org. Wouldn't it be awesome if we could assess all of them together, at scale?"*

---

### 2.2 — Assess at Scale: The Modernize CLI 🚀
**Persona:** Architect | **DEMO: Modernize CLI — Assessment at Scale**

> *"Same GitHub Copilot Modernization agent. Now in a CLI built for at-scale operations."*

Introduce the **Modernize CLI** — it brings the **same GitHub Copilot Modernization agent** that powers the IDE experience into a purpose-built CLI. It's multipurpose: use its **TUI (Terminal UI) experience** interactively, or go **headless** and execute in a DevOps pipeline. Same intelligence, different interface.

You can run the Modernize CLI **locally against repos on your machine**, or **link it to your GitHub repositories** and run against them directly — no cloning required.

**Demo Steps:**

1. **Show the `repos.json` file** — a manifest listing all of Zava Bank's repositories to assess.

2. **Run the Modernize CLI** in headless mode, pointing at the `repos.json`:
   ```
   modernize assess --repos repos.json 
   ```
   The CLI fans out across all repositories, running the Copilot Modernization agent against each one — in parallel, no IDE required.

3. **Switch to GitHub Agent HQ** — show the assessment process **running live**. Each repository is being analyzed by the agent. T

4. **Show the results** — the agent has produced:
   - **Individual app reports** — detailed per-repo assessments committed directly into each repository **as a Pull Request**, so the team that owns that repo gets their findings right where they work
   - Consolidated report - Also generates a consolidated report when assessed together.

---

### 2.3 — Announcing Command Center (Private Preview) 📊
**Persona:** App Owner / Architect | **DEMO: Command Center**

> *"Developers got their PRs. But what about the people responsible for the entire portfolio?"*

Now announce the **private preview of the Command Center** — the place where **App Owners and Architects** monitor modernization at scale.

**Demo Steps:**

1. **Open the Command Center** — show that all assessment reports are accessible in one place. All apps are visible, categorized by technology (.NET, Java), risk level, and modernization readiness.

2. **Walk through the portfolio view** — everything at a glance:
   - Portfolio-wide technology breakdown and effort estimation
   - Which apps are on unsupported frameworks, which have critical vulnerabilities
   - Prioritized modernization order based on risk, effort, and business value

3. **Show the dashboard** — the Command Center isn't just a dashboard. From here, App Owners and Architects can decide what to modernize next, initiate planning, and set the governance guardrails for execution. We will talk more about that later.

> *"Assessment told us WHERE we are. Now we need to decide HOW we get there — with governance."*

---

### 2.4 — Planning with Guardrails: The Rulebook 📋🔒
**Persona:** Architect | **DEMO: Rulebook + Plan Comparison**

> *"We can't have 15 teams modernizing in 15 different ways. We need standards — starting at the plan."*

Before any modernization work begins, Zava Bank's **architects** define a **Rulebook** — a codified set of organizational standards, architectural patterns, and compliance requirements. When a team creates a modernization **plan**, the rulebook is attached, and the plan is automatically shaped by its rules.

**The rulebook enforces things like:**

- Target cloud platform must be **Azure**
- All services must use **managed identity** (no connection string secrets)
- Logging must use **structured telemetry** (OpenTelemetry/App Insights)
- Database access must use **parameterized queries only**
- All apps must include **health check endpoints**
- Data migration from **S3 → Azure Blob Storage**

#### One Rulebook, Two Ecosystems

The **same rulebook works across both .NET and Java**. The rules are expressed at an *architectural intent* level, not a framework-specific level:

| Rulebook Rule | .NET Implementation | Java Implementation |
|---|---|---|
| Use managed identity | `Azure.Identity` + `DefaultAzureCredential` | `azure-identity` + `DefaultAzureCredentialBuilder` |
| Structured telemetry | `OpenTelemetry.Extensions.Hosting` | `opentelemetry-javaagent` |
| Health checks | `Microsoft.Extensions.Diagnostics.HealthChecks` | Spring Boot Actuator `/health` |
| No secrets in config | Azure Key Vault + `SecretClient` | Azure Key Vault + `SecretClient` |
| Parameterized DB queries | EF Core / Dapper parameters | JPA / PreparedStatement |


#### Demo: Two Agent Plans, Same Rulebook — .NET vs Java

To show the power of the rulebook in action, generate **two plans** from the assessment — one for a .NET app, one for a Java app — and compare them side by side:

**Plan A — ZavaLoan Portal (.NET): Web Forms → Blazor + Aspire + Azure**
- Migrate Web Forms → Blazor components
- Enable .NET Aspire for orchestration and service defaults
- Deploy to Azure Container Apps
- Managed identity via `DefaultAzureCredential`
- Health checks via `Microsoft.Extensions.Diagnostics.HealthChecks`
- Telemetry via OpenTelemetry + App Insights
- S3 data migrated to Azure Blob Storage

**Plan B — ZavaPay Gateway (Java): Struts → Spring Boot + AKS**
- Migrate Struts → Spring Boot 3.x
- Containerize with Dockerfile + Helm chart
- Deploy to AKS with pod-managed identity
- Health checks via Spring Boot Actuator (liveness + readiness probes)
- Telemetry via OpenTelemetry Java agent + App Insights
- S3 data migrated to Azure Blob Storage

**Walk through the diff** — completely different tech stacks, completely different deployment targets, but the **same rulebook rules applied to both**: managed identity, structured telemetry, health checks, no secrets in config, S3 → Blob migration. The rulebook ensures consistency at the governance level while each plan adapts to its ecosystem.

> *"Different languages. Different frameworks. Different deployment targets. Same guardrails. That's what governance at scale looks like."*

---

### 2.5 — Extensibility Create Custom Logic: Custom Skills 🧩
**Persona:** Developer | **DEMO: Custom Skills**

> *"We have internal compliance rules that no generic tool understands."*

Custom Skills are a **developer feature** — they let teams encode their own domain-specific logic into the modernization agent. While the rulebook governs the *plan*, custom skills govern the *execution*.

Zava Bank's developers have authored custom skills for:

- **PII handling** — ensures no customer PII (SSN, account numbers) appears in log statements during migration
- **Zava Bank error codes** — maps legacy error handling to Zava Bank's standardized error response format
- **ZavaQueue messaging library** — Zava Bank uses an internal messaging queue wrapper (`ZavaQueue`) across all services; this custom skill ensures the agent recognizes `ZavaQueue` calls and correctly migrates them to the target framework's patterns

---

### 2.6 — Execute the Java Workstream: Struts → Spring Boot + Azure ☕
**Persona:** Developer | **DEMO: VS Code — Modernization Agent + Custom Skills**

> *"Our payment gateway is stuck on Struts 1.x and Java 8. Nobody wants to touch it."*

**Two core workstreams** drive Zava Bank's modernization:
- **Java path:** Struts → Spring Boot + containerization + Azure
- **.NET path:** WebForms → Blazor + Aspire + Azure

We start with Java — in **VS Code**.

#### Demo Steps:

1. **Open the ZavaPay Gateway in VS Code** — show the Struts 1.x codebase: action classes, XML configs, Java 8 syntax.

2. **Show the custom skills included** in the workspace — the developer has the Zava Bank custom skills loaded:
   - PII handling skill
   - Zava Bank error codes skill
   - ZavaQueue messaging library skill

3. **Run the Modernization Agent in VS Code** — execute the plan against the ZavaPay Gateway. The agent begins migrating Struts action classes to Spring Boot controllers, upgrading Java 8 → 21, converting Struts XML configs to Spring Boot annotations, and containerizing the app with a Dockerfile.

4. **Show Custom Skills in action** — as the agent migrates code, the PII custom skill catches a `logger.info("Processing customer SSN: " + ssn)` line and redacts it. The ZavaQueue skill correctly migrates the internal messaging library calls to Spring Boot's messaging patterns.

5. **Show the result** — a fully modernized Spring Boot 3.x app, containerized, with Azure-ready configuration. The PR includes all changes with clear commit messages.

This is a **repeatable process** — the same agent, same rulebook, same custom skills can be applied to every Java app in the portfolio.

---

### 2.7 — Execute the .NET Workstream: Web Forms → Blazor + Aspire + Azure 🔄🚀
**Persona:** Developer | **DEMO: Visual Studio — Modernization Agent + Custom Skills**

> *"Our customer portal looks like it's from 2008 — because it is."*

Now switch to the .NET workstream — in **Visual Studio**.

#### Demo Steps:

1. **Open the ZavaLoan Portal in Visual Studio** — show the Web Forms codebase: `.aspx` pages, code-behind files, ViewState, server controls.

2. **Show the custom skills included** — the same Zava Bank custom skills are loaded here too:
   - PII handling skill
   - Zava Bank error codes skill
   - ZavaQueue messaging library skill

3. **Run the Modernization Agent in Visual Studio** — execute the plan to migrate Web Forms → Blazor.

#### The UI Transformation

**Before — Web Forms:**
- A clunky **multi-step loan application wizard** with full-page postbacks between each step
- Server-round-trip validation that **wipes your form on error** — users lose progress and start over
- A **GridView** showing loan history with no client-side sorting, filtering, or pagination
- An **UpdatePanel** with a "Loading..." spinner that freezes the entire page during async operations
- Fixed-width layout that **doesn't work on mobile** — customers can't apply for loans from their phone

**After — Blazor:**
- A smooth **single-page step-to-step experience** with real-time inline validation — errors appear as you type, no data loss
- An **interactive loan calculator** — drag a slider to adjust loan amount and term, see monthly payments update instantly
- A **filterable, sortable, searchable loan history table** with virtual scrolling for performance
- A **live approval status tracker** — real-time updates via SignalR as the loan moves through underwriting
- **Fully responsive** — the same portal works beautifully on desktop, tablet, and mobile

> *Same business logic. Same loan workflow. Completely transformed experience.*

#### Then — Enable .NET Aspire

The newly converted Blazor app is then enhanced with **.NET Aspire** — adding orchestration, service defaults, OpenTelemetry, and managed Azure connections. The rulebook's telemetry and health check requirements? **Already satisfied by Aspire's defaults.** The rulebook and Aspire are naturally aligned.

---

### 2.8 — Manage the Projects: Back to Command Center 📊✅
**Persona:** App Owner | **DEMO: Progress Report in Command Center**

> *"Show me where we stand."*

The App Owner returns to the **Command Center** to see the modernization progress across the entire portfolio. The dashboard shows:

- **ZavaPay Gateway** — migrated from Struts → Spring Boot 3.x, containerized, deployed to AKS ✅
- **ZavaLoan Portal** — converted from Web Forms → Blazor + Aspire, deployed to Azure Container Apps ✅
- **ZavaLedger** — modernized core banking engine, deployed to Azure ✅
- **Data migration** — S3 → Azure Blob Storage complete ✅
- **Remaining apps** — prioritized, with plans ready, rulebook attached

A customer applies for a loan → Blazor portal → Java payment service → ZavaLedger core banking logic — **all in Azure, all governed by the same rulebook, all observable in Application Insights.**

> *"Same rulebook governed both the Java and .NET modernizations. That's why everything just works together."*

From the Command Center, let's see these apps **running in action**.

---

### 2.9 — See It Running: Apps in Azure 🌐

> *"Show me everything working together."*

All the modernized apps are live in Azure.

**Demo Steps:**

1. **Show the apps running in Azure** — walk through the Azure portal:
   - **ZavaPay Gateway** — Spring Boot 3.x running in AKS
   - **ZavaLoan Portal** — Blazor + Aspire running in Azure Container Apps
   - **ZavaLedger** — the modernized core banking engine (Java 17, converted from mainframe COBOL)
   - All connected to Azure Blob Storage, Azure SQL, Application Insights

2. **Walk the end-to-end flow** — a customer applies for a loan:
   - Opens the **Blazor portal** → fills out the loan application
   - Portal calls the **Java payment service** → processes the payment
   - Payment service calls **ZavaLedger** (the modernized Java core banking engine) → evaluates the loan
   - **Application Insights** shows a unified distributed trace across all services

3. **The punchline** — this is the same loan workflow that ran on a mainframe last year. Same business logic. Now it's a Java app, running cloud-native on Azure, observable, and governed.

> *"From mainframe COBOL to Java. From on-prem to Azure. From manual to governed. That's the modernization journey."*

---

### 🔮 TODO: AI Infusion — Chat Agent in the App

> *Can we show a chat agent embedded in the ZavaLoan Portal? Imagine a customer interacting with an AI-powered loan advisor — asking questions about rates, eligibility, application status — all powered by Azure OpenAI, running inside the modernized Blazor app. The ultimate demo moment: a legacy mainframe COBOL app → modernized to Java → cloud-native on Azure → with AI infused. The full arc from 1990s to 2026.*

---

**Tagline:** *"From mainframe to cloud-native — governed by one rulebook, modernized by Copilot, running on Azure."*

