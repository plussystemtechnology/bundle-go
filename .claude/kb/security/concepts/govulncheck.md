# govulncheck

## What It Does

govulncheck reports known vulnerabilities in Go dependencies. It checks if your code actually calls vulnerable functions (not just imports the package).

## Running

```bash
# Install
go install golang.org/x/vuln/cmd/govulncheck@latest

# Check current module
govulncheck ./...

# JSON output
govulncheck -json ./...

# Check binary
govulncheck -mode=binary ./bin/api
```

## Output

```text
Vulnerability #1: GO-2024-1234
    Affected: github.com/example/lib v1.2.3
    Fixed in: v1.2.4
    Details: Buffer overflow in Parse function
    Your code calls: lib.Parse (main.go:42)
```

## CI Integration

```yaml
- name: Run govulncheck
  run: |
    go install golang.org/x/vuln/cmd/govulncheck@latest
    govulncheck ./...
```

## Key Points

- Checks actual call graphs, not just imports
- Uses Go vulnerability database (vuln.go.dev)
- Fix by updating: `go get github.com/example/lib@latest`
- Run regularly in CI (weekly or on every PR)
