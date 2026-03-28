---
name: define
description: Capture and validate requirements in one pass (Phase 1)
---

# Define Command

> Capture requirements and validate them in one pass (Phase 1)

## Usage

```bash
/define <input>
```

## Examples

```bash
# From a BRAINSTORM document (recommended after /brainstorm)
/define .claude/sdd/features/BRAINSTORM_USER_AUTH.md

# From meeting notes or raw input
/define notes/meeting-notes.md
/define "Build a REST API for user management with JWT auth"
```

---

## Overview

This is **Phase 1** of the 5-phase NoxCare-Go workflow:

```text
Phase 0: /brainstorm → .claude/sdd/features/BRAINSTORM_{FEATURE}.md (optional)
Phase 1: /define     → .claude/sdd/features/DEFINE_{FEATURE}.md (THIS COMMAND)
Phase 2: /design     → .claude/sdd/features/DESIGN_{FEATURE}.md
Phase 3: /build      → Code + .claude/sdd/reports/BUILD_REPORT_{FEATURE}.md
Phase 4: /ship       → .claude/sdd/archive/{FEATURE}/SHIPPED_{DATE}.md
```

The `/define` command combines intake, PRD, and refinement into a single iterative phase.

---

## What This Command Does

1. **Extract** - Pull requirements from any input (notes, emails, conversations)
2. **Structure** - Organize into problem, users, goals, success criteria
3. **Go Context** - Gather Go-specific technical context (stack, layers, deploy)
4. **Validate** - Built-in clarity scoring (must reach 12/15 to proceed)
5. **Clarify** - Ask targeted questions for any gaps

---

## Process

### Step 1: Load Context

```markdown
Read(.claude/sdd/templates/DEFINE_TEMPLATE.md)
Read(CLAUDE.md)
Read(go.mod) → Existing dependencies

# If file provided:
Read(<input-file>)
```

### Step 2: Extract Entities

Extract these elements from input:

| Element | Extraction Patterns |
|---------|---------------------|
| **Problem** | "We're struggling with...", "The issue is...", "Pain point:" |
| **Users** | "For the team...", "Customers want...", "Users need..." |
| **Goals** | "We need to...", "Goal is to...", "Success looks like..." |
| **Success Criteria** | "Success means...", "We'll know when...", "Measured by..." |
| **Constraints** | "Must work with...", "Can't change...", "Limited by..." |
| **Out of Scope** | "Not including...", "Deferred to...", "Excluded:" |

### Step 3: Go Technical Context

Gather Go-specific context:

| Question | Why |
|----------|-----|
| Which Clean Arch layers are affected? | Determines file structure |
| Which KB domains apply? | Design phase pulls correct patterns |
| What's the deployment target? | Container, K8s, serverless |
| Any existing interfaces to implement? | Ensures compatibility |

### Step 4: Calculate Clarity Score

Score each element (0-3 points):

| Element | Score | Meaning |
|---------|-------|---------|
| Problem | 0-3 | Clear, specific, actionable |
| Users | 0-3 | Identified with pain points |
| Goals | 0-3 | Measurable outcomes |
| Success | 0-3 | Testable criteria |
| Scope | 0-3 | Explicit boundaries |

**Minimum to proceed:** 12/15 (80%)

### Step 5: Fill Gaps (if needed)

If score < 12, ask specific questions:

```markdown
"What's the expected throughput?
(a) < 100 req/s
(b) 100-1000 req/s
(c) 1000-10000 req/s
(d) > 10000 req/s"
```

### Step 6: Generate Document

```markdown
Write(.claude/sdd/features/DEFINE_{FEATURE_NAME}.md)
```

---

## Output

| Artifact | Location |
|----------|----------|
| **DEFINE** | `.claude/sdd/features/DEFINE_{FEATURE_NAME}.md` |

**Next Step:** `/design .claude/sdd/features/DEFINE_{FEATURE_NAME}.md`

---

## Quality Gate

Before saving, verify:

```text
[ ] Problem statement is clear and specific
[ ] At least one user persona identified
[ ] Success criteria are measurable
[ ] Out of scope is explicit
[ ] Go technical context gathered (stack, layers, deploy)
[ ] KB domains identified for Design phase
[ ] Clarity Score >= 12/15
```

---

## Tips

1. **Be Specific** - "Improve performance" -> "Reduce API latency to <200ms p99"
2. **Use Numbers** - "Handle many users" -> "Support 1000 concurrent connections"
3. **Test Criteria** - If you can't test it, it's not clear enough
4. **Scope Ruthlessly** - What's OUT is as important as what's IN
5. **Gather Go Context** - Stack, layers, and deploy target save design time

---

## References

- Agent: `.claude/agents/workflow/define-agent.md`
- Template: `.claude/sdd/templates/DEFINE_TEMPLATE.md`
- Contracts: `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- Previous Phase: `.claude/commands/workflow/brainstorm.md` (optional)
- Next Phase: `.claude/commands/workflow/design.md`
