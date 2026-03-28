# CRUD Query Patterns

## Standard CRUD Set

```sql
-- name: CreateUser :one
INSERT INTO users (id, name, email, role, created_at, updated_at)
VALUES (sqlc.arg(id), sqlc.arg(name), sqlc.arg(email), sqlc.arg(role), now(), now())
RETURNING id, name, email, role, created_at, updated_at;

-- name: GetUserByID :one
SELECT id, name, email, role, created_at, updated_at
FROM users
WHERE id = $1 AND deleted_at IS NULL;

-- name: GetUserByEmail :one
SELECT id, name, email, role, created_at, updated_at
FROM users
WHERE email = $1 AND deleted_at IS NULL;

-- name: ListUsers :many
SELECT id, name, email, role, created_at, updated_at
FROM users
WHERE deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: CountUsers :one
SELECT count(*) FROM users WHERE deleted_at IS NULL;

-- name: UpdateUser :one
UPDATE users
SET name = coalesce(sqlc.narg(name), name),
    email = coalesce(sqlc.narg(email), email),
    role = coalesce(sqlc.narg(role), role),
    updated_at = now()
WHERE id = $1 AND deleted_at IS NULL
RETURNING id, name, email, role, created_at, updated_at;

-- name: SoftDeleteUser :exec
UPDATE users SET deleted_at = now() WHERE id = $1;
```

## Key Points

- Use `sqlc.arg(name)` for named params
- Use `sqlc.narg(name)` for nullable params (partial updates with `coalesce`)
- Always use explicit column lists (never `SELECT *`)
- Prefer soft delete (`deleted_at`) over hard delete
- Add `AND deleted_at IS NULL` to all read queries
