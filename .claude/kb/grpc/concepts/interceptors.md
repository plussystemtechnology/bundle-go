# gRPC Interceptors

## Unary Interceptor

```go
func LoggingInterceptor(logger *zap.Logger) grpc.UnaryServerInterceptor {
    return func(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
        start := time.Now()
        resp, err := handler(ctx, req)
        duration := time.Since(start)

        logger.Info("gRPC call",
            zap.String("method", info.FullMethod),
            zap.Duration("duration", duration),
            zap.Error(err),
        )
        return resp, err
    }
}
```

## Auth Interceptor

```go
func AuthInterceptor(authSvc port.AuthService) grpc.UnaryServerInterceptor {
    return func(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
        // Skip auth for health checks
        if info.FullMethod == "/grpc.health.v1.Health/Check" {
            return handler(ctx, req)
        }

        md, ok := metadata.FromIncomingContext(ctx)
        if !ok {
            return nil, status.Error(codes.Unauthenticated, "missing metadata")
        }

        tokens := md.Get("authorization")
        if len(tokens) == 0 {
            return nil, status.Error(codes.Unauthenticated, "missing token")
        }

        claims, err := authSvc.ValidateToken(ctx, tokens[0])
        if err != nil {
            return nil, status.Error(codes.Unauthenticated, "invalid token")
        }

        ctx = context.WithValue(ctx, userClaimsKey, claims)
        return handler(ctx, req)
    }
}
```

## Chaining Interceptors

```go
s := grpc.NewServer(
    grpc.ChainUnaryInterceptor(
        otelgrpc.UnaryServerInterceptor(),  // tracing first
        LoggingInterceptor(logger),
        AuthInterceptor(authSvc),
        RecoveryInterceptor(),
    ),
)
```
