# NoxCare-Go Architecture

> Visual reference for the NoxCare-Go 5-phase SDD workflow and Go Clean Architecture

---

## System Overview

```text
+----------------------------------------------------------------------------------------------------------+
|                                   NOXCARE-GO 5-PHASE PIPELINE                                            |
+----------------------------------------------------------------------------------------------------------+
|                                                                                                           |
|   PHASE 0              PHASE 1              PHASE 2              PHASE 3              PHASE 4            |
|   ========             ========             ========             ========             ========           |
|   BRAINSTORM           DEFINE               DESIGN               BUILD                SHIP               |
|   (Explore)            (What + Why)         (How)                (Do)                 (Close)            |
|   [Optional]                                                                                             |
|                                                                                                           |
|   /brainstorm          /define              /design              /build               /ship              |
|        |                    |                    |                    |                    |              |
|        v                    v                    v                    v                    v              |
|   +----------+         +---------+          +---------+          +---------+          +---------+        |
|   |BRAINSTORM|-------->| DEFINE  |--------->| DESIGN  |--------->|  BUILD  |--------->|  SHIP   |        |
|   |  AGENT   | or skip |  AGENT  |          |  AGENT  |          |  AGENT  |          |  AGENT  |        |
|   |  (Opus)  |         | (Opus)  |          | (Opus)  |          |(Sonnet) |          | (Haiku) |        |
|   +----------+         +---------+          +---------+          +---------+          +---------+        |
|        |                    |                    |                    |                    |              |
|        v                    v                    v                    v                    v              |
|   features/            features/            features/            reports/ +           archive/           |
|   BRAINSTORM_*.md      DEFINE_*.md          DESIGN_*.md          CODE FILES           {FEATURE}/         |
|                                                                  BUILD_REPORT_*.md    SHIPPED_*.md       |
|                                                                                                           |
+----------------------------------------------------------------------------------------------------------+
|                                                                                                           |
|                                      CROSS-PHASE: ITERATE                                                 |
|                                      ===================                                                  |
|                                                                                                           |
|                                           /iterate                                                        |
|                                                |                                                          |
|                                                v                                                          |
|                                           +---------+                                                     |
|                                           | ITERATE |                                                     |
|                                           |  AGENT  |                                                     |
|                                           |(Sonnet) |                                                     |
|                                           +---------+                                                     |
|                                                |                                                          |
|                              +-----------------+-----------------+                                        |
|                              v                 v                 v                                        |
|                       Updates BRAINSTORM  Updates DEFINE    Updates DESIGN                                |
|                       (with cascade)      (with cascade)    (with cascade)                                |
|                                                                                                           |
+----------------------------------------------------------------------------------------------------------+
```

---

## Phase Flow

```text
+----------------------------------------------------------------------------------------+
|                                    WORKFLOW FLOW                                        |
+----------------------------------------------------------------------------------------+
|                                                                                         |
|   RAW IDEA                                                                              |
|   (vague request,         PHASE 0: BRAINSTORM (Optional)                               |
|    problem)          ------------------------------>   BRAINSTORM_{FEATURE}.md          |
|                           One Q at a time             - Discovery Q&A                  |
|                           2-3 Approaches              - Approaches Explored             |
|                           YAGNI Ruthlessly            - Features Removed               |
|                                                       - Selected Approach              |
|                                  |                                                      |
|                                  v                                                      |
|   RAW INPUT                                                                             |
|   (notes, emails,         PHASE 1: DEFINE                                              |
|    brainstorm doc)   ------------------------------>   DEFINE_{FEATURE}.md              |
|                           Extract + Validate          - Problem Statement              |
|                           Clarity Score >=12          - Target Users                   |
|                                                       - Success Criteria               |
|                                                       - Acceptance Tests               |
|                                                       - Out of Scope                   |
|                                  |                                                      |
|                                  v                                                      |
|                           PHASE 2: DESIGN                                              |
|   DEFINE_{FEATURE}.md ----------------------------->   DESIGN_{FEATURE}.md              |
|                           Architect + Decide          - Architecture Diagram           |
|                           Clean Arch Gate             - Layer Mapping                  |
|                           No Layer Violations         - Key Decisions (inline)         |
|                                                       - File Manifest + Agents         |
|                                                       - Code Patterns (Go)             |
|                                                       - Testing Strategy               |
|                                  |                                                      |
|                                  v                                                      |
|                           PHASE 3: BUILD                                               |
|   DESIGN_{FEATURE}.md ----------------------------->   CODE + BUILD_REPORT             |
|                           Execute + Verify            - All files from manifest        |
|                           Delegate to agents          - Verification results           |
|                           go test -race passes        - Issues encountered             |
|                                  |                                                      |
|                                  v                                                      |
|                           PHASE 4: SHIP                                                |
|   All Artifacts      ------------------------------>   archive/{FEATURE}/              |
|                           Archive + Learn             - All artifacts moved            |
|                                                       - SHIPPED_{DATE}.md             |
|                                                       - Lessons learned               |
|                                                                                         |
+----------------------------------------------------------------------------------------+
```

