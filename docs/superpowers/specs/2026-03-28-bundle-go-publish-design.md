# Bundle-Go Publication Design

> Publish bundle-go to GitHub, Claude Code marketplace, and skills.sh

**Date:** 2026-03-28
**Status:** Approved

---

## Goal

Make bundle-go publicly available through three channels:

1. **GitHub** — Public repository at `plussystemtechnology/bundle-go`
2. **Claude Code Marketplace** — Installable via `/plugin marketplace add`
3. **skills.sh** — Discoverable via `npx skills add`

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Repo location | `plussystemtechnology/bundle-go` | Matches existing README references |
| Structure | Keep `.claude/` as-is, add `.claude-plugin/` | Non-breaking, minimal changes |
| Marketplace | Self-hosted marketplace (Approach B) | Full marketplace UX with auto-updates |
| skills.sh | Single top-level `SKILL.md` | Plugin is a single cohesive unit |
| Official submission | Skip for now | Users install via `/plugin marketplace add` directly |

## Files to Create

### 1. `.claude-plugin/plugin.json`

Plugin manifest with metadata:

```json
{
  "name": "bundle-go",
  "description": "Claude Code plugin for Go Backend/API development with Clean Architecture and SDD workflow. 43 agents, 23 commands, 22 KB domains.",
  "version": "1.0.0",
  "author": {
    "name": "Plus System Technology"
  },
  "homepage": "https://github.com/plussystemtechnology/bundle-go",
  "repository": "https://github.com/plussystemtechnology/bundle-go",
  "license": "MIT",
  "keywords": ["go", "golang", "clean-architecture", "backend", "api", "sdd"]
}
```

### 2. `.claude-plugin/marketplace.json`

Marketplace catalog listing bundle-go as a plugin:

```json
{
  "name": "bundle-go",
  "owner": {
    "name": "Plus System Technology"
  },
  "metadata": {
    "description": "Go Backend/API development with Clean Architecture and SDD workflow",
    "version": "1.0.0"
  },
  "plugins": [
    {
      "name": "bundle-go",
      "source": "./",
      "description": "43 agents, 23 commands, 22 KB domains for Go Backend/API with Clean Architecture",
      "version": "1.0.0",
      "category": "development",
      "tags": ["go", "golang", "clean-architecture", "backend", "api"],
      "strict": false
    }
  ]
}
```

- `source: "./"` — plugin is the repo root itself
- `strict: false` — marketplace entry defines components; existing `.claude/` structure loads naturally

### 3. `SKILL.md` (repo root)

Single skill entry for skills.sh discovery:

```yaml
---
name: bundle-go
description: Claude Code plugin for Go Backend/API development with Clean Architecture. Provides 43 specialized agents, 23 commands, and 22 KB domains through a 5-phase SDD workflow (brainstorm, define, design, build, ship).
---
```

With a brief body describing the plugin and installation instructions.

## Files Changed

None. Existing files remain untouched.

## GitHub Repo Setup

1. Create public repo `plussystemtechnology/bundle-go` via `gh repo create`
2. Add remote origin to local repo
3. Push `main` branch
4. Description: "Claude Code plugin for Go Backend/API development with Clean Architecture and SDD workflow"

## Installation UX

| Method | Command | Audience |
|--------|---------|----------|
| Claude Marketplace | `/plugin marketplace add plussystemtechnology/bundle-go` then `/plugin install bundle-go@bundle-go` | Claude Code users |
| skills.sh | `npx skills add plussystemtechnology/bundle-go` | skills.sh discovery |
| Manual clone | `git clone` + `cp -r .claude/ project/.claude/` | Manual setup |

## Sources

- [Claude Code Plugin Docs](https://code.claude.com/docs/en/plugins)
- [Claude Code Marketplace Docs](https://code.claude.com/docs/en/plugin-marketplaces)
- [Official Marketplace Submission](https://clau.de/plugin-directory-submission)
- [skills.sh Directory](https://skills.sh/docs)
- [Anthropic Skills Repo](https://github.com/anthropics/skills)
- [Vercel Skills CLI](https://github.com/vercel-labs/skills)
