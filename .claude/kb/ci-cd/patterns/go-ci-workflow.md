# Complete Go CI Workflow

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
          cache: true
      - uses: golangci/golangci-lint-action@v4
        with:
          version: latest

  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: test
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
        ports: ['5432:5432']
        options: >-
          --health-cmd "pg_isready -U test"
          --health-interval 5s
          --health-retries 5
      redis:
        image: redis:7-alpine
        ports: ['6379:6379']
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
          cache: true
      - run: go test -race -coverprofile=coverage.out -covermode=atomic ./...
        env:
          DB_URL: postgres://test:test@localhost:5432/test?sslmode=disable
          REDIS_ADDR: localhost:6379

  build:
    runs-on: ubuntu-latest
    needs: [lint, test]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
          cache: true
      - run: CGO_ENABLED=0 go build -o bin/api ./cmd/api

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - run: |
          go install github.com/securego/gosec/v2/cmd/gosec@latest
          gosec ./...
      - run: |
          go install golang.org/x/vuln/cmd/govulncheck@latest
          govulncheck ./...
```
