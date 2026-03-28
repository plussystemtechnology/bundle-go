---
name: design
description: Create architecture and technical specification (Phase 2)
---

# Design Command

> Create architecture and technical specification in one pass (Phase 2)

## Usage

```bash
/design <define-file>
```

## Examples

```bash
/design .claude/sdd/features/DEFINE_USER_AUTH.md
/design DEFINE_RATE_LIMITER.md
/design .claude/sdd/features/DEFINE_ORDER_SERVICE.md
```

---

## Overview

This is **Phase 2** of the 5-phase Bundle-Go workflow:

```text
Phase 0: /brainstorm → .claude/sdd/features/BRAINSTORM_{FEATURE}.md (optional)
Phase 1: /define     → .claude/sdd/features/DEFINE_{FEATURE}.md
Phase 2: /design     → .claude/sdd/features/DESIGN_{FEATURE}.md (THIS COMMAND)
Phase 3: /build      → Code + .claude/sdd/reports/BUILD_REPORT_{FEATURE}.md
Phase 4: /ship       → .claude/sdd/archive/{FEATURE}/SHIPPED_{DATE}.md
```

The `/design` command combines architecture, spec, and ADRs into a single document.

---

## What This Command Does

1. **Analyze** - Understand requirements from DEFINE
2. **Architect** - Design solution following Clean Architecture layers
3. **Decide** - Document key decisions with rationale (inline ADRs)
4. **Specify** - Create file manifest with Go agent assignments
5. **Pattern** - Generate copy-paste ready Go code patterns
6. **Plan Testing** - Define testing strategy per layer

---

## Process

### Step 1: Load Context

```markdown
Read(.claude/sdd/features/DEFINE_{FEATURE}.md)
Read(.claude/sdd/templates/DESIGN_TEMPLATE.md)
Read(CLAUDE.md)

# Load KB patterns from DEFINE's domains:
Read(.claude/kb/{domain}/patterns/*.md)

# Explore existing codebase:
Glob(internal/**/*.go) | Grep("type.*interface")
```

### Step 2: Create Clean Architecture Design

Design the solution following layer rules:

| Layer | Path | Imports | Content |
|-------|------|---------|---------|
| domain | `internal/domain/` | stdlib only | Entities, VOs |
| port | `internal/port/` | domain | Interfaces |
| app | `internal/app/` | domain, port | Use cases |
| adapter | `internal/adapter/` | app, domain, port | HTTP, DB, cache |
| bootstrap | `internal/bootstrap/` | all | Wire deps |
| cmd | `cmd/` | bootstrap | Entry points |

### Step 3: Document Decisions (Inline ADRs)

For each significant choice:

```markdown
### Decision: {Name}

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | YYYY-MM-DD |

**Context:** Why this decision was needed
**Choice:** What we're doing
**Rationale:** Why this approach
**Consequences:** Trade-offs we accept
```

### Step 4: Create File Manifest with Agent Assignments

```markdown
| # | File | Action | Purpose | Agent |
|---|------|--------|---------|-------|
| 1 | internal/domain/user.go | Create | Entity | @go-developer |
| 2 | internal/port/user_repo.go | Create | Interface | @go-developer |
| 3 | internal/app/user_service.go | Create | Use case | @service-builder |
| 4 | internal/adapter/repo/user.go | Create | pgx impl | @repository-builder |
| 5 | internal/adapter/http/user.go | Create | Gin handler | @handler-builder |
```

### Step 5: Define Go Code Patterns

Provide copy-paste ready Go snippets from KB:

```go
// Pattern: Service with dependency injection
type UserService struct {
    repo port.UserRepository
    cache port.CacheStore
}

func NewUserService(repo port.UserRepository, cache port.CacheStore) *UserService {
    return &UserService{repo: repo, cache: cache}
}
```

### Step 6: Plan Testing Strategy

| Layer | Test Type | Tools | Pattern |
|-------|-----------|-------|---------|
| domain | Unit | `go test` | Table-driven tests |
| app | Unit + Mock | `go test` + `gomock` | Mock ports |
| adapter/http | Integration | `httptest` | Gin test router |
| adapter/repo | Integration | `testcontainers-go` | Real PostgreSQL |

### Step 7: Save

```markdown
Write(.claude/sdd/features/DESIGN_{FEATURE_NAME}.md)
```

---

## Output

| Artifact | Location |
|----------|----------|
| **DESIGN** | `.claude/sdd/features/DESIGN_{FEATURE_NAME}.md` |

**Next Step:** `/build .claude/sdd/features/DESIGN_{FEATURE_NAME}.md`

---

## Quality Gate

Before saving, verify:

```text
[ ] Architecture diagram shows Clean Architecture layers
[ ] All major decisions documented with rationale
[ ] File manifest is complete with agent assignments
[ ] Code patterns are idiomatic Go
[ ] Import rules respected (domain has zero internal imports)
[ ] Testing strategy covers all layers
[ ] No circular dependencies in architecture
```

---

## Tips

1. **Diagram First** - ASCII art clarifies Clean Architecture layer thinking
2. **Decisions Are Permanent** - Document the "why" not just "what"
3. **Self-Contained** - Each package should work independently
4. **KB Patterns** - Use patterns from `.claude/kb/` domains, not generic Go
5. **Agent Match** - Assign Go specialists to files for best results

---

## References

- Agent: `.claude/agents/workflow/design-agent.md`
- Template: `.claude/sdd/templates/DESIGN_TEMPLATE.md`
- Contracts: `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- Next Phase: `.claude/commands/workflow/build.md`