---

## Clean Architecture Layers

```text
+----------------------------------------------------------------------------------------+
|                           GO CLEAN ARCHITECTURE                                         |
+----------------------------------------------------------------------------------------+
|                                                                                         |
|                              cmd/api/                                                   |
|                        +------------------+                                             |
|                        |   ENTRY POINT    |   imports bootstrap only                   |
|                        +--------+---------+                                             |
|                                 |                                                       |
|                        +--------v---------+                                             |
|                        |   BOOTSTRAP      |   wires everything (DI), no business logic |
|                        +--------+---------+                                             |
|                                 |                                                       |
|          +-----------+----------+-----------+-----------+                               |
|          |           |          |           |           |                               |
|   +------v-----+  +--v-------+  +----------v-+  +------v------+                        |
|   |  ADAPTER   |  | ADAPTER  |  |  ADAPTER   |  |   ADAPTER   |                        |
|   |  handler/  |  | consumer |  | repository |  | middleware  |                        |
|   |  http      |  | kafka    |  | postgres   |  | http/grpc   |                        |
|   | grpc       |  |          |  |            |  |             |                        |
|   +------+-----+  +--+-------+  +----+-------+  +-------------+                        |
|          |           |               |                                                  |
|          +-----------v---------------+                                                  |
|                      |                                                                  |
|             +--------v----------+                                                       |
|             |   APP / SERVICE   |   orchestrates use cases                             |
|             |   internal/app/   |   imports: domain, port, config                      |
|             |   service/        |                                                       |
|             +--------+----------+                                                       |
|                      |                                                                  |
|             +--------v----------+                                                       |
|             |      PORT         |   interfaces only                                    |
|             |   internal/port/  |   imports: domain only                               |
|             +--------+----------+                                                       |
|                      |                                                                  |
|             +--------v----------+                                                       |
|             |     DOMAIN        |   zero external imports                              |
|             | internal/domain/  |   pure Go structs + domain logic                    |
|             +-------------------+                                                       |
|                                                                                         |
|   +-------------------+    +-------------------+    +-------------------+              |
|   |      config/      |    |       pkg/        |    |    db/sqlc.yaml   |              |
|   |  stdlib+3rd party |    |   stdlib only,    |    |     db/query/     |              |
|   |  no internal deps |    |   generic utils   |    |    db/migration/  |              |
|   +-------------------+    +-------------------+    +-------------------+              |
|                                                                                         |
+----------------------------------------------------------------------------------------+

Import Rules (enforced by ./scripts/check_arch.sh):
  domain     <- stdlib only
  port       <- domain
  app        <- domain, port, config, third-party
  adapter    <- app, domain, port, config, pkg, third-party
  bootstrap  <- all layers (assembly only, zero business logic)
  cmd        <- bootstrap only
  config     <- stdlib, third-party (no internal)
  pkg        <- stdlib only
```

---

## Model Assignment

