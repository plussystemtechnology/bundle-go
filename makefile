											# makefile - CI/CD optimized version

	# Variables
APP_NAME := is-person
BUILD_DIR := bin
GO_TAGS ?=
       DOCKER_COMPOSE := docker compose
GO := go
GO_VERSION ?= $(shell grep '^go ' go.mod | awk '{print $$2}')
LOCAL_TOOL_BIN ?= $(CURDIR)/bin/tools
GOPATH_BIN ?= $(shell $(GO) env GOPATH)/bin
GOCACHE ?= /tmp/go-build
GO_BUILD_FLAGS ?= -buildvcs=false
XDG_CACHE_HOME ?= /tmp/.cache
GOLANGCI_LINT_CACHE ?= $(XDG_CACHE_HOME)/golangci-lint

export PATH := $(LOCAL_TOOL_BIN):$(GOPATH_BIN):$(PATH)
export GOCACHE
export XDG_CACHE_HOME
export GOLANGCI_LINT_CACHE

# Default environment variables
DB_USER ?= usrperson
DB_PASS ?= passperson
DB_NAME ?= dbperson
DB_HOST ?= postgres
DB_PORT ?= 5432

define install_tool_if_missing
	@mkdir -p "$(LOCAL_TOOL_BIN)" "$(GOCACHE)" "$(XDG_CACHE_HOME)" "$(GOLANGCI_LINT_CACHE)"
	@if command -v $(1) >/dev/null 2>&1; then \
		echo "✅ $(1) already installed"; \
	else \
		echo "⬇️ Installing $(1)..."; \
		GOBIN="$(LOCAL_TOOL_BIN)" GOTOOLCHAIN=go$(GO_VERSION) $(GO) install $(2) || { \
			echo "❌ Failed to install $(1). Run ./scripts/setup-codex.sh with internet access."; \
			exit 1; \
		}; \
	fi
endef

.PHONY: tool-staticcheck
tool-staticcheck:
	$(call install_tool_if_missing,staticcheck,honnef.co/go/tools/cmd/staticcheck@latest)

.PHONY: tool-golangci-lint
tool-golangci-lint:
	$(call install_tool_if_missing,golangci-lint,github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.10.1)

.PHONY: tool-gosec
tool-gosec:
	$(call install_tool_if_missing,gosec,github.com/securego/gosec/v2/cmd/gosec@latest)

.PHONY: tool-govulncheck
tool-govulncheck:
	$(call install_tool_if_missing,govulncheck,golang.org/x/vuln/cmd/govulncheck@latest)

.PHONY: tool-gotestsum
tool-gotestsum:
	$(call install_tool_if_missing,gotestsum,gotest.tools/gotestsum@latest)

.PHONY: tool-gocover-cobertura
tool-gocover-cobertura:
	$(call install_tool_if_missing,gocover-cobertura,github.com/t-yuki/gocover-cobertura@latest)

.PHONY: tool-swag
tool-swag:
	$(call install_tool_if_missing,swag,github.com/swaggo/swag/cmd/swag@v1.16.6)

.PHONY: tool-sqlc
tool-sqlc:
	$(call install_tool_if_missing,sqlc,github.com/sqlc-dev/sqlc/cmd/sqlc@latest)

.PHONY: tool-protoc-gen-go
tool-protoc-gen-go:
	$(call install_tool_if_missing,protoc-gen-go,google.golang.org/protobuf/cmd/protoc-gen-go@latest)
	$(call install_tool_if_missing,protoc-gen-go-grpc,google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest)

.PHONY: help
help: ## Show this help message
		@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ==================== DEVELOPMENT ====================
.PHONY: setup
setup: ## Setup development environment
	@echo "🔧 Setting up development environment..."
	@cp .env.example .env
	@go mod download
	@go mod tidy

.PHONY: fmt
fmt: ## Format Go code
	@echo "🎨 Formatting code..."
	@gofmt -w .
	@go mod tidy

.PHONY: vet
vet: tool-staticcheck ## Run go vet and staticcheck
	@echo "🔍 Running go vet..."
	@go vet ./...
	@echo "🏗️ Checking architecture boundaries..."
	@./scripts/check_arch.sh
	@echo "🔎 Running staticcheck..."
	@staticcheck ./...

.PHONY: staticcheck
staticcheck: tool-staticcheck ## Run static analysis
	@echo "🔎 Running staticcheck..."
	@staticcheck ./...

.PHONY: lint
lint: tool-golangci-lint ## Run golangci-lint
	@echo "🔍 Running golangci-lint..."
	@golangci-lint run

