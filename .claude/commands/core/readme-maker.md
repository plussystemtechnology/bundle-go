---
name: readme-maker
description: Generate comprehensive README.md by analyzing the Go codebase
---

# Readme-Maker Command

> Scan the Go project and generate a production-ready README.md in one pass.

## Usage

```
/readme-maker
/readme-maker --output <path>
```

## Examples

```
/readme-maker
/readme-maker --output docs/README.md
```

## What This Command Does

Five-phase workflow:

1. **EXPLORE** — scan project layout using Go-specific patterns:
   - `go.mod`, `go.sum` — module name, Go version, dependencies
   - `cmd/*/main.go` — entrypoints
   - `Makefile` — available build targets
   - `Dockerfile`, `docker-compose.yml` — container setup
   - `.env.example` — required environment variables
   - `internal/` layer structure (domain, port, app, adapter, bootstrap)

2. **EXTRACT** — identify:
   - Module name and version
   - HTTP framework (Gin, Echo, Chi…)
   - Database drivers (pgx, sqlc, GORM…)
   - Messaging (Kafka, Redis, NATS…)
   - Observability (OpenTelemetry, Prometheus…)
   - Available `make` targets

3. **GENERATE** — produce README sections:
   - Project title and one-line description
   - Tech stack badges
   - Quick Start (`go run`, `go build`, `make`)
   - Environment variables table (from `.env.example`)
   - Project structure overview (Clean Architecture layers)
   - API overview (endpoints from handler files)
   - Running tests (`go test -race -cover ./...`)
   - Docker instructions
   - Contributing guidelines link

4. **VALIDATE** — check for missing sections, broken references, empty tables

5. **OUTPUT** — write to `README.md` (or `--output` path), report diff summary

## Output

File: `README.md` (default) or the path given via `--output`.

Quick Start section always includes:

```bash
go mod download
cp .env.example .env
make run        # or: go run ./cmd/api
```
