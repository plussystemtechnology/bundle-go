# Generics in Go (1.18+)

## Syntax Overview

```go
// Generic function: [TypeParam Constraint]
func Map[T, U any](s []T, fn func(T) U) []U { ... }

// Generic type
type Stack[T any] struct { items []T }

// Constraint = interface
type Number interface { ~int | ~int64 | ~float32 | ~float64 }
```

## Built-in Constraints (`golang.org/x/exp/constraints` or `cmp`)

```go
// any     = interface{} (no constraint)
// comparable = supports == and !=
// Go 1.21+: cmp.Ordered = all ordered types

import "cmp"
func Min[T cmp.Ordered](a, b T) T {
    if a < b { return a }
    return b
}
```

## Generic Collection Utilities (pkg/slices, pkg/maps)

```go
// pkg/slice/slice.go
package slice

// Map transforms []T to []U
func Map[T, U any](s []T, fn func(T) U) []U {
    result := make([]U, len(s))
    for i, v := range s {
        result[i] = fn(v)
    }
    return result
}

// Filter returns elements satisfying predicate
func Filter[T any](s []T, pred func(T) bool) []T {
    var result []T
    for _, v := range s {
        if pred(v) {
            result = append(result, v)
        }
    }
    return result
}

// Reduce folds []T to U
func Reduce[T, U any](s []T, init U, fn func(U, T) U) U {
    acc := init
    for _, v := range s {
        acc = fn(acc, v)
    }
    return acc
}

// Contains reports whether s contains v (requires comparable)
func Contains[T comparable](s []T, v T) bool {
    for _, item := range s {
        if item == v { return true }
    }
    return false
}

// Unique returns deduplicated slice preserving order
func Unique[T comparable](s []T) []T {
    seen := make(map[T]struct{}, len(s))
    result := make([]T, 0, len(s))
    for _, v := range s {
        if _, ok := seen[v]; !ok {
            seen[v] = struct{}{}
            result = append(result, v)
        }
    }
    return result
}
```

## Generic Result Type

```go
// pkg/result/result.go
package result

type Result[T any] struct {
    value T
    err   error
}

func Ok[T any](v T) Result[T]       { return Result[T]{value: v} }
func Err[T any](e error) Result[T]  { return Result[T]{err: e} }

func (r Result[T]) Unwrap() (T, error) { return r.value, r.err }
func (r Result[T]) IsOk() bool         { return r.err == nil }
func (r Result[T]) Value() T           { return r.value }
func (r Result[T]) Err() error         { return r.err }
```

## Generic Stack

```go
// pkg/stack/stack.go
package stack

type Stack[T any] struct{ items []T }

func (s *Stack[T]) Push(v T)           { s.items = append(s.items, v) }
func (s *Stack[T]) Len() int           { return len(s.items) }
func (s *Stack[T]) IsEmpty() bool      { return len(s.items) == 0 }

func (s *Stack[T]) Pop() (T, bool) {
    var zero T
    if s.IsEmpty() { return zero, false }
    n := len(s.items) - 1
    v := s.items[n]
    s.items = s.items[:n]
    return v, true
}
```

## Type Sets and Union Constraints

```go
// Tilde (~) means "underlying type is"
type Integer interface { ~int | ~int8 | ~int16 | ~int32 | ~int64 }
type Signed   interface { ~int | ~int8 | ~int16 | ~int32 | ~int64 }
type Unsigned interface { ~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 }

// Custom numeric type still satisfies Number
type PatientAge int  // ~int — satisfies Integer

func IsAdult[T Integer](age T) bool { return age >= 18 }
```

## Constraints with Methods

```go
type Stringer interface {
    comparable
    String() string
}

func PrintAll[T Stringer](items []T) {
    for _, item := range items {
        fmt.Println(item.String())
    }
}
```

## Generic Pagination Helper

```go
// pkg/pagination/pagination.go
package pagination

type Page[T any] struct {
    Items      []T   `json:"items"`
    Total      int64 `json:"total"`
    PageNumber int   `json:"page"`
    PageSize   int   `json:"page_size"`
    HasNext    bool  `json:"has_next"`
}

func NewPage[T any](items []T, total int64, page, size int) Page[T] {
    return Page[T]{
        Items:      items,
        Total:      total,
        PageNumber: page,
        PageSize:   size,
        HasNext:    int64(page*size) < total,
    }
}
```

## When to Use Generics

- Collection/container utilities (Map, Filter, Contains)
- Type-safe wrappers (Result[T], Optional[T], Page[T])
- Algorithms that work on multiple numeric types
- Code that would otherwise use `interface{}` with type assertions

## When NOT to Use Generics

- When a plain interface is sufficient
- When the logic differs per type (use interface methods instead)
- For simple functions with 1-2 types — just write them twice
- When it makes the code harder to read than the alternatives
