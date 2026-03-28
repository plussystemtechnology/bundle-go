---
name: build
description: Execute implementation with agent delegation and Go verification (Phase 3)
---

# Build Command

> Execute implementation with agent delegation and Go verification (Phase 3)

## Usage

```bash
/build <design-file>
```

## Examples

```bash
/build .claude/sdd/features/DESIGN_USER_AUTH.md
/build DESIGN_ORDER_SERVICE.md
```

---

## Overview

This is **Phase 3** of the 5-phase NoxCare-Go workflow:

```text
Phase 0: /brainstorm → .claude/sdd/features/BRAINSTORM_{FEATURE}.md (optional)
Phase 1: /define     → .claude/sdd/features/DEFINE_{FEATURE}.md
Phase 2: /design     → .claude/sdd/features/DESIGN_{FEATURE}.md
Phase 3: /build      → Code + .claude/sdd/reports/BUILD_REPORT_{FEATURE}.md (THIS COMMAND)
Phase 4: /ship       → .claude/sdd/archive/{FEATURE}/SHIPPED_{DATE}.md
```

The `/build` command executes the implementation, generating tasks from the file manifest and delegating to Go specialist agents.

---

## What This Command Does

1. **Parse** - Extract file manifest from DESIGN
2. **Prioritize** - Order by Clean Architecture layers (domain -> port -> app -> adapter -> bootstrap -> cmd)
3. **Delegate** - Assign to Go specialist agents per manifest
4. **Execute** - Create each file with verification
5. **Validate** - Run full Go verification suite
6. **Report** - Generate build report

---

## Process

### Step 1: Load Context

```markdown
Read(.claude/sdd/features/DESIGN_{FEATURE}.md)
Read(.claude/sdd/features/DEFINE_{FEATURE}.md)
Read(CLAUDE.md)
```

### Step 2: Extract Tasks from File Manifest

Convert the file manifest to a task list ordered by Clean Architecture layers.

### Step 3: Execute Each Task

For each file:

1. **Delegate** - Send to assigned agent (or execute directly)
2. **Write** - Create the file following code patterns from DESIGN
3. **Verify** - Run Go verification
4. **Mark Complete** - Update progress

### Step 4: Run Full Go Verification

After all files created:

```bash
# Format check
gofmt -l .

# Static analysis
go vet ./...
staticcheck ./...

# Lint
golangci-lint run

# Tests with race detection and coverage
go test -race -cover ./...

# Build check
CGO_ENABLED=0 go build ./cmd/api
```

### Step 5: Verify Clean Architecture

```bash
# Verify domain has no internal imports
grep -r '"internal/' internal/domain/ && echo "VIOLATION" || echo "OK"

# Verify port imports only domain
grep -r '"internal/' internal/port/ | grep -v '"internal/domain' && echo "VIOLATION" || echo "OK"
```

### Step 6: Generate Build Report

```markdown
Write(.claude/sdd/reports/BUILD_REPORT_{FEATURE}.md)
```

---

## Output

| Artifact | Location |
|----------|----------|
| **Code** | As specified in DESIGN file manifest |
| **Build Report** | `.claude/sdd/reports/BUILD_REPORT_{FEATURE}.md` |

**Next Step:** `/ship .claude/sdd/features/DEFINE_{FEATURE}.md` (when ready)

---

## Execution Loop

```text
┌─────────────────────────────────────────────────────────────┐
│                       EXECUTE TASK                           │
├─────────────────────────────────────────────────────────────┤
│  1. Read task from manifest                                  │
│  2. Delegate to Go specialist agent (or execute directly)   │
│  3. Write code following DESIGN patterns                    │
│  4. Run Go verification                                     │
│     └─ If FAIL → Fix and retry (max 3)                     │
│  5. Mark task complete                                      │
│  6. Move to next task                                       │
└─────────────────────────────────────────────────────────────┘
```

---

## Quality Gate

Before marking complete, verify:

```text
[ ] All files from manifest created
[ ] gofmt check passes
[ ] go vet passes
[ ] golangci-lint passes
[ ] go test -race passes
[ ] Clean Architecture imports verified
[ ] No panic() for error handling
[ ] context.Context used throughout
[ ] No TODO comments left in code
[ ] Build report generated
```

---

## Tips

1. **Follow the DESIGN** - Don't improvise, use the code patterns
2. **Verify Incrementally** - Test after each file, not at the end
3. **Fix Forward** - If something breaks, fix it immediately
4. **Self-Contained** - Each package should be independently functional
5. **Delegate to Specialists** - Use handler-builder for handlers, repo-builder for repos

---

## Handling Issues During Build

| Issue | Action |
|-------|--------|
| Missing requirement | Use `/iterate` to update DEFINE |
| Architecture problem | Use `/iterate` to update DESIGN |
| Compilation error | Fix immediately and continue |
| Import cycle | Restructure following Clean Architecture |
| Major blocker | Stop and report in build report |

---

## References

- Agent: `.claude/agents/workflow/build-agent.md`
- Template: `.claude/sdd/templates/BUILD_REPORT_TEMPLATE.md`
- Contracts: `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- Next Phase: `.claude/commands/workflow/ship.md`
