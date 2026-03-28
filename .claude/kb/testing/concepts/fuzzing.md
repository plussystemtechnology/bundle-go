# Fuzz Testing (Go 1.18+)

## What Is Fuzzing?

The fuzzer generates random inputs to find crashes, panics, or logic errors
in functions that handle untrusted input. Perfect for:
- Parsers (CPF, date, JSON)
- Validators
- Encoders/decoders
- String manipulation

## Syntax

```go
func FuzzXxx(f *testing.F) {
    // Seed corpus — known interesting inputs
    f.Add("input1")
    f.Add("input2")

    // Fuzz target
    f.Fuzz(func(t *testing.T, input string) {
        // Must not panic, must not hang
        result, err := Parse(input)
        if err == nil {
            // If it succeeded, verify the output is valid
            assert.NotEmpty(t, result)
        }
    })
}
```

## Fuzz CPF Validator

```go
// domain/patient/validate_fuzz_test.go
package patient_test

import (
    "testing"
    "github.com/org/bundle-go/domain/patient"
)

func FuzzValidateCPF(f *testing.F) {
    // Seed corpus with interesting cases
    f.Add("123.456.789-09")
    f.Add("000.000.000-00")
    f.Add("")
    f.Add("not-a-cpf")
    f.Add("111.111.111-11")
    f.Add("99999999999")
    f.Add("123456789-09")

    f.Fuzz(func(t *testing.T, cpf string) {
        // Must never panic
        _ = patient.ValidateCPF(cpf)
    })
}
```

## Fuzz JSON Parser

```go
// adapter/http/handler/parse_fuzz_test.go
func FuzzParseCreatePatientRequest(f *testing.F) {
    f.Add(`{"name":"Alice","cpf":"123.456.789-09"}`)
    f.Add(`{}`)
    f.Add(`{"name":""}`)

    f.Fuzz(func(t *testing.T, body string) {
        var req CreatePatientRequest
        // Must not panic on arbitrary JSON
        _ = json.Unmarshal([]byte(body), &req)
    })
}
```

## Fuzz a Data Transformer

```go
// Round-trip fuzz: encode → decode should return equal value
func FuzzPatientMarshal(f *testing.F) {
    f.Add("Alice", "123.456.789-09")

    f.Fuzz(func(t *testing.T, name, cpf string) {
        p := &patient.Patient{Name: name, CPF: cpf}

        data, err := json.Marshal(p)
        if err != nil { return }

        var p2 patient.Patient
        if err := json.Unmarshal(data, &p2); err != nil {
            t.Fatalf("unmarshal failed after successful marshal: %v", err)
        }

        if p.Name != p2.Name {
            t.Fatalf("name mismatch: %q != %q", p.Name, p2.Name)
        }
    })
}
```

## Running Fuzz Tests

```bash
# Run as regular test (uses corpus only, no fuzzing)
go test -run FuzzValidateCPF ./domain/patient/

# Run fuzzer for 30 seconds
go test -fuzz=FuzzValidateCPF -fuzztime=30s ./domain/patient/

# Run indefinitely (until failure or Ctrl+C)
go test -fuzz=FuzzValidateCPF ./domain/patient/

# Run all fuzz tests for 1 minute each
go test -fuzz=. -fuzztime=1m ./...
```

## Corpus Files

When the fuzzer finds a failure, it saves the input to `testdata/fuzz/FuzzXxx/`:

```
domain/patient/testdata/fuzz/FuzzValidateCPF/
    abc123def          # found crash input
    corpus1            # manually added corpus
```

These files are committed and replayed on every `go test -run FuzzXxx`.

## Fuzz Constraints

- Fuzz targets must only use `testing.T` (no `testing.M`)
- Only `string`, `[]byte`, `int`, `uint`, `bool`, `float` are supported seed types
- Each fuzz call must be deterministic — no random inside `f.Fuzz`
- The fuzz target must not rely on global state

## CI Integration

Run corpus-only (no actual fuzzing) in CI:

```yaml
# .github/workflows/test.yml
- name: Run fuzz tests (corpus only)
  run: go test -run "^Fuzz" ./...
```

Run fuzzing on schedule or dedicated job:

```yaml
- name: Fuzz 5 minutes
  run: |
    for pkg in ./domain/patient ./pkg/...; do
      go test -fuzz=. -fuzztime=5m $pkg || true
    done
```
