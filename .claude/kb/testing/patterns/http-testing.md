# HTTP Testing with httptest

## Overview

Use `net/http/httptest` to test HTTP handlers without starting a real server.
No ports, no network, fast and deterministic.

## Basic Setup with Gin

```go
// adapter/http/handler/patient_handler_test.go
package handler_test

import (
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "strings"
    "testing"

    "github.com/gin-gonic/gin"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
    "go.uber.org/zap"
    "github.com/org/noxcare-go/adapter/http/handler"
    "github.com/org/noxcare-go/domain/patient"
)

func init() {
    gin.SetMode(gin.TestMode)  // silence Gin debug output
}

func setupRouter(h *handler.PatientHandler) *gin.Engine {
    r := gin.New()
    r.GET("/patients/:id", h.Get)
    r.POST("/patients", h.Create)
    r.PUT("/patients/:id", h.Update)
    r.DELETE("/patients/:id", h.Delete)
    return r
}
```

## GET Handler Test

```go
func TestPatientHandler_Get(t *testing.T) {
    tests := []struct {
        name       string
        id         string
        svcResult  *patient.Patient
        svcErr     error
        wantStatus int
        wantName   string
    }{
        {
            name:       "found",
            id:         "p-123",
            svcResult:  &patient.Patient{ID: "p-123", Name: "Alice"},
            wantStatus: http.StatusOK,
            wantName:   "Alice",
        },
        {
            name:       "not found",
            id:         "p-999",
            svcErr:     patient.ErrNotFound,
            wantStatus: http.StatusNotFound,
        },
        {
            name:       "internal error",
            id:         "p-err",
            svcErr:     errors.New("db down"),
            wantStatus: http.StatusInternalServerError,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            svc := &mockPatientService{
                getResult: tt.svcResult,
                getErr:    tt.svcErr,
            }
            h      := handler.NewPatientHandler(svc, zap.NewNop())
            router := setupRouter(h)

            w   := httptest.NewRecorder()
            req := httptest.NewRequest(http.MethodGet, "/patients/"+tt.id, nil)
            router.ServeHTTP(w, req)

            assert.Equal(t, tt.wantStatus, w.Code)
            if tt.wantName != "" {
                var resp map[string]any
                require.NoError(t, json.Unmarshal(w.Body.Bytes(), &resp))
                data := resp["data"].(map[string]any)
                assert.Equal(t, tt.wantName, data["name"])
            }
        })
    }
}
```

## POST Handler Test

```go
func TestPatientHandler_Create(t *testing.T) {
    tests := []struct {
        name       string
        body       string
        svcResult  *patient.Patient
        svcErr     error
        wantStatus int
    }{
        {
            name:       "created",
            body:       `{"name":"Alice","cpf":"123.456.789-09","birth_date":"1990-01-15"}`,
            svcResult:  &patient.Patient{ID: "p-new", Name: "Alice"},
            wantStatus: http.StatusCreated,
        },
        {
            name:       "invalid json",
            body:       `not json`,
            wantStatus: http.StatusBadRequest,
        },
        {
            name:       "cpf conflict",
            body:       `{"name":"Bob","cpf":"123.456.789-09"}`,
            svcErr:     patient.ErrCPFAlreadyExists,
            wantStatus: http.StatusConflict,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            svc := &mockPatientService{
                createResult: tt.svcResult,
                createErr:    tt.svcErr,
            }
            h      := handler.NewPatientHandler(svc, zap.NewNop())
            router := setupRouter(h)

            w   := httptest.NewRecorder()
            req := httptest.NewRequest(http.MethodPost, "/patients",
                strings.NewReader(tt.body))
            req.Header.Set("Content-Type", "application/json")
            router.ServeHTTP(w, req)

            assert.Equal(t, tt.wantStatus, w.Code)
        })
    }
}
```

## Testing Middleware

```go
func TestAuthMiddleware(t *testing.T) {
    r := gin.New()
    r.Use(middleware.Auth(mockAuthService))
    r.GET("/protected", func(c *gin.Context) {
        userID, _ := ctxkey.UserID(c.Request.Context())
        c.JSON(200, gin.H{"user_id": userID})
    })

    t.Run("valid token", func(t *testing.T) {
        w   := httptest.NewRecorder()
        req := httptest.NewRequest("GET", "/protected", nil)
        req.Header.Set("Authorization", "Bearer valid-token")
        r.ServeHTTP(w, req)
        assert.Equal(t, 200, w.Code)
    })

    t.Run("missing token", func(t *testing.T) {
        w   := httptest.NewRecorder()
        req := httptest.NewRequest("GET", "/protected", nil)
        r.ServeHTTP(w, req)
        assert.Equal(t, 401, w.Code)
    })
}
```

## Assertion Helpers

```go
// Assert JSON response body field
func assertJSONField(t *testing.T, body *bytes.Buffer, path string, expected any) {
    t.Helper()
    var data map[string]any
    require.NoError(t, json.Unmarshal(body.Bytes(), &data))
    // navigate path like "data.name"
    parts := strings.Split(path, ".")
    var current any = data
    for _, p := range parts {
        m, ok := current.(map[string]any)
        require.True(t, ok, "path %q: expected object at %q", path, p)
        current = m[p]
    }
    assert.Equal(t, expected, current)
}

// Usage
assertJSONField(t, w.Body, "data.name", "Alice")
assertJSONField(t, w.Body, "error", "PATIENT_NOT_FOUND")
```

## Mock Service for Handler Tests

```go
type mockPatientService struct {
    getResult    *patient.Patient
    getErr       error
    createResult *patient.Patient
    createErr    error
}

func (m *mockPatientService) GetPatient(_ context.Context, _ string) (*patient.Patient, error) {
    return m.getResult, m.getErr
}
func (m *mockPatientService) CreatePatient(_ context.Context, _ dto.CreatePatientCommand) (*patient.Patient, error) {
    return m.createResult, m.createErr
}
```
