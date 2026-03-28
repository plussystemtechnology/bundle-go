---
name: memory
description: Save session insights to .claude/storage/
---

# Memory Command

> Compress and persist valuable session insights before context is lost.

## Usage

```
/memory
/memory --tag <label>
```

## Examples

```
/memory
/memory --tag auth-refactor
/memory --tag kafka-consumer-patterns
```

## What This Command Does

1. **Scan conversation** — reviews the current session for decisions, patterns, and blockers
2. **Extract high-signal content** — filters noise, keeps only actionable insights
3. **Compress to structured format** — organizes into decisions, patterns, gotchas, open items
4. **Write to storage** — saves to `.claude/storage/memory-{YYYY-MM-DD}.md` (appends if file exists)
5. **Confirm save** — reports what was written and the file path

## Output

File: `.claude/storage/memory-{YYYY-MM-DD}.md`

```markdown
## Session: {YYYY-MM-DD} {HH:MM} [tag?]

### Decisions (max 5)
- [DECISION] <what was decided and why>

### Patterns (max 3)
- [PATTERN] <reusable approach or convention>

### Gotchas (max 3)
- [GOTCHA] <pitfall or non-obvious constraint>

### Open Items (max 3)
- [ ] <unresolved question or deferred task>
```

## Limits

| Field | Max |
|-------|-----|
| Decisions | 5 |
| Patterns | 3 |
| Gotchas | 3 |
| Open items | 3 |

Only insights with clear reuse value are saved — not every message in the session.
