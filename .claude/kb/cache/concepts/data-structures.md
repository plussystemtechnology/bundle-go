# Redis Data Structures

## Strings

Most basic type. Store serialized JSON, counters, flags.

```go
// Set JSON
data, _ := json.Marshal(user)
rdb.Set(ctx, "user:"+id, data, 5*time.Minute)

// Get JSON
val, err := rdb.Get(ctx, "user:"+id).Bytes()
if errors.Is(err, redis.Nil) {
    // cache miss
}
json.Unmarshal(val, &user)
```

## Hashes

Map of field→value. Good for objects with partial updates.

```go
rdb.HSet(ctx, "user:"+id, map[string]any{
    "name":  user.Name,
    "email": user.Email,
    "role":  user.Role,
})

name, _ := rdb.HGet(ctx, "user:"+id, "name").Result()
all, _ := rdb.HGetAll(ctx, "user:"+id).Result() // map[string]string
```

## Sets

Unique collections. Good for tags, membership, deduplication.

```go
rdb.SAdd(ctx, "user:"+id+":roles", "admin", "editor")
isMember, _ := rdb.SIsMember(ctx, "user:"+id+":roles", "admin").Result()
```

## Sorted Sets

Ordered by score. Good for leaderboards, rate limiting, priority queues.

```go
rdb.ZAdd(ctx, "leaderboard", redis.Z{Score: 100, Member: userID})
top10, _ := rdb.ZRevRangeWithScores(ctx, "leaderboard", 0, 9).Result()
```

## Lists

Ordered sequences. Good for queues, recent activity.

```go
rdb.LPush(ctx, "notifications:"+id, notificationJSON)
rdb.LTrim(ctx, "notifications:"+id, 0, 99) // keep last 100
```
