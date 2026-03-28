# Rename bundle-go to bundle-go

**Date:** 2026-03-28
**Status:** Approved

## Summary

Rename the project from `bundle-go` to `bundle-go`, update the GitHub org to `plussystemtechnology`, restructure commands under a `bundle-go/` namespace, and rename the root directory.

## Text Replacement Rules

Order matters to avoid partial matches:

| Order | From | To | Scope |
|-------|------|----|-------|
| 1 | `Bundle-Go` | `Bundle-Go` | Formal title |
| 2 | `BundleGo` | `BundleGo` | Short reference (after order 1 to avoid "BundleGo-Go") |
| 3 | `bundle-go` | `bundle-go` | Technical name, paths, URLs |
| 4 | `plussystemtechnology` | `plussystemtechnology` | GitHub org |

Affects ~56 files, ~150 occurrences.

## Command Restructuring

Current structure (flat subdirectories under `.claude/commands/`):

```
.claude/commands/{workflow,go-engineering,core,knowledge,review}/
```

New structure (wrapped under `bundle-go/`):

```
.claude/commands/bundle-go/{workflow,go-engineering,core,knowledge,review}/
```

This changes invocation from `/workflow:brainstorm` to `/bundle-go:workflow:brainstorm`.

### Full command mapping

| Before | After |
|--------|-------|
| `/workflow:brainstorm` | `/bundle-go:workflow:brainstorm` |
| `/workflow:define` | `/bundle-go:workflow:define` |
| `/workflow:design` | `/bundle-go:workflow:design` |
| `/workflow:build` | `/bundle-go:workflow:build` |
| `/workflow:ship` | `/bundle-go:workflow:ship` |
| `/workflow:iterate` | `/bundle-go:workflow:iterate` |
| `/workflow:create-pr` | `/bundle-go:workflow:create-pr` |
| `/go-engineering:handler` | `/bundle-go:go-engineering:handler` |
| `/go-engineering:service` | `/bundle-go:go-engineering:service` |
| `/go-engineering:repository` | `/bundle-go:go-engineering:repository` |
| `/go-engineering:migration` | `/bundle-go:go-engineering:migration` |
| `/go-engineering:middleware` | `/bundle-go:go-engineering:middleware` |
| `/go-engineering:proto` | `/bundle-go:go-engineering:proto` |
| `/go-engineering:kafka-consumer` | `/bundle-go:go-engineering:kafka-consumer` |
| `/go-engineering:swagger` | `/bundle-go:go-engineering:swagger` |
| `/go-engineering:security-scan` | `/bundle-go:go-engineering:security-scan` |
| `/go-engineering:go-review` | `/bundle-go:go-engineering:go-review` |
| `/core:memory` | `/bundle-go:core:memory` |
| `/core:meeting` | `/bundle-go:core:meeting` |
| `/core:readme-maker` | `/bundle-go:core:readme-maker` |
| `/core:sync-context` | `/bundle-go:core:sync-context` |
| `/knowledge:create-kb` | `/bundle-go:knowledge:create-kb` |
| `/review:review` | `/bundle-go:review:review` |

## File Renames

| From | To |
|------|----|
| `docs/superpowers/specs/2026-03-27-bundle-go-plugin-design.md` | `docs/superpowers/specs/2026-03-27-bundle-go-plugin-design.md` |
| `docs/superpowers/plans/2026-03-27-bundle-go-plugin.md` | `docs/superpowers/plans/2026-03-27-bundle-go-plugin.md` |

## CLAUDE.md Updates

- All command tables updated with `bundle-go:` prefix
- Project description updated
- Repository URL updated to `https://github.com/plussystemtechnology/bundle-go`

## Root Directory Rename

`/home/lerry/models/bundle-go` -> `/home/lerry/models/bundle-go`

Done last, after all in-repo edits.

## Memory Update

Update `MEMORY.md` and `project_noxcare.md` to reflect new name.

## Out of Scope

- `go.mod` / `makefile` (deleted, were for tooling analysis only)
- Agent file content (agents reference KB domains by relative path, no project name in agent logic)
