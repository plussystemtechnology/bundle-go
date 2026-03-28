# gRPC Tracing

```go
import "go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"

// Server-side
s := grpc.NewServer(
    grpc.StatsHandler(otelgrpc.NewServerHandler()),
)

// Client-side
conn, err := grpc.Dial(addr,
    grpc.WithStatsHandler(otelgrpc.NewClientHandler()),
)
```

Automatically traces all unary and streaming RPCs with:
- RPC method name as span name
- Status code attributes
- Message size attributes
- Error recording
