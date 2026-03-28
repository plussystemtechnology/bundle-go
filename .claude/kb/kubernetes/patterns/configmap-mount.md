# ConfigMap Mount Patterns

## Environment Variables (Simple)

```yaml
envFrom:
  - configMapRef:
      name: api-config
```

## Volume Mount (Config Files)

```yaml
volumes:
  - name: config
    configMap:
      name: api-config
      items:
        - key: config.yaml
          path: config.yaml
containers:
  - volumeMounts:
      - name: config
        mountPath: /etc/app/config.yaml
        subPath: config.yaml
        readOnly: true
```

## Go Code to Read Mounted Config

```go
func LoadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("read config: %w", err)
    }
    var cfg Config
    if err := yaml.Unmarshal(data, &cfg); err != nil {
        return nil, fmt.Errorf("parse config: %w", err)
    }
    return &cfg, nil
}
```

## Auto-Reload with fsnotify

ConfigMaps mounted as volumes update automatically. Watch for changes:

```go
watcher, _ := fsnotify.NewWatcher()
watcher.Add("/etc/app/config.yaml")
for event := range watcher.Events {
    if event.Op&fsnotify.Write == fsnotify.Write {
        reloadConfig()
    }
}
```
