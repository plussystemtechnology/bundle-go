# NoxCare-Go

> 5-phase spec-driven development workflow for Go backend API with Clean Architecture.
> *"Brainstorm -> Define -> Design -> Build -> Ship"*

---

## Overview

NoxCare-Go provides Agent Matching (Design phase) and Agent Delegation (Build phase) specialized for Go backend development with Gin, sqlc, pgx, Kafka, Redis, and Clean Architecture.

| Traditional Approach | NoxCare-Go SDD |
|---------------------|----------------|
| 8 phases | **5 phases** (Brainstorm optional) |
| 3 development modes | **1 unified stream** |
| Generic agents only | **43 specialized agents** across 8 categories |
| No domain expertise | **15+ KB domains** for Go backend stack |
| 12+ commands | **23 commands** (7 SDD + 10 Go + 6 core) |
| 11+ artifact types | **5 artifact types** |
| Separate ADR files | **Inline decisions** |
| Pre-generated tasks | **On-the-fly execution** |

---

## The 5-Phase Pipeline

```text
+----------+    +----------+    +----------+    +----------+    +----------+
| Phase 0  |--->| Phase 1  |--->| Phase 2  |--->| Phase 3  |--->| Phase 4  |
|BRAINSTORM|    |  DEFINE  |    |  DESIGN  |    |  BUILD   |    |   SHIP   |
| (Explore)|    |(What+Why)|    |   (How)  |    |   (Do)   |    |  (Close) |
|[Optional]|    +----------+    +----------+    +----------+    +----------+
+----------+         |               |               |               |
     |               v               v               v               v
     v          DEFINE_*.md     DESIGN_*.md    Code + Report    SHIPPED_*.md
BRAINSTORM_*.md

     <------------------------------------------------------------------------>
                                /iterate (any phase)
```

---

## Commands

### SDD Workflow (7)

| Command | Phase | Purpose | Model |
|---------|-------|---------|-------|
| `/brainstorm` | 0 | Explore ideas through collaborative dialogue | Opus |
| `/define` | 1 | Capture and validate requirements | Opus |
| `/design` | 2 | Create architecture and specification | Opus |
| `/build` | 3 | Execute implementation with verification | Sonnet |
| `/ship` | 4 | Archive with lessons learned | Haiku |
| `/iterate` | Any | Update documents when changes needed | Sonnet |
| `/create-pr` | -- | Create pull request with conventional commits | -- |

### Go-Specific (10)

| Command | Purpose |
|---------|---------|
| `/handler` | Gin HTTP handler scaffolding |
| `/service` | App service layer scaffolding |
| `/repository` | sqlc repository scaffolding |
| `/consumer` | Kafka consumer scaffolding |
| `/migration` | Database migration generation |
| `/proto` | gRPC protobuf definition |
| `/test` | Go test suite generation |
| `/bench` | Benchmark test generation |
| `/swagger` | Swagger/OpenAPI doc generation |
| `/loadtest` | k6 load test scaffolding |

### Core & Utilities (6)

| Command | Purpose |
|---------|---------|
| `/create-kb` | Create KB domain |
| `/review` | Go code review |
| `/meeting` | Meeting transcript analysis |
| `/memory` | Save session insights |
| `/sync-context` | Update CLAUDE.md |
| `/readme-maker` | Generate README |

---

## Artifacts

| Artifact | Phase | Location |
|----------|-------|----------|
| `BRAINSTORM_{FEATURE}.md` | 0 | `.claude/sdd/features/` |
| `DEFINE_{FEATURE}.md` | 1 | `.claude/sdd/features/` |
| `DESIGN_{FEATURE}.md` | 2 | `.claude/sdd/features/` |
| `BUILD_REPORT_{FEATURE}.md` | 3 | `.claude/sdd/reports/` |
| `SHIPPED_{DATE}.md` | 4 | `.claude/sdd/archive/{FEATURE}/` |

---

## Quick Start

### Go Backend Feature (Full Pipeline)

