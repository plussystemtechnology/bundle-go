# GitHub Actions for Go

## Workflow Structure

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
          cache: true
      # ... steps
```

## Caching

`actions/setup-go` caches `~/go/pkg/mod` automatically when `cache: true`.

For additional caching:

```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.cache/golangci-lint
    key: lint-${{ hashFiles('.golangci.yml') }}
```

## Matrix Strategy

```yaml
strategy:
  matrix:
    go-version: ['1.21', '1.22']
    os: [ubuntu-latest, macos-latest]
```

## Secrets

```yaml
env:
  DB_URL: ${{ secrets.TEST_DB_URL }}
```
