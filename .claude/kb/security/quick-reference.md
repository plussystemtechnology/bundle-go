# Security Quick Reference

## Tools

| Tool | Purpose | Command |
|------|---------|---------|
| `gosec` | SAST — static analysis | `gosec ./...` |
| `govulncheck` | Known vulnerabilities | `govulncheck ./...` |
| `staticcheck` | Code quality + some security | `staticcheck ./...` |
| `go vet` | Common mistakes | `go vet ./...` |
| `trivy` | Container image CVEs | `trivy image myapp:latest` |

## OWASP Top 10 Go Mitigations

| OWASP | Mitigation |
|-------|-----------|
| Injection | Parameterized queries (sqlc), input validation |
| Broken Auth | JWT validation, bcrypt passwords, rate limiting |
| Sensitive Data | TLS, Vault secrets, no hardcoded credentials |
| XXE | Go's encoding/xml is safe by default |
| Broken Access | RBAC middleware, resource ownership checks |
| Security Misconfig | No debug in production, secure headers |
| XSS | html/template auto-escaping, Content-Type headers |
| Insecure Deserialization | json.Unmarshal into typed structs (safe) |
| Components with Vulns | govulncheck, Dependabot |
| Logging | Structured logging, never log secrets |

## Quick Checks

```bash
# Run all security checks
gosec ./...
govulncheck ./...
go vet ./...
```
