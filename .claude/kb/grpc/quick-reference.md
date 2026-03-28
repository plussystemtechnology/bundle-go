# gRPC Quick Reference

## Proto File Structure

```protobuf
syntax = "proto3";
package api.v1;
option go_package = "internal/adapter/grpc/pb/v1";

service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse);
  rpc ListUsers(ListUsersRequest) returns (stream User);
}
```

## Server Setup

```go
s := grpc.NewServer(
    grpc.ChainUnaryInterceptor(interceptors...),
    grpc.ChainStreamInterceptor(streamInterceptors...),
)
pb.RegisterUserServiceServer(s, &userServer{})
grpc_health_v1.RegisterHealthServer(s, healthSrv)
```

## Status Codes

| gRPC Code | HTTP Equivalent | When |
|-----------|----------------|------|
| `codes.OK` | 200 | Success |
| `codes.NotFound` | 404 | Resource not found |
| `codes.InvalidArgument` | 400 | Bad request |
| `codes.Unauthenticated` | 401 | No/invalid auth |
| `codes.PermissionDenied` | 403 | Forbidden |
| `codes.AlreadyExists` | 409 | Conflict |
| `codes.Internal` | 500 | Server error |
| `codes.Unavailable` | 503 | Service unavailable |

## Code Generation Commands

```bash
protoc --go_out=. --go_opt=paths=source_relative \
       --go-grpc_out=. --go-grpc_opt=paths=source_relative \
       api/proto/*.proto
```
