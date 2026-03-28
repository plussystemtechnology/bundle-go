# Option Pattern

## Overview

Functional options provide a clean API for optional configuration.
They make constructors self-documenting, extensible, and backward-compatible.

## Full Implementation

```go
// adapter/http/server/server.go
package server

import (
    "context"
    "fmt"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "go.uber.org/zap"
)

// options holds all configurable parameters (unexported)
type options struct {
    readTimeout     time.Duration
    writeTimeout    time.Duration
    idleTimeout     time.Duration
    maxHeaderBytes  int
    shutdownTimeout time.Duration
    logger          *zap.Logger
    trustedProxies  []string
}

func defaultOptions() options {
    return options{
        readTimeout:     15 * time.Second,
        writeTimeout:    15 * time.Second,
        idleTimeout:     60 * time.Second,
        maxHeaderBytes:  1 << 20,
        shutdownTimeout: 10 * time.Second,
        logger:          zap.NewNop(),
        trustedProxies:  nil,
    }
}

// Option modifies server options
type Option func(*options)

func WithReadTimeout(d time.Duration) Option {
    return func(o *options) { o.readTimeout = d }
}

func WithWriteTimeout(d time.Duration) Option {
    return func(o *options) { o.writeTimeout = d }
}

func WithIdleTimeout(d time.Duration) Option {
    return func(o *options) { o.idleTimeout = d }
}

func WithShutdownTimeout(d time.Duration) Option {
    return func(o *options) { o.shutdownTimeout = d }
}

func WithLogger(l *zap.Logger) Option {
    return func(o *options) { o.logger = l }
}

func WithTrustedProxies(proxies []string) Option {
    return func(o *options) { o.trustedProxies = proxies }
}

// Preset options for common scenarios
func WithProductionDefaults() Option {
    return func(o *options) {
        o.readTimeout    = 30 * time.Second
        o.writeTimeout   = 30 * time.Second
        o.maxHeaderBytes = 2 << 20
    }
}

// Server is the application HTTP server
type Server struct {
    opts    options
    engine  *gin.Engine
    httpSrv *http.Server
}

func New(addr string, engine *gin.Engine, opts ...Option) *Server {
    o := defaultOptions()
    for _, opt := range opts {
        opt(&o)
    }

    httpSrv := &http.Server{
        Addr:           addr,
        Handler:        engine,
        ReadTimeout:    o.readTimeout,
        WriteTimeout:   o.writeTimeout,
        IdleTimeout:    o.idleTimeout,
        MaxHeaderBytes: o.maxHeaderBytes,
    }

    return &Server{opts: o, engine: engine, httpSrv: httpSrv}
}

func (s *Server) Start() error {
    s.opts.logger.Info("server starting", zap.String("addr", s.httpSrv.Addr))
    if err := s.httpSrv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
        return fmt.Errorf("server listen: %w", err)
    }
    return nil
}

func (s *Server) Shutdown(ctx context.Context) error {
    ctx, cancel := context.WithTimeout(ctx, s.opts.shutdownTimeout)
    defer cancel()
    return s.httpSrv.Shutdown(ctx)
}
```

## Usage in bootstrap/

```go
// bootstrap/server.go
func NewHTTPServer(r *gin.Engine, cfg *config.AppConfig, logger *zap.Logger) *server.Server {
    opts := []server.Option{
        server.WithReadTimeout(cfg.Server.ReadTimeout),
        server.WithWriteTimeout(cfg.Server.WriteTimeout),
        server.WithLogger(logger),
    }
    if cfg.Server.Production {
        opts = append(opts, server.WithProductionDefaults())
    }
    return server.New(cfg.Server.Addr, r, opts...)
}
```

## Option Pattern for DB Pool

```go
// adapter/db/pool.go
type poolOptions struct {
    maxConns        int32
    minConns        int32
    maxConnLifetime time.Duration
    maxConnIdleTime time.Duration
}

type PoolOption func(*poolOptions)

func WithMaxConns(n int32) PoolOption {
    return func(o *poolOptions) { o.maxConns = n }
}
func WithMinConns(n int32) PoolOption {
    return func(o *poolOptions) { o.minConns = n }
}

func NewPool(dsn string, opts ...PoolOption) (*pgxpool.Pool, error) {
    o := &poolOptions{
        maxConns:        25,
        minConns:        5,
        maxConnLifetime: 30 * time.Minute,
        maxConnIdleTime: 5 * time.Minute,
    }
    for _, opt := range opts {
        opt(o)
    }

    cfg, err := pgxpool.ParseConfig(dsn)
    if err != nil {
        return nil, fmt.Errorf("parse db config: %w", err)
    }
    cfg.MaxConns = o.maxConns
    cfg.MinConns = o.minConns
    cfg.MaxConnLifetime = o.maxConnLifetime
    cfg.MaxConnIdleTime = o.maxConnIdleTime

    return pgxpool.NewWithConfig(context.Background(), cfg)
}
```

## Testing with Options

```go
func TestServer_Shutdown(t *testing.T) {
    srv := server.New(":0", gin.New(),
        server.WithShutdownTimeout(1*time.Second),
        server.WithLogger(zap.NewNop()),
    )
    // test shutdown behavior
}
```
