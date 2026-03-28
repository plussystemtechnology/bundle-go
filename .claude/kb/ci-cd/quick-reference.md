# CI/CD Quick Reference

## Standard Go CI Pipeline

```text
Push/PR → Lint → Test → Build → Security → (Deploy)
```

## Makefile Targets

```makefile
make lint        # golangci-lint run
make test        # go test -race -cover ./...
make build       # CGO_ENABLED=0 go build ./cmd/api
make security    # gosec + govulncheck
make generate    # sqlc + protoc + swag
make docker      # docker build
make ci          # lint + test + build + security
```

## GitHub Actions Triggers

| Event | When | Use For |
|-------|------|---------|
| `push` (main) | Code merged | Deploy, release |
| `pull_request` | PR opened/updated | CI checks |
| `schedule` | Cron | Security scans |
| `workflow_dispatch` | Manual | Ad-hoc deploys |

## Key CI Checks

| Check | Tool | Must Pass |
|-------|------|-----------|
| Format | `gofmt -d .` | Yes |
| Lint | `golangci-lint run` | Yes |
| Vet | `go vet ./...` | Yes |
| Test | `go test -race ./...` | Yes |
| Build | `go build ./cmd/api` | Yes |
| Security | `gosec`, `govulncheck` | Yes |
| Coverage | `go test -coverprofile` | Advisory |
