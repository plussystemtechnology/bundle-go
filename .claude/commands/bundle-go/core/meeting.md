---
name: meeting
description: Analyze meeting transcripts and extract structured documentation
---

# Meeting Command

> Turn raw meeting transcripts into structured decisions, action items, and open questions.

## Usage

```
/meeting
/meeting --output define
/meeting --output design
```

## Examples

```
/meeting
/meeting --output define
/meeting --output define FEATURE_NAME
```

Paste or provide the transcript when prompted.

## What This Command Does

1. **Receive transcript** — accepts pasted text or a file path
2. **Identify participants** — extracts names and roles from the transcript
3. **Extract decisions** — finds explicit and implicit decisions with context
4. **List action items** — captures tasks with owners and deadlines
5. **Flag open questions** — marks unresolved issues and blockers
6. **Generate report** — outputs structured markdown tables
7. **SDD integration** — if `--output` is provided, seeds the target SDD document

## Output

### Decisions

| Decision | Decider | Context | Date |
|----------|---------|---------|------|
| Use Kafka for async order events | Tech Lead | Low coupling needed | 2026-03-28 |

### Action Items

| Task | Owner | Deadline | Priority |
|------|-------|----------|----------|
| Define OrderCreated proto schema | @dev1 | 2026-04-02 | High |

### Open Questions

| Question | Blocker? | Owner |
|----------|----------|-------|
| Which Kafka topic naming convention? | Yes | @dev2 |

## Flags

| Flag | Behavior |
|------|----------|
| _(none)_ | Output to terminal only |
| `--output define` | Seed `.claude/sdd/features/FEATURE/define.md` |
| `--output design` | Seed `.claude/sdd/features/FEATURE/design.md` |

## Notes

- Timestamps are extracted when present in the transcript
- Ambiguous decisions are flagged with `[INFERRED]`
- Action items without owners are tagged `[UNASSIGNED]`
