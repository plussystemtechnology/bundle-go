# Linting with golangci-lint

## What It Does

golangci-lint runs 100+ linters in parallel. Much faster than running each individually.

## Running

```bash
golangci-lint run          # current directory
golangci-lint run ./...    # all packages
golangci-lint run --fix    # auto-fix where possible
```

## Key Linters

| Linter | What It Checks |
|--------|---------------|
| `govet` | Suspicious constructs |
| `staticcheck` | Advanced analysis |
| `errcheck` | Unchecked errors |
| `gosimple` | Simplification suggestions |
| `unused` | Unused code |
| `ineffassign` | Ineffective assignments |
| `gosec` | Security issues |
| `goconst` | Repeated strings → constants |
| `gocyclo` | Cyclomatic complexity |
| `misspell` | Common misspellings |

## Suppressing Linter Warnings

```go
//nolint:errcheck // intentionally ignoring close error
defer file.Close()

//nolint:gosec // G104: test helper, error checking not needed
```
