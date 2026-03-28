---
name: security-scan
description: Run a security audit of Go code — delegates to security-scanner agent
---

# Security Scan Command

> Run a security audit using gosec and govulncheck with OWASP severity mapping.

## Usage

```bash
/security-scan [path] [flags]
```

## Examples

```bash
/security-scan
/security-scan internal/adapter/
/security-scan internal/adapter/handler/http/auth.go
/security-scan --ci
```

---

## What This Command Does

1. Invokes the **security-scanner** agent
2. Scans the target path (defaults to `./...`) for security issues
3. Loads KB patterns from `security` and `ci-cd` domains
4. Generates: Security report with categorized findings and remediation guidance

## Agent Delegation

| Agent | Role |
|-------|------|
| `security-scanner` | Primary — gosec, govulncheck, OWASP Top 10 analysis |
| `code-reviewer` | Escalation — deep review of flagged code, false positive triage |
| `ci-cd-specialist` | Escalation — CI pipeline integration, automated gate configuration |

## KB Domains Used

- `security` — OWASP Top 10, Go-specific CVEs, secrets detection, injection patterns
- `ci-cd` — GitHub Actions security job, artifact signing, SARIF report upload

## Output

- Security findings report grouped by OWASP category and severity (Critical/High/Medium/Low)
- gosec rule violations with file locations and remediation snippets
- govulncheck dependency vulnerability list with CVE references
- `--ci` flag: exits non-zero on High/Critical findings for pipeline gating
