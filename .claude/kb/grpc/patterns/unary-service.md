# Unary Service Pattern

```go
type userServer struct {
    pb.UnimplementedUserServiceServer
    svc port.UserService
}

func NewUserServer(svc port.UserService) pb.UserServiceServer {
    return &userServer{svc: svc}
}

func (s *userServer) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.GetUserResponse, error) {
    if req.GetId() == "" {
        return nil, status.Error(codes.InvalidArgument, "id is required")
    }

    id, err := uuid.Parse(req.GetId())
    if err != nil {
        return nil, status.Error(codes.InvalidArgument, "invalid id format")
    }

    user, err := s.svc.GetByID(ctx, id)
    if err != nil {
        if errors.Is(err, domain.ErrNotFound) {
            return nil, status.Error(codes.NotFound, "user not found")
        }
        return nil, status.Error(codes.Internal, "internal error")
    }

    return &pb.GetUserResponse{
        User: toProtoUser(user),
    }, nil
}

func toProtoUser(u *domain.User) *pb.User {
    return &pb.User{
        Id:        u.ID.String(),
        Name:      u.Name,
        Email:     u.Email,
        Role:      pb.UserRole(pb.UserRole_value["USER_ROLE_"+strings.ToUpper(string(u.Role))]),
        CreatedAt: timestamppb.New(u.CreatedAt),
        UpdatedAt: timestamppb.New(u.UpdatedAt),
    }
}
```
