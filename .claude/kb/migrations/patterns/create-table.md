# Create Table Migration

## Up

```sql
-- 000001_create_users.up.sql
CREATE TABLE IF NOT EXISTS users (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       TEXT NOT NULL,
    email      TEXT NOT NULL UNIQUE,
    role       TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user', 'viewer')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at DESC);
```

## Down

```sql
-- 000001_create_users.down.sql
DROP TABLE IF EXISTS users;
```
