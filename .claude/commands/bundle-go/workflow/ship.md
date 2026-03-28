---
name: ship
description: Archive completed feature with lessons learned (Phase 4)
---

# Ship Command

> Archive completed feature with lessons learned (Phase 4)

## Usage

```bash
/ship <define-file>
```

## Examples

```bash
/ship .claude/sdd/features/DEFINE_USER_AUTH.md
/ship DEFINE_ORDER_SERVICE.md
```

---

## Overview

This is **Phase 4** of the 5-phase Bundle-Go workflow:

```text
Phase 0: /brainstorm → .claude/sdd/features/BRAINSTORM_{FEATURE}.md (optional)
Phase 1: /define     → .claude/sdd/features/DEFINE_{FEATURE}.md
Phase 2: /design     → .claude/sdd/features/DESIGN_{FEATURE}.md
Phase 3: /build      → Code + .claude/sdd/reports/BUILD_REPORT_{FEATURE}.md
Phase 4: /ship       → .claude/sdd/archive/{FEATURE}/SHIPPED_{DATE}.md (THIS COMMAND)
```

The `/ship` command archives all feature artifacts and captures lessons learned.

---

## What This Command Does

1. **Verify** - Confirm all artifacts exist and Go verification passes
2. **Archive** - Move feature documents to archive folder
3. **Document** - Create SHIPPED summary with lessons learned
4. **Clean** - Remove working files from features folder

---

## Process

### Step 1: Verify Completion

```markdown
Read(.claude/sdd/features/DEFINE_{FEATURE}.md)
Read(.claude/sdd/features/DESIGN_{FEATURE}.md)
Read(.claude/sdd/reports/BUILD_REPORT_{FEATURE}.md)

# Verify Go checks pass
gofmt -l .
go vet ./...
golangci-lint run
go test -race ./...
```

### Step 2: Create Archive Folder

```bash
mkdir -p .claude/sdd/archive/{FEATURE_NAME}/
```

### Step 3: Copy Artifacts to Archive

```bash
cp .claude/sdd/features/DEFINE_{FEATURE}.md .claude/sdd/archive/{FEATURE}/
cp .claude/sdd/features/DESIGN_{FEATURE}.md .claude/sdd/archive/{FEATURE}/
cp .claude/sdd/reports/BUILD_REPORT_{FEATURE}.md .claude/sdd/archive/{FEATURE}/
```

### Step 4: Generate SHIPPED Document

Create summary with timeline, metrics, Go verification results, and lessons learned.

### Step 5: Update Document Statuses

Update archived documents to "Shipped" status.

### Step 6: Clean Up Working Files

```bash
rm .claude/sdd/features/DEFINE_{FEATURE}.md
rm .claude/sdd/features/DESIGN_{FEATURE}.md
rm .claude/sdd/reports/BUILD_REPORT_{FEATURE}.md
```

### Step 7: Save SHIPPED Document

```markdown
Write(.claude/sdd/archive/{FEATURE}/SHIPPED_{DATE}.md)
```

---

## Output

| Artifact | Location |
|----------|----------|
| **SHIPPED** | `.claude/sdd/archive/{FEATURE}/SHIPPED_{DATE}.md` |
| **DEFINE** | `.claude/sdd/archive/{FEATURE}/DEFINE_{FEATURE}.md` |
| **DESIGN** | `.claude/sdd/archive/{FEATURE}/DESIGN_{FEATURE}.md` |
| **BUILD_REPORT** | `.claude/sdd/archive/{FEATURE}/BUILD_REPORT_{FEATURE}.md` |

**Next Step:** Start new feature with `/define`

---

## Quality Gate

Before shipping, verify:

```text
[ ] BUILD_REPORT shows all tasks completed
[ ] gofmt passes
[ ] go vet passes
[ ] golangci-lint passes
[ ] go test -race passes
[ ] No critical issues in build report
```

---

## Lessons Learned Categories

| Category | Example |
|----------|---------|
| **Process** | "Defining port interfaces first enabled parallel adapter work" |
| **Technical** | "Table-driven tests caught 3 edge cases manual tests missed" |
| **Communication** | "Early clarification of auth flow saved rework" |
| **Tools** | "Using testcontainers-go for repo tests improved reliability" |

---

## Tips

1. **Don't Skip This** - Lessons learned prevent future mistakes
2. **Be Honest** - Document what didn't work too
3. **Be Specific** - "Better planning" -> "Create architecture diagram before coding"
4. **Archive Everything** - Future you will thank present you

---

## References

- Agent: `.claude/agents/workflow/ship-agent.md`
- Template: `.claude/sdd/templates/SHIPPED_TEMPLATE.md`
- Contracts: `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- Previous Phase: `.claude/commands/workflow/build.md`
