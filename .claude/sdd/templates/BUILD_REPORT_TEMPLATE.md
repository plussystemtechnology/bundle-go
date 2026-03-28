# BUILD REPORT: {Feature Name}

> Implementation report for {Feature Name}

## Metadata

| Attribute | Value |
|-----------|-------|
| **Feature** | {FEATURE_NAME} |
| **Date** | {YYYY-MM-DD} |
| **Author** | build-agent |
| **DEFINE** | [DEFINE_{FEATURE}.md](../features/DEFINE_{FEATURE}.md) |
| **DESIGN** | [DESIGN_{FEATURE}.md](../features/DESIGN_{FEATURE}.md) |
| **Status** | In Progress / Complete / Blocked |

---

## Summary

| Metric | Value |
|--------|-------|
| **Tasks Completed** | {X}/{Y} |
| **Files Created** | {N} |
| **Lines of Code** | {N} |
| **Build Time** | {Duration} |
| **Tests Passing** | {X}/{Y} |
| **Agents Used** | {N} |

---

## Task Execution with Agent Attribution

| # | Task | Agent | Status | Duration | Notes |
|---|------|-------|--------|----------|-------|
| 1 | {Task description} | @{agent-name} | ✅ Complete | {Xm} | {Any notes} |
| 2 | {Task description} | @{agent-name} | ✅ Complete | {Xm} | {Any notes} |
| 3 | {Task description} | (direct) | 🔄 In Progress | - | {No specialist matched} |
| 4 | {Task description} | @{agent-name} | ⏳ Pending | - | - |

**Legend:** ✅ Complete | 🔄 In Progress | ⏳ Pending | ❌ Blocked

**Agent Key:**
- `@{agent-name}` = Delegated to specialist agent via Task tool
- `(direct)` = Built directly by build-agent (no specialist matched)

---

## Agent Contributions

| Agent | Files | Specialization Applied |
|-------|-------|------------------------|
| @{agent-1} | {N} | {What patterns/KB used} |
| @{agent-2} | {N} | {What patterns/KB used} |
| (direct) | {N} | DESIGN patterns only |

---

## Files Created

| File | Lines | Agent | Verified | Notes |
| ---- | ----- | ----- | -------- | ----- |
| `internal/domain/{entity}/{entity}.go` | {N} | @domain-modeler | ✅ | {Any notes} |
| `internal/port/out/{entity}_repository.go` | {N} | @domain-modeler | ✅ | {Any notes} |
| `internal/port/in/{feature}_service.go` | {N} | @domain-modeler | ✅ | {Any notes} |
| `internal/app/{feature}/{feature}_service.go` | {N} | @service-builder | ✅ | {Any notes} |
| `internal/adapter/repository/pg/{entity}_repository.go` | {N} | @repository-builder | ✅ | {Any notes} |
| `internal/adapter/handler/http/{feature}_handler.go` | {N} | @handler-builder | ✅ | {Any notes} |
| `internal/adapter/handler/http/{feature}_handler_test.go` | {N} | @test-builder | ✅ | {Any notes} |
| `db/queries/{feature}.sql` | {N} | @repository-builder | ✅ | {Any notes} |
| `db/migrations/{timestamp}_{feature}.sql` | {N} | @repository-builder | ✅ | {Any notes} |

---

## Verification Results

### Per-File Verification

> Each file must compile and pass its own checks before full CI runs.

| File | `go build` | `go vet` | Tests | Notes |
|------|-----------|---------|-------|-------|
| `{path/to/file.go}` | ✅ / ❌ | ✅ / ❌ | ✅ / ❌ / N/A | {Notes} |
| `{path/to/file_test.go}` | ✅ / ❌ | ✅ / ❌ | ✅ / ❌ | {Notes} |

---

### Lint Check

```text
$ golangci-lint run ./...

{Output from golangci-lint or "All checks passed"}
```

**Status:** ✅ Pass / ❌ Fail

---

### Static Analysis

```text
$ staticcheck ./...

{Output from staticcheck or "No issues found"}
```

**Status:** ✅ Pass / ❌ Fail

---

### Build Check

```text
$ go build -o /dev/null ./cmd/...

{Output or "Build succeeded"}
```

