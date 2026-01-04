# Pod Disruption Budgets (PDB)

Pod Disruption Budgets are policies to maintain application availability during cluster maintenance or node failures.

## What is a Disruption?

A voluntary disruption is when cluster operations intentionally remove or drain Pods:
- Node maintenance
- Cluster upgrades
- Manual Pod deletion
- Horizontal Pod Autoscaler scaling down

Non-voluntary disruptions (hardware failures, network partitions) are NOT covered by PDB.

## PDB Specification

### minAvailable
Minimum number of Pods that must remain available.

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: web-server
```

Ensures at least 2 web-server Pods remain available.

### maxUnavailable
Maximum number of Pods that can be unavailable.

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: database-pdb
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app: postgres
```

Allows only 1 database Pod to be unavailable at a time.

## Percentage-Based PDB

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
spec:
  minAvailable: "50%"
  selector:
    matchLabels:
      app: myapp
```

Maintains at least 50% of Pods available.

## Real-World Example

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: critical-app-pdb
  namespace: production
spec:
  minAvailable: 3
  selector:
    matchLabels:
      tier: critical
      app: api-server
```

Ensures a critical API server always has at least 3 Pods running during maintenance.

## Best Practices

1. **Use minAvailable for critical apps** - API servers, databases
2. **Use maxUnavailable for less critical** - Batch processors, workers
3. **Set realistic values** - Too strict (minAvailable: 10 out of 10) prevents maintenance
4. **Monitor PDB status** - Check if Pods are blocked from disruption

## Checking PDB Status

```bash
kubectl get pdb
kubectl describe pdb <name>

# Output shows:
# Allowed Disruptions: X  (how many Pods can be disrupted)
```

## Limitations

- PDB only prevents **voluntary disruptions**
- Does NOT protect against node hardware failures
- Does NOT work with StaticPods
- Requires at least minAvailable/maxUnavailable replicas running
