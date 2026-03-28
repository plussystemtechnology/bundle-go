# Idempotent DDL

## Safe DDL Patterns

```sql
-- Tables
CREATE TABLE IF NOT EXISTS users (...);
DROP TABLE IF EXISTS users;

-- Columns
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE users DROP COLUMN IF EXISTS phone;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
DROP INDEX IF EXISTS idx_users_email;

-- Constraints (PostgreSQL 11+)
ALTER TABLE orders ADD CONSTRAINT fk_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    NOT VALID; -- add without full table scan
ALTER TABLE orders VALIDATE CONSTRAINT fk_user; -- validate separately

-- Enums
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_status') THEN
        CREATE TYPE order_status AS ENUM ('pending', 'processing', 'completed');
    END IF;
END $$;
```

## Key Points

- Always use `IF NOT EXISTS` / `IF EXISTS`
- Add constraints as `NOT VALID` then `VALIDATE` separately (no table lock)
- Create indexes `CONCURRENTLY` for zero-downtime (but can't use in transactions)