```text
+----------------------------------------------------------------------------------------+
|                              STRATEGIC MODEL ASSIGNMENT                                 |
+----------------------------------------------------------------------------------------+
|                                                                                         |
|   +------------------------------------------------------------------------------+     |
|   |                                  OPUS                                        |     |
|   |               (Nuanced Understanding & Creative Thinking)                    |     |
|   |                                                                              |     |
|   |   +-----------------+    +-----------------+    +-----------------+          |     |
|   |   |   BRAINSTORM    |    |     DEFINE      |    |     DESIGN      |          |     |
|   |   |     AGENT       |    |     AGENT       |    |     AGENT       |          |     |
|   |   |                 |    |                 |    |                 |          |     |
|   |   | Collaborative   |    | Requirements    |    | Architecture    |          |     |
|   |   | exploration     |    | extraction      |    | decisions +     |          |     |
|   |   | YAGNI filtering |    | clarity scoring |    | clean arch gate |          |     |
|   |   +-----------------+    +-----------------+    +-----------------+          |     |
|   +------------------------------------------------------------------------------+     |
|                                                                                         |
|   +------------------------------------------------------------------------------+     |
|   |                                  SONNET                                      |     |
|   |                         (Fast, Accurate Go Coding)                           |     |
|   |                                                                              |     |
|   |   +-----------------+              +-----------------+                       |     |
|   |   |      BUILD      |              |     ITERATE     |                       |     |
|   |   |      AGENT      |              |      AGENT      |                       |     |
|   |   |                 |              |                 |                       |     |
|   |   | Go code gen     |              | Change          |                       |     |
|   |   | agent delegat.  |              | management      |                       |     |
|   |   | verification    |              | cascade updates |                       |     |
|   |   +-----------------+              +-----------------+                       |     |
|   +------------------------------------------------------------------------------+     |
|                                                                                         |
|   +------------------------------------------------------------------------------+     |
|   |                                   HAIKU                                      |     |
|   |                            (Fast, Simple Tasks)                              |     |
|   |                                                                              |     |
|   |   +-----------------+                                                        |     |
|   |   |      SHIP       |                                                        |     |
|   |   |      AGENT      |                                                        |     |
|   |   |                 |                                                        |     |
|   |   | Archive &       |                                                        |     |
|   |   | document        |                                                        |     |
|   |   +-----------------+                                                        |     |
|   +------------------------------------------------------------------------------+     |
|                                                                                         |
+----------------------------------------------------------------------------------------+
```

---

## Data Flow

```text
+----------------------------------------------------------------------------------------+
|                                    DATA FLOW                                            |
+----------------------------------------------------------------------------------------+
|                                                                                         |
|   +===================+                                                                |
|   |    RAW IDEA       |   (Optional Phase 0)                                           |
|   |  (Vague request)  |                                                                |
|   +==========+========+                                                                |
|              |                                                                         |
|              v                                                                         |
|   +-------------------+                                                               |
|   | BRAINSTORM_*.md   |-----+                                                          |
|   |                   |     |                                                          |
|   | - Discovery Q&A   |     |                                                          |
|   | - Approaches      |     | (or skip to DEFINE                                       |
|   | - YAGNI List      |     |  with raw input)                                         |
|   | - Selected Path   |     |                                                          |
|   +---------+---------+     |                                                          |
|             |               |                                                          |
|             v               v                                                          |
|   +-------------------+         +-------------------+                                  |
|   | DEFINE_*.md       |-------->| DESIGN_*.md       |                                  |
|   |                   |         |                   |                                  |
|   | - Problem         |         | - Architecture    |                                  |
|   | - Users           |         | - Layer Mapping   |                                  |
|   | - Success         |         | - Decisions       |                                  |
|   | - Acc. Tests      |         | - File Manifest   |                                  |
|   | - Scope           |         | - Go Patterns     |                                  |
|   +-------------------+         | - Testing         |                                  |
|                                 +---------+---------+                                  |
|                                           |                                             |
|              +----------------------------+----------------------------+                |
|              |                                                        |                |
|              v                                                        v                |
|   +-------------------+                                    +-------------------+       |
|   | CODE FILES        |                                    | BUILD_REPORT_*.md |       |
|   |                   |                                    |                   |       |
|   | (From manifest)   |                                    | - Tasks completed |       |
|   | internal/         |                                    | - Agent attribs   |       |
|   | cmd/              |                                    | - Verification    |       |
|   | db/               |                                    | - Issues          |       |
|   | pkg/              |                                    +--------+----------+       |
|   +---------+---------+                                             |                  |
|             |                                                       |                  |
|             +---------------------------+---------------------------+                  |
|                                         |                                              |
|                                         v                                              |
|                            +========================+                                  |
|                            |  archive/{FEATURE}/    |                                  |
|                            |                        |                                  |
|                            |  - BRAINSTORM_*.md     |                                  |
|                            |  - DEFINE_*.md         |                                  |
|                            |  - DESIGN_*.md         |                                  |
|                            |  - BUILD_REPORT_*.md   |                                  |
|                            |  - SHIPPED_*.md        |                                  |
|                            +========================+                                  |
|                                                                                         |
+----------------------------------------------------------------------------------------+
```

---

## Agent Delegation Flow (Build Phase)

