# Update Strategies

Update strategies define how Pods are updated when a Deployment changes (e.g., new image version).

## RollingUpdate (Default)

Gradually replaces old Pods with new ones to maintain availability.

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

### Parameters

**maxSurge**
- Maximum number of Pods above the desired replica count
- Default: 1
- Allows creating additional Pods during update for testing

```yaml
# Desired: 3 Pods
# maxSurge: 2
# During update: up to 5 Pods running temporarily
maxSurge: 2
```

**maxUnavailable**
- Maximum number of Pods that can be unavailable
- Default: 1
- Higher value = faster update, lower availability
- Set to 0 for zero-downtime deployments

```yaml
# Zero-downtime update
maxUnavailable: 0
maxSurge: 1
```

## Recreate

Terminates all old Pods before starting new ones. Causes downtime.

```yaml
spec:
  strategy:
    type: Recreate
```

**Use Case:** Development/testing environments where downtime is acceptable.

**Behavior:**
1. All existing Pods are terminated
2. All new Pods are created
3. Brief service unavailability

## Update Strategy Selection

### RollingUpdate - Production
```yaml
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

Ensures at least 3 Pods always available.

### Recreate - Development
```yaml
spec:
  replicas: 1
  strategy:
    type: Recreate
```

Simple and fast for non-critical environments.

### Aggressive RollingUpdate - Fast Updates
```yaml
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
```

Balances speed and availability.

## Blue-Green Deployment Pattern

Not a built-in strategy, but achievable with manual Deployment management:

1. Create "blue" Deployment with current version
2. Create "green" Deployment with new version
3. Switch Service selector from blue to green
4. Delete old blue Deployment

```yaml
# Blue Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-blue
spec:
  template:
    metadata:
      labels:
        version: blue
---
# Service routes to current version
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    version: blue  # Points to blue or green
```

## Canary Deployment Pattern

Gradually roll out new version to small percentage of users:

1. Keep most replicas on old version
2. Add few replicas with new version
3. Monitor metrics
4. Gradually increase new version replicas
5. Remove old version

```bash
# Initial: 9 old Pods, 1 new Pod
# Monitor: Check metrics on new Pod
# 9 old, 2 new → 8 old, 3 new → ... until fully updated
```

## Monitoring Updates

```bash
# Watch update progress
kubectl rollout status deployment <deployment-name>

# View update history
kubectl rollout history deployment <deployment-name>

# Rollback to previous version
kubectl rollout undo deployment <deployment-name>
```
