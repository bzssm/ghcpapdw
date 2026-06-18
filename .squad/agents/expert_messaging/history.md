# History (Project Complete)

## Project Context
- **Project:** Build2026GHCPAppModDemoWare — Zava Bank legacy banking demoware (23 app nodes: 11 .NET, 12 Java)
- **User:** Brady
- **Tech:** ASP.NET 4.x/WCF (Mono), Java Struts/Servlet (Gradle), SQL Server, RabbitMQ, Docker Compose
- **Goal:** Build authentic legacy demoware (2005-2015 era) for GitHub Copilot App Modernization demos
- **Status:** ✅ All milestones M0-M6 complete

## Key Learnings

### RabbitMQ Architecture
- **8 exchanges:** topic (loans/payments/fraud/accounts), fanout (notifications), direct (compliance/statements), DLX
- **15 application queues + 1 dead-letter queue:** All durable with error routing configured
- **Vhost:** Single `/zavabank` for all services

### Serialization & Error Handling
- **Dual format by language:** .NET→XML (XmlSerializer), Java→JSON (org.json)
- **Intentionally inconsistent:** Realistic legacy pain point and modernization target
- **Consumer pattern:** Manual ack/nack; failures routed to DLX for manual inspection
- **Worker polling:** 5-second intervals with `System.Threading.Timer` (.NET) and `ScheduledExecutorService` (Java)

### Cross-Ecosystem Messaging Patterns
- **RabbitMQ replaces MSMQ:** Windows-only MSMQ doesn't work in Docker; RabbitMQ is portable
- **DLX strategy:** Single `q.deadletter` queue collects all failed messages (intentional anti-pattern)
- **ZavaQueue Bridge:** Bridges file drops into RabbitMQ for legacy file-based integration

### Folder Layout & Scalability
- **Each worker:** Root-level PascalCase folder (e.g., `ZavaNotifyWorker/`)
- **Infrastructure shared:** RabbitMQ config in `infrastructure/rabbitmq/`
- **Future repo split:** Each folder becomes its own GitHub repository trivially


## 2026-05-14 — Scribe Cross-Agent Update
- expert_docker: nginx proxy_redirect fixes deployed (1fc6cd4)
- legacy_frontend: ZavaBank Portal navigation added (d5f2d63)

