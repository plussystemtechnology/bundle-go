# Migration Versioning

## Sequential Numbering

```text
000001_create_users.up.sql
000002_create_orders.up.sql
000003_add_user_email_index.up.sql
```

Use `migrate create -seq` for sequential numbering. Avoids timestamp-based conflicts.

## Version Table

golang-migrate creates `schema_migrations` table:

```sql
CREATE TABLE schema_migrations (
    version bigint NOT NULL PRIMARY KEY,
    dirty boolean NOT NULL
);
```

## Migration Ordering Rules

- Never reorder existing migrations
- Never modify applied migrations
- New migrations always get the next number
- If team conflicts arise, renumber before merge