```text
+----------------------------------------------------------------------------------------+
|                              GO AGENT DELEGATION                                        |
+----------------------------------------------------------------------------------------+
|                                                                                         |
|   File Manifest (DESIGN):                                                               |
|   +--------------------------------------------------------------------+               |
|   | internal/adapter/handler/http/user_handler.go | handler-builder    |               |
|   | internal/app/service/user_service.go          | service-builder    |               |
|   | internal/adapter/repository/user_repo.go      | repository-builder |               |
|   | internal/port/user_port.go                    | clean-arch-arch.   |               |
|   | internal/domain/user.go                       | go-developer       |               |
|   | db/query/user.sql                             | sqlc-specialist    |               |
|   | internal/adapter/consumer/order_consumer.go   | kafka-specialist   |               |
|   | user_handler_test.go                          | test-generator     |               |
|   +--------------------------------------------------------------------+               |
|                           |                                                             |
|                           v                                                             |
|   +--------------------------------------------------------------------+               |
|   |                    PARALLEL DELEGATION                              |               |
|   |                                                                     |               |
|   |  Task(subagent: "handler-builder",    prompt: "...")               |               |
|   |  Task(subagent: "service-builder",    prompt: "...")               |               |
|   |  Task(subagent: "repository-builder", prompt: "...")               |               |
|   |  Task(subagent: "sqlc-specialist",    prompt: "...")               |               |
|   |  Task(subagent: "test-generator",     prompt: "...")               |               |
|   +--------------------------------------------------------------------+               |
|                           |                                                             |
|                           v                                                             |
|   BUILD_REPORT: per-file status + agent attribution                                     |
|                                                                                         |
+----------------------------------------------------------------------------------------+
```

---

## Folder Structure

```text
.claude/
+-- commands/                    # Slash commands
|   +-- workflow/                # 7 SDD commands (/brainstorm, /define, /design, /build, /ship, /iterate, /create-pr)
|   +-- go/                      # 10 Go-specific commands
|   +-- core/                    # 6 utility commands
|
+-- agents/                      # 43 specialized agents
|   +-- workflow/                # 6 SDD phase agents
|   +-- architect/               # 6 system-level design
|   +-- go-core/                 # 6 Go code generation
|   +-- api/                     # 6 HTTP/gRPC/REST agents
|   +-- data/                    # 6 DB/sqlc/migration agents
|   +-- cloud/                   # 4 cloud infrastructure
|   +-- observability/           # 4 metrics/tracing/logging
|   +-- test-quality/            # 5 testing and quality
|
+-- kb/                          # Curated KB domains
|   +-- go-core/                 # Go idioms, clean arch, error handling
|   +-- gin/                     # Gin HTTP framework patterns
|   +-- sqlc/                    # sqlc + pgx query generation
|   +-- kafka/                   # Sarama consumer/producer patterns
|   +-- redis/                   # go-redis caching patterns
|   +-- grpc/                    # gRPC + protobuf patterns
|   +-- postgres/                # PostgreSQL best practices
|   +-- docker/                  # Docker + compose patterns
|   +-- k8s/                     # Kubernetes deployment patterns
|   +-- ... (more domains)
|
+-- sdd/
    +-- _index.md                # Workflow overview (this file points here)
    +-- README.md                # Comprehensive documentation
    +-- features/                # Active feature documents
    +-- reports/                 # Build reports
    +-- archive/                 # Shipped features
    +-- templates/               # 5 document templates
    +-- architecture/            # Workflow contracts
        +-- WORKFLOW_CONTRACTS.yaml
        +-- ARCHITECTURE.md      # This file
```

---

## Iteration Flow

```text
+----------------------------------------------------------------------------------------+
|                                  ITERATION FLOW                                         |
+----------------------------------------------------------------------------------------+
|                                                                                         |
|                         /iterate DEFINE_*.md "change"                                  |
|                                      |                                                  |
|                                      v                                                  |
|                              +--------------+                                           |
|                              | DETECT PHASE |                                           |
|                              +------+-------+                                           |
|                                     |                                                   |
|                    +----------------+----------------+                                  |
|                    v                                 v                                  |
|            +--------------+                  +--------------+                           |
|            |   DEFINE_*   |                  |   DESIGN_*   |                           |
|            |   (Phase 1)  |                  |   (Phase 2)  |                           |
|            +------+-------+                  +------+-------+                           |
|                   |                                 |                                   |
|                   v                                 v                                   |
|            +--------------+                  +--------------+                           |
|            | APPLY CHANGE |                  | APPLY CHANGE |                           |
|            | + VERSION    |                  | + VERSION    |                           |
|            +------+-------+                  +------+-------+                           |
|                   |                                 |                                   |
|                   v                                 v                                   |
|            +--------------+                  +--------------+                           |
|            | CASCADE      |                  | CASCADE      |                           |
|            | CHECK        |                  | CHECK        |                           |
|            +------+-------+                  +------+-------+                           |
|                   |                                 |                                   |
|          +--------+--------+                +-------+--------+                          |
|          v                 v                v                v                          |
|   +-----------+   +------------+   +-----------+   +-------------+                      |
|   |  No Impact|   | DESIGN may |   |  No Impact|   | CODE may    |                      |
|   |           |   | need update|   |           |   | need update |                      |
|   |           |   | (arch gate)|   |           |   | (re-run     |                      |
|   +-----------+   +------------+   +-----------+   | /build)     |                      |
|                                                    +-------------+                      |
|                                                                                         |
+----------------------------------------------------------------------------------------+
```

