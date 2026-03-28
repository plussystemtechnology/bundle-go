# Rollback Strategies

## Single Rollback

```bash
migrate -path db/migration -database "$DB_URL" down 1
```

## Fix Dirty State

If a migration fails mid-execution, the database is marked dirty.

```bash
# Check current version
migrate -path db/migration -database "$DB_URL" version
# Output: 5 (dirty)

# Force to last known good version
migrate -path db/migration -database "$DB_URL" force 4

# Fix the migration SQL, then re-run
migrate -path db/migration -database "$DB_URL" up
```

## Rollback Checklist

1. Check if data was modified (not just DDL)
2. If data changed, the down migration must reverse it
3. Test down migration in staging first
4. Run `migrate down 1` in production
5. Verify application works with previous schema
6. If rollback fails, use `force` to fix dirty state

## Zero-Downtime Rollback

For production, prefer forward-fixing over rollback:
1. Deploy code that works with both old and new schema
2. Apply new migration to fix the issue
3. Avoid dropping columns/tables until old code is fully retired
