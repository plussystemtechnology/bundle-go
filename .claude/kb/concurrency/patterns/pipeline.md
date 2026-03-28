# Pipeline Pattern

## Overview

A pipeline transforms data through a series of stages, where each stage:
- Reads from an input channel
- Processes data
- Writes to an output channel
- Runs in its own goroutine

This enables parallel processing: stage N+1 processes while stage N is still producing.

## Basic Pipeline Structure

```go
// Each stage: func stageName(ctx, in <-chan T) <-chan U
// Source: func source(ctx) <-chan T
// Sink: consume the final channel

// Example: CSV import pipeline
// fetch → parse → validate → enrich → save
```

## Patient Import Pipeline

```go
// adapter/pipeline/patient_import.go
package pipeline

import (
    "context"
    "encoding/csv"
    "fmt"
    "io"
    "time"

    "go.uber.org/zap"
    "github.com/org/bundle-go/domain/patient"
    "github.com/org/bundle-go/port"
)

type ImportRecord struct {
    Line  int
    Name  string
    CPF   string
    Birth string
}

type ImportResult struct {
    Record ImportRecord
    Patient *patient.Patient
    Err     error
}

// Stage 1: Read CSV rows
func readCSV(ctx context.Context, r io.Reader) <-chan ImportRecord {
    out := make(chan ImportRecord)
    go func() {
        defer close(out)
        cr := csv.NewReader(r)
        cr.Read() // skip header
        for i := 1; ; i++ {
            row, err := cr.Read()
            if err == io.EOF { return }
            if err != nil {
                // non-fatal: skip bad rows
                continue
            }
            select {
            case out <- ImportRecord{Line: i, Name: row[0], CPF: row[1], Birth: row[2]}:
            case <-ctx.Done():
                return
            }
        }
    }()
    return out
}

// Stage 2: Validate records
func validateRecords(ctx context.Context, in <-chan ImportRecord) <-chan ImportRecord {
    out := make(chan ImportRecord)
    go func() {
        defer close(out)
        for {
            select {
            case rec, ok := <-in:
                if !ok { return }
                if rec.Name == "" || rec.CPF == "" { continue } // skip invalid
                select {
                case out <- rec:
                case <-ctx.Done():
                    return
                }
            case <-ctx.Done():
                return
            }
        }
    }()
    return out
}

// Stage 3: Transform to domain entity
func transformRecords(ctx context.Context, in <-chan ImportRecord) <-chan ImportResult {
    out := make(chan ImportResult)
    go func() {
        defer close(out)
        for {
            select {
            case rec, ok := <-in:
                if !ok { return }
                birth, err := time.Parse("2006-01-02", rec.Birth)
                var result ImportResult
                if err != nil {
                    result = ImportResult{Record: rec, Err: fmt.Errorf("line %d: invalid date: %w", rec.Line, err)}
                } else {
                    p := patient.New(rec.Name, rec.CPF, birth)
                    result = ImportResult{Record: rec, Patient: p}
                }
                select {
                case out <- result:
                case <-ctx.Done():
                    return
                }
            case <-ctx.Done():
                return
            }
        }
    }()
    return out
}

// Stage 4: Save to DB (bounded concurrency)
func saveRecords(ctx context.Context, in <-chan ImportResult, repo port.PatientRepository, workers int) <-chan ImportResult {
    out := make(chan ImportResult, workers)
    go func() {
        defer close(out)
        sem := make(chan struct{}, workers)
        for result := range in {
            if result.Err != nil {
                out <- result
                continue
            }
            result := result
            sem <- struct{}{}
            go func() {
                defer func() { <-sem }()
                if err := repo.Save(ctx, result.Patient); err != nil {
                    result.Err = fmt.Errorf("save patient line %d: %w", result.Record.Line, err)
                }
                select {
                case out <- result:
                case <-ctx.Done():
                }
            }()
        }
        // drain semaphore
        for i := 0; i < workers; i++ { sem <- struct{}{} }
    }()
    return out
}

// Run assembles and runs the pipeline
func RunPatientImport(ctx context.Context, r io.Reader, repo port.PatientRepository, logger *zap.Logger) (int, []error) {
    records   := readCSV(ctx, r)
    validated := validateRecords(ctx, records)
    results   := transformRecords(ctx, validated)
    saved     := saveRecords(ctx, results, repo, 10)

    var (
        success int
        errs    []error
    )
    for res := range saved {
        if res.Err != nil {
            errs = append(errs, res.Err)
            logger.Warn("import error", zap.Error(res.Err))
        } else {
            success++
        }
    }
    return success, errs
}
```

## Pipeline with Merge

When multiple goroutines write to a stage's output, merge their channels:

```go
func merge[T any](ctx context.Context, channels ...<-chan T) <-chan T {
    out := make(chan T)
    var wg sync.WaitGroup

    output := func(c <-chan T) {
        defer wg.Done()
        for v := range c {
            select {
            case out <- v:
            case <-ctx.Done():
                return
            }
        }
    }

    wg.Add(len(channels))
    for _, c := range channels {
        go output(c)
    }

    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}
```

## Key Principles

- Each stage owns its output channel and closes it when done
- Context cancellation propagates through every `select`
- Never close an input channel (you don't own it)
- Use buffered channels between stages to avoid blocking (decouple stages)
- Bounded concurrency in I/O stages prevents DB overload
