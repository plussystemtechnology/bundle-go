# Benchmarks

## Overview

Benchmarks measure performance and allocation counts.
Run with `go test -bench=. -benchmem`.
Used for hot paths: CPF validation, JSON serialization, cache lookups, DB query paths.

## Basic Benchmark

```go
// domain/patient/validate_bench_test.go
package patient_test

import (
    "testing"
    "github.com/org/bundle-go/domain/patient"
)

func BenchmarkValidateCPF(b *testing.B) {
    cpf := "123.456.789-09"
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        _ = patient.ValidateCPF(cpf)
    }
}

func BenchmarkValidateCPF_Invalid(b *testing.B) {
    cpf := "000.000.000-00"
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        _ = patient.ValidateCPF(cpf)
    }
}
```

## Benchmark with allocs (-benchmem)

```go
// pkg/slice/bench_test.go
func BenchmarkMap(b *testing.B) {
    input := make([]int, 1000)
    for i := range input { input[i] = i }

    b.ReportAllocs()
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        _ = slice.Map(input, func(v int) string { return fmt.Sprintf("%d", v) })
    }
}
```

Output:
```
BenchmarkMap-8    12345    95432 ns/op    81920 B/op    1001 allocs/op
```

- `ns/op` — nanoseconds per operation
- `B/op` — bytes allocated per operation
- `allocs/op` — number of heap allocations

## Benchmark Comparing Implementations

```go
// pkg/json/bench_test.go
var benchPatient = &patient.Patient{
    ID:   "p-bench-001",
    Name: "Benchmark Patient",
    CPF:  "123.456.789-09",
}

func BenchmarkMarshal_StdLib(b *testing.B) {
    b.ReportAllocs()
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        _, _ = json.Marshal(benchPatient)
    }
}

func BenchmarkMarshal_WithPool(b *testing.B) {
    b.ReportAllocs()
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        _, _ = jsonpool.Marshal(benchPatient)
    }
}
```

Run comparison:
```bash
go test -bench=BenchmarkMarshal -benchmem ./pkg/json/
# Then use benchstat for comparison:
go test -bench=. -benchmem -count=5 ./pkg/json/ | tee old.txt
# After change:
go test -bench=. -benchmem -count=5 ./pkg/json/ | tee new.txt
benchstat old.txt new.txt
```

## Sub-Benchmarks

```go
func BenchmarkHash(b *testing.B) {
    sizes := []int{100, 1000, 10000}
    for _, size := range sizes {
        size := size
        data := make([]byte, size)
        b.Run(fmt.Sprintf("size=%d", size), func(b *testing.B) {
            b.SetBytes(int64(size))
            b.ResetTimer()
            for i := 0; i < b.N; i++ {
                _ = sha256.Sum256(data)
            }
        })
    }
}
```

## Memory Profile During Benchmark

```bash
# Generate memory profile
go test -bench=BenchmarkMap -benchmem -memprofile=mem.out ./pkg/slice/

# Analyze
go tool pprof mem.out
(pprof) top10
(pprof) list slice.Map
```

## CPU Profile During Benchmark

```bash
go test -bench=BenchmarkValidateCPF -cpuprofile=cpu.out ./domain/patient/
go tool pprof cpu.out
(pprof) top10
(pprof) web  # opens graph in browser
```

## Running Benchmarks

```bash
# Run all benchmarks in package
go test -bench=. -benchmem ./pkg/...

# Run specific benchmark
go test -bench=BenchmarkValidateCPF -benchmem ./domain/patient/

# Run for longer (more stable results)
go test -bench=. -benchmem -benchtime=5s ./pkg/slice/

# Run N times for statistical stability (use with benchstat)
go test -bench=. -benchmem -count=10 ./pkg/slice/
```

## Benchmark in CI

Run benchmarks as part of CI to detect regressions:

```yaml
# .github/workflows/bench.yml
- name: Run benchmarks
  run: go test -bench=. -benchmem ./... 2>&1 | tee bench.txt

- name: Compare benchmarks
  if: github.event_name == 'pull_request'
  run: |
    git stash
    go test -bench=. -benchmem ./... 2>&1 | tee bench-base.txt
    git stash pop
    benchstat bench-base.txt bench.txt
```

## What to Benchmark

- CPF / date / input validators (called per request)
- JSON serialization for large response objects
- Cache key hashing / encoding
- DB query result mapping (toDomain functions)
- Pagination / sorting utilities in pkg/
