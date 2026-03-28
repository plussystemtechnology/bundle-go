# Server Streaming Pattern

```go
func (s *server) WatchOrders(req *pb.WatchOrdersRequest, stream pb.OrderService_WatchOrdersServer) error {
    ctx := stream.Context()
    userID, err := uuid.Parse(req.GetUserId())
    if err != nil {
        return status.Error(codes.InvalidArgument, "invalid user_id")
    }

    ch, cancel := s.svc.Subscribe(ctx, userID)
    defer cancel()

    for {
        select {
        case event, ok := <-ch:
            if !ok {
                return nil // channel closed
            }
            if err := stream.Send(toProtoOrderEvent(event)); err != nil {
                return err
            }
        case <-ctx.Done():
            return ctx.Err()
        }
    }
}
```

## Client-Side Consumption

```go
stream, err := client.WatchOrders(ctx, &pb.WatchOrdersRequest{UserId: userID})
if err != nil {
    return err
}

for {
    event, err := stream.Recv()
    if err == io.EOF {
        break
    }
    if err != nil {
        return err
    }
    handleEvent(event)
}
```
