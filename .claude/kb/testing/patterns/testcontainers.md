# Testcontainers-Go

## Overview

testcontainers-go starts real Docker containers in tests, providing authentic
infrastructure (Postgres, Kafka, Redis) without mocking infrastructure details.

```bash
go get github.com/testcontainers/testcontainers-go
go get github.com/testcontainers/testcontainers-go/modules/postgres
go get github.com/testcontainers/testcontainers-go/modules/kafka
go get github.com/testcontainers/testcontainers-go/modules/redis
```

## PostgreSQL Container

```go
// testutil/containers/postgres.go
package containers

import (
    "context"
    "testing"
    "time"

    "github.com/jackc/pgx/v5/pgxpool"
    "github.com/stretchr/testify/require"
    tcpostgres "github.com/testcontainers/testcontainers-go/modules/postgres"
    "github.com/testcontainers/testcontainers-go"
    "github.com/testcontainers/testcontainers-go/wait"
)

type PostgresContainer struct {
    Container tcpostgres.PostgresContainer
    Pool      *pgxpool.Pool
    DSN       string
}

func NewPostgres(t *testing.T, initScripts ...string) *PostgresContainer {
    t.Helper()
    ctx := context.Background()

    opts := []testcontainers.ContainerCustomizer{
        tcpostgres.WithDatabase("noxcare_test"),
        tcpostgres.WithUsername("postgres"),
        tcpostgres.WithPassword("postgres"),
        testcontainers.WithWaitStrategy(
            wait.ForLog("database system is ready to accept connections").
                WithOccurrence(2).
                WithStartupTimeout(60*time.Second),
        ),
    }
    for _, script := range initScripts {
        opts = append(opts, tcpostgres.WithInitScripts(script))
    }

    c, err := tcpostgres.Run(ctx, "postgres:16-alpine", opts...)
    require.NoError(t, err)

    t.Cleanup(func() { _ = c.Terminate(context.Background()) })

    dsn, err := c.ConnectionString(ctx, "sslmode=disable")
    require.NoError(t, err)

    pool, err := pgxpool.New(ctx, dsn)
    require.NoError(t, err)

    t.Cleanup(func() { pool.Close() })

    return &PostgresContainer{Container: *c, Pool: pool, DSN: dsn}
}
```

## Kafka Container

```go
// testutil/containers/kafka.go
package containers

import (
    "context"
    "testing"

    "github.com/stretchr/testify/require"
    tckafka "github.com/testcontainers/testcontainers-go/modules/kafka"
    "github.com/testcontainers/testcontainers-go"
    "github.com/testcontainers/testcontainers-go/wait"
    "github.com/twmb/franz-go/pkg/kgo"
)

type KafkaContainer struct {
    Brokers []string
}

func NewKafka(t *testing.T) *KafkaContainer {
    t.Helper()
    ctx := context.Background()

    c, err := tckafka.Run(ctx, "confluentinc/confluent-local:7.5.0",
        tckafka.WithClusterID("test-cluster"),
        testcontainers.WithWaitStrategy(wait.ForListeningPort("9093/tcp")),
    )
    require.NoError(t, err)
    t.Cleanup(func() { _ = c.Terminate(context.Background()) })

    brokers, err := c.Brokers(ctx)
    require.NoError(t, err)

    return &KafkaContainer{Brokers: brokers}
}

func (k *KafkaContainer) NewClient(t *testing.T, opts ...kgo.Opt) *kgo.Client {
    t.Helper()
    allOpts := append([]kgo.Opt{kgo.SeedBrokers(k.Brokers...)}, opts...)
    client, err := kgo.NewClient(allOpts...)
    require.NoError(t, err)
    t.Cleanup(func() { client.Close() })
    return client
}
```

## Redis Container

```go
// testutil/containers/redis.go
package containers

import (
    "context"
    "fmt"
    "testing"

    "github.com/redis/go-redis/v9"
    "github.com/stretchr/testify/require"
    tcredis "github.com/testcontainers/testcontainers-go/modules/redis"
)

func NewRedis(t *testing.T) *redis.Client {
    t.Helper()
    ctx := context.Background()

    c, err := tcredis.Run(ctx, "redis:7-alpine")
    require.NoError(t, err)
    t.Cleanup(func() { _ = c.Terminate(context.Background()) })

    host, err := c.Host(ctx)
    require.NoError(t, err)
    port, err := c.MappedPort(ctx, "6379")
    require.NoError(t, err)

    client := redis.NewClient(&redis.Options{
        Addr: fmt.Sprintf("%s:%s", host, port.Port()),
    })
    t.Cleanup(func() { _ = client.Close() })

    return client
}
```

## Usage in Tests

```go
// adapter/db/repo/patient_repo_test.go
func TestPatientRepo_Integration(t *testing.T) {
    pg := containers.NewPostgres(t, "testdata/schema.sql")
    r  := repo.NewPatientRepo(pg.Pool, zap.NewNop())

    p := &patient.Patient{ID: "p-1", Name: "Alice", CPF: "123.456.789-09"}
    require.NoError(t, r.Save(context.Background(), p))

    found, err := r.FindByID(context.Background(), p.ID)
    require.NoError(t, err)
    assert.Equal(t, "Alice", found.Name)
}

// adapter/kafka/publisher/patient_publisher_test.go
func TestPatientKafkaPublisher(t *testing.T) {
    kc := containers.NewKafka(t)

    producer := kc.NewClient(t)
    publisher := publisher.NewPatientKafkaPublisher(producer, "test.patient.events")

    p := &patient.Patient{ID: "p-1", Name: "Alice"}
    err := publisher.PublishCreated(context.Background(), p)
    require.NoError(t, err)

    // Consume and verify
    consumer := kc.NewClient(t,
        kgo.ConsumeTopics("test.patient.events"),
        kgo.ConsumeResetOffset(kgo.NewOffset().AtStart()),
    )
    fetches := consumer.PollFetches(context.Background())
    require.NoError(t, fetches.Err())
    // assert message content...
}
```

## Reuse Container Across Tests (Performance)

Containers are slow to start. Reuse them at the package level via `TestMain`:

```go
// adapter/db/repo/main_test.go
var sharedPG *containers.PostgresContainer

func TestMain(m *testing.M) {
    // Can't use t here; manage cleanup manually
    ctx := context.Background()
    c, _ := tcpostgres.Run(ctx, "postgres:16-alpine", ...)
    dsn, _ := c.ConnectionString(ctx, "sslmode=disable")
    pool, _ := pgxpool.New(ctx, dsn)
    sharedPG = &containers.PostgresContainer{Pool: pool}

    code := m.Run()

    _ = c.Terminate(ctx)
    os.Exit(code)
}
```
