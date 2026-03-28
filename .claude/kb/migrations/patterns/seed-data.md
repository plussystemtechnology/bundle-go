# Seed Data Migration

```sql
-- 000010_seed_roles.up.sql
INSERT INTO roles (id, name, description)
VALUES
    ('admin', 'Administrator', 'Full system access'),
    ('user', 'User', 'Standard user access'),
    ('viewer', 'Viewer', 'Read-only access')
ON CONFLICT (id) DO NOTHING;
```

```sql
-- 000010_seed_roles.down.sql
DELETE FROM roles WHERE id IN ('admin', 'user', 'viewer');
```

## Key Points

- Use `ON CONFLICT DO NOTHING` for idempotency
- Seed data belongs in migrations (not application code)
- Keep seed data minimal — only what's needed for the app to function
