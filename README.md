# Zava Bank — Multi-Service Banking Platform

A distributed banking application composed of 23 microservices, demonstrating multi-repo architecture with git submodules.

## Quick Start

```bash
# Clone with all services
git clone --recurse-submodules https://github.com/yungezz/Build2026GHCPAppModDemoWare.git

# If you already cloned without submodules
git submodule update --init --recursive

# Start all services
docker compose up
```

## Architecture

This repository is the **orchestration layer** — it contains the Docker Compose configuration, shared infrastructure, and references to each service as a git submodule. Each service lives in its own repository and can be developed independently.

### Services

| Service | Description | Stack |
|---------|-------------|-------|
| [ZavaAccountManager](https://github.com/yungezz/ZavaAccountManager) | Customer account management portal | ASP.NET WebForms / Mono |
| [ZavaACHProcessor](https://github.com/yungezz/ZavaACHProcessor) | ACH payment batch processing | Java / Gradle |
| [ZavaAlertService](https://github.com/yungezz/ZavaAlertService) | Real-time alert notifications | ASP.NET / Mono |
| [ZavaAuditWorker](https://github.com/yungezz/ZavaAuditWorker) | Audit trail queue consumer | .NET / RabbitMQ |
| [ZavaAuthGateway](https://github.com/yungezz/ZavaAuthGateway) | Authentication & SSO gateway | ASP.NET WebForms / Mono |
| [ZavaBatchScheduler](https://github.com/yungezz/ZavaBatchScheduler) | Scheduled batch job orchestration | Java / Gradle |
| [ZavaComplianceReporter](https://github.com/yungezz/ZavaComplianceReporter) | Regulatory compliance reporting | Java / Spring Boot |
| [ZavaCurrencyService](https://github.com/yungezz/ZavaCurrencyService) | Currency exchange rates | ASP.NET / Mono |
| [ZavaDocVault](https://github.com/yungezz/ZavaDocVault) | Document storage & retrieval | Java / Spring Boot |
| [ZavaFileIngestion](https://github.com/yungezz/ZavaFileIngestion) | File intake processing pipeline | Java / Gradle |
| [ZavaFraudDetector](https://github.com/yungezz/ZavaFraudDetector) | Fraud detection & alerting | Java / Spring Boot |
| [ZavaInterestCalculator](https://github.com/yungezz/ZavaInterestCalculator) | Interest rate calculations | Java / Spring Boot |
| [ZavaKYCService](https://github.com/yungezz/ZavaKYCService) | Know Your Customer verification | Java / Spring Boot |
| [ZavaLedger](https://github.com/yungezz/ZavaLedger) | Core ledger / general ledger | Java / Spring Boot |
| [ZavaLoanOriginationAPI](https://github.com/yungezz/ZavaLoanOriginationAPI) | Loan application processing API | Java / Spring Boot |
| [ZavaLoanPortal](https://github.com/yungezz/ZavaLoanPortal) | Loan application customer portal | ASP.NET WebForms / Mono |
| [ZavaNotifyWorker](https://github.com/yungezz/ZavaNotifyWorker) | Notification queue consumer | .NET / RabbitMQ |
| [ZavaPayGateway](https://github.com/yungezz/ZavaPayGateway) | Payment processing gateway | Java / Spring Boot |
| [ZavaQueueBridge](https://github.com/yungezz/ZavaQueueBridge) | Message queue bridge service | .NET / RabbitMQ |
| [ZavaReportDashboard](https://github.com/yungezz/ZavaReportDashboard) | Management reporting dashboard | ASP.NET / Mono |
| [ZavaRiskEngine](https://github.com/yungezz/ZavaRiskEngine) | Risk assessment engine | ASP.NET / Mono |
| [ZavaStatementService](https://github.com/yungezz/ZavaStatementService) | Account statement generation | ASP.NET / Mono |
| [ZavaWireTransferService](https://github.com/yungezz/ZavaWireTransferService) | Wire transfer processing | Java / Spring Boot |

### Infrastructure (in this repo)

| Directory | Purpose |
|-----------|---------|
| `infrastructure/sql/` | SQL Server initialization scripts (numbered execution order) |
| `infrastructure/nginx/` | Nginx reverse proxy & portal UI |
| `docker-compose.yml` | Full service orchestration (28 containers) |
| `tests/` | Integration smoke tests |

## Port Mappings

| Service | Port |
|---------|------|
| Nginx (entry point) | 80 |
| Loan Portal | 8001 |
| Account Manager | 8002 |
| Auth Gateway | 8003 |
| Currency Service | 8004 |
| Risk Engine | 8005 |
| Report Dashboard | 8006 |
| Statement Service | 8007 |
| Alert Service | 8008 |
| SQL Server | 1433 |
| RabbitMQ Management | 15672 |

## Working with Submodules

```bash
# Pull latest changes for all services
git submodule update --remote --merge

# Work on a specific service
cd ZavaAuthGateway
git checkout -b my-feature
# ... make changes, commit, push, PR against the service repo ...

# Update the main repo to point to new commits
cd ..
git add ZavaAuthGateway
git commit -m "Update ZavaAuthGateway submodule reference"
```

## Requirements

- Docker & Docker Compose
- Git (with submodule support)
- Access to all 23 service repositories (private — requires collaborator access)
