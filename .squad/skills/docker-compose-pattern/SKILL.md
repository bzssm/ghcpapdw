# Docker Compose Pattern for Multi-Ecosystem Monoliths

Confidence: high
Last validated: 2026-05-14

## Pattern

Structure Docker Compose for multi-ecosystem monoliths (.NET Mono + Java Tomcat) with clear port mapping, network topology, and health checks supporting legacy cross-language service discovery inside containers.

## When to Use

- Building legacy demoware with mixed .NET Framework + Java technologies
- Requiring cross-language service communication via Docker DNS
- Supporting local development with debug host port mapping (8001-8010 .NET, 9001-9015 Java)
- Implementing health checks and startup dependency ordering

## Implementation

### Port Mapping Convention
- **Container-internal:** All apps listen on port 8080 (service-to-service via Docker DNS)
- **Host-mapped (debug only):** .NET apps → 8001-8010, Java apps → 9001-9015
- **External:** Nginx reverse proxy on port 80, routes to internal services via Docker DNS + 8080

### Network Topology (4 Networks)
```
frontend-net   → Web servers, frontends
backend-net    → Core services, domain services
db-net         → Database access only
mq-net         → Message broker access only
```

### Health Check Patterns
- **Web services:** HTTP GET `/health` (15s interval, 5s timeout)
- **Database:** sqlcmd health check (30s interval, 10s timeout)
- **Message broker:** diagnostics or API check (30s interval)
- **Workers:** Process check `pgrep` (30s interval) or file-based heartbeat

### Startup Ordering
Use `depends_on` with `condition: service_healthy` for strict ordering:
```
Infrastructure (SQL, RabbitMQ) → Core Services → Domain Services → Frontends → Workers → Nginx
```

### Environment Variable Strategy
All services accept config via environment variables with sensible defaults in application config files.

## Gotchas

1. **Port confusion:** Container-internal 8080 is for Docker DNS service-to-service calls, not localhost or host ports.
2. **Service DNS:** Services reference each other by service name (e.g., `sqlserver:1433`), not localhost or host ports.
3. **Health checks:** Must be fast and realistic; overly strict checks block startup of dependent services.
4. **Network membership:** Services need shared networks to communicate; multi-network membership is valid for cross-layer services.
5. **Volume persistence:** Legacy apps need persistent volumes for logs and file-based integration; define explicitly to avoid losing debug output.
