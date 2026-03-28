---
name: create-pr
description: Create pull request with conventional commits and structured descriptions
---

# Create PR Command

> Automate professional pull request creation with conventional commits and structured descriptions

## Usage

```bash
/create-pr                           # Auto-detect changes and create PR
/create-pr "feat: add user auth"     # Create PR with custom title
/create-pr --draft                   # Create as draft PR
/create-pr --review                  # Run Go review before PR creation
/create-pr --review --draft          # Review + create as draft
```

---

## Overview

This command streamlines PR creation by:

1. **Analyzing** all staged/unstaged changes
2. **Categorizing** changes by type (feat/fix/refactor/docs)
3. **Generating** conventional commit messages
4. **Building** structured PR descriptions with test plans
5. **Creating** the PR via GitHub CLI

---

## Process

### Step 1: Analyze Changes

```bash
git status
git diff --stat
git log origin/main..HEAD --oneline
```

Categorize files into change types:

```text
CHANGE CATEGORIES
=================

feat:     New features, capabilities
fix:      Bug fixes, error corrections
refactor: Code restructuring, no behavior change
docs:     Documentation only
test:     Test additions or corrections
chore:    Build, CI/CD, dependencies
perf:     Performance improvements
```

### Step 2: Determine PR Type

| Files Changed | Likely Type |
|---------------|-------------|
| `internal/**/*.go` + new functionality | `feat:` |
| `internal/**/*.go` + bug fix | `fix:` |
| `internal/**/*.go` + restructure | `refactor:` |
| `*.md`, `docs/**` | `docs:` |
| `*_test.go` | `test:` |
| `.github/**`, `Makefile`, `go.mod` | `chore:` |
| `.claude/agents/**` | `refactor(agents):` |
| `.claude/kb/**` | `docs(kb):` |
| `.claude/sdd/**` | `docs(sdd):` |
| `migrations/**` | `feat(db):` or `fix(db):` |

### Step 3: Generate Commit Message

Use Conventional Commits format:

```text
<type>(<scope>): <short description>

<body - what changed and why>

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Examples:**

```text
feat(auth): add JWT middleware with role-based access

- Implement JWT validation middleware for Gin
- Add RBAC with RequireRole middleware
- Update user handler to use authenticated context

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Step 4: Pre-PR Go Verification (--review flag)

When using `--review`:

```bash
# Format check
gofmt -l .

# Static analysis
go vet ./...

# Lint
golangci-lint run

# Tests
go test -race -cover ./...

# Build
CGO_ENABLED=0 go build ./cmd/api
```

| Review Result | Action |
|---------------|--------|
| All pass | Continue to PR |
| Lint warnings | Include in PR description |
| Test failures | STOP, fix before PR |
| Build failure | STOP, fix before PR |

### Step 5: Build PR Description

```markdown
## Summary

{2-3 bullet points describing the change}

### Key Changes
- {Primary change 1}
- {Primary change 2}

## What's Changed

### {Category 1}
{Description of changes}

## Files Changed

| Category | Files | Description |
|----------|-------|-------------|
| {cat1} | {count} | {brief} |

## Verification

| Check | Result |
|-------|--------|
| gofmt | Pass |
| go vet | Pass |
| golangci-lint | Pass |
| go test -race | Pass |

## Test Plan

- [ ] {Test case 1}
- [ ] {Test case 2}

## Breaking Changes

{Describe or "None"}

---

Generated with [Claude Code](https://claude.ai/code)
```

### Step 6: Create Branch (if needed)

```bash
git checkout -b <type>/<short-description>

# Examples:
git checkout -b feat/jwt-auth-middleware
git checkout -b fix/handler-null-check
git checkout -b refactor/clean-arch-layers
```

### Step 7: Commit and Push

```bash
git add -A
git commit -m "<message>"
git push -u origin <branch-name>
```

### Step 8: Create PR

```bash
gh pr create \
  --title "<type>(<scope>): <description>" \
  --body "<generated-body>" \
  --base main
```

---

## Output

- **Branch:** `<type>/<short-description>`
- **Commit:** Conventional commit format
- **PR URL:** Returned from `gh pr create`

---

## Conventional Commits Reference

| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(api): add user endpoint` |
| `fix` | Bug fix | `fix(handler): handle nil context` |
| `refactor` | Code restructure | `refactor(service): extract auth logic` |
| `docs` | Documentation | `docs(kb): add redis caching patterns` |
| `test` | Tests | `test(repo): add integration tests` |
| `chore` | Maintenance | `chore(deps): update go dependencies` |
| `perf` | Performance | `perf(query): add database index` |

**Scopes for Go projects:**

| Scope | Applies To |
|-------|------------|
| `api` | `internal/adapter/http/` |
| `service` | `internal/app/` |
| `repo` | `internal/adapter/repo/` |
| `domain` | `internal/domain/` |
| `auth` | Authentication/authorization |
| `grpc` | `internal/adapter/grpc/` |
| `kafka` | `internal/adapter/kafka/` |
| `cache` | `internal/adapter/cache/` |
| `db` | `migrations/`, database |
| `infra` | `Dockerfile`, `k8s/`, Terraform |
| `ci` | `.github/` |
| `agents` | `.claude/agents/` |
| `kb` | `.claude/kb/` |
| `sdd` | `.claude/sdd/` |

---

## Quality Checklist

```text
COMMIT MESSAGE
[ ] Uses conventional commits format
[ ] Type matches the primary change
[ ] Scope is specific and meaningful
[ ] Description is concise (< 72 chars)

PR DESCRIPTION
[ ] Summary explains WHY not just WHAT
[ ] Go verification results included
[ ] Test plan has actionable items
[ ] Breaking changes documented (if any)

BRANCH
[ ] Branch name matches convention
[ ] Not committing directly to main
```

---

## Tips

1. **Keep PRs Small** - Aim for < 400 lines changed
2. **One Concern Per PR** - Don't mix features with refactors
3. **Write for Reviewers** - Assume they don't know the context
4. **Link Issues** - Use "Closes #XX" to auto-close issues
5. **Include Verification** - Show gofmt/vet/lint/test results

---

## References

- Review Command: `.claude/commands/review/review.md`
- Code Reviewer Agent: `.claude/agents/test/code-reviewer.md`
- Workflow: `.claude/sdd/_index.md`