.PHONY: test
test: tool-gocover-cobertura ## Run unit tests
	@echo "🧪 Running unit tests..."
	@mkdir -p $(BUILD_DIR)
	@go test -coverprofile=$(BUILD_DIR)/coverage.out ./...
	@gocover-cobertura < $(BUILD_DIR)/coverage.out > $(BUILD_DIR)/report.xml

.PHONY: test-race
test-race: ## Run unit tests with the race detector
	@echo "🧪 Running race detector tests..."
	@CGO_ENABLED=1 $(GO) test -race ./...

.PHONY: test-integration
test-integration: ## Run integration tests
	@echo "🔗 Running integration tests..."
	@go test -tags=integration -timeout=15m ./integration/...

.PHONY: coverage
coverage: test ## Generate test coverage report
	@echo "📊 Generating coverage report..."
	@go tool cover -html=$(BUILD_DIR)/coverage.out -o $(BUILD_DIR)/coverage.html
	@echo "Coverage report: $(BUILD_DIR)/coverage.html"

.PHONY: bench
bench: ## Run benchmarks
	@echo "⚡ Running benchmarks..."
	@go test -bench=. -benchmem ./...

.PHONY: check-go-version
check-go-version: ## Ensure the Go version matches GO_VERSION
	@echo "🔍 Checking Go version..."
	@current=$$($(GO) version | awk '{print $$3}' | sed 's/go//'); \
	if [ "$$current" != "$(GO_VERSION)" ]; then \
	echo "❌ Expected Go $(GO_VERSION), got $$current"; \
	exit 1; \
	else \
	echo "✅ Using Go $$current"; \
	fi

# ==================== RUN ====================
.PHONY: run
run: ## Start the application locally
	@echo "Running application..."
	@$(GO) run -tags="$(GO_TAGS)" ./cmd/api

# ==================== BUILD ====================
.PHONY: build
build: gen-docs ## Build the application
	@echo "🏗️ Building application..."
	@mkdir -p $(BUILD_DIR)
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GO) build \
	$(GO_BUILD_FLAGS) \
	-tags="$(GO_TAGS)" \
	-ldflags="-w -s -X main.BuildInfo=$(shell git describe --tags --always)" \
	-o $(BUILD_DIR)/$(APP_NAME) \
	./cmd/api

.PHONY: build-race
build-race: gen-docs ## Build with race detection
	@echo "🏗️ Building with race detection..."
	@mkdir -p $(BUILD_DIR)
	@CGO_ENABLED=1 $(GO) build -race \
	$(GO_BUILD_FLAGS) \
	-tags="$(GO_TAGS)" \
	-ldflags="-X main.BuildInfo=$(shell git describe --tags --always)" \
	-o $(BUILD_DIR)/$(APP_NAME) \
	./cmd/api



.PHONY: gen-docs
gen-docs: tool-swag ## Generate Swagger documentation (YAML only)
	@echo "📚 Generating Swagger documentation..."
	@swag init -g ./cmd/api/main.go -o cmd/docs --outputTypes yaml

.PHONY: sqlc
sqlc: tool-sqlc ## Generate sqlc query code
	@echo "🗄️ Generating sqlc code..."
	@sqlc generate -f db/sqlc.yaml

.PHONY: sqlc-check
sqlc-check: tool-sqlc ## Ensure sqlc generated code is up to date
	@echo "🔍 Checking sqlc generated code..."
	@sqlc diff -f db/sqlc.yaml

