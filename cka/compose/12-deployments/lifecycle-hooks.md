# Pod Lifecycle Hooks

Lifecycle hooks allow containers to be aware of events in their management lifecycle and run code when they occur.

## Types of Hooks

### 1. postStart
Executed immediately after a container is created. Does NOT wait for the container process to start.

### 2. preStop
Executed just before a container is terminated. Gives containers time to gracefully shut down.

## Hook Handler Types

### Exec
Executes a specific command inside the container.

```yaml
postStart:
  exec:
    command: ["/bin/sh", "-c", "echo 'Container started'"]
```

### HTTPGet
Makes an HTTP request to a specified endpoint.

```yaml
postStart:
  httpGet:
    host: localhost
    port: 8080
    path: /init
```

### TCPSocket
Performs a TCP check against a specific port.

```yaml
preStop:
  tcpSocket:
    port: 5432
```

## Important Notes

- **postStart is not guaranteed to execute before ENTRYPOINT** - use init containers for setup
- **preStop is synchronous** - Pod termination waits for preStop to complete
- Failure in preStop hook will cause Pod to immediately terminate
- preStop is useful for cleanup: closing database connections, draining requests, etc.
- postStart failures will restart the container (if RestartPolicy allows)

## Example: Graceful Shutdown with preStop

```yaml
lifecycle:
  preStop:
    exec:
      command: ["/bin/sh", "-c", "sleep 15"]
```

This gives the application 15 seconds to finish ongoing requests before termination.
