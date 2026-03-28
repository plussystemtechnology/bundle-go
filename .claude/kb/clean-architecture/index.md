# Clean Architecture — Bundle-Go

## Layer Stack (inner → outer)

```
domain/        Pure business entities and rules. No external deps.
port/          Interfaces (contracts). Depends only on domain.
app/           Use cases / application services. Orchestrates domain + port.
adapter/       Concrete implementations (HTTP, DB, Kafka, Redis).
bootstrap/     Wiring: instantiates adapters, injects into app services.
cmd/           Entry points (main packages). Calls bootstrap only.
config/        Config structs loaded from env/file. stdlib + third-party only.
pkg/           Shared utilities (no business logic). Imported by adapter+.
```

## Dependency Flow

```
cmd → bootstrap → adapter ↘
                  app     → port → domain
                  config  ↗
                  pkg    ↗
```

## Key Rules

- **domain** imports nothing outside stdlib
- **port** imports domain only
- **app** imports domain + port + config
- **adapter** imports app + domain + port + config + pkg
- **bootstrap** imports everything to wire it up
- **cmd** imports bootstrap only
- **config** imports stdlib + allowed third-party (viper, etc.)
- **pkg** imports stdlib only (no business packages)

## What Goes Where

| Concern              | Layer     |
|----------------------|-----------|
| Entity / Value Object | domain   |
| Repository interface  | port      |
| Service interface     | port      |
| Use case logic        | app       |
| HTTP handler          | adapter   |
| DB query (sqlc)       | adapter   |
| Kafka producer/consumer | adapter |
| Redis client wrapper  | adapter   |
| DI wiring             | bootstrap |
| main()                | cmd       |
| Env config struct     | config    |
| HTTP helpers, logger  | pkg       |

## Reference Files
- `concepts/layer-rules.md` — detailed import matrix
- `patterns/port-adapter.md` — interface + implementation
- `patterns/dependency-injection.md` — constructor injection
- `patterns/repository-pattern.md` — DB repository
- `patterns/service-pattern.md` — application service
