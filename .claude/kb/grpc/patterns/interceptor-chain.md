# Interceptor Chain Setup

```go
func NewGRPCServer(cfg config.GRPC, authSvc port.AuthService, logger *zap.Logger) *grpc.Server {
    // Recovery interceptor — must be first (catches panics from all others)
    recoveryOpts := []recovery.Option{
        recovery.WithRecoveryHandler(func(p any) error {
            logger.Error("gRPC panic recovered", zap.Any("panic", p))
            return status.Error(codes.Internal, "internal server error")
        }),
    }

    s := grpc.NewServer(
        grpc.ChainUnaryInterceptor(
            recovery.UnaryServerInterceptor(recoveryOpts...),
            otelgrpc.UnaryServerInterceptor(),
            LoggingUnaryInterceptor(logger),
            AuthUnaryInterceptor(authSvc),
        ),
        grpc.ChainStreamInterceptor(
            recovery.StreamServerInterceptor(recoveryOpts...),
            otelgrpc.StreamServerInterceptor(),
            LoggingStreamInterceptor(logger),
            AuthStreamInterceptor(authSvc),
        ),
        grpc.MaxRecvMsgSize(4*1024*1024), // 4MB
        grpc.KeepaliveParams(keepalive.ServerParameters{
            MaxConnectionIdle: 5 * time.Minute,
            Time:              2 * time.Minute,
            Timeout:           20 * time.Second,
        }),
    )

    return s
}
```

## Interceptor Order

```text
Request → Recovery → Tracing → Logging → Auth → Handler
Response ← Recovery ← Tracing ← Logging ← Auth ← Handler
```

Recovery wraps everything. Tracing creates spans. Logging records calls. Auth validates tokens.
