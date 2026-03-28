# Release Automation

## GoReleaser

```yaml
# .goreleaser.yml
project_name: api
builds:
  - env: [CGO_ENABLED=0]
    goos: [linux, darwin]
    goarch: [amd64, arm64]
    main: ./cmd/api
    ldflags:
      - -s -w
      - -X main.version={{.Version}}
      - -X main.commit={{.Commit}}

dockers:
  - image_templates:
      - "myregistry/api:{{ .Tag }}"
      - "myregistry/api:latest"
    dockerfile: Dockerfile

changelog:
  sort: asc
  filters:
    exclude:
      - '^docs:'
      - '^chore:'
```

## GitHub Action

```yaml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - uses: goreleaser/goreleaser-action@v5
        with:
          args: release --clean
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
