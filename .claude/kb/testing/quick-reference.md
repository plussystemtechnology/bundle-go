# Testing — Quick Reference

## Test Command Cheat Sheet

```bash
# Run all tests with race detector
go test -race ./...

# Run specific package
go test -race ./app/service/...

# Run with coverage
go test -race -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run specific test by name
go test -run TestPatientService_Create ./app/service/

# Run benchmarks
go test -bench=. -benchmem ./pkg/...

# Update golden files
go test -update-golden ./adapter/http/...

# Run fuzz test (1 minute)
go test -fuzz=FuzzValidateCPF -fuzztime=1m ./domain/patient/
```

## Table-Driven Test Template

```go
func TestFunctionName(t *testing.T) {
    tests := []struct {
        name    string
        input   InputType
        want    OutputType
        wantErr bool
    }{
        {name: "success case", input: validInput, want: expectedOutput},
        {name: "error case", input: badInput, wantErr: true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := FunctionUnderTest(tt.input)
            if tt.wantErr {
                assert.Error(t, err)
                return
            }
            assert.NoError(t, err)
            assert.Equal(t, tt.want, got)
        })
    }
}
```

## Mock Interface Template

```go
type mockPatientRepo struct {
    findByIDFn  func(ctx context.Context, id string) (*patient.Patient, error)
    saveFn      func(ctx context.Context, p *patient.Patient) error
}

func (m *mockPatientRepo) FindByID(ctx context.Context, id string) (*patient.Patient, error) {
    if m.findByIDFn != nil { return m.findByIDFn(ctx, id) }
    return nil, nil
}
func (m *mockPatientRepo) Save(ctx context.Context, p *patient.Patient) error {
    if m.saveFn != nil { return m.saveFn(ctx, p) }
    return nil
}
```

## HTTP Test Template

```go
func TestHandler_Get(t *testing.T) {
    router := gin.New()
    handler := NewPatientHandler(mockSvc, zap.NewNop())
    router.GET("/patients/:id", handler.Get)

    w := httptest.NewRecorder()
    req := httptest.NewRequest(http.MethodGet, "/patients/123", nil)
    router.ServeHTTP(w, req)

    assert.Equal(t, http.StatusOK, w.Code)
    // assert body...
}
```

## testcontainers Postgres Template

```go
func setupTestDB(t *testing.T) *pgxpool.Pool {
    t.Helper()
    ctx := context.Background()
    c, err := postgres.Run(ctx, "postgres:16-alpine",
        postgres.WithDatabase("testdb"),
        postgres.WithUsername("test"),
        postgres.WithPassword("test"),
        testcontainers.WithWaitStrategy(wait.ForListeningPort("5432/tcp")),
    )
    require.NoError(t, err)
    t.Cleanup(func() { _ = c.Terminate(context.Background()) })

    dsn, _ := c.ConnectionString(ctx, "sslmode=disable")
    pool, err := pgxpool.New(ctx, dsn)
    require.NoError(t, err)
    return pool
}
```

## Assert Cheat Sheet (testify)

```go
assert.Equal(t, expected, actual)
assert.NotNil(t, value)
assert.Nil(t, err)
assert.Error(t, err)
assert.NoError(t, err)
assert.True(t, cond)
assert.False(t, cond)
assert.Contains(t, slice, element)
assert.ErrorIs(t, err, target)
assert.ErrorAs(t, err, &target)
assert.EqualError(t, err, "message")
assert.Len(t, slice, 3)
assert.Empty(t, slice)

// Fatal (stops test immediately)
require.NoError(t, err)    // use for setup steps
require.NotNil(t, result)
```

## What To Test

| Layer         | Test Type     | Focus                              |
|---------------|---------------|------------------------------------|
| domain/       | Unit          | Business rules, validation         |
| app/service/  | Unit + mocks  | Orchestration, error paths         |
| adapter/db/   | Integration   | SQL queries, testcontainers        |
| adapter/http/ | HTTP (unit)   | Status codes, response bodies      |
| pkg/          | Unit          | Utilities, edge cases              |
| Benchmarks    | Benchmark     | Hot paths, allocations             |
