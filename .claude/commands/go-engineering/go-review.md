---
name: go-review
description: Perform a Go-specific code review — delegates to code-reviewer agent
---

# Go Review Command

> Perform a Go-specific code review covering quality, security, anti-patterns, and Clean Architecture compliance.

## Usage

```bash
/go-review <path-or-file> [flags]
```

## Examples

```bash
/go-review internal/adapter/handler/
/go-review internal/app/service/order_service.go
/go-review --focus security
/go-review --focus architecture
```

---

## What This Command Does

1. Invokes the **code-reviewer** agent
2. Analyzes the target path or file
3. Loads KB patterns from `go-patterns`, `testing`, `security`, and `clean-architecture` domains
4. Generates: Structured review report with actionable findings

## Agent Delegation

| Agent | Role |
|-------|------|
| `code-reviewer` | Primary — Go idioms, test coverage, anti-pattern detection |
| `clean-arch-architect` | Escalation — layer boundary violations, dependency rule breaches |
| `security-scanner` | Escalation — security-focused deep dive on flagged code |

## KB Domains Used

- `go-patterns` — Idiomatic Go, interface design, error wrapping, context propagation
- `testing` — Table-driven tests, mock patterns, coverage gaps
- `security` — Input validation, secrets handling, injection risks
- `clean-architecture` — Layer import rules, dependency inversion, port compliance

## Output

- Review report organized by category: Code Quality, Testing, Security, Architecture
- Line-level findings with severity (Critical / Warning / Suggestion)
- Anti-pattern list: goroutine leaks, `interface{}` misuse, ignored errors, `SELECT *`
- Actionable refactoring suggestions with idiomatic Go alternatives