```bash
# Phase 0: Explore the idea (optional)
/brainstorm "Build Kafka consumer for order events with idempotency"

# Phase 1: Define requirements
/define .claude/sdd/features/BRAINSTORM_ORDER_CONSUMER.md

# Phase 2: Create technical design
/design .claude/sdd/features/DEFINE_ORDER_CONSUMER.md

# Phase 3: Build the code
/build .claude/sdd/features/DESIGN_ORDER_CONSUMER.md

# Phase 4: Archive when complete
/ship .claude/sdd/features/DEFINE_ORDER_CONSUMER.md
```

### Go-Specific Commands (Skip SDD)

```bash
# Scaffold a handler
/handler "CRUD endpoints for user resource"

# Generate sqlc repository
/repository "user queries with pagination"

# Scaffold Kafka consumer
/consumer "order-events topic consumer"
```

### Making Changes Mid-Stream

```bash
# Update DEFINE with new requirement
/iterate DEFINE_ORDER_CONSUMER.md "Add dead-letter queue support"

# Update DESIGN with architecture change
/iterate DESIGN_ORDER_CONSUMER.md "Switch from sync to async processing"
```

---

## Folder Structure

```text
.claude/sdd/
+-- _index.md                    # This file (workflow overview)
+-- README.md                    # Comprehensive documentation
+-- features/                    # Active feature documents
|   +-- BRAINSTORM_{FEATURE}.md
|   +-- DEFINE_{FEATURE}.md
|   +-- DESIGN_{FEATURE}.md
+-- reports/                     # Build reports
|   +-- BUILD_REPORT_{FEATURE}.md
+-- archive/                     # Shipped features
|   +-- {FEATURE}/
|       +-- BRAINSTORM_{FEATURE}.md  (if used)
|       +-- DEFINE_{FEATURE}.md
|       +-- DESIGN_{FEATURE}.md
|       +-- BUILD_REPORT_{FEATURE}.md
|       +-- SHIPPED_{DATE}.md
+-- templates/                   # Document templates
|   +-- BRAINSTORM_TEMPLATE.md
|   +-- DEFINE_TEMPLATE.md
|   +-- DESIGN_TEMPLATE.md
|   +-- BUILD_REPORT_TEMPLATE.md
|   +-- SHIPPED_TEMPLATE.md
+-- architecture/                # Workflow contracts
    +-- WORKFLOW_CONTRACTS.yaml
    +-- ARCHITECTURE.md
```

---

## Key Principles

| Principle | Application |
|-----------|-------------|
| **Single Stream** | No mode switching, one unified workflow |
| **Inline Decisions** | ADRs in DESIGN document, not separate files |
| **On-the-Fly Tasks** | Tasks generated from file manifest during build |
| **Clean Architecture** | Import boundaries enforced by check_arch.sh |
| **Config Over Code** | Use YAML/env for configuration, not hardcoded values |
| **Iterate Anywhere** | Changes can be made at any phase via `/iterate` |
| **Go First** | Idiomatic Go, explicit errors, no panics in libraries |

---

## Model Assignment

| Phase | Model | Rationale |
|-------|-------|-----------|
| Brainstorm | Opus | Creative thinking and nuanced dialogue |
| Define | Opus | Nuanced understanding of requirements |
| Design | Opus | Architectural decisions require depth |
| Build | Sonnet | Fast, accurate Go code generation |
| Ship | Haiku | Simple archival operations |
| Iterate | Sonnet | Balanced speed and understanding |

---

## References

| Resource | Location |
|----------|----------|
| Full Documentation | `.claude/sdd/README.md` |
| Workflow Contracts | `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml` |
| Architecture | `.claude/sdd/architecture/ARCHITECTURE.md` |
| Templates | `.claude/sdd/templates/` |
| Agents (43) | `.claude/agents/` |
| KB Domains | `.claude/kb/` |
| SDD Commands | `.claude/commands/workflow/` |
| Go Commands | `.claude/commands/go/` |
| Core Commands | `.claude/commands/core/` |
