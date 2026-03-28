---
name: migration
description: Generate SQL migration files — delegates to migration-specialist agent
---

# Migration Command

> Generate idempotent up/down SQL migration files compatible with golang-migrate.

## Usage

```bash
/migration <description-or-file>
```

## Examples

```bash
/migration "Create orders table with indexes"
/migration "Add status enum to orders"
/migration "Add foreign key from order_items to orders"
/migration path/to/spec.md
```

---

## What This Command Does

1. Invokes the **migration-specialist** agent
2. Analyzes your description or requirements file
3. Loads KB patterns from `migrations` and `pgx` domains
4. Generates: Timestamped up/down migration files with safe DDL

## Agent Delegation

| Agent | Role |
|-------|------|
| `migration-specialist` | Primary — generates idempotent DDL with up/down symmetry |
| `schema-designer` | Escalation — complex schemas, normalization, index strategy |
| `pgx-specialist` | Escalation — advanced PostgreSQL types, JSONB, partitioning |

## KB Domains Used

- `migrations` — golang-migrate conventions, naming, rollback safety
- `pgx` — PostgreSQL-specific DDL, custom types, index types

## Output

- `db/migration/<timestamp>_<name>.up.sql` — Forward migration with idempotent guards
- `db/migration/<timestamp>_<name>.down.sql` — Rollback migration
- Index definitions, constraint names, and enum type declarations
- Comments on performance considerations and rollback caveats
