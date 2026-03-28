---
name: sync-context
description: Analyze codebase and update CLAUDE.md with current project context
---

# Sync-Context Command

> Keep CLAUDE.md in sync with the actual state of the Go codebase.

## Usage

```
/sync-context
/sync-context --dry-run
/sync-context --section <section-name>
```

## Examples

```
/sync-context
/sync-context --dry-run
/sync-context --section commands
```

## What This Command Does

1. **Scan Go project** — glob patterns: `**/*.go`, `go.mod`, `go.sum`, `Makefile`, `Dockerfile`
2. **Detect Clean Architecture layers** — identify `domain/`, `port/`, `app/`, `adapter/`, `bootstrap/`, `cmd/`
3. **Extract patterns in use**:
   - Interfaces (ports) in `port/`
   - HTTP handlers in `adapter/http/handler/`
   - Services in `app/`
   - Repositories in `adapter/`
   - Kafka consumers/producers
   - Middleware registered in Gin router
4. **Detect active agents** — cross-reference `.claude/agents/` with actual code patterns
5. **Detect active commands** — list slash commands in `.claude/commands/`
6. **Read current CLAUDE.md** — parse manual sections (marked with `<!-- manual -->`)
7. **Regenerate auto sections** — replace content between `<!-- auto-start -->` and `<!-- auto-end -->` markers
8. **Write updated CLAUDE.md** — preserve all manual sections untouched
9. **Report diff** — print what changed

## Sections Updated

| Section | Source |
|---------|--------|
| Repository Structure | actual directory tree |
| Commands Available | `.claude/commands/**/*.md` frontmatter |
| Key Files to Know | detected layer entrypoints |
| Go dependencies | `go.mod` |

## Flags

| Flag | Behavior |
|------|----------|
| `--dry-run` | Print proposed changes without writing |
| `--section <name>` | Update only the named section |

## Safety Rules

- Sections without `<!-- auto-start/end -->` markers are never touched
- If `CLAUDE.md` does not exist, a new one is scaffolded from template
- A backup is written to `.claude/storage/CLAUDE.md.bak` before any write