**Status:** ✅ Pass / ❌ Fail

---

### Tests (Race + Coverage)

```text
$ go test -race -cover ./...

{Output from go test or summary — include package-level coverage percentages}
```

| Package | Tests | Coverage | Status |
|---------|-------|----------|--------|
| `internal/domain/{entity}` | {X} passed | {N}% | ✅ |
| `internal/app/{feature}` | {X} passed | {N}% | ✅ |
| `internal/adapter/handler/http` | {X} passed | {N}% | ✅ |
| `internal/adapter/repository/pg` | {X} passed | {N}% | ✅ |

**Overall:** ✅ {X}/{Y} Pass | ❌ {N} Fail

---

### Full CI Verification

```text
$ golangci-lint run ./...    # lint
$ go test -race -cover ./... # unit + integration (race detector)
$ go build -o /dev/null ./cmd/... # compilation
$ staticcheck ./...          # additional static analysis
```

**CI Status:** ✅ All checks passed / ❌ {N} failures

---

## Issues Encountered

| # | Issue | Resolution | Time Impact |
|---|-------|------------|-------------|
| 1 | {Description of issue} | {How it was resolved} | {+Xm} |
| 2 | {Description of issue} | {How it was resolved} | {+Xm} |

---

## Deviations from Design

| Deviation | Reason | Impact |
|-----------|--------|--------|
| {What changed from DESIGN} | {Why it changed} | {Effect on system} |

---

## Blockers (if any)

| Blocker | Required Action | Owner |
|---------|-----------------|-------|
| {Description} | {What needs to happen} | {Who can unblock} |

---

## Acceptance Test Verification

| ID | Scenario | Status | Evidence |
|----|----------|--------|----------|
| AT-001 | {From DEFINE} | ✅ Pass / ❌ Fail | {How verified} |
| AT-002 | {From DEFINE} | ✅ Pass / ❌ Fail | {How verified} |
| AT-003 | {From DEFINE} | ✅ Pass / ❌ Fail | {How verified} |

---

## Performance Notes

| Metric | Expected | Actual | Status |
|--------|----------|--------|--------|
| {e.g., p99 response time} | {From DEFINE} | {Measured via benchmark} | ✅ / ❌ |
| {e.g., Throughput req/s} | {From DEFINE} | {Measured via benchmark} | ✅ / ❌ |

```text
$ go test -bench=. -benchmem ./...

{Benchmark output if applicable}
```

---

## Data Quality Results (if applicable)

> Include this section when the build involves database migrations, Kafka consumers, or data pipelines.

### Migration Results

```text
$ goose up  # or migrate up

{Output from migration tool or "N/A"}
```

**Status:** ✅ Pass / ❌ Fail

### sqlc Generation

```text
$ sqlc generate

{Output or "Generated successfully — no diff"}
```

**Status:** ✅ Pass / ❌ Fail

### Data Quality Checks

| Check | Tool | Result | Details |
|-------|------|--------|---------|
| {Null PK check} | {go test / testcontainers} | ✅ / ❌ | {0 nulls found} |
| {Unique constraint} | {go test / testcontainers} | ✅ / ❌ | {0 duplicates} |
| {Referential integrity} | {go test / DB migration} | ✅ / ❌ | {0 orphans} |
| {Kafka message schema} | {go test / consumer test} | ✅ / ❌ | {Schema valid} |

---

## Final Status

### Overall: {✅ COMPLETE / 🔄 IN PROGRESS / ❌ BLOCKED}

**Completion Checklist:**

- [ ] All tasks from manifest completed
- [ ] `golangci-lint run ./...` passes with no errors
- [ ] `go test -race -cover ./...` passes with no failures
- [ ] `go build -o /dev/null ./cmd/...` succeeds
- [ ] `staticcheck ./...` reports no issues
- [ ] All acceptance tests verified
- [ ] No blocking issues remain
- [ ] Ready for /ship

---

## Next Step

**If Complete:** `/ship .claude/sdd/features/DEFINE_{FEATURE_NAME}.md`

**If Blocked:** Resolve blockers, then `/build` to resume

**If Issues Found:** `/iterate DESIGN_{FEATURE}.md "{change needed}"`
