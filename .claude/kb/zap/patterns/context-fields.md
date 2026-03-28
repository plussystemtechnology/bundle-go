# Context Fields Pattern

## Overview

Inject contextual fields (trace ID, request ID, user ID) into the logger
so they appear on every log line within a request without passing them manually.

## Context Keys

```go
// pkg/ctxkey/keys.go
package ctxkey

import "context"

type requestIDKey struct{}
type userIDKey    struct{}
type traceIDKey   struct{}

func WithRequestID(ctx context.Context, id string) context.Context {
    return context.WithValue(ctx, requestIDKey{}, id)
}
func RequestID(ctx context.Context) (string, bool) {
    v, ok := ctx.Value(requestIDKey{}).(string)
    return v, ok
}

func WithUserID(ctx context.Context, id string) context.Context {
    return context.WithValue(ctx, userIDKey{}, id)
}
func UserID(ctx context.Context) (string, bool) {
    v, ok := ctx.Value(userIDKey{}).(string)
    return v, ok
}

func WithTraceID(ctx context.Context, id string) context.Context {
    return context.WithValue(ctx, traceIDKey{}, id)
}
func TraceID(ctx context.Context) (string, bool) {
    v, ok := ctx.Value(traceIDKey{}).(string)
    return v, ok
}
```

## Logger from Context

Create a logger with all request-level fields pre-populated:

```go
// pkg/logger/ctx.go
package logger

import (
    "context"

    "go.uber.org/zap"
    "github.com/org/noxcare-go/pkg/ctxkey"
)

// FromContext returns a child logger with trace/request/user fields
func FromContext(ctx context.Context, base *zap.Logger) *zap.Logger {
    fields := make([]zap.Field, 0, 3)

    if requestID, ok := ctxkey.RequestID(ctx); ok {
        fields = append(fields, zap.String("request_id", requestID))
    }
    if userID, ok := ctxkey.UserID(ctx); ok {
        fields = append(fields, zap.String("user_id", userID))
    }
    if traceID, ok := ctxkey.TraceID(ctx); ok {
        fields = append(fields, zap.String("trace_id", traceID))
    }

    if len(fields) == 0 {
        return base
    }
    return base.With(fields...)
}
```

## Storing Logger in Context (Alternative)

Some teams prefer to store the enriched logger directly in context:

```go
type ctxLoggerKey struct{}

func WithLogger(ctx context.Context, logger *zap.Logger) context.Context {
    return context.WithValue(ctx, ctxLoggerKey{}, logger)
}

func L(ctx context.Context) *zap.Logger {
    if logger, ok := ctx.Value(ctxLoggerKey{}).(*zap.Logger); ok {
        return logger
    }
    return zap.L()  // fallback to global
}
```

Middleware stores enriched logger in context:
```go
func RequestContextMiddleware(base *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        reqID := c.GetHeader("X-Request-ID")
        if reqID == "" { reqID = uuid.New().String() }

        // Enrich the base logger
        log := base.With(
            zap.String("request_id", reqID),
            zap.String("method", c.Request.Method),
            zap.String("path", c.Request.URL.Path),
        )

        // Store in context
        ctx := logger.WithLogger(c.Request.Context(), log)
        c.Request = c.Request.WithContext(ctx)
        c.Header("X-Request-ID", reqID)
        c.Next()
    }
}
```

Usage in handler:
```go
func (h *PatientHandler) Create(c *gin.Context) {
    log := logger.L(c.Request.Context())  // already has request_id, method, path
    log.Info("creating patient")  // → {"request_id":"req-abc","method":"POST","msg":"creating patient"}
}
```

## OTel Trace ID from Context

Automatically extract the OTel trace ID and inject into logs:

```go
// pkg/logger/otel_fields.go
package logger

import (
    "context"

    "go.opentelemetry.io/otel/trace"
    "go.uber.org/zap"
)

// FieldsFromSpan returns zap fields for the current OTel span
func FieldsFromSpan(ctx context.Context) []zap.Field {
    span := trace.SpanFromContext(ctx)
    if !span.IsRecording() {
        return nil
    }
    sc := span.SpanContext()
    return []zap.Field{
        zap.String("trace_id", sc.TraceID().String()),
        zap.String("span_id",  sc.SpanID().String()),
    }
}

// Usage in service
func (s *PatientService) CreatePatient(ctx context.Context, cmd dto.CreatePatientCommand) (*patient.Patient, error) {
    log := s.logger.With(logger.FieldsFromSpan(ctx)...)
    log.Info("creating patient")
    // ...
}
```

## Full Request Log Flow

```
Request arrives
    → RequestID middleware: ctx = WithRequestID(ctx, "req-abc")
    → Auth middleware:      ctx = WithUserID(ctx, "user-xyz")
    → OTel middleware:      ctx = WithTraceID(ctx, "trace-123")

Handler:
    log := logger.L(ctx)  // base + request_id + user_id + trace_id
    log.Info("handler start")
    // → {"request_id":"req-abc","user_id":"user-xyz","trace_id":"trace-123","msg":"handler start"}

Service:
    log := logger.FromContext(ctx, s.logger)  // service logger + ctx fields
    log.Info("patient created")
    // → {"service":"patient","request_id":"req-abc","user_id":"user-xyz","msg":"patient created"}
```
