# Termination Grace Period

The amount of time Kubernetes waits for a container to gracefully shut down before forcefully terminating it.

## Default Value
30 seconds

## How It Works

1. Pod receives SIGTERM signal
2. Container has `terminationGracePeriodSeconds` to shut down gracefully
3. If container doesn't exit, SIGKILL is sent to force termination
4. Pod is removed

## Setting Termination Grace Period

```yaml
spec:
  terminationGracePeriodSeconds: 60
  containers:
  - name: app
    image: myapp:1.0
```

## Typical Use Cases

### Web Application
Need time to drain connection pools and close active requests.

```yaml
terminationGracePeriodSeconds: 30
```

### Database
Needs time to flush writes and close gracefully.

```yaml
terminationGracePeriodSeconds: 120
```

### Long-Running Job
Needs significant time to save state.

```yaml
terminationGracePeriodSeconds: 300
```

## Best Practices

1. **Combine with preStop hook** - preStop should complete before grace period expires
2. **Match with app shutdown time** - set grace period longer than app's shutdown time
3. **Default 30s is usually sufficient** - increase only if needed
4. **Monitor actual shutdown times** - adjust based on real behavior

## Example: Web Server with Graceful Shutdown

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-server
spec:
  terminationGracePeriodSeconds: 45
  containers:
  - name: app
    image: nginx:latest
    lifecycle:
      preStop:
        exec:
          command: ["/bin/sh", "-c", "nginx -s quit; while killall -0 nginx 2>/dev/null; do sleep 1; done"]
  restartPolicy: Always
```

This gives nginx up to 45 seconds to gracefully shut down before being killed.
