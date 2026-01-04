---

## Solution — HPA (Memory with Custom Behavior)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: mem-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: mem-hpa
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      policies:
      - type: Pods
        value: 2
        periodSeconds: 30
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Pods
        value: 1
        periodSeconds: 60
```

---

## Solution — HPA (CPU + Memory with Complex Behavior)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: multi-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: multi-hpa
  minReplicas: 2
  maxReplicas: 8
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 65
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 75
  behavior:
    scaleUp:
      selectPolicy: Max
      policies:
      - type: Pods
        value: 4
        periodSeconds: 30
      - type: Percent
        value: 50
        periodSeconds: 30
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Pods
        value: 1
        periodSeconds: 90
```

---

## Solution — VPA Off Mode

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: vpa-off
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: vpa-off
  updatePolicy:
    updateMode: Off
  resourcePolicy:
    containerPolicies:
    - containerName: app
      controlledResources: ["cpu", "memory"]
      minAllowed:
        cpu: 30m
        memory: 40Mi
      maxAllowed:
        cpu: 200m
        memory: 200Mi
```

---

## Solution — VPA Initial Mode

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: vpa-initial
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: vpa-initial
  updatePolicy:
    updateMode: Initial
  resourcePolicy:
    containerPolicies:
    - containerName: app
      controlledResources: ["cpu", "memory"]
      minAllowed:
        cpu: 20m
        memory: 30Mi
      maxAllowed:
        cpu: 100m
        memory: 100Mi
```

---

## Solution — VPA Auto Mode

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: vpa-auto
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: vpa-auto
  updatePolicy:
    updateMode: Auto
  resourcePolicy:
    containerPolicies:
    - containerName: app
      controlledResources: ["cpu", "memory"]
      minAllowed:
        cpu: 20m
        memory: 30Mi
      maxAllowed:
        cpu: 150m
        memory: 200Mi
```

---

# HINTS

```text
HPA scales replicas using resource requests, never limits.
Memory HPA requires usage well above the request to be observable.
Multi-metric HPA chooses the highest desired replica count.
HPA behavior controls rate and stability, not scaling triggers.
VPA Off observes only.
VPA Initial injects requests only on pod creation.
VPA Auto evicts and recreates pods to enforce recommendations.
```
