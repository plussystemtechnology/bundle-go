# OAuth2

## Authorization Code Flow

```go
import "golang.org/x/oauth2"

func NewOAuth2Config(cfg config.OAuth2) *oauth2.Config {
    return &oauth2.Config{
        ClientID:     cfg.ClientID,
        ClientSecret: cfg.ClientSecret,
        Endpoint: oauth2.Endpoint{
            AuthURL:  cfg.AuthURL,
            TokenURL: cfg.TokenURL,
        },
        RedirectURL: cfg.RedirectURL,
        Scopes:      []string{"openid", "profile", "email"},
    }
}

// Step 1: Redirect to provider
func (h *AuthHandler) Login(c *gin.Context) {
    state := generateState()
    storeState(c, state)
    url := h.oauth2Config.AuthCodeURL(state)
    c.Redirect(http.StatusTemporaryRedirect, url)
}

// Step 2: Handle callback
func (h *AuthHandler) Callback(c *gin.Context) {
    if !validateState(c, c.Query("state")) {
        c.AbortWithStatus(http.StatusBadRequest)
        return
    }

    token, err := h.oauth2Config.Exchange(c.Request.Context(), c.Query("code"))
    if err != nil {
        c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "token exchange failed"})
        return
    }

    // Extract ID token from OAuth2 token
    rawIDToken, ok := token.Extra("id_token").(string)
    if !ok {
        c.AbortWithStatus(http.StatusInternalServerError)
        return
    }

    // Verify and use the ID token
    idToken, err := h.verifier.Verify(c.Request.Context(), rawIDToken)
    // ...
}
```
