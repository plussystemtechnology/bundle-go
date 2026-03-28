# Add Column Migration

## Up

```sql
-- 000003_add_user_phone.up.sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Add index for search
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_phone ON users(phone) WHERE phone IS NOT NULL;
```

## Down

```sql
-- 000003_add_user_phone.down.sql
DROP INDEX IF EXISTS idx_users_phone;
ALTER TABLE users DROP COLUMN IF EXISTS avatar_url;
ALTER TABLE users DROP COLUMN IF EXISTS phone;
```

## Notes

- `ADD COLUMN` doesn't rewrite the table (fast for nullable columns)
- Adding a NOT NULL column without default requires table rewrite — avoid on large tables
- `CREATE INDEX CONCURRENTLY` can't run inside a transaction (golang-migrate handles this)
