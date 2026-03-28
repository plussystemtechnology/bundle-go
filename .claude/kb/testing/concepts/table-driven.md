# Table-Driven Tests

## Why Table-Driven?

- Add a test case by adding one struct literal
- All cases run with the same setup/teardown
- `-run TestX/case_name` runs a single case
- Easy to see all cases at a glance

## Basic Structure

```go
func TestValidateCPF(t *testing.T) {
    tests := []struct {
        name    string
        cpf     string
        wantErr bool
    }{
        {name: "valid cpf", cpf: "123.456.789-09", wantErr: false},
        {name: "empty string", cpf: "", wantErr: true},
        {name: "digits only", cpf: "12345678909", wantErr: true},
        {name: "wrong format", cpf: "123-456-789.09", wantErr: true},
        {name: "all zeros", cpf: "000.000.000-00", wantErr: true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := patient.ValidateCPF(tt.cpf)
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
            }
        })
    }
}
```

## Table-Driven with Multiple Return Values

```go
func TestPatientService_GetPatient(t *testing.T) {
    tests := []struct {
        name        string
        patientID   string
        repoResult  *patient.Patient
        repoErr     error
        wantPatient *patient.Patient
        wantErr     bool
        wantErrIs   error  // specific sentinel to check
    }{
        {
            name:       "found",
            patientID:  "p-123",
            repoResult: &patient.Patient{ID: "p-123", Name: "Alice"},
            wantPatient: &patient.Patient{ID: "p-123", Name: "Alice"},
        },
        {
            name:      "not found",
            patientID: "p-999",
            repoErr:   patient.ErrNotFound,
            wantErr:   true,
            wantErrIs: patient.ErrNotFound,
        },
        {
            name:      "db error",
            patientID: "p-123",
            repoErr:   errors.New("connection reset"),
            wantErr:   true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            repo := &mockPatientRepo{
                findByIDFn: func(_ context.Context, _ string) (*patient.Patient, error) {
                    return tt.repoResult, tt.repoErr
                },
            }
            svc := service.NewPatientService(repo, testLogger())

            got, err := svc.GetPatient(context.Background(), tt.patientID)

            if tt.wantErr {
                require.Error(t, err)
                if tt.wantErrIs != nil {
                    assert.ErrorIs(t, err, tt.wantErrIs)
                }
                assert.Nil(t, got)
                return
            }

            require.NoError(t, err)
            assert.Equal(t, tt.wantPatient, got)
        })
    }
}
```

## Table-Driven HTTP Tests

```go
func TestPatientHandler_Create(t *testing.T) {
    tests := []struct {
        name       string
        body       string
        svcErr     error
        wantStatus int
        wantBody   string
    }{
        {
            name:       "success",
            body:       `{"name":"Alice","cpf":"123.456.789-09"}`,
            wantStatus: http.StatusCreated,
        },
        {
            name:       "bad json",
            body:       `{invalid}`,
            wantStatus: http.StatusBadRequest,
        },
        {
            name:       "service error - cpf exists",
            body:       `{"name":"Bob","cpf":"123.456.789-09"}`,
            svcErr:     patient.ErrCPFAlreadyExists,
            wantStatus: http.StatusConflict,
        },
        {
            name:       "service error - internal",
            body:       `{"name":"Carol","cpf":"111.222.333-44"}`,
            svcErr:     errors.New("db down"),
            wantStatus: http.StatusInternalServerError,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            router := gin.New()
            svc := &mockPatientService{createErr: tt.svcErr}
            h   := handler.NewPatientHandler(svc, zap.NewNop())
            router.POST("/patients", h.Create)

            w := httptest.NewRecorder()
            req := httptest.NewRequest(http.MethodPost, "/patients",
                strings.NewReader(tt.body))
            req.Header.Set("Content-Type", "application/json")
            router.ServeHTTP(w, req)

            assert.Equal(t, tt.wantStatus, w.Code)
            if tt.wantBody != "" {
                assert.Contains(t, w.Body.String(), tt.wantBody)
            }
        })
    }
}
```

## Subtests and Parallelism

```go
func TestSomething(t *testing.T) {
    tests := []struct{ ... }{ ... }

    for _, tt := range tests {
        tt := tt  // capture (required pre-Go 1.22)
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()  // run test cases in parallel
            // test body
        })
    }
}
```

Use `t.Parallel()` when test cases are truly independent and don't share state.

## Naming Convention

- Test case names: lowercase, spaces OK, describe scenario
- `"success"`, `"not found"`, `"invalid cpf format"`, `"db connection error"`
- Use `-run TestFoo/not_found` (spaces become underscores in filter)

## Test Helpers (reduce repetition)

```go
// testdata helpers
func newTestPatient(t *testing.T, opts ...func(*patient.Patient)) *patient.Patient {
    t.Helper()
    p := &patient.Patient{
        ID:     "p-test",
        Name:   "Test Patient",
        CPF:    "123.456.789-09",
        Active: true,
    }
    for _, opt := range opts { opt(p) }
    return p
}

// Usage
p := newTestPatient(t, func(p *patient.Patient) { p.Active = false })
```
