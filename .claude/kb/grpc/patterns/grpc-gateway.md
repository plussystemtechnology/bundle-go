# gRPC-Gateway — REST to gRPC

## Proto Annotations

```protobuf
import "google/api/annotations.proto";

service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse) {
    option (google.api.http) = {
      get: "/api/v1/users/{id}"
    };
  }

  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse) {
    option (google.api.http) = {
      post: "/api/v1/users"
      body: "*"
    };
  }

  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse) {
    option (google.api.http) = {
      get: "/api/v1/users"
    };
  }
}
```

## Gateway Server

```go
func RunGateway(ctx context.Context, grpcAddr, httpAddr string) error {
    mux := runtime.NewServeMux(
        runtime.WithMarshalerOption(runtime.MIMEWildcard, &runtime.JSONPb{
            MarshalOptions: protojson.MarshalOptions{UseProtoNames: true},
        }),
    )

    opts := []grpc.DialOption{grpc.WithTransportCredentials(insecure.NewCredentials())}

    if err := pb.RegisterUserServiceHandlerFromEndpoint(ctx, mux, grpcAddr, opts); err != nil {
        return fmt.Errorf("register gateway: %w", err)
    }

    srv := &http.Server{Addr: httpAddr, Handler: mux}
    return srv.ListenAndServe()
}
```

## When to Use

Use gRPC-Gateway when you need both REST and gRPC from the same service definition. The gateway translates HTTP/JSON calls to gRPC automatically.
