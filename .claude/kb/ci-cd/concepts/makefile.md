# Makefile Patterns

## Standard Go Makefile

```makefile
.DEFAULT_GOAL := help
BINARY := api
VERSION := $(shell git describe --tags --always --dirty)

.PHONY: build
build: ## Build the binary
	CGO_ENABLED=0 go build -ldflags="-w -s -X main.version=$(VERSION)" -o bin/$(BINARY) ./cmd/api

.PHONY: test
test: ## Run tests with race detector
	go test -race -cover -coverprofile=coverage.out ./...

.PHONY: lint
lint: ## Run linter
	golangci-lint run

.PHONY: fmt
fmt: ## Format code
	gofmt -w .
	goimports -w .

.PHONY: vet
vet: ## Run go vet and staticcheck
	go vet ./...
	staticcheck ./...

.PHONY: ci
ci: fmt lint vet test build ## Run full CI pipeline

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
```

## Key Patterns

- `.PHONY` for all targets (not real files)
- `## Comment` for self-documenting help
- Use variables for binary name and version
- `ci` target chains all checks
