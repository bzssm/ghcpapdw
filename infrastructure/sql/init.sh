#!/bin/bash
# init-db.sh — waits for SQL Server to be ready, then runs init scripts in order
# ZavaBankDB initialization for Docker Compose sidecar pattern
# Generated: 2026-05-14

set -e

SA_PASSWORD="${SA_PASSWORD:-Zava123!}"
SQL_SERVER="${SQL_SERVER:-localhost}"

echo "========================================="
echo "ZavaBankDB Initialization"
echo "========================================="
echo ""

echo "Waiting for SQL Server to start..."
for i in $(seq 1 60); do
    /opt/mssql-tools18/bin/sqlcmd -S "$SQL_SERVER" -U sa -P "$SA_PASSWORD" -C -Q "SELECT 1" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "SQL Server is ready after ${i} attempts."
        break
    fi
    if [ $i -eq 60 ]; then
        echo "ERROR: SQL Server did not start within 120 seconds."
        exit 1
    fi
    sleep 2
done

echo ""
echo "Running schema scripts (01-39)..."
for script in /scripts/*.sql; do
    filename=$(basename "$script")
    num=${filename%%-*}
    echo "  Executing ${filename}..."
    if [ "$num" -lt "40" ] 2>/dev/null; then
        # Schema scripts: fail on error
        /opt/mssql-tools18/bin/sqlcmd -S "$SQL_SERVER" -U sa -P "$SA_PASSWORD" -C -i "$script" -b
        if [ $? -ne 0 ]; then
            echo "  ERROR: Schema script failed: ${filename}"
            exit 1
        fi
    else
        # Seed scripts (40+): warn but continue on error
        /opt/mssql-tools18/bin/sqlcmd -S "$SQL_SERVER" -U sa -P "$SA_PASSWORD" -C -i "$script"
        if [ $? -ne 0 ]; then
            echo "  WARNING: Seed script had errors: ${filename} (continuing)"
        fi
    fi
done

echo ""
echo "========================================="
echo "Database initialization complete."
echo "========================================="
