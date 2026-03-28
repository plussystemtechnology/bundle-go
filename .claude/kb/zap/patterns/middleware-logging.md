# Middleware Logging with Gin + Zap

## Request Logger Middleware

```go
// adapter/http/middleware/logger.go
package middleware

import (
    "time"

    "github.com/gin-gonic/gin"
    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

// ZapLogger logs each HTTP request with structured fields
func ZapLogger(logger *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start  := time.Now()
        path   := c.Request.URL.Path
        query  := c.Request.URL.RawQuery

        c.Next()

        latency    := time.Since(start)
        statusCode := c.Writer.Status()
        clientIP   := c.ClientIP()
        method     := c.Request.Method

        fields := []zapcore.Field{
            zap.Int("status",   statusCode),
            zap.String("method", method),
            zap.String("path",   path),
            zap.String("ip",     clientIP),
            zap.Duration("latency", latency),
            zap.String("user_agent", c.Request.UserAgent()),
        }

        if query != "" {
            fields = append(fields, zap.String("query", query))
        }

        if requestID := c.GetHeader("X-Request-ID"); requestID != "" {
            fields = append(fields, zap.String("request_id", requestID))
        }

        // Select log level based on status code
        switch {
        case statusCode >= 500:
            logger.Error("request", fields...)
        case statusCode >= 400:
            logger.Warn("request", fields...)
        default:
            logger.Info("request", fields...)
        }
    }
}
```

## Recovery Middleware

```go
// adapter/http/middleware/recovery.go
package middleware

import (
    "net/http"
    "runtime/debug"

    "github.com/gin-gonic/gin"
    "go.uber.org/zap"
)

// ZapRecovery recovers from panics, logs the stack trace, and returns 500
func ZapRecovery(logger *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        defer func() {
            if r := recover(); r != nil {
                stack := debug.Stack()
                logger.Error("panic recovered",
                    zap.Any("error", r),
                    zap.ByteString("stack", stack),
                    zap.String("method", c.Request.Method),
                    zap.String("path", c.Request.URL.Path),
                    zap.String("ip", c.ClientIP()),
                )
                c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
                    "error": "INTERNAL_ERROR",
                    "message": "an unexpected error occurred",
                })
            }
        }()
        c.Next()
    }
}
```

## Request ID Middleware

```go
// adapter/http/middleware/request_id.go
package middleware

import (
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
    "github.com/org/bundle-go/pkg/ctxkey"
    "go.uber.org/zap"
)

// RequestID adds a unique request ID to the context and response headers
func RequestID(logger *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        reqID := c.GetHeader("X-Request-ID")
        if reqID == "" {
            reqID = uuid.New().String()
        }

        // Store in context
        ctx := ctxkey.WithRequestID(c.Request.Context(), reqID)
        c.Request = c.Request.WithContext(ctx)

        // Set response header
        c.Header("X-Request-ID", reqID)

        // Add to logger for all subsequent logs in this request
        // (done via context fields pattern — see context-fields.md)

        c.Next()
    }
}
```

## Latency Warning Middleware

```go
// Warn on slow requests
func SlowRequestLogger(threshold time.Duration, logger *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        c.Next()
        elapsed := time.Since(start)

        if elapsed > threshold {
            logger.Warn("slow request",
                zap.Duration("elapsed", elapsed),
                zap.Duration("threshold", threshold),
                zap.String("path", c.Request.URL.Path),
                zap.String("method", c.Request.Method),
                zap.Int("status", c.Writer.Status()),
            )
        }
    }
}
```

## Router Setup

```go
// adapter/http/router/router.go
package router

import (
    "github.com/gin-gonic/gin"
    "go.uber.org/zap"
    "github.com/org/bundle-go/adapter/http/middleware"
)

func New(logger *zap.Logger) *gin.Engine {
    r := gin.New()  // NOT gin.Default() — that adds its own Logger and Recovery

    r.Use(middleware.RequestID(logger))
    r.Use(middleware.ZapLogger(logger))
    r.Use(middleware.ZapRecovery(logger))
    r.Use(middleware.SlowRequestLogger(500*time.Millisecond, logger))
    r.Use(middleware.ErrorHandler(logger))

    return r
}
```

## Sample Log Output

```json
{"ts":"2026-03-27T10:00:01.234Z","level":"info","service":"bundle-go","msg":"request",
 "status":200,"method":"GET","path":"/api/v1/patients/p-123","ip":"10.0.0.1",
 "latency":"12.5ms","request_id":"req-abc123"}

{"ts":"2026-03-27T10:00:02.000Z","level":"warn","service":"bundle-go","msg":"request",
 "status":404,"method":"GET","path":"/api/v1/patients/p-999","ip":"10.0.0.2",
 "latency":"3.2ms","request_id":"req-def456"}

{"ts":"2026-03-27T10:00:03.000Z","level":"error","service":"bundle-go","msg":"request",
 "status":500,"method":"POST","path":"/api/v1/appointments","ip":"10.0.0.3",
 "latency":"201ms","request_id":"req-ghi789"}
```
