# Golden Files

## Overview

Golden files store expected outputs in files under `testdata/`.
On test run, actual output is compared to the golden file.
To update: run with `-update-golden` flag.

Perfect for: JSON responses, generated SQL, HTML output, large structs.

## Implementation

```go
// testutil/golden/golden.go
package golden

import (
    "flag"
    "os"
    "path/filepath"
    "testing"

    "github.com/stretchr/testify/require"
)

var update = flag.Bool("update-golden", false, "update golden files")

// Assert compares actual to the golden file, or writes golden file if -update-golden
func Assert(t *testing.T, name string, actual []byte) {
    t.Helper()
    path := filepath.Join("testdata", "golden", name)

    if *update {
        require.NoError(t, os.MkdirAll(filepath.Dir(path), 0755))
        require.NoError(t, os.WriteFile(path, actual, 0644))
        t.Logf("updated golden file: %s", path)
        return
    }

    expected, err := os.ReadFile(path)
    if os.IsNotExist(err) {
        t.Fatalf("golden file not found: %s\nRun with -update-golden to create it", path)
    }
    require.NoError(t, err)

    if string(expected) != string(actual) {
        t.Errorf("golden file mismatch: %s\n--- want ---\n%s\n--- got ---\n%s",
            path, expected, actual)
    }
}

// AssertJSON normalizes JSON before comparing (handles key ordering)
func AssertJSON(t *testing.T, name string, actual any) {
    t.Helper()
    data, err := json.MarshalIndent(actual, "", "  ")
    require.NoError(t, err)
    data = append(data, '\n')
    Assert(t, name+".json", data)
}
```

## Using Golden Files for HTTP Response Tests

```go
// adapter/http/handler/patient_handler_test.go
func TestPatientHandler_GetDashboard(t *testing.T) {
    svc := &mockDashboardService{
        result: &dto.DashboardResponse{
            TotalPatients:      142,
            AppointmentsToday:  8,
            PendingReports:     3,
        },
    }
    h := handler.NewDashboardHandler(svc, zap.NewNop())

    r := gin.New()
    r.GET("/dashboard", h.Get)

    w   := httptest.NewRecorder()
    req := httptest.NewRequest("GET", "/dashboard", nil)
    r.ServeHTTP(w, req)

    require.Equal(t, http.StatusOK, w.Code)

    // Compare to golden file
    golden.Assert(t, "get_dashboard_response", w.Body.Bytes())
}
```

Golden file at `testdata/golden/get_dashboard_response`:
```json
{
  "data": {
    "total_patients": 142,
    "appointments_today": 8,
    "pending_reports": 3
  }
}
```

## Updating Golden Files

```bash
# Update all golden files
go test -update-golden ./adapter/http/...

# Update specific test
go test -update-golden -run TestDashboard ./adapter/http/handler/
```

## Golden Files for SQL Queries

Test that sqlc-generated queries produce expected SQL:

```go
func TestBuildPatientQuery(t *testing.T) {
    tests := []struct{ name string; q *QueryBuilder }{
        {
            name: "active_patients_by_doctor",
            q: querybuilder.New("patients").
                Where("doctor_id", "doc-1").
                Where("active", true).
                OrderBy("name", "ASC").
                Limit(10),
        },
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            sql, _, err := tt.q.Build()
            require.NoError(t, err)
            golden.Assert(t, "sql/"+tt.name+".sql", []byte(sql+"\n"))
        })
    }
}
```

## File Organization

```
adapter/http/handler/
    testdata/
        golden/
            get_patient_response.json
            list_patients_response.json
            get_dashboard_response.json
            create_patient_201.json
            get_patient_404.json

adapter/db/repo/
    testdata/
        schema.sql          // used by testcontainers
        golden/
            sql/
                find_active_patients.sql
```

## When to Use Golden Files

- Response bodies with many fields (10+)
- Generated output (SQL, HTML templates)
- Output that changes rarely but needs exact comparison
- When `assert.Equal` with a large struct hurts readability
- API contract regression tests

## When NOT to Use

- Simple responses (`{"id": "123"}`) — inline assertion is clearer
- Outputs containing timestamps or random IDs — normalize first
