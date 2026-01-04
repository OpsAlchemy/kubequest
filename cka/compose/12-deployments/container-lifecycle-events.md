# Container Lifecycle Events

Container lifecycle events track the state transitions of a container from creation to termination.

## Container States

### Waiting
Container is not yet running. Reasons include:
- **PullBackOff** - Failed to pull image
- **CrashLoopBackOff** - Container keeps crashing
- **CreateContainerConfigError** - Invalid config
- **ImagePullBackOff** - Can't access image registry

```bash
kubectl describe pod <pod-name>
# Shows: State: Waiting, Reason: ImagePullBackOff
```

### Running
Container is executing and healthy.

```yaml
State:
  Running
  Started: 2026-01-03T11:00:00Z
```

### Terminated
Container has finished execution. Can be due to:
- Successful exit (exit code 0)
- Failure (non-zero exit code)
- Signal (SIGKILL, SIGTERM)
- Resource limit exceeded

```yaml
State:
  Terminated
  Exit Code: 137  # SIGKILL
  Reason: OOMKilled
  Message: Out of memory
```

## Lifecycle Hooks (Related)

### postStart
Runs right after container starts (not guaranteed before ENTRYPOINT).

```yaml
lifecycle:
  postStart:
    exec:
      command: ["/bin/sh", "-c", "echo 'Started'"]
```

### preStop
Runs before container is terminated.

```yaml
lifecycle:
  preStop:
    exec:
      command: ["/bin/sh", "-c", "sleep 15"]
```

## Monitoring Container Lifecycle

```bash
# View detailed container state
kubectl describe pod <pod-name>

# Watch state transitions in real-time
kubectl get pods -w

# Check container logs
kubectl logs <pod-name> <container-name>

# View previous logs (if container restarted)
kubectl logs <pod-name> <container-name> --previous
```

## Exit Codes and Signals

| Exit Code | Meaning |
|-----------|---------|
| 0 | Success |
| 1-127 | Application error |
| 128+N | Killed by signal N |
| 137 | SIGKILL (OOMKilled) |
| 143 | SIGTERM (Graceful shutdown) |

## Example: Tracking Lifecycle

```bash
# Pod starts
kubectl get pods
# NAME              READY   STATUS
# myapp-abc123      0/1     Pending

# Container is pulling image
# STATUS: PullImage

# Container is running
# READY: 1/1, STATUS: Running

# Container crashes
# READY: 0/1, STATUS: CrashLoopBackOff
# Check logs: kubectl logs <pod-name>
```

## Restarting Container vs Pod

- **Container restart** - Only the container restarts, increment restart count
- **Pod restart** - Entire Pod is terminated and recreated

Container restarts (controlled by RestartPolicy) are less disruptive than Pod restarts.
