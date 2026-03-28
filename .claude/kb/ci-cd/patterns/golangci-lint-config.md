# golangci-lint Configuration

## .golangci.yml

```yaml
run:
  timeout: 5m
  go: '1.22'

linters:
  enable:
    - govet
    - staticcheck
    - errcheck
    - gosimple
    - unused
    - ineffassign
    - gosec
    - goconst
    - gocyclo
    - misspell
    - bodyclose
    - noctx
    - sqlclosecheck
    - exportloopref
    - whitespace
    - predeclared

linters-settings:
  gocyclo:
    min-complexity: 15
  goconst:
    min-len: 3
    min-occurrences: 3
  errcheck:
    check-type-assertions: true
  gosec:
    excludes:
      - G104  # too noisy

issues:
  exclude-rules:
    - path: _test\.go
      linters:
        - gosec
        - errcheck
    - path: cmd/
      linters:
        - gocyclo
  max-issues-per-linter: 50
  max-same-issues: 5
```
