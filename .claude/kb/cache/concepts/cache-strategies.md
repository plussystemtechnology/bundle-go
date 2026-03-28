# Cache Strategies

## Cache-Aside (Lazy Loading)

Application checks cache first, loads from DB on miss, writes to cache.

```text
Read:  App → Cache? Hit → return. Miss → DB → write Cache → return.
Write: App → DB → invalidate Cache.
```

Best for: read-heavy workloads, tolerable staleness.

## Write-Through

Every write goes to both cache and DB synchronously.

```text
Write: App → Cache + DB (both).
Read:  App → Cache (always hit after first write).
```

Best for: data that must be fresh, moderate write volume.

## Write-Behind (Write-Back)

Write to cache immediately, async flush to DB.

```text
Write: App → Cache → (async) → DB.
Read:  App → Cache (always hit).
```

Best for: high write throughput. Risk: data loss if cache crashes before flush.

## Cache Invalidation Strategies

| Strategy | How | Use When |
|----------|-----|----------|
| TTL expiry | Set expiration time | Default choice |
| Event-driven | Invalidate on write events | Strong consistency needed |
| Version keys | `user:123:v5` | Atomic cache updates |
| Tag-based | Invalidate all keys with tag | Related data changes together |

## Key Naming Convention

```text
{entity}:{id}              → user:550e8400-...
{entity}:{id}:{field}      → user:550e8400-...:profile
{entity}:list:{filter}     → user:list:role=admin
{entity}:count:{filter}    → user:count:active=true
```
