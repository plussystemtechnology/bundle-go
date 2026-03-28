---
name: brainstorm
description: Explore ideas through collaborative dialogue before requirements capture (Phase 0)
---

# Brainstorm Command

> Collaborative exploration before requirements capture (Phase 0)

## Usage

```bash
/brainstorm <idea-or-request>
/brainstorm "Build a REST API for user management"
/brainstorm notes/rough-idea.txt
```

## Examples

```bash
# From a direct idea
/brainstorm "I want to build a JWT authentication middleware"

# From a file with notes
/brainstorm docs/meeting-notes.md

# From a problem statement
/brainstorm "Our API needs rate limiting and request throttling"
```

---

## Overview

This is **Phase 0** of the 5-phase NoxCare-Go workflow:

```text
Phase 0: /brainstorm → .claude/sdd/features/BRAINSTORM_{FEATURE}.md (THIS COMMAND)
Phase 1: /define     → .claude/sdd/features/DEFINE_{FEATURE}.md
Phase 2: /design     → .claude/sdd/features/DESIGN_{FEATURE}.md
Phase 3: /build      → Code + .claude/sdd/reports/BUILD_REPORT_{FEATURE}.md
Phase 4: /ship       → .claude/sdd/archive/{FEATURE}/SHIPPED_{DATE}.md
```

The `/brainstorm` command explores ideas through dialogue before capturing formal requirements.

---

## What This Command Does

1. **Explore** - Understand project context, Go stack, and existing patterns
2. **Question** - Ask one question at a time to clarify intent
3. **Collect** - Gather existing Go interfaces, types, proto files, schemas
4. **Propose** - Present 2-3 approaches with trade-offs
5. **Simplify** - Apply YAGNI to remove unnecessary features
6. **Validate** - Incrementally confirm understanding
7. **Document** - Generate BRAINSTORM document for /define

---

## Process

### Step 1: Gather Context

```markdown
Read(CLAUDE.md)
Read(.claude/sdd/templates/BRAINSTORM_TEMPLATE.md)
Read(go.mod) → Understand existing dependencies
Explore project structure: Glob(**/*.go), existing handlers/services
```

### Step 2: Discovery Questions

Ask questions ONE AT A TIME:

| Question Type | When to Use |
|---------------|-------------|
| Multiple Choice | When options are clear (preferred) |
| Open-Ended | When exploring unknown territory |
| Clarifying | When answer was vague |

**Minimum:** 3 questions before proposing approaches

### Step 3: Go-Specific Sample Collection

Ask about available resources to ground the solution:

```markdown
"Do you have any of the following to help ground the solution?
(a) Existing Go interfaces or types to implement
(b) Proto definitions for the service
(c) Database schema or migrations
(d) OpenAPI/Swagger spec
(e) None yet"
```

If samples exist, analyze and document them in the BRAINSTORM output.

### Step 4: Explore Approaches

Present 2-3 distinct approaches:

```markdown
### Approach A: {Name} -- Recommended
**Why:** {Reasoning}
**Pros:** {Benefits}
**Cons:** {Trade-offs}

### Approach B: {Name}
**Why not recommended:** {Reasoning}
```

### Step 5: Apply YAGNI

For each feature, ask:
- Do we need this for MVP?
- Does this solve the core problem?

Remove features that don't pass. Document what was removed and why.

### Step 6: Validate Incrementally

Present design in sections (200-300 words each):

```text
Section → Check with user → Adjust if needed → Next section
```

**Minimum:** 2 validation checkpoints

### Step 7: Generate Document

```markdown
Write(.claude/sdd/features/BRAINSTORM_{FEATURE}.md)
```

---

## Output

| Artifact | Location |
|----------|----------|
| **Brainstorm Document** | `.claude/sdd/features/BRAINSTORM_{FEATURE}.md` |

**Next Step:** `/define .claude/sdd/features/BRAINSTORM_{FEATURE}.md`

---

## Quality Gate

Before marking complete:

```text
[ ] Minimum 3 discovery questions asked
[ ] Go-specific sample collection asked
[ ] At least 2 approaches explored
[ ] YAGNI applied (features removed)
[ ] Minimum 2 validations completed
[ ] User confirmed selected approach
[ ] Draft requirements included
```

---

## Interaction Style

### One Question at a Time

```markdown
GOOD:
"What's the primary use case?
(a) Internal microservice
(b) Public-facing API
(c) Background worker
(d) CLI tool"

BAD:
"What's the use case? Who are the users? What's the timeline?"
```

### Lead with Recommendation

```markdown
GOOD:
"I recommend Approach A because [reasoning].
Here are the alternatives to consider..."

BAD:
"Here are three approaches. Which one do you want?"
```

---

## When to Use /brainstorm vs /define

| Scenario | Use |
|----------|-----|
| Vague idea, need to explore | `/brainstorm` |
| Clear requirements, ready to capture | `/define` directly |
| Existing BRAINSTORM document | `/define <brainstorm-file>` |
| "I want to build something but not sure what" | `/brainstorm` |

---

## Tips

1. **Take your time** - Exploration is about understanding, not speed
2. **Ask why** - "Why do you need this?" reveals true requirements
3. **Challenge scope** - Most features aren't needed for MVP
4. **Check go.mod** - Existing dependencies inform approach choices
5. **Document removed features** - They might come back later

---

## References

- Agent: `.claude/agents/workflow/brainstorm-agent.md`
- Template: `.claude/sdd/templates/BRAINSTORM_TEMPLATE.md`
- Contracts: `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- Next Phase: `.claude/commands/workflow/define.md`
