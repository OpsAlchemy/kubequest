# Restart Policies

RestartPolicy determines what happens to a Pod when its containers exit or are terminated.

## Available Restart Policies

### Always (Default)
Container is always restarted if it exits, regardless of exit code.

```yaml
spec:
  restartPolicy: Always
  containers:
  - name: app
    image: myapp:1.0
```

**Use Case:** Deployments, Services, web servers that should always be running.

### OnFailure
Container is restarted only if it exits with a non-zero exit code.

```yaml
spec:
  restartPolicy: OnFailure
  containers:
  - name: job
    image: batch-job:1.0
```

**Use Case:** Jobs that should retry on failure but not restart on successful completion.

### Never
Container is never restarted, even if it fails.

```yaml
spec:
  restartPolicy: Never
  containers:
  - name: one-time-task
    image: init-task:1.0
```

**Use Case:** Jobs, one-time scripts, initialization tasks.

## Restart Behavior Details

- **Restart delay increases exponentially** - 100ms, 200ms, 400ms, 800ms, 1.6s, 3.2s, etc.
- **Max restart delay is capped at 5 minutes**
- **Restarts count toward resource quotas**
- **CrashLoopBackOff** state occurs when container keeps crashing

## Pod-Level vs Container-Level

RestartPolicy is specified at Pod level and applies to all containers in the Pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  restartPolicy: OnFailure
  containers:
  - name: container1
    image: image1:1.0
  - name: container2
    image: image2:1.0
```

Both containers follow the same restart policy.

## Important Notes

- If a container exit code is 0, it's considered successful (no restart with OnFailure)
- Deployments override RestartPolicy for individual container restarts
- StatefulSets and DaemonSets typically use Always
- CronJobs and Jobs typically use Never or OnFailure

## Checking Restart Count

```bash
kubectl get pods
kubectl describe pod <pod-name>  # Shows 'Restarts' column
```
