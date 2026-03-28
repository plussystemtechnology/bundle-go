# Factory Pattern

## Overview

A factory function creates and returns the correct implementation based on configuration
or runtime conditions. In Go it typically returns an interface, hiding which concrete type is used.

## Simple Factory: Cache Provider

```go
// adapter/cache/factory.go
package cache

import (
    "fmt"
    "time"

    "github.com/org/bundle-go/config"
    "github.com/org/bundle-go/port"
)

type Provider string

const (
    ProviderRedis  Provider = "redis"
    ProviderMemory Provider = "memory"
    ProviderNoop   Provider = "noop"
)

// NewCache returns the appropriate cache implementation for the given provider
func NewCache(provider Provider, cfg *config.CacheConfig) (port.Cache, error) {
    switch provider {
    case ProviderRedis:
        return NewRedisCache(cfg.Redis.Addr, cfg.Redis.Password, cfg.Redis.DB)
    case ProviderMemory:
        return NewMemoryCache(cfg.Memory.MaxEntries, cfg.Memory.DefaultTTL)
    case ProviderNoop:
        return NewNoopCache(), nil
    default:
        return nil, fmt.Errorf("unknown cache provider %q (valid: redis, memory, noop)", provider)
    }
}
```

Usage in bootstrap:
```go
cacheProvider := cache.Provider(cfg.Cache.Provider) // from env: "redis"
cacheStore, err := cache.NewCache(cacheProvider, &cfg.Cache)
if err != nil {
    return nil, fmt.Errorf("init cache: %w", err)
}
```

## Abstract Factory: Notification Sender

When you have a family of related objects to create together:

```go
// port/notification.go
type NotificationFactory interface {
    NewEmailSender() EmailSender
    NewSMSSender() SMSSender
    NewPushSender() PushSender
}

// adapter/notification/aws_factory.go
type AWSNotificationFactory struct {
    cfg *config.AWSConfig
}

func NewAWSNotificationFactory(cfg *config.AWSConfig) *AWSNotificationFactory {
    return &AWSNotificationFactory{cfg: cfg}
}

func (f *AWSNotificationFactory) NewEmailSender() port.EmailSender {
    return ses.NewSender(f.cfg.SES)
}
func (f *AWSNotificationFactory) NewSMSSender() port.SMSSender {
    return sns.NewSender(f.cfg.SNS)
}
func (f *AWSNotificationFactory) NewPushSender() port.PushSender {
    return pinpoint.NewSender(f.cfg.Pinpoint)
}

// adapter/notification/stub_factory.go — for testing
type StubNotificationFactory struct{}

func (f *StubNotificationFactory) NewEmailSender() port.EmailSender { return &noopEmailSender{} }
func (f *StubNotificationFactory) NewSMSSender() port.SMSSender     { return &noopSMSSender{} }
func (f *StubNotificationFactory) NewPushSender() port.PushSender   { return &noopPushSender{} }
```

## Registry Factory (plugin pattern)

Allows registering new implementations at package init time:

```go
// pkg/registry/registry.go
package registry

import (
    "fmt"
    "sync"
)

type Constructor[T any] func(cfg map[string]string) (T, error)

type Registry[T any] struct {
    mu      sync.RWMutex
    entries map[string]Constructor[T]
}

func New[T any]() *Registry[T] {
    return &Registry[T]{entries: make(map[string]Constructor[T])}
}

func (r *Registry[T]) Register(name string, ctor Constructor[T]) {
    r.mu.Lock()
    defer r.mu.Unlock()
    r.entries[name] = ctor
}

func (r *Registry[T]) Create(name string, cfg map[string]string) (T, error) {
    r.mu.RLock()
    ctor, ok := r.entries[name]
    r.mu.RUnlock()
    var zero T
    if !ok {
        return zero, fmt.Errorf("no implementation registered for %q", name)
    }
    return ctor(cfg)
}
```

## Factory for Database Connection

```go
// adapter/db/factory.go
package db

import (
    "context"
    "fmt"

    "github.com/jackc/pgx/v5/pgxpool"
    "github.com/org/bundle-go/config"
)

type DBDriver string

const (
    DriverPostgres DBDriver = "postgres"
)

func NewPool(driver DBDriver, cfg *config.DatabaseConfig) (*pgxpool.Pool, error) {
    switch driver {
    case DriverPostgres:
        return newPgxPool(cfg)
    default:
        return nil, fmt.Errorf("unsupported DB driver: %s", driver)
    }
}

func newPgxPool(cfg *config.DatabaseConfig) (*pgxpool.Pool, error) {
    poolCfg, err := pgxpool.ParseConfig(cfg.DSN)
    if err != nil {
        return nil, fmt.Errorf("parse db config: %w", err)
    }
    poolCfg.MaxConns = int32(cfg.MaxOpenConns)
    poolCfg.MinConns = int32(cfg.MinOpenConns)

    pool, err := pgxpool.NewWithConfig(context.Background(), poolCfg)
    if err != nil {
        return nil, fmt.Errorf("create db pool: %w", err)
    }
    if err := pool.Ping(context.Background()); err != nil {
        return nil, fmt.Errorf("ping db: %w", err)
    }
    return pool, nil
}
```

## Key Points

- Factory functions typically return an **interface** (unlike constructors which return structs)
- The concrete type is determined by config or runtime conditions, not the caller
- Always include a `default` case with a helpful error message listing valid options
- Factories belong in `adapter/` or `bootstrap/` — not in `app/` or `domain/`
