Here’s a complete **notes + example** for HPA with Deployments.

---

## Notes on Horizontal Pod Autoscaler (HPA)

* **Purpose**: Automatically adjusts the number of pod replicas in a Deployment, ReplicaSet, or StatefulSet based on observed metrics.
* **Default metrics supported**:

  * CPU utilization (requires `resources.requests.cpu`)
  * Memory utilization (requires `resources.requests.memory`)
* **Custom metrics**: Supported via adapters like **Prometheus Adapter**, not metrics-server alone.

### Key Points

1. **Metrics-server required**

   * For CPU/Memory scaling. Provides `metrics.k8s.io` API.
2. **Deployment replicas vs HPA replicas**

   * `replicas:` in Deployment is the starting count.
   * Once HPA is applied, it controls scaling between `minReplicas` and `maxReplicas`.
   * Manual scaling (`kubectl scale`) will be overridden by HPA.
3. **HPA spec essentials**

   * `scaleTargetRef`: Points to the Deployment (or ReplicaSet/StatefulSet).
   * `minReplicas` / `maxReplicas`: Scaling boundaries.
   * `metrics`: Defines what metric to monitor and the target utilization.
4. **Formula for CPU utilization**

   ```
   currentCPUUtilization = (currentPodCPUUsage / requestedCPU) * 100
   ```

   * HPA compares the average of all pods against the `averageUtilization` target.

---

## Example: Deployment + HPA

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-deployment
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50   # scale when >50% of requested CPU
```

---

## Quick Commands

* Check HPA status:

  ```
  kubectl get hpa -n production
  kubectl describe hpa web-hpa -n production
  ```
* Check metrics:

  ```
  kubectl top pods -n production
  kubectl top nodes
  ```

---

Would you like me to also add a **load generator Job YAML** (like busybox `while true; wget`) so you can actually trigger scaling during practice?
