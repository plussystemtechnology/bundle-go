# Validation Errors

## Overview

Validation errors collect all field-level problems before returning,
so the client gets a complete picture in one response.

## ValidationError Type

```go
// pkg/apierror/validation.go
package apierror

import (
    "fmt"
    "strings"
)

type FieldError struct {
    Field   string `json:"field"`
    Message string `json:"message"`
    Value   any    `json:"value,omitempty"`
}

type ValidationError struct {
    Fields []FieldError
}

func (e *ValidationError) Error() string {
    msgs := make([]string, len(e.Fields))
    for i, f := range e.Fields {
        msgs[i] = fmt.Sprintf("%s: %s", f.Field, f.Message)
    }
    return "validation failed: " + strings.Join(msgs, "; ")
}

func (e *ValidationError) Add(field, msg string, value ...any) {
    fe := FieldError{Field: field, Message: msg}
    if len(value) > 0 {
        fe.Value = value[0]
    }
    e.Fields = append(e.Fields, fe)
}

func (e *ValidationError) HasErrors() bool { return len(e.Fields) > 0 }
```

## Domain Validator

```go
// domain/patient/validator.go
package patient

import (
    "regexp"
    "strings"
    "time"
    "unicode/utf8"
    "github.com/org/bundle-go/pkg/apierror"
)

var cpfRe = regexp.MustCompile(`^\d{3}\.\d{3}\.\d{3}-\d{2}$`)

// ValidateCreateInput validates a create patient request and returns all errors at once
func ValidateCreateInput(name, cpf string, birthDate time.Time) error {
    ve := &apierror.ValidationError{}

    if strings.TrimSpace(name) == "" {
        ve.Add("name", "name is required")
    } else if utf8.RuneCountInString(name) < 2 {
        ve.Add("name", "name must have at least 2 characters", name)
    } else if utf8.RuneCountInString(name) > 200 {
        ve.Add("name", "name must not exceed 200 characters")
    }

    if strings.TrimSpace(cpf) == "" {
        ve.Add("cpf", "CPF is required")
    } else if !cpfRe.MatchString(cpf) {
        ve.Add("cpf", "CPF must be in format 000.000.000-00", cpf)
    } else if !isValidCPF(cpf) {
        ve.Add("cpf", "CPF is not valid", cpf)
    }

    if birthDate.IsZero() {
        ve.Add("birth_date", "birth date is required")
    } else if birthDate.After(time.Now()) {
        ve.Add("birth_date", "birth date cannot be in the future", birthDate)
    } else if time.Since(birthDate) > 150*365*24*time.Hour {
        ve.Add("birth_date", "birth date seems unrealistic")
    }

    if ve.HasErrors() {
        return ve
    }
    return nil
}
```

## Using in App Service

```go
// app/service/patient_service.go
func (s *PatientService) CreatePatient(ctx context.Context, cmd dto.CreatePatientCommand) (*patient.Patient, error) {
    if err := patient.ValidateCreateInput(cmd.Name, cmd.CPF, cmd.BirthDate); err != nil {
        return nil, fmt.Errorf("create patient validate: %w", err)
    }
    // ... proceed with creation
}
```

## Handler Response

```go
// adapter/http/handler/patient_handler.go
func (h *PatientHandler) Create(c *gin.Context) {
    var req CreatePatientRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid JSON"})
        return
    }

    p, err := h.svc.CreatePatient(c.Request.Context(), toCreateCommand(req))
    if err != nil {
        var ve *apierror.ValidationError
        if errors.As(err, &ve) {
            c.JSON(http.StatusUnprocessableEntity, gin.H{
                "error":  "VALIDATION_ERROR",
                "fields": ve.Fields,
            })
            return
        }
        if errors.Is(err, patient.ErrCPFAlreadyExists) {
            c.JSON(http.StatusConflict, gin.H{"error": "CPF already registered"})
            return
        }
        h.logger.Error("create patient", zap.Error(err))
        c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
        return
    }

    c.JSON(http.StatusCreated, gin.H{"data": toResponse(p)})
}
```

Response body for validation error:
```json
{
  "error": "VALIDATION_ERROR",
  "fields": [
    {"field": "name", "message": "name is required"},
    {"field": "cpf",  "message": "CPF must be in format 000.000.000-00", "value": "123abc"}
  ]
}
```

## Gin Binding + Validation Tags

```go
// When using gin's built-in binding with go-playground/validator
type CreatePatientRequest struct {
    Name      string `json:"name"      binding:"required,min=2,max=200"`
    CPF       string `json:"cpf"       binding:"required"`
    BirthDate string `json:"birth_date" binding:"required"`
}

// Translate validator.ValidationErrors to our ValidationError
func toValidationError(err error) *apierror.ValidationError {
    var ve validator.ValidationErrors
    if !errors.As(err, &ve) {
        return nil
    }
    result := &apierror.ValidationError{}
    for _, fe := range ve {
        result.Add(
            strings.ToLower(fe.Field()),
            validationMessage(fe.Tag(), fe.Param()),
        )
    }
    return result
}

func validationMessage(tag, param string) string {
    switch tag {
    case "required": return "this field is required"
    case "min":      return fmt.Sprintf("minimum length is %s", param)
    case "max":      return fmt.Sprintf("maximum length is %s", param)
    case "email":    return "must be a valid email address"
    default:         return fmt.Sprintf("failed %s validation", tag)
    }
}
```
