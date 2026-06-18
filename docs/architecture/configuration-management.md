# Zava Bank — Configuration Management

> **Author:** expert_docs  
> **Date:** 2026-05-13  
> **Status:** Active  
> **Purpose:** Document configuration file locations, patterns, and secrets strategy for legacy .NET and Java services running in Docker Compose

---

## Table of Contents

1. [Overview](#overview)
2. [.NET Configuration](#net-configuration)
3. [Java Configuration](#java-configuration)
4. [Docker Environment Variables](#docker-environment-variables)
5. [Secrets Strategy](#secrets-strategy)
6. [Configuration File Locations](#configuration-file-locations)
7. [Cross-References](#cross-references)

---

## Overview

Zava Bank's 23-node legacy system spans two technology ecosystems — Microsoft .NET Framework 4.x and Java (8/11/17) — each with distinct configuration approaches. The demoware intentionally reflects late-2000s practices: XML configuration files for .NET (web.config, app.config), properties files for Java (application.properties), and hardcoded connection strings for simplicity (not production-grade).

**Configuration Principle:** Externalize configuration via Docker environment variables at container startup. Each service receives environment variables that populate connection strings, RabbitMQ hosts, and feature flags. This allows a single Docker image to run in multiple environments (dev, staging, demo) without rebuilds.

**Secrets Approach (Demoware Only):** Credentials are passed as plaintext environment variables in `docker-compose.yml`. A real system would use Azure Key Vault or HashiCorp Vault. This approach is acceptable for a non-production demo system.

---

## .NET Configuration

### Pattern: web.config for Web Forms, app.config for WCF Services

All .NET Framework 4.x services use XML-based configuration files following the classic enterprise pattern:

- **Web Forms frontends** (ZavaLoan Portal, ZavaAccount Manager, ZavaReport Dashboard): `web.config` in the application root
- **WCF services** (ZavaRisk Engine, ZavaStatement Service, ZavaAlert Service, ZavaCurrency Service): `web.config` if hosted in IIS/IIS Express, or `app.config` if hosted as console applications
- **Console workers** (ZavaNotify, ZavaAudit Worker, ZavaQueue Bridge): `app.config` in the application root

### Key Configuration Sections

#### 1. Connection Strings

```xml
<configuration>
  <connectionStrings>
    <!-- SQL Server connection string populated from Docker env vars -->
    <add name="ZavaBankDb" 
         connectionString="Server=zava-sqlserver,1433;Database=ZavaBank;User Id=sa;Password=Zava123!;" 
         providerName="System.Data.SqlClient" />
  </connectionStrings>
</configuration>
```

Docker sets `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_USER`, `DATABASE_PASSWORD`, and these are injected into the connection string at container startup via an initialization script.

#### 2. appSettings

```xml
<configuration>
  <appSettings>
    <!-- RabbitMQ Configuration -->
    <add key="RabbitMQ.Host" value="zava-rabbitmq" />
    <add key="RabbitMQ.Port" value="5672" />
    <add key="RabbitMQ.VirtualHost" value="/zavabank" />
    <add key="RabbitMQ.Username" value="zava_app" />
    <add key="RabbitMQ.Password" value="zava_pass" />
    
    <!-- Feature Flags -->
    <add key="Features.EnableFraudDetection" value="true" />
    <add key="Features.EnableCompliance" value="true" />
    
    <!-- Service Endpoint URLs -->
    <add key="Service.RiskEngine.Endpoint" value="http://zava-risk-engine:8090" />
    <add key="Service.Ledger.Endpoint" value="http://zava-ledger:8190" />
    
    <!-- Email Configuration -->
    <add key="Email.SmtpHost" value="zava-mailhog" />
    <add key="Email.SmtpPort" value="1025" />
    <add key="Email.FromAddress" value="noreply@zavabank.local" />
  </appSettings>
</configuration>
```

#### 3. WCF Service Configuration (system.serviceModel)

```xml
<configuration>
  <system.serviceModel>
    <!-- Bindings -->
    <bindings>
      <basicHttpBinding>
        <binding name="BasicHttpBinding_IZavaRiskEngine" 
                 maxBufferSize="2147483647" 
                 maxReceivedMessageSize="2147483647">
          <security mode="None" />
        </binding>
      </basicHttpBinding>
    </bindings>
    
    <!-- Client Endpoints (for services calling other WCF services) -->
    <client>
      <endpoint address="http://zava-risk-engine:8090/ZavaRiskEngine.svc" 
                binding="basicHttpBinding" 
                bindingConfiguration="BasicHttpBinding_IZavaRiskEngine"
                contract="ZavaBank.Services.Contracts.IZavaRiskEngine" 
                name="RiskEngineEndpoint" />
    </client>
    
    <!-- Service Behaviors -->
    <behaviors>
      <serviceBehaviors>
        <behavior>
          <serviceMetadata httpGetEnabled="true" />
          <serviceDebug includeExceptionDetailInFaults="false" />
        </behavior>
      </serviceBehaviors>
    </behaviors>
  </system.serviceModel>
</configuration>
```

#### 4. Forms Authentication (ASP.NET Web Forms)

```xml
<configuration>
  <system.web>
    <authentication mode="Forms">
      <forms loginUrl="~/Login.aspx" 
             timeout="30" 
             defaultUrl="~/Default.aspx"
             name=".ASPXAUTH"
             path="/"
             protection="All" />
    </authentication>
    
    <authorization>
      <deny users="?" />
    </authorization>
  </system.web>
</configuration>
```

All .NET frontends redirect unauthenticated users to the centralized **ZavaAuth Gateway** for login.

#### 5. Shared machineKey (Cross-Container FormsAuth)

All .NET Web Forms frontends **and** ZavaAuth Gateway must share an identical `<machineKey>` so that FormsAuthentication cookies issued by one container can be decrypted by another. Without this, each container auto-generates its own keys and tickets are not portable.

```xml
<configuration>
  <system.web>
    <!-- MUST be identical across: ZavaAuth Gateway, ZavaLoan Portal,
         ZavaAccount Manager, ZavaReport Dashboard -->
    <machineKey
      validationKey="CB2721ABDAF8E9DC516D621D8B8BF13A2C9E8689A25303BF"
      decryptionKey="E9D2490BD0075B51D1BA5288514514AF"
      validation="SHA1"
      decryption="AES" />
  </system.web>
</configuration>
```

**Configuration rules:**
- The `validationKey` and `decryptionKey` values must be **byte-for-byte identical** in all four .NET web.config files
- Use `validation="SHA1"` and `decryption="AES"` — both are supported by Mono 6.12
- Do **not** use `AutoGenerate` or `IsolateApps` modifiers — these generate per-app keys and break cross-container ticket sharing
- The Nginx reverse proxy routes all apps under `zava-bank.local` (see system-topology.md §4.4), so the `.ASPXAUTH` cookie domain/path scope works automatically
- For demoware, these keys are committed to source control; in production they would be injected via environment variables or a key vault

**Affected web.config files:**
| Application | Config Path |
|---|---|
| ZavaAuth Gateway | `ZavaAuthGateway/web.config` |
| ZavaLoan Portal | `ZavaLoanPortal/web.config` |
| ZavaAccount Manager | `ZavaAccountManager/web.config` |
| ZavaReport Dashboard | `ZavaReportDashboard/web.config` |

### Configuration Initialization in .NET

Each .NET service includes an initialization hook (in `Global.asax` for Web Forms, or `Program.Main` for console apps) that reads environment variables and populates `web.config` / `app.config` at runtime:

```csharp
// Pseudo-code: Initialize config from environment at startup
string databaseHost = Environment.GetEnvironmentVariable("DATABASE_HOST") ?? "localhost";
string connectionString = $"Server={databaseHost},1433;Database=ZavaBank;User Id=sa;Password=...";
ConfigurationManager.AppSettings["RabbitMQ.Host"] = 
    Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
```

---

## Java Configuration

### Pattern: application.properties for Spring-like apps, context.xml for Struts/Servlet

Java services use property files and context XML for configuration:

- **Web applications** (ZavaPay Gateway, ZavaFraud Detector, ZavaCompliance Reporter): `application.properties` + `context.xml` (or `applicationContext.xml` if using Spring)
- **REST/Servlet services** (ZavaLedger, ZavaKYC Service, ZavaInterest Calculator, ZavaLoan Origination API, etc.): `application.properties` in classpath root
- **Console workers** (ZavaACH Processor, ZavaBatch Scheduler, ZavaFile Ingestion): `application.properties` bundled in JAR

### Key Configuration Sections

#### 1. application.properties

```properties
# Database Configuration
database.host=zava-sqlserver
database.port=1433
database.name=ZavaBank
database.user=sa
database.password=Zava123!
database.driver=com.microsoft.sqlserver.jdbc.SQLServerDriver

# Connection Pool (HikariCP)
hikari.maximumPoolSize=20
hikari.minimumIdle=5
hikari.maxIdleTime=300000

# RabbitMQ Configuration
rabbitmq.host=zava-rabbitmq
rabbitmq.port=5672
rabbitmq.vhost=/zavabank
rabbitmq.username=zava_app
rabbitmq.password=zava_pass

# Service Endpoints (for REST calls to other services)
service.ledger.base.url=http://zava-ledger:8190
service.risk-engine.base.url=http://zava-risk-engine:8090
service.kyc.base.url=http://zava-kyc:8191
service.currency.base.url=http://zava-currency:8093

# Struts Configuration (if using Struts 1.x or 2.x)
struts.i18n.encoding=UTF-8
struts.action.extension=.do
struts.multipart.maxSize=52428800

# Feature Flags
feature.fraud.detection.enabled=true
feature.compliance.reporting.enabled=true

# Logging
logging.level=INFO
logging.file=/var/log/zavabank/zavabank.log
```

#### 2. context.xml (Struts/Servlet Context Configuration)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Context>
    <!-- Database Connection Pool -->
    <Resource name="jdbc/ZavaBankDB"
              auth="Container"
              type="javax.sql.DataSource"
              driverClassName="com.microsoft.sqlserver.jdbc.SQLServerDriver"
              url="jdbc:sqlserver://zava-sqlserver:1433;databaseName=ZavaBank"
              username="sa"
              password="Zava123!"
              maxActive="20"
              maxIdle="5"
              maxWait="30000" />
    
    <!-- RabbitMQ Connection Factory (if using Spring AMQP) -->
    <Parameter name="rabbitmq.host" value="zava-rabbitmq" />
    <Parameter name="rabbitmq.port" value="5672" />
    <Parameter name="rabbitmq.vhost" value="/zavabank" />
    <Parameter name="rabbitmq.username" value="zava_app" />
    <Parameter name="rabbitmq.password" value="zava_pass" />
</Context>
```

#### 3. struts-config.xml (Struts 1.x)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE struts-config PUBLIC "-//Apache Software Foundation//DTD Struts Configuration 1.3//EN"
    "http://struts.apache.org/dtds/struts-config_1_3.dtd">
<struts-config>
    <data-sources>
        <data-source key="default"
                     driver="com.microsoft.sqlserver.jdbc.SQLServerDriver"
                     url="jdbc:sqlserver://zava-sqlserver:1433;databaseName=ZavaBank"
                     user="sa"
                     password="Zava123!"
                     maxActive="20"
                     maxIdle="5" />
    </data-sources>
    
    <form-beans>
        <form-bean name="loanApplicationForm" type="com.zavabank.forms.LoanApplicationForm" />
    </form-beans>
    
    <action-mappings>
        <action path="/submitLoan" 
                type="com.zavabank.actions.SubmitLoanAction" 
                name="loanApplicationForm"
                input="/loanApplication.jsp"
                scope="request">
            <forward name="success" path="/loanConfirmation.jsp" />
            <forward name="error" path="/loanError.jsp" />
        </action>
    </action-mappings>
</struts-config>
```

#### 4. struts.xml (Struts 2.x)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE struts PUBLIC "-//Apache Software Foundation//DTD Struts Configuration 2.5//EN"
    "http://struts.apache.org/dtds/struts-2.5.dtd">
<struts>
    <constant name="struts.devMode" value="false" />
    <constant name="struts.i18n.encoding" value="UTF-8" />
    
    <package name="frauddetection" namespace="/" extends="struts-default">
        <action name="detectFraud" class="com.zavabank.fraud.FraudDetectionAction">
            <interceptor-ref name="defaultStack" />
            <result name="success">/fraudResult.jsp</result>
            <result name="error">/fraudError.jsp</result>
        </action>
    </package>
</struts>
```

#### 5. web.xml (Servlet Deployment Descriptor)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee 
         http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0">
    
    <!-- JDBC Data Source Reference -->
    <resource-ref>
        <description>Database Connection Pool</description>
        <res-ref-name>jdbc/ZavaBankDB</res-ref-name>
        <res-type>javax.sql.DataSource</res-type>
        <res-auth>Container</res-auth>
    </resource-ref>
    
    <!-- Struts 1.x Action Servlet -->
    <servlet>
        <servlet-name>action</servlet-name>
        <servlet-class>org.apache.struts.action.ActionServlet</servlet-class>
        <init-param>
            <param-name>config</param-name>
            <param-value>/WEB-INF/struts-config.xml</param-value>
        </init-param>
    </servlet>
    
    <servlet-mapping>
        <servlet-name>action</servlet-name>
        <url-pattern>*.do</url-pattern>
    </servlet-mapping>
    
    <!-- Struts 2.x Dispatcher Filter -->
    <filter>
        <filter-name>struts2</filter-name>
        <filter-class>org.apache.struts2.dispatcher.filter.StrutsPrepareAndExecuteFilter</filter-class>
    </filter>
    
    <filter-mapping>
        <filter-name>struts2</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>
    
    <!-- Environment-specific ServletContext init parameters -->
    <context-param>
        <param-name>rabbitmq.host</param-name>
        <param-value>zava-rabbitmq</param-value>
    </context-param>
</web-app>
```

### Configuration Initialization in Java

Each Java service reads `application.properties` at startup via a configuration loader:

```java
// Pseudo-code: Load config from properties and environment
Properties props = new Properties();
props.load(new FileInputStream("application.properties"));

String dbHost = System.getenv("DATABASE_HOST") != null ? 
    System.getenv("DATABASE_HOST") : 
    props.getProperty("database.host", "localhost");

// Initialize connection pool, RabbitMQ client, etc.
```

---

## Docker Environment Variables

All services receive configuration via environment variables set in `docker-compose.yml`. This decouples the Docker image from environment-specific settings.

### Common Environment Variables (All Services)

| Variable | Default | Purpose |
|----------|---------|---------|
| `DATABASE_HOST` | `zava-sqlserver` | SQL Server hostname |
| `DATABASE_PORT` | `1433` | SQL Server port |
| `DATABASE_USER` | `sa` | SQL Server user |
| `DATABASE_PASSWORD` | `Zava123!` | SQL Server password |
| `RABBITMQ_HOST` | `zava-rabbitmq` | RabbitMQ hostname |
| `RABBITMQ_PORT` | `5672` | RabbitMQ AMQP port |
| `RABBITMQ_VHOST` | `/zavabank` | RabbitMQ virtual host |
| `RABBITMQ_USER` | `zava_app` | RabbitMQ username |
| `RABBITMQ_PASSWORD` | `zava_pass` | RabbitMQ password |
| `LOG_LEVEL` | `INFO` | Logging level (DEBUG, INFO, WARN, ERROR) |

### .NET-Specific Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `ASPNET_PORT` | `8080` (frontends), `80XX` (services) | HTTP port for ASP.NET application |
| `SMTP_HOST` | `zava-mailhog` | SMTP server for email |
| `SMTP_PORT` | `1025` | SMTP port (MailHog accepts on 1025) |

### Java-Specific Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `JAVA_OPTS` | `-Xmx512m -Xms256m` | JVM heap size (adjust per service) |
| `CATALINA_HOME` | `/opt/tomcat` | Tomcat base (if using Tomcat container) |
| `PORT` | `8180`–`8195` | HTTP port for Servlet/Struts application |

### Example docker-compose.yml Environment Block

```yaml
services:
  zava-loan-portal:
    image: zavabank/aspnet-loan-portal:latest
    environment:
      DATABASE_HOST: zava-sqlserver
      DATABASE_USER: sa
      DATABASE_PASSWORD: Zava123!
      RABBITMQ_HOST: zava-rabbitmq
      RABBITMQ_USER: zava_app
      RABBITMQ_PASSWORD: zava_pass
      ASPNET_PORT: 8080
      LOG_LEVEL: INFO
    ports:
      - "8080:8080"

  zava-pay-gateway:
    image: zavabank/java-pay-gateway:latest
    environment:
      DATABASE_HOST: zava-sqlserver
      DATABASE_USER: sa
      DATABASE_PASSWORD: Zava123!
      RABBITMQ_HOST: zava-rabbitmq
      RABBITMQ_USER: zava_app
      RABBITMQ_PASSWORD: zava_pass
      PORT: 8180
      JAVA_OPTS: "-Xmx512m -Xms256m"
      LOG_LEVEL: INFO
    ports:
      - "8180:8180"
```

---

## Secrets Strategy

### Demoware Approach (Non-Production)

For this legacy demoware system, secrets (database password, RabbitMQ credentials) are stored as plaintext environment variables in `docker-compose.yml`:

```yaml
environment:
  DATABASE_PASSWORD: Zava123!
  RABBITMQ_PASSWORD: zava_pass
```

**Why This Is Acceptable Here:**
- Demo environment, no real customer data
- Credentials are weak (demo-only)
- Single-developer/team setup
- Demonstrates realistic legacy configuration patterns

### Production Approach (Reference)

A real Zava Bank system would use Azure Key Vault or HashiCorp Vault:

1. **Azure Key Vault** (recommended for Azure deployments):
   ```csharp
   // .NET: Retrieve secret from Key Vault at startup
   var credential = new DefaultAzureCredential();
   var client = new SecretClient(new Uri("https://zava-kv.vault.azure.net/"), credential);
   KeyVaultSecret secret = await client.GetSecretAsync("database-password");
   ```

2. **HashiCorp Vault** (platform-agnostic):
   ```bash
   # Retrieve secret from Vault at container startup
   VAULT_TOKEN=$(vault write -field=token auth/jwt/login jwt=$JWT)
   SECRET=$(vault kv get -field=password secret/zavabank/database)
   ```

3. **Docker Secrets** (for Docker Swarm):
   ```yaml
   services:
     zava-sqlserver:
       environment:
         MSSQL_SA_PASSWORD_FILE: /run/secrets/db_password
       secrets:
         - db_password
   
   secrets:
     db_password:
       file: ./secrets/db_password.txt
   ```

### Secrets Not Committed to Source Control

> [!IMPORTANT]
> Never commit `docker-compose.override.yml` or `.env` files containing secrets to Git. Demoware maintainers should use:
> ```bash
> git update-index --assume-unchanged docker-compose.override.yml
> ```
> Or maintain a template file:
> ```
> docker-compose.override.yml.template
> ```

---

## Configuration File Locations

This table summarizes all configuration files across the 23-node system:

| Service Name | Technology | Primary Config File(s) | Key Settings | Environment Override |
|---|---|---|---|---|
| **ZavaLoan Portal** | ASP.NET 4.x Web Forms | `web.config` | Connection string, RabbitMQ host, auth endpoint | `DATABASE_HOST`, `RABBITMQ_HOST` |
| **ZavaAccount Manager** | ASP.NET 4.x Web Forms | `web.config` | Connection string, ledger endpoint, auth endpoint | `DATABASE_HOST`, `RABBITMQ_HOST` |
| **ZavaReport Dashboard** | ASP.NET 4.x Web Forms | `web.config` | Connection string, ledger endpoint, auth endpoint | `DATABASE_HOST`, `RABBITMQ_HOST` |
| **ZavaRisk Engine** | WCF Service (.NET 4.8) | `web.config` | RabbitMQ host, database connection | `DATABASE_HOST`, `RABBITMQ_HOST` |
| **ZavaStatement Service** | WCF Service (.NET 4.8) | `web.config` | RabbitMQ host, database connection, email config | `DATABASE_HOST`, `RABBITMQ_HOST`, `SMTP_HOST` |
| **ZavaAlert Service** | WCF Service (.NET 4.8) | `web.config` | RabbitMQ host, alert rules DB schema | `DATABASE_HOST`, `RABBITMQ_HOST` |
| **ZavaCurrency Service** | WCF Service (.NET 4.8) | `web.config` | Database connection (FX rates table) | `DATABASE_HOST` |
| **ZavaAuth Gateway** | ASP.NET 4.x (HTTP Handlers) | `web.config` | Connection string, forms auth timeout | `DATABASE_HOST` |
| **ZavaNotify** | .NET Framework 4.8 Console | `app.config` | RabbitMQ host, SMTP config | `RABBITMQ_HOST`, `SMTP_HOST` |
| **ZavaAudit Worker** | .NET Framework 4.8 Console | `app.config` | RabbitMQ host, database connection | `RABBITMQ_HOST`, `DATABASE_HOST` |
| **ZavaQueue Bridge** | .NET Framework 4.8 Console | `app.config` | RabbitMQ host, file-drop directory | `RABBITMQ_HOST`, `FILEDROP_PATH` |
| **ZavaPay Gateway** | Java 8 Struts 1.x | `application.properties`, `struts-config.xml`, `context.xml` | DB pool, RabbitMQ, service endpoints | `DATABASE_HOST`, `RABBITMQ_HOST` |
| **ZavaFraud Detector** | Java 11 Struts 2.x | `application.properties`, `struts.xml`, `context.xml` | DB pool, RabbitMQ, fraud rules | `DATABASE_HOST`, `RABBITMQ_HOST`, `LOG_LEVEL` |
| **ZavaCompliance Reporter** | Java 8 Servlet | `application.properties`, `web.xml`, `context.xml` | DB pool, CTR/SAR config, regulatory endpoints | `DATABASE_HOST` |
| **ZavaLedger** | Java 17 Servlet | `application.properties`, `web.xml` | DB pool, ledger schema, transaction config | `DATABASE_HOST`, `PORT` |
| **ZavaKYC Service** | Java 8 Servlet | `application.properties`, `web.xml` | DB pool, KYC database, watchlist config | `DATABASE_HOST` |
| **ZavaInterest Calculator** | Java 8 Servlet | `application.properties`, `web.xml` | DB pool, interest rate config | `DATABASE_HOST` |
| **ZavaLoan Origination API** | Java 11 Servlet | `application.properties`, `web.xml` | DB pool, RabbitMQ, workflow config | `DATABASE_HOST`, `RABBITMQ_HOST` |
| **ZavaDoc Vault** | Java 8 Servlet | `application.properties`, `web.xml` | DB pool, document storage path | `DATABASE_HOST` |
| **ZavaWire Transfer Service** | Java 11 Servlet | `application.properties`, `web.xml` | DB pool, RabbitMQ, FX service endpoint | `DATABASE_HOST`, `RABBITMQ_HOST` |
| **ZavaACH Processor** | Java 8 Console | `application.properties` | DB pool, file-drop directory, NACHA config | `DATABASE_HOST`, `FILEDROP_PATH` |
| **ZavaBatch Scheduler** | Java 8 Console | `application.properties` | DB pool, scheduler cron expressions, service endpoints | `DATABASE_HOST` |
| **ZavaFile Ingestion** | Java 8 Console | `application.properties` | DB pool, file-drop directory, CSV parsing config | `DATABASE_HOST`, `FILEDROP_PATH` |

---

## Cross-References

### Docker Environment Variable Definitions

Environment variable details (such as port mappings and service discovery) are defined in **docker-topology.md §7.1 — Environment Configuration**.

### Database Configuration

Schema-level configuration is documented in **database-topology.md §2 — Schemas and Tables**.

### Message Queue Configuration

RabbitMQ exchanges, queues, and bindings are documented in **messaging-topology.md §1.2 — Exchanges** and **§1.3 — Queues**.

### Error Handling & Configuration

When a service fails to read configuration, see **error-handling-patterns.md § Cross-Stack Configuration Errors** for retry strategies and fallback behavior.

---

## Configuration Best Practices for Maintainers

1. **Test Configuration Changes Locally:** Always update `docker-compose.yml` locally and run `docker compose up` to verify services start and connect to databases/queues.

2. **Use Environment-Specific Override Files:** Create `docker-compose.override.yml` for local overrides (never commit to Git):
   ```bash
   cp docker-compose.yml docker-compose.override.yml
   # Edit docker-compose.override.yml with local paths, credentials
   ```

3. **Keep Config Files Minimal:** Default values in code; only override in config files if necessary.

4. **Document Changes:** When adding a new environment variable or config section, update this file and the relevant service README.

5. **Rotation Cadence:** For demo purposes, rotate credentials monthly. For production, use secret rotation policies in your vault provider.

---

**Last Updated:** 2026-05-13
