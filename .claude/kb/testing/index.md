# Testing — NoxCare-Go

## Test Strategy

```
Unit tests      → app/service/, domain/  (fast, no I/O, mocks)
Integration     → adapter/db/, adapter/kafka/ (testcontainers)
HTTP tests      → adapter/http/handler/ (httptest, no real server)
E2E / contract  → cmd/ level (optional, full stack)
Benchmarks      → pkg/, domain/ hot paths
```

## Test Pyramid

```
     /         \
    / E2E (few) \
   /─────────────\
  / Integration   \
 / (testcontainers)\
/───────────────────\
  Unit Tests (many)
  (fast, isolated)
```

## Key Testing Rules

1. Use **table-driven tests** (`[]struct{ ... }`) for any non-trivial function
2. Run with **`-race`** always in CI
3. Prefer **interface mocks** over concrete stubs for app/ tests
4. Use **httptest** for HTTP handler tests — no running server needed
5. Use **testcontainers-go** for DB/Kafka integration tests
6. Use **golden files** for large expected outputs (HTML, JSON blobs)
7. Add **benchmarks** for hot paths in pkg/ and domain/

## Test File Layout

```
app/service/
    patient_service.go
    patient_service_test.go   // unit, mocks
adapter/db/repo/
    patient_repo.go
    patient_repo_test.go      // integration, testcontainers
adapter/http/handler/
    patient_handler.go
    patient_handler_test.go   // httptest
domain/patient/
    patient.go
    patient_test.go           // pure unit
```

## Quick Navigation

- `concepts/table-driven.md` — standard table-driven test structure
- `concepts/mocking.md` — mock interfaces, hand-written vs mockery
- `concepts/test-helpers.md` — test fixtures, builders, setup helpers
- `concepts/fuzzing.md` — Go 1.18+ fuzz testing
- `patterns/http-testing.md` — httptest.NewRecorder + Gin
- `patterns/db-testing.md` — testcontainers Postgres
- `patterns/testcontainers.md` — testcontainers-go setup
- `patterns/golden-files.md` — golden file comparison
- `patterns/benchmark.md` — benchmarks and profiling
