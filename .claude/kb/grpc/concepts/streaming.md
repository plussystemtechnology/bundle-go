# gRPC Streaming

## Server Streaming

Server sends multiple responses to a single request.

```protobuf
rpc ListUsers(ListUsersRequest) returns (stream User);
```

```go
func (s *server) ListUsers(req *pb.ListUsersRequest, stream pb.UserService_ListUsersServer) error {
    users, err := s.svc.ListAll(stream.Context())
    if err != nil {
        return status.Errorf(codes.Internal, "list users: %v", err)
    }

    for _, user := range users {
        if err := stream.Send(toProtoUser(user)); err != nil {
            return err
        }
    }
    return nil
}
```

## Client Streaming

Client sends multiple requests, server responds once.

```protobuf
rpc BatchCreateUsers(stream CreateUserRequest) returns (BatchCreateResponse);
```

## Bidirectional Streaming

Both sides send streams simultaneously.

```protobuf
rpc Chat(stream ChatMessage) returns (stream ChatMessage);
```

## When to Use

| Pattern | Use Case |
|---------|----------|
| Unary | Standard CRUD operations |
| Server stream | Large result sets, real-time updates |
| Client stream | Bulk uploads, log ingestion |
| Bidi stream | Chat, collaborative editing |
