# Custom Validators Pattern

## Registering Custom Validation

```go
func RegisterCustomValidators(v *validator.Validate) {
    v.RegisterValidation("slug", validateSlug)
    v.RegisterValidation("phone_br", validateBrazilianPhone)
    v.RegisterValidation("cpf", validateCPF)
}

func validateSlug(fl validator.FieldLevel) bool {
    slug := fl.Field().String()
    matched, _ := regexp.MatchString(`^[a-z0-9]+(-[a-z0-9]+)*$`, slug)
    return matched
}

func validateBrazilianPhone(fl validator.FieldLevel) bool {
    phone := fl.Field().String()
    matched, _ := regexp.MatchString(`^\+55\d{10,11}$`, phone)
    return matched
}
```

## Setup in Gin

```go
func setupValidator() {
    if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
        RegisterCustomValidators(v)

        // Use JSON tag names in error messages
        v.RegisterTagNameFunc(func(fld reflect.StructField) string {
            name := strings.SplitN(fld.Tag.Get("json"), ",", 2)[0]
            if name == "-" {
                return ""
            }
            return name
        })
    }
}
```

## Usage in Structs

```go
type CreateProductRequest struct {
    Name  string `json:"name"  binding:"required,min=2"`
    Slug  string `json:"slug"  binding:"required,slug"`
    Phone string `json:"phone" binding:"omitempty,phone_br"`
}
```
