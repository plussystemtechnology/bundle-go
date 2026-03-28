# Cache KB Domain

> Caching strategies — Redis (go-redis), in-memory LRU, Memcached, cache patterns.

## Topics

- **Data Structures** — Redis strings, hashes, sets, sorted sets, lists
- **Cache Strategies** — Cache-aside, write-through, write-behind, TTL
- **Pub/Sub** — Redis pub/sub for event distribution
- **LRU In-Memory** — hashicorp/golang-lru for local caching
- **Cache-Aside** — Read-through with fallback to DB
- **Distributed Lock** — Redis-based distributed locking
- **Rate Limiter** — Token bucket / sliding window with Redis
- **Session Store** — HTTP session storage in Redis

## Concepts

- `concepts/data-structures.md` — Redis data types and use cases
- `concepts/cache-strategies.md` — Caching patterns and invalidation
- `concepts/pub-sub.md` — Redis pub/sub messaging
- `concepts/lru-inmemory.md` — In-memory LRU caching

## Patterns

- `patterns/cache-aside.md` — Cache-aside with go-redis
- `patterns/distributed-lock.md` — Distributed locking
- `patterns/rate-limiter.md` — Rate limiting with Redis
- `patterns/session-store.md` — Session management
- `patterns/write-through.md` — Write-through cache pattern
