---
name: review
description: Code review with architectural and security analysis for Go projects
---

# Review Command

> Static analysis + deep architectural review for Go code — runs tools then delegates to code-reviewer agent.

## Usage

```
/review
/review uncommitted
/review committed
/review --quick
/review --deep
/review <file-or-directory>
```

## Examples

```
/review
/review uncommitted
/review internal/adapter/http/handler/auth.go
/review --deep internal/app/
/review --quick
```

## What This Command Does

1. **Determine scope** — all changes vs main (default), uncommitted, committed, or a specific path
2. **Run static analysis**:
   ```bash
   golangci-lint run ./...
   go vet ./...
   staticcheck ./...
   ```
3. **Parse tool output** — collect linting errors, vet warnings, staticcheck findings
4. **Delegate to code-reviewer agent** — deep review covering:
   - Clean Architecture layer violations (import direction)
   - Error handling (`errors.Is`, `errors.As`, wrapping with `%w`)
   - Concurrency safety (goroutine lifecycle, `context.Context` propagation)
   - Security (SQL injection, input validation, secret exposure)
   - Performance (N+1 queries, missing indexes, unnecessary allocations)
   - Test coverage gaps
5. **Generate report** — structured findings with severity levels

## Modes

| Mode | Scope | Static Analysis | Deep Review |
|------|-------|----------------|-------------|
| _(default)_ | all changes vs main | yes | yes |
| `uncommitted` | unstaged + staged | yes | yes |
| `committed` | commits ahead of main | yes | yes |
| `--quick` | current diff | yes only | no |
| `--deep` | specified path | yes | yes + full arch |

## Report Format

```
## Review Report

### Critical
- [CRITICAL] ...

### Errors
- [ERROR] ...

### Warnings
- [WARNING] ...

### Info
- [INFO] ...

### Summary
X critical, X errors, X warnings, X info
```

## Agent Delegation

Delegates to: `code-reviewer` agent

KB domains referenced: `go-patterns`, `testing`, `security`, `clean-architecture`
