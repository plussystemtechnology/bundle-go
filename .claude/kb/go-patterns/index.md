# Go Patterns — Bundle-Go

## Core Philosophy

> Accept interfaces, return structs.
> Errors are values. Concurrency is explicit.
> Simple is better than clever.

## Pattern Categories

### Structural Patterns
| Pattern           | File                           | Use When                                    |
|-------------------|--------------------------------|---------------------------------------------|
| Functional Options | patterns/option-pattern.md    | Struct with 3+ optional config fields       |
| Builder           | patterns/builder-pattern.md   | Complex object construction with validation |
| Factory           | patterns/factory-pattern.md   | Choosing between implementations at runtime |
| Strategy          | patterns/strategy-pattern.md  | Swappable algorithms / behaviors            |

### Language Concepts
| Concept           | File                           | Key Idea                                    |
|-------------------|--------------------------------|---------------------------------------------|
| Functional Options| concepts/functional-options.md | `type Option func(*Config)` pattern         |
| Generics          | concepts/generics.md           | `[T any]` constraints, type sets (Go 1.18+) |
| Interfaces        | concepts/interfaces.md         | Implicit satisfaction, small interfaces     |
| Embedding         | concepts/embedding.md          | Struct + interface embedding                |

## Golden Rules

1. **Accept interfaces, return structs** — callers get full capability, functions stay flexible
2. **Keep interfaces small** — 1-3 methods; compose if needed
3. **Errors are values** — return `error`, never panic in library code
4. **Zero values should be useful** — design structs so the zero value works
5. **Prefer explicit over implicit** — no magic, no globals, no `init()` side effects
6. **Goroutines are cheap, leaks are not** — always have a shutdown path

## Bundle-Go Conventions

- Config structs use functional options (`adapter/http/server.go`)
- All repositories return domain types, never DB-generated types
- Generic helpers live in `pkg/` (e.g., `pkg/slice`, `pkg/maps`)
- Strategy pattern used for notification channels (SMS, email, push)
- Factory pattern used in bootstrap for adapter selection by config

## Reference
- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Go Proverbs](https://go-proverbs.github.io/)
