# Database Testing

## Overview

Test database repositories against a real PostgreSQL instance using testcontainers-go.
No in-memory SQLite — test against the same Postgres version used in production.

## Package-Level DB Setup (TestMain)

```go
// adapter/db/repo/main_test.go
package repo_test

import (
    "context"
    "os"
    "testing"

    "github.com/jackc/pgx/v5/pgxpool"
    tcpostgres "github.com/testcontainers/testcontainers-go/modules/postgres"
    "github.com/testcontainers/testcontainers-go/wait"
)

var testPool *pgxpool.Pool

func TestMain(m *testing.M) {
    ctx := context.Background()

    c, err := tcpostgres.Run(ctx, "postgres:16-alpine",
        tcpostgres.WithDatabase("noxcare_test"),
        tcpostgres.WithUsername("postgres"),
        tcpostgres.WithPassword("postgres"),
        tcpostgres.WithInitScripts("../../../migrations/schema.sql"),
        testcontainers.WithWaitStrategy(
            wait.ForLog("database system is ready to accept connections").
                WithOccurrence(2).
                WithStartupTimeout(30*time.Second),
        ),
    )
    if err != nil {
        panic("start test postgres: " + err.Error())
    }

    dsn, _ := c.ConnectionString(ctx, "sslmode=disable")
    testPool, err = pgxpool.New(ctx, dsn)
    if err != nil {
        panic("connect test db: " + err.Error())
    }

    code := m.Run()

    _ = c.Terminate(ctx)
    os.Exit(code)
}
```

## Per-Test Isolation (Truncate)

```go
// adapter/db/repo/patient_repo_test.go
package repo_test

import (
    "context"
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
    "go.uber.org/zap"
    "github.com/org/noxcare-go/adapter/db/repo"
    "github.com/org/noxcare-go/domain/patient"
)

func truncatePatients(t *testing.T) {
    t.Helper()
    _, err := testPool.Exec(context.Background(),
        "TRUNCATE TABLE patients RESTART IDENTITY CASCADE")
    require.NoError(t, err)
}

func TestPatientRepo_Save(t *testing.T) {
    truncatePatients(t)

    r := repo.NewPatientRepo(testPool, zap.NewNop())
    p := &patient.Patient{
        ID:     "p-save-001",
        Name:   "Alice",
        CPF:    "123.456.789-09",
        Active: true,
    }

    err := r.Save(context.Background(), p)
    require.NoError(t, err)

    found, err := r.FindByID(context.Background(), p.ID)
    require.NoError(t, err)
    assert.Equal(t, p.Name, found.Name)
    assert.Equal(t, p.CPF, found.CPF)
    assert.True(t, found.Active)
}

func TestPatientRepo_FindByID_NotFound(t *testing.T) {
    truncatePatients(t)

    r := repo.NewPatientRepo(testPool, zap.NewNop())
    _, err := r.FindByID(context.Background(), "nonexistent")

    require.Error(t, err)
    assert.ErrorIs(t, err, patient.ErrNotFound)
}

func TestPatientRepo_Delete(t *testing.T) {
    truncatePatients(t)

    r := repo.NewPatientRepo(testPool, zap.NewNop())
    p := &patient.Patient{ID: "p-del-001", Name: "Bob", CPF: "111.222.333-44", Active: true}

    require.NoError(t, r.Save(context.Background(), p))
    require.NoError(t, r.Delete(context.Background(), p.ID))

    _, err := r.FindByID(context.Background(), p.ID)
    assert.ErrorIs(t, err, patient.ErrNotFound)
}
```

## Transaction Test

```go
func TestPatientRepo_Transaction_Rollback(t *testing.T) {
    truncatePatients(t)

    r   := repo.NewPatientRepo(testPool, zap.NewNop())
    txm := repo.NewPgxTxManager(testPool)

    p1 := &patient.Patient{ID: "p-tx-1", Name: "Alice", CPF: "111.111.111-11"}
    p2 := &patient.Patient{ID: "p-tx-1", Name: "Bob", CPF: "222.222.222-22"}  // duplicate ID

    err := txm.WithTx(context.Background(), func(ctx context.Context) error {
        if err := r.Save(ctx, p1); err != nil { return err }
        return r.Save(ctx, p2)  // will fail: duplicate PK
    })

    require.Error(t, err)  // transaction rolled back

    // p1 should NOT be in DB (rolled back)
    _, findErr := r.FindByID(context.Background(), p1.ID)
    assert.ErrorIs(t, findErr, patient.ErrNotFound)
}
```

## Subtests with Shared DB

```go
func TestPatientRepo(t *testing.T) {
    // All subtests share testPool, use unique IDs to avoid conflicts
    t.Run("save", func(t *testing.T) {
        t.Parallel()
        r := repo.NewPatientRepo(testPool, zap.NewNop())
        p := &patient.Patient{ID: "p-save-" + uuid.New().String(), ...}
        require.NoError(t, r.Save(context.Background(), p))
    })

    t.Run("find not found", func(t *testing.T) {
        t.Parallel()
        r := repo.NewPatientRepo(testPool, zap.NewNop())
        _, err := r.FindByID(context.Background(), "p-does-not-exist")
        assert.ErrorIs(t, err, patient.ErrNotFound)
    })
}
```

## Skip If No DB Available

```go
func TestPatientRepo_Integration(t *testing.T) {
    if os.Getenv("INTEGRATION") == "" {
        t.Skip("skipping integration test: set INTEGRATION=1 to run")
    }
    // ... test
}
```

Run with: `INTEGRATION=1 go test -race ./adapter/db/...`