---

## Quality Gates

```text
+----------------------------------------------------------------------------------------+
|                                   QUALITY GATES                                         |
+----------------------------------------------------------------------------------------+
|                                                                                         |
|   PHASE 0: BRAINSTORM (Optional)                                                        |
|   ==============================                                                        |
|   +-------------------------------------------------------------------+                |
|   | Exploration Checklist                                              |                |
|   +-------------------------------------------------------------------+                |
|   | [ ] Minimum 3 discovery questions asked                            |                |
|   | [ ] 2-3 approaches explored with trade-offs                        |                |
|   | [ ] YAGNI applied (features removed section not empty)             |                |
|   | [ ] Minimum 2 incremental validations completed                    |                |
|   | [ ] User confirmed selected approach                               |                |
|   | [ ] Draft requirements ready for /define                           |                |
|   +-------------------------------------------------------------------+                |
|                                                                                         |
|   PHASE 1: DEFINE                                                                       |
|   ===============                                                                       |
|   +-------------------------------------------------------------------+                |
|   | Clarity Score Breakdown                        Minimum: 12/15     |                |
|   +-------------------------------------------------------------------+                |
|   | Problem:  [0-3] Clear, specific, actionable?                       |                |
|   | Users:    [0-3] Identified with pain points?                       |                |
|   | Goals:    [0-3] Measurable outcomes (MUST/SHOULD/COULD)?           |                |
|   | Success:  [0-3] Testable criteria?                                 |                |
|   | Scope:    [0-3] Explicit boundaries?                               |                |
|   +-------------------------------------------------------------------+                |
|                                                                                         |
|   PHASE 2: DESIGN                                                                       |
|   ===============                                                                       |
|   +-------------------------------------------------------------------+                |
|   | Checklist                                                          |                |
|   +-------------------------------------------------------------------+                |
|   | [ ] Architecture diagram present (ASCII)                           |                |
|   | [ ] Clean Architecture layer mapping documented                    |                |
|   | [ ] At least one decision with rationale (inline ADR)              |                |
|   | [ ] Complete file manifest with agents assigned                    |                |
|   | [ ] Code patterns are copy-paste ready Go                          |                |
|   | [ ] Testing strategy defined (unit + integration)                  |                |
|   | [ ] No shared dependencies across layers                           |                |
|   | [ ] clean_architecture_gate respected for all files                |                |
|   +-------------------------------------------------------------------+                |
|                                                                                         |
|   PHASE 3: BUILD                                                                        |
|   ==============                                                                        |
|   +-------------------------------------------------------------------+                |
|   | Go Verification                                                    |                |
|   +-------------------------------------------------------------------+                |
|   | [ ] go build ./... passes                                          |                |
|   | [ ] go vet ./... passes                                            |                |
|   | [ ] golangci-lint run passes (0 errors)                            |                |
|   | [ ] go test -race ./... passes                                     |                |
|   | [ ] ./scripts/check_arch.sh passes (no layer violations)          |                |
|   | [ ] All files from manifest created                                |                |
|   | [ ] No TODO comments in code                                       |                |
|   | [ ] No ignored error returns                                       |                |
|   +-------------------------------------------------------------------+                |
|                                                                                         |
|   PHASE 4: SHIP                                                                         |
|   =============                                                                         |
|   +-------------------------------------------------------------------+                |
|   | Pre-Ship Checklist                                                 |                |
|   +-------------------------------------------------------------------+                |
|   | [ ] BUILD_REPORT shows 100% completion                             |                |
|   | [ ] All tests passing (unit + integration)                         |                |
|   | [ ] No blocking issues                                             |                |
|   | [ ] Acceptance tests verified                                      |                |
|   | [ ] golangci-lint clean                                            |                |
|   | [ ] No architecture violations                                     |                |
|   | [ ] Lessons captured                                               |                |
|   +-------------------------------------------------------------------+                |
|                                                                                         |
+----------------------------------------------------------------------------------------+
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-03-27 | Initial NoxCare-Go port from AgentSpec v2.1.0 |
