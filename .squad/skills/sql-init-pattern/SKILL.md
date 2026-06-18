# SQL Server Init Pattern for Docker

Confidence: high
Last validated: 2026-05-14

## Pattern

Structure SQL Server initialization scripts for Docker using numbered files (01-50 pattern), sidecar init container, and idempotent DDL/DML for reproducible schema and seed data deployment.

## When to Use

- Deploying SQL Server in Docker Compose for legacy demoware or multi-tenant systems
- Requiring reproducible schema initialization across environments (dev, test, staging, prod)
- Needing to manage DDL, stored procedures, indexes, and seed data as version-controlled code
- Supporting multiple concurrent container instances with shared database

## Implementation

### Directory Structure

```
infrastructure/sql/
├── 01-database.sql         # CREATE DATABASE, initial schemas
├── 02-auth-tables.sql      # Auth.Users, Auth.SessionTokens
├── 03-core-tables.sql      # Accounts, Transactions, Ledger
├── ...
├── 20-stored-procedures.sql
├── 30-indexes.sql
├── 40-seed-data.sql
├── 50-verify.sql           # Final validation queries
└── init.sh                 # Sidecar entrypoint script
```

### Numbered File Convention

**Prefix ranges:**
- **01-15:** DDL (CREATE TABLE, CREATE SCHEMA)
- **16-25:** Stored procedures and functions
- **26-35:** Indexes and constraints
- **36-45:** Seed data
- **46-50:** Verification and post-init tasks

### Idempotent DDL Pattern

```sql
-- ✅ CORRECT: Idempotent with IF NOT EXISTS
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Users' AND TABLE_SCHEMA = 'Auth')
BEGIN
    CREATE TABLE Auth.Users (
        user_id INT PRIMARY KEY IDENTITY(1,1),
        username NVARCHAR(100) NOT NULL UNIQUE,
        password_hash NVARCHAR(256) NOT NULL,  -- SHA-1 hashed for era-appropriateness
        email NVARCHAR(100) NOT NULL,
        created_date DATETIME DEFAULT GETUTCDATE()
    );
    
    CREATE UNIQUE INDEX IX_Users_Username ON Auth.Users(username);
    CREATE UNIQUE INDEX IX_Users_Email ON Auth.Users(email);
    
    PRINT 'Created table Auth.Users';
END
ELSE
BEGIN
    PRINT 'Table Auth.Users already exists';
END
```

### Seed Data Pattern

```sql
-- ✅ CORRECT: Idempotent seed with NOT EXISTS guard
IF NOT EXISTS (SELECT 1 FROM Auth.Users WHERE username = 'maria.rodriguez')
BEGIN
    INSERT INTO Auth.Users (username, password_hash, email)
    VALUES ('maria.rodriguez', 'b93d...[SHA-1 hash]...', 'maria@zavabank.example');
    PRINT 'Seeded user: maria.rodriguez';
END
```

### Stored Procedure Pattern

```sql
-- ✅ CORRECT: DROP IF EXISTS then CREATE for idempotence
IF OBJECT_ID('[dbo].[PostTransaction]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[PostTransaction];
GO

CREATE PROCEDURE [dbo].[PostTransaction]
    @account_id INT,
    @amount DECIMAL(18, 2),
    @transaction_type NVARCHAR(20),
    @description NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Insert transaction
        INSERT INTO Transactions (account_id, amount, type, description, created_date)
        VALUES (@account_id, @amount, @transaction_type, @description, GETUTCDATE());
        
        -- Update account balance
        UPDATE Accounts SET balance = balance + @amount WHERE account_id = @account_id;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
```

### init.sh Sidecar Entrypoint

```bash
#!/bin/bash
set -e

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to be ready..."
for i in {1..50}; do
    /opt/mssql-tools/bin/sqlcmd -S $MSSQL_HOST -U sa -P $SA_PASSWORD -Q "SELECT 1" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "SQL Server is ready!"
        break
    fi
    echo "Attempt $i/50: SQL Server not ready, waiting..."
    sleep 2
done

# Run all SQL scripts in order
echo "Running SQL initialization scripts..."
for script in /sql/0*.sql /sql/1*.sql /sql/2*.sql /sql/3*.sql /sql/4*.sql /sql/5*.sql; do
    if [ -f "$script" ]; then
        echo "Executing: $(basename $script)"
        /opt/mssql-tools/bin/sqlcmd -S $MSSQL_HOST -U sa -P $SA_PASSWORD \
            -d ZavaBankDB -i "$script"
        if [ $? -ne 0 ]; then
            echo "ERROR executing $(basename $script)"
            exit 1
        fi
    fi
done

echo "SQL initialization complete!"
```

### Docker Compose Integration

```yaml
services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2019-latest
    environment:
      SA_PASSWORD: MyP@ssw0rd!
      MSSQL_SA_PASSWORD: MyP@ssw0rd!
      ACCEPT_EULA: Y
    healthcheck:
      test: ["CMD", "/opt/mssql-tools/bin/sqlcmd", "-S", "localhost", "-U", "sa", "-Q", "SELECT 1"]
      interval: 30s
      timeout: 10s
      retries: 3
    volumes:
      - sqlserver-data:/var/opt/mssql/data

  sqlserver-init:
    build: ./infrastructure/sql
    depends_on:
      sqlserver:
        condition: service_healthy
    environment:
      MSSQL_HOST: sqlserver
      SA_PASSWORD: MyP@ssw0rd!
    volumes:
      - ./infrastructure/sql:/sql:ro
    command: /app/init.sh

  # Other services depend on sqlserver-init
  zava-ledger:
    depends_on:
      sqlserver-init:
        condition: service_completed_successfully

volumes:
  sqlserver-data:
```

### Dockerfile for Init Container

```dockerfile
FROM mcr.microsoft.com/mssql/server:2019-latest

RUN apt-get update && \
    apt-get install -y mssql-tools

COPY init.sh /app/init.sh
RUN chmod +x /app/init.sh

WORKDIR /app
```

## Gotchas

1. **Identity insert:** If using `IDENTITY(1,1)` columns, script must handle `SET IDENTITY_INSERT` for seed data that specifies explicit IDs.

2. **Circular foreign keys:** Order scripts to handle parent tables before child tables. Use `ALTER TABLE ... ADD CONSTRAINT` after all tables exist if needed.

3. **Index names:** SQL Server requires unique index names across schema. Use naming convention: `IX_TableName_ColumnName` or `IX_TableName_ColumnName1_ColumnName2`.

4. **Transaction logging:** Log each script execution (PRINT statements) for debugging. Logs appear in Docker container output.

5. **Timeout handling:** Init container must wait long enough for SQL Server to accept connections. Use retry loop with 30-50 attempts.

6. **Seed data uniqueness:** Guard all seed inserts with `NOT EXISTS` or `IF NOT EXISTS (SELECT ... WHERE unique_column = value)` to support idempotent re-runs.

7. **Default values:** Use `DEFAULT GETUTCDATE()` for timestamps, never hardcoded dates. This ensures reproducible seed data across environments and time zones.

8. **Connection failures:** SQL Server init failures should fail the init container (`exit 1`) to prevent dependent services from starting prematurely.
