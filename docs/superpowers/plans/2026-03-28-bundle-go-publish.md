# Bundle-Go Publication Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish bundle-go to GitHub as a public repo with Claude Code marketplace and skills.sh support.

**Architecture:** Add a `.claude-plugin/` directory with `plugin.json` and `marketplace.json` to the existing repo, plus a root `SKILL.md` for skills.sh. Then create the public GitHub repo and push.

**Tech Stack:** GitHub CLI (`gh`), Claude Code plugin system, skills.sh

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `.claude-plugin/plugin.json` | Create | Plugin manifest (name, version, author, metadata) |
| `.claude-plugin/marketplace.json` | Create | Marketplace catalog listing bundle-go as installable plugin |
| `SKILL.md` | Create | skills.sh discovery entry |

No existing files are modified.

---

### Task 1: Create plugin manifest

**Files:**
- Create: `.claude-plugin/plugin.json`

- [ ] **Step 1: Create the `.claude-plugin/` directory**

Run:
```bash
mkdir -p /home/lerry/models/bundle-go/.claude-plugin
```

- [ ] **Step 2: Create `plugin.json`**

Write to `.claude-plugin/plugin.json`:

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

- [ ] **Step 3: Verify the file is valid JSON**

Run:
```bash
cat /home/lerry/models/bundle-go/.claude-plugin/plugin.json | python3 -m json.tool > /dev/null && echo "Valid JSON"
```

Expected: `Valid JSON`

- [ ] **Step 4: Commit**

```bash
cd /home/lerry/models/bundle-go && git add .claude-plugin/plugin.json && git commit -m "feat: add plugin manifest for Claude Code marketplace"
```

---

### Task 2: Create marketplace catalog

**Files:**
- Create: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Create `marketplace.json`**

Write to `.claude-plugin/marketplace.json`:

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

Key fields:
- `source: "./"` — the plugin is the repo root itself (`.claude/` structure loads from there)
- `strict: false` — marketplace entry defines components, no conflict with existing `.claude/` layout

- [ ] **Step 2: Verify the file is valid JSON**

Run:
```bash
cat /home/lerry/models/bundle-go/.claude-plugin/marketplace.json | python3 -m json.tool > /dev/null && echo "Valid JSON"
```

Expected: `Valid JSON`

- [ ] **Step 3: Commit**

```bash
cd /home/lerry/models/bundle-go && git add .claude-plugin/marketplace.json && git commit -m "feat: add marketplace catalog for plugin discovery"
```

---

### Task 3: Create SKILL.md for skills.sh

**Files:**
- Create: `SKILL.md`

- [ ] **Step 1: Create `SKILL.md` at repo root**

Write to `SKILL.md`:

```markdown
---
name: bundle-go
description: Claude Code plugin for Go Backend/API development with Clean Architecture. Provides 43 specialized agents, 23 commands, and 22 KB domains through a 5-phase SDD workflow (brainstorm, define, design, build, ship).
---

# Bundle-Go

Claude Code plugin for Go Backend/API development with Clean Architecture and Spec-Driven Development (SDD).

## What You Get

- **43 specialized agents** across 8 categories (workflow, architect, go-core, api, data, cloud, observability, test)
- **23 slash commands** for SDD phases and Go engineering tasks
- **22 KB domains** covering Go patterns, Gin, sqlc, pgx, Kafka, gRPC, Docker, Kubernetes, and more

## Install via Claude Code Marketplace

```bash
/plugin marketplace add plussystemtechnology/bundle-go
/plugin install bundle-go@bundle-go
```

## SDD Workflow

```
/brainstorm → /define → /design → /build → /ship
```

## Go Engineering Commands

```
/handler    /service     /repository   /migration
/middleware  /proto       /kafka-consumer
/swagger    /security-scan  /go-review
```

## Learn More

See the full [README](https://github.com/plussystemtechnology/bundle-go) for documentation.
```

- [ ] **Step 2: Verify SKILL.md frontmatter has required fields**

Run:
```bash
head -4 /home/lerry/models/bundle-go/SKILL.md
```

Expected output should show `name:` and `description:` in YAML frontmatter.

- [ ] **Step 3: Commit**

```bash
cd /home/lerry/models/bundle-go && git add SKILL.md && git commit -m "feat: add SKILL.md for skills.sh discovery"
```

---

### Task 4: Create public GitHub repo and push

**Files:** None (git operations only)

- [ ] **Step 1: Create the public repo on GitHub**

Run:
```bash
gh repo create plussystemtechnology/bundle-go --public --description "Claude Code plugin for Go Backend/API development with Clean Architecture and SDD workflow" --source /home/lerry/models/bundle-go --push
```

This creates the repo, sets the remote, and pushes `main` in one command.

Expected: Repo created at `https://github.com/plussystemtechnology/bundle-go`

- [ ] **Step 2: Verify repo is public and accessible**

Run:
```bash
gh repo view plussystemtechnology/bundle-go --json name,visibility,url --jq '"\(.name) | \(.visibility) | \(.url)"'
```

Expected: `bundle-go | PUBLIC | https://github.com/plussystemtechnology/bundle-go`

- [ ] **Step 3: Verify all commits are pushed**

Run:
```bash
git log --oneline -5
```

Should show the 3 new commits at the top:
1. `feat: add SKILL.md for skills.sh discovery`
2. `feat: add marketplace catalog for plugin discovery`
3. `feat: add plugin manifest for Claude Code marketplace`

---

### Task 5: Validate plugin structure

- [ ] **Step 1: Validate plugin with Claude Code validator**

Run:
```bash
claude plugin validate /home/lerry/models/bundle-go
```

Expected: No errors. Warnings about missing components are acceptable since the plugin uses `strict: false`.

- [ ] **Step 2: Verify skills.sh discoverability**

Run:
```bash
gh api repos/plussystemtechnology/bundle-go/contents/SKILL.md --jq '.name'
```

Expected: `SKILL.md`

- [ ] **Step 3: Verify marketplace.json is accessible**

Run:
```bash
gh api repos/plussystemtechnology/bundle-go/contents/.claude-plugin/marketplace.json --jq '.name'
```

Expected: `marketplace.json`
