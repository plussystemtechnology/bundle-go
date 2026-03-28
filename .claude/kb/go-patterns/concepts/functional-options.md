# Functional Options

## Problem

How do you provide optional configuration to a constructor without:
- An options struct with many zero-value traps
- A dozen overloaded constructors
- Exported fields that shouldn't be changed after construction

## Solution: `type Option func(*Config)`

```go
// pkg/server/server.go
package server

import (
    "time"
    "go.uber.org/zap"
)

type config struct {
    readTimeout     time.Duration
    writeTimeout    time.Duration
    maxHeaderBytes  int
    logger          *zap.Logger
    shutdownTimeout time.Duration
}

// Option is a function that modifies config
type Option func(*config)

// WithReadTimeout sets the HTTP read timeout
func WithReadTimeout(d time.Duration) Option {
    return func(c *config) { c.readTimeout = d }
}

// WithWriteTimeout sets the HTTP write timeout
func WithWriteTimeout(d time.Duration) Option {
    return func(c *config) { c.writeTimeout = d }
}

// WithLogger injects a logger
func WithLogger(l *zap.Logger) Option {
    return func(c *config) { c.logger = l }
}

// WithShutdownTimeout sets graceful shutdown timeout
func WithShutdownTimeout(d time.Duration) Option {
    return func(c *config) { c.shutdownTimeout = d }
}

type Server struct {
    cfg config
    // ... other fields
}

// NewServer creates a server with sensible defaults, overridden by opts
func NewServer(addr string, opts ...Option) *Server {
    cfg := config{
        readTimeout:     15 * time.Second,
        writeTimeout:    15 * time.Second,
        maxHeaderBytes:  1 << 20, // 1 MB
        logger:          zap.NewNop(),
        shutdownTimeout: 10 * time.Second,
    }
    for _, opt := range opts {
        opt(&cfg)
    }
    return &Server{cfg: cfg}
}
```

Usage:
```go
// Minimal — all defaults
srv := NewServer(":8080")

// With specific overrides
srv := NewServer(":8080",
    WithReadTimeout(30*time.Second),
    WithLogger(logger),
    WithShutdownTimeout(5*time.Second),
)
```

## Advanced: Options with Validation

```go
type Option func(*config) error

func WithMaxConns(n int) Option {
    return func(c *config) error {
        if n <= 0 {
            return fmt.Errorf("max conns must be positive, got %d", n)
        }
        c.maxConns = n
        return nil
    }
}

func New(addr string, opts ...Option) (*Pool, error) {
    cfg := defaultConfig()
    for _, opt := range opts {
        if err := opt(&cfg); err != nil {
            return nil, fmt.Errorf("pool config: %w", err)
        }
    }
    return &Pool{cfg: cfg}, nil
}
```

## Options as Middleware (combining)

```go
// Group related options
func WithProductionDefaults() Option {
    return func(c *config) {
        c.readTimeout    = 30 * time.Second
        c.writeTimeout   = 30 * time.Second
        c.maxHeaderBytes = 2 << 20
    }
}

func WithDevelopmentDefaults() Option {
    return func(c *config) {
        c.readTimeout  = 120 * time.Second // longer for debugging
        c.writeTimeout = 120 * time.Second
    }
}
```

## When to Use Functional Options

- 3 or more optional parameters
- Parameters have sensible defaults
- The config is not needed after construction
- You want to add options without breaking existing callers

## When NOT to Use

- All parameters are required → use plain constructor params
- Only 1-2 optional params → use `...opt` or separate constructor
- The "option" needs to be inspected/serialized → use a plain Options struct

## Functional Options vs Config Struct

```go
// Config struct approach — good when config comes from file/env
type ServerConfig struct {
    Addr           string        `env:"SERVER_ADDR"`
    ReadTimeout    time.Duration `env:"SERVER_READ_TIMEOUT"`
}
func NewServer(cfg ServerConfig) *Server { ... }

// Functional options — good for programmatic construction
func NewServer(addr string, opts ...Option) *Server { ... }

// Often used together: load config, then pass as option
srv := NewServer(cfg.Addr, WithReadTimeout(cfg.ReadTimeout))
```
