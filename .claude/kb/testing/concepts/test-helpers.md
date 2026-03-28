# Test Helpers

## t.Helper()

Mark a function as a test helper so failures show the caller's line, not the helper's:

```go
func requirePatientExists(t *testing.T, repo port.PatientRepository, id string) *patient.Patient {
    t.Helper()  // ALWAYS include in test helper functions
    p, err := repo.FindByID(context.Background(), id)
    require.NoError(t, err, "patient should exist: %s", id)
    require.NotNil(t, p)
    return p
}
```

## Test Fixtures / Builders

```go
// testutil/fixtures/patient.go
package fixtures

import (
    "time"
    "github.com/org/bundle-go/domain/patient"
)

type PatientBuilder struct {
    p patient.Patient
}

func NewPatient() *PatientBuilder {
    return &PatientBuilder{
        p: patient.Patient{
            ID:        "p-test-001",
            Name:      "Test Patient",
            CPF:       "123.456.789-09",
            BirthDate: time.Date(1990, 1, 15, 0, 0, 0, 0, time.UTC),
            Active:    true,
            CreatedAt: time.Now(),
            UpdatedAt: time.Now(),
        },
    }
}

func (b *PatientBuilder) WithID(id string) *PatientBuilder {
    b.p.ID = id
    return b
}
func (b *PatientBuilder) WithName(name string) *PatientBuilder {
    b.p.Name = name
    return b
}
func (b *PatientBuilder) WithCPF(cpf string) *PatientBuilder {
    b.p.CPF = cpf
    return b
}
func (b *PatientBuilder) Inactive() *PatientBuilder {
    b.p.Active = false
    return b
}
func (b *PatientBuilder) Build() *patient.Patient {
    p := b.p
    return &p
}
```

Usage:
```go
p := fixtures.NewPatient().WithName("Alice").WithID("p-alice").Build()
inactive := fixtures.NewPatient().Inactive().Build()
```

## Test Logger

```go
// testutil/logger.go
package testutil

import "go.uber.org/zap"

// TestLogger returns a no-op logger for tests
func TestLogger() *zap.Logger { return zap.NewNop() }

// VerboseLogger returns a development logger that writes to test output
func VerboseLogger(t testing.TB) *zap.Logger {
    t.Helper()
    cfg := zap.NewDevelopmentConfig()
    cfg.OutputPaths = []string{"stdout"}
    l, _ := cfg.Build()
    return l
}
```

## Test Config

```go
// testutil/config.go
package testutil

import (
    "time"
    "github.com/org/bundle-go/config"
)

func TestConfig() *config.AppConfig {
    return &config.AppConfig{
        Server: config.ServerConfig{Addr: ":0"},
        Cache:  config.CacheConfig{PatientTTL: 5 * time.Minute},
    }
}
```

## Database Helpers for Integration Tests

```go
// testutil/db.go
package testutil

import (
    "context"
    "testing"

    "github.com/jackc/pgx/v5/pgxpool"
    "github.com/stretchr/testify/require"
)

// TruncateTables clears specified tables between tests
func TruncateTables(t *testing.T, db *pgxpool.Pool, tables ...string) {
    t.Helper()
    for _, table := range tables {
        _, err := db.Exec(context.Background(),
            "TRUNCATE TABLE "+table+" RESTART IDENTITY CASCADE")
        require.NoError(t, err, "truncate %s", table)
    }
}

// InsertPatient inserts a test patient and returns it
func InsertPatient(t *testing.T, db *pgxpool.Pool, p *patient.Patient) {
    t.Helper()
    _, err := db.Exec(context.Background(),
        `INSERT INTO patients (id, name, cpf, active, created_at, updated_at)
         VALUES ($1, $2, $3, $4, NOW(), NOW())`,
        p.ID, p.Name, p.CPF, p.Active,
    )
    require.NoError(t, err)
}
```

## TestMain — Shared Setup

When all tests in a package need expensive setup (e.g., one DB container per package):

```go
// adapter/db/repo/main_test.go
package repo_test

import (
    "context"
    "os"
    "testing"

    "github.com/jackc/pgx/v5/pgxpool"
    "go.uber.org/goleak"
)

var testDB *pgxpool.Pool

func TestMain(m *testing.M) {
    // Detect goroutine leaks
    opts := goleak.IgnoreCurrentGoroutines()

    // Start shared container
    var cleanup func()
    testDB, cleanup = testutil.SetupPostgres()

    code := m.Run()
    cleanup()

    if err := goleak.Find(opts); err != nil {
        os.Exit(1)
    }
    os.Exit(code)
}
```

## t.Cleanup — Resource Teardown

```go
func TestPatientRepo_Save(t *testing.T) {
    pool := setupTestDB(t)  // this calls t.Cleanup internally

    t.Cleanup(func() {
        // Additional cleanup after test
        testutil.TruncateTables(t, pool, "patients")
    })

    repo := repo.NewPatientRepo(pool, zap.NewNop())
    // ...
}
```

## Parallelism in Integration Tests

```go
func TestPatientRepo(t *testing.T) {
    pool := setupTestDB(t)  // shared pool

    t.Run("save and find", func(t *testing.T) {
        t.Parallel()  // safe if using unique IDs per test
        repo := repo.NewPatientRepo(pool, zap.NewNop())
        p := fixtures.NewPatient().WithID("p-save-find").Build()
        // ...
    })
}
```

Use unique IDs (UUID or test-name-prefixed) to avoid conflicts in parallel DB tests.