.PHONY: proto
proto: tool-protoc-gen-go ## Generate protobuf/gRPC code
	@echo "📡 Generating protobuf/gRPC code..."
	@protoc --go_out=. --go_opt=paths=source_relative \
		--go-grpc_out=. --go-grpc_opt=paths=source_relative \
		api/proto/*.proto

.PHONY: generate
generate: gen-docs sqlc proto ## Run all code generation
	@echo "✅ All code generation completed!"

.PHONY: docs
docs: gen-docs ## Generate API documentation
	@echo "📚 Generating API documentation..."

.PHONY: swagger-json
swagger-json: ## Generate swagger.json from swagger.yaml
	@echo "📦 Generating swagger.json from swagger.yaml..."
	@go install github.com/mikefarah/yq/v4@latest
	@yq eval -o=json cmd/docs/swagger.yaml > cmd/docs/swagger.json


.PHONY: gen-docs-check
gen-docs-check: ## Ensure Swagger documentation is up to date
	@echo "🔍 Checking Swagger documentation..."
	@tmpdir=$$(mktemp -d); \
	swag init -g ./cmd/api/main.go -o $$tmpdir >/dev/null; \
	diff -u cmd/docs/swagger.yaml $$tmpdir/swagger.yaml; \
	rm -rf $$tmpdir
	
.PHONY: docs-watch
docs-watch: ## Watch handlers and regenerate docs on changes
	@echo "👀 Watching handlers for changes..."
	@while inotifywait -r -e close_write,create,delete,move internal/adapter/http/handler cmd/api; do \
		$(MAKE) docs; \
	done

# ==================== DOCKER ====================
.PHONY: docker-build
docker-build: ## Build Docker image for amd64 and arm64
	@echo "🐳 Building Docker image for linux/amd64 and linux/arm64..."
	@docker buildx build --platform linux/amd64,linux/arm64 --load -t $(APP_NAME):latest .

.PHONY: docker-up
docker-up: ## Start services with docker-compose
	@echo "🚀 Starting services..."
	@$(DOCKER_COMPOSE) up -d

.PHONY: docker-down
docker-down: ## Stop services
	@echo "🛑 Stopping services..."
	@$(DOCKER_COMPOSE) down

.PHONY: docker-logs
docker-logs: ## Show service logs
	@$(DOCKER_COMPOSE) logs -f


.PHONY: signoz
signoz: ## Start SigNoz stack and import dashboards
	@echo "🚀 Starting SigNoz stack..."
	@docker info >/dev/null 2>&1 || { echo "🐳 Docker daemon not running"; exit 1; }
	@docker compose -f deploy/docker-compose-signoz.yml up -d
	@status=$$?; \
	if [ "$$status" -eq 0 ]; then \
	        if [ "$(IMPORT_DASHBOARDS)" != "false" ]; then \
	                echo "📊 Importing dashboards..."; \
	                scripts/import_dashboards.sh; \
	                echo "🚨 Importing alerts..."; \
	                scripts/import_alerts.sh; \
	        else \
	                echo "Skipping dashboard import (IMPORT_DASHBOARDS=false)"; \
	        fi; \
	else \
	        exit $$status; \
	fi

.PHONY: signoz-import
signoz-import: ## Import dashboards and alerts into SigNoz
	@echo "📊 Importing dashboards..."
	scripts/import_dashboards.sh
	@echo "🚨 Importing alerts..."
	scripts/import_alerts.sh

.PHONY: signoz-watch
signoz-watch: ## Watch docs/signoz and import on changes
	@echo "👀 Watching docs/signoz for changes..."
	@while inotifywait -r -e close_write,create,delete,move docs/signoz; do \
		$(MAKE) signoz-import; \
done

.PHONY: signoz-capture
signoz-capture: ## Export dashboards from SigNoz into docs/signoz
	@echo "📥 Exporting dashboards..."
	@scripts/export_dashboards.sh
# ==================== DATABASE ====================
.PHONY: migrate
migrate: ## Run database migrations
	@echo "🔄 Running migrations..."
	@echo "Using database configuration:"
	@echo "  Host: $(DB_HOST)"
	@echo "  Port: $(DB_PORT)"
	@echo "  User: $(DB_USER)"
	@echo "  Database: $(DB_NAME)"
	@echo ""
	@echo "🐳 Starting PostgreSQL container..."
	@DB_PORT=$(DB_PORT) DB_USER=$(DB_USER) DB_PASS=$(DB_PASS) DB_NAME=$(DB_NAME) \
	    $(DOCKER_COMPOSE) up -d postgres --wait
	@echo ""
	@echo "⏳ Waiting for database to be ready..."
	@timeout 60s bash -c 'while ! $(DOCKER_COMPOSE) exec postgres pg_isready -U $(DB_USER) -d $(DB_NAME) -h localhost -p 5432; do sleep 2; echo "Waiting..."; done'
	@echo ""
	@echo "🚀 Running migrations in container..."
	@$(DOCKER_COMPOSE) run --rm \
	    -e API_MODE=dev \
	    -e API_PORT=3000 \
	    -e GRPC_PORT=5000 \
	    -e SWAGGER_HOST=localhost:3000 \
	    -e DB_HOST=postgres \
	    -e DB_PORT=5432 \
	    -e DB_USER=$(DB_USER) \
	    -e DB_PASS=$(DB_PASS) \
	    -e DB_NAME=$(DB_NAME) \
	    -e JWT_SECRET=example-secret-key-replace-in-prod-1234567890 \
	    -e OTEL_REQUIRE_COLLECTOR=false \
	    $(APP_NAME)-is-person-api ./$(APP_NAME) migrate up
	@echo "✅ Migrations completed successfully!"

.PHONY: migrate-down
migrate-down: ## Rollback database migrations
	@echo "🔄 Rolling back migrations..."
	@$(DOCKER_COMPOSE) run --rm \
	    -e API_MODE=dev \
	    -e DB_HOST=postgres \
	    -e DB_USER=$(DB_USER) \
	    -e DB_PASS=$(DB_PASS) \
	    -e DB_NAME=$(DB_NAME) \
	    -e JWT_SECRET=example-secret-key-replace-in-prod-1234567890 \
	    -e OTEL_REQUIRE_COLLECTOR=false \
	    $(APP_NAME)-is-person-api ./$(APP_NAME) migrate down

.PHONY: migrate-reset
migrate-reset: migrate-down migrate ## Reset database migrations

# ==================== QUALITY CHECKS ====================

.PHONY: security-tools
security-tools: tool-gosec tool-govulncheck ## Install gosec and govulncheck
	@echo "🔧 Installing security tools..."

.PHONY: security
security: security-tools ## Run security checks
	@echo "🔒 Running security checks..."
	@gosec -exclude-generated -conf .gosec.json -severity=high ./...
	@./scripts/check_govuln.sh

.PHONY: gosec
gosec: security-tools ## Run gosec security scanner
	@echo "🔒 Running gosec security scan..."
	@gosec -exclude-generated -conf .gosec.json ./...

.PHONY: logger-check
logger-check: ## Check logger context usage
	@echo "📝 Checking logger context usage..."
	@if [ -f "scripts/check_logger_context.sh" ]; then \
	    chmod +x scripts/check_logger_context.sh; \
	    ./scripts/check_logger_context.sh; \
	else \
	    echo "Logger check script not found"; \
	fi

.PHONY: metrics-check
metrics-check: ## Check metrics documentation
	@echo "📊 Checking metrics documentation..."
	@if [ -f "scripts/check_metrics_doc.sh" ]; then \
	    chmod +x scripts/check_metrics_doc.sh; \
	    ./scripts/check_metrics_doc.sh; \
	else \
	    echo "Metrics check script not found"; \
	fi

.PHONY: error-docs-check
error-docs-check: ## Ensure error codes are documented
	@echo "🚨 Checking error code documentation..."
	@if [ -f "scripts/check_error_docs.sh" ]; then \
		chmod +x scripts/check_error_docs.sh; \
		./scripts/check_error_docs.sh; \
	else \
		echo "Error docs check script not found"; \
	fi
.PHONY: env-docs
env-docs: ## Generate environment documentation
	@echo "📋 Generating environment documentation..."
	@if [ -f "scripts/generate_env_docs.sh" ]; then \
	chmod +x scripts/generate_env_docs.sh; \
	./scripts/generate_env_docs.sh environment.md; \
	else \
	echo "Environment docs script not found"; \
	fi

.PHONY: env-docs-check
env-docs-check: ## Ensure environment.md is up to date
	@echo "🔍 Checking environment documentation..."
	@$(MAKE) --no-print-directory env-docs > /tmp/env_docs.md
	@diff -u environment.md /tmp/env_docs.md
		
.PHONY: env-usage-check
env-usage-check: ## Ensure adapters do not access env vars directly
	@echo "🔍 Checking configuration usage..."
	@if [ -f "scripts/check_env_usage.sh" ]; then \
	chmod +x scripts/check_env_usage.sh; \
	./scripts/check_env_usage.sh; \
	else \
	echo "Environment usage check script not found"; \
	fi

# ==================== LOAD TESTING ====================
.PHONY: loadtest
loadtest: ## Run load tests
	@echo "⚡ Running load tests..."
	@if command -v k6 >/dev/null 2>&1; then \
                    if [ -f "loadtest/loadtest_default.ts" ]; then k6 run loadtest/loadtest_default.ts; fi; \
                    if [ -f "loadtest/loadtest_recommended.ts" ]; then k6 run loadtest/loadtest_recommended.ts; fi; \
                    if [ -f "loadtest/loadtest_api_flow.ts" ]; then k6 run loadtest/loadtest_api_flow.ts; fi; \
                    if [ -f "loadtest/grpc_flow.ts" ]; then k6 run loadtest/grpc_flow.ts; fi; \
                else \
                    echo "k6 not installed. Please install k6 to run load tests"; \
                fi

# ==================== CI/CD ====================
.PHONY: ci
ci: fmt vet staticcheck lint gen-docs-check test build ## Run CI pipeline locally
	@echo "✅ CI pipeline completed successfully!"

.PHONY: ci-full
ci-full: ci test-integration security coverage ## Run full CI pipeline
	@echo "✅ Full CI pipeline completed successfully!"

.PHONY: clean
clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@docker system prune -f

.PHONY: install-tools
install-tools: tool-golangci-lint tool-staticcheck tool-gosec tool-govulncheck tool-gotestsum tool-gocover-cobertura tool-swag tool-sqlc tool-protoc-gen-go ## Install development tools
	@echo "🔧 Installing development tools..."
	@echo "✅ Development tools installed!"
