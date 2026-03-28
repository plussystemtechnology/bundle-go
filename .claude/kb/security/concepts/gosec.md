# gosec — Go Security Scanner

## What It Does

gosec scans Go source code for security issues: hardcoded credentials, weak crypto, SQL injection, file path traversal, etc.

## Common Rules

| Rule | Description |
|------|-------------|
| G101 | Hardcoded credentials |
| G201 | SQL string concatenation |
| G202 | SQL string formatting |
| G301 | File permissions too open |
| G304 | File path from user input |
| G401 | Weak cryptographic primitive |
| G501 | Blocklisted import (crypto/md5) |

## Running

```bash
# Install
go install github.com/securego/gosec/v2/cmd/gosec@latest

# Scan all packages
gosec ./...

# JSON output
gosec -fmt=json -out=gosec-report.json ./...

# Exclude rules
gosec -exclude=G104 ./...
```

## Inline Suppression

```go
// #nosec G101 -- this is a test value, not a real credential
const testAPIKey = "test-key-12345"
```
