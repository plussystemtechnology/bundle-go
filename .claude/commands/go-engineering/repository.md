---
name: repository
description: Scaffold a sqlc/pgx repository — delegates to repository-builder agent
---

# Repository Command

> Scaffold data-access repositories with sqlc queries, pgx pool config, and port interfaces.

## Usage

```bash
/repository <description-or-file>
```

## Examples

```bash
/repository "Orders with search and soft-delete"
/repository "UserRepository with CRUD operations"
/repository "ProductRepository with full-text search and pagination"
/repository path/to/spec.md
```

---

## What This Command Does

1. Invokes the **repository-builder** agent
2. Analyzes your description or requirements file
3. Loads KB patterns from `sqlc`, `pgx`, and `clean-architecture` domains
4. Generates: Repository implementation, sqlc query files, port interface, migration hint

## Agent Delegation

| Agent | Role |
|-------|------|
| `repository-builder` | Primary — generates repository with sqlc queries and pgx integration |
| `sqlc-specialist` | Escalation — complex query generation, CTEs, window functions |
| `pgx-specialist` | Escalation — pool config, custom types, batch operations |

## KB Domains Used

- `sqlc` — Query annotations, generated code patterns, nullable types
- `pgx` — Connection pool setup, transaction handling, error mapping
- `clean-architecture` — Repository port interfaces, dependency inversion

## Output

- `internal/adapter/repository/<name>_repository.go` — Repository struct and methods
- `internal/port/<name>_repository_port.go` — Repository interface
- `db/query/<name>.sql` — sqlc annotated SQL queries
- `internal/adapter/repository/<name>_repository_test.go` — Integration test stubs
