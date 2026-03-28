# Query Annotations

## Syntax

Every query file starts with a comment annotation that tells sqlc the function name and return type.

```sql
-- name: FunctionName :return_type
SELECT ... ;
```

## Return Types

### :one — Single Row

```sql
-- name: GetUserByID :one
SELECT id, name, email, created_at
FROM users
WHERE id = $1;
```

Generates: `func (q *Queries) GetUserByID(ctx context.Context, id uuid.UUID) (User, error)`

### :many — Multiple Rows

```sql
-- name: ListUsers :many
SELECT id, name, email, created_at
FROM users
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;
```

Generates: `func (q *Queries) ListUsers(ctx context.Context, arg ListUsersParams) ([]User, error)`

### :exec — No Return

```sql
-- name: DeleteUser :exec
DELETE FROM users WHERE id = $1;
```

Generates: `func (q *Queries) DeleteUser(ctx context.Context, id uuid.UUID) error`

### :execrows — Affected Row Count

```sql
-- name: SoftDeleteInactive :execrows
UPDATE users SET deleted_at = now() WHERE last_login < $1;
```

Generates: `func (q *Queries) SoftDeleteInactive(ctx context.Context, lastLogin time.Time) (int64, error)`

## Parameter Naming

```sql
-- name: CreateUser :one
INSERT INTO users (name, email)
VALUES (sqlc.arg(name), sqlc.arg(email))
RETURNING id, name, email, created_at;
```

`sqlc.arg(name)` creates a named parameter in the generated `CreateUserParams` struct.
