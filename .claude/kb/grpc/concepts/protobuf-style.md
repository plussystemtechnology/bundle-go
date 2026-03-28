# Protobuf Style Guide

## File Organization

```text
api/proto/
├── v1/
│   ├── user.proto
│   ├── order.proto
│   └── common.proto
└── v2/
    └── user.proto
```

## Message Design

```protobuf
syntax = "proto3";
package api.v1;

import "google/protobuf/timestamp.proto";

message User {
  string id = 1;           // UUID as string
  string name = 2;
  string email = 3;
  UserRole role = 4;
  google.protobuf.Timestamp created_at = 5;
  google.protobuf.Timestamp updated_at = 6;
}

enum UserRole {
  USER_ROLE_UNSPECIFIED = 0;
  USER_ROLE_ADMIN = 1;
  USER_ROLE_USER = 2;
  USER_ROLE_VIEWER = 3;
}

message GetUserRequest {
  string id = 1;
}

message GetUserResponse {
  User user = 1;
}

message ListUsersRequest {
  int32 page_size = 1;
  string page_token = 2;
}

message ListUsersResponse {
  repeated User users = 1;
  string next_page_token = 2;
}
```

## Conventions

- Use `snake_case` for field names
- Enum values prefixed with enum name: `USER_ROLE_ADMIN`
- First enum value is `_UNSPECIFIED = 0`
- Use `google.protobuf.Timestamp` for times (not int64)
- Pagination: `page_size` + `page_token` / `next_page_token`
- Wrap response in a response message (not bare types)
