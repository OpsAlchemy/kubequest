
# HPA & VPA Practice Questions

This document contains **detailed, step-by-step practice questions** for understanding **Horizontal Pod Autoscaler (HPA)** and **Vertical Pod Autoscaler (VPA)** behavior using realistic workloads.
All workloads are intentionally simple so that autoscaling behavior is clearly observable.

---

## 🔥 HPA PRACTICE QUESTIONS

---

## Question 1: Memory-based HPA

### Objective

Practice configuring an HPA that scales **based on memory utilization**.
Understand how memory usage is calculated **relative to memory requests**, not limits.

### Requirements

* Create a Deployment named **`mem-hpa`**
* Container image: `polinux/stress`
* Container must stay running using:

  ```yaml
  command: ["sleep", "3600"]
  ```
* Set **memory request** to:

  ```yaml
  memory: 50Mi
  ```
* Configure an HPA with:

  * Metric: memory utilization
  * Target: **80%**
  * Minimum replicas: **1**
  * Maximum replicas: **4**

### Expected Behavior

* When memory usage crosses ~40Mi per pod:

  * HPA should calculate a higher desired replica count
  * New pods should be created
* When memory load stops:

  * Replica count should eventually reduce

### Load Generation

```bash
kubectl exec deploy/mem-hpa -it -- stress --vm 1 --vm-bytes 45M --timeout 600
```

### Observation

```bash
watch -n 5 '
kubectl get hpa mem-hpa;
echo "---";
kubectl get pods -l app=mem-hpa
'
```

---

## Question 2: CPU-based HPA

### Objective

Understand CPU utilization–based scaling and the importance of **CPU requests**.

### Requirements

* Deployment name: **`cpu-hpa`**
* Image: `polinux/stress`
* Command:

  ```yaml
  ["sleep", "3600"]
  ```
* Set **CPU request** to:

  ```yaml
  cpu: 50m
  ```
* HPA configuration:

  * Metric: CPU utilization
  * Target: **70%**
  * Min replicas: **2**
  * Max replicas: **6**

### Expected Behavior

* Sustained CPU usage above ~35m per pod should:

  * Trigger scale-up
* Removing CPU stress should:

  * Gradually scale replicas down

### Load Generation

```bash
kubectl exec deploy/cpu-hpa -it -- stress --cpu 4 --timeout 600
```

### Observation

```bash
watch -n 10 '
kubectl get hpa cpu-hpa;
kubectl top pods -l app=cpu-hpa
'
```

---

## Question 3: Multi-Metric HPA (CPU OR Memory)

### Objective

Understand how HPA behaves when **multiple metrics are configured**.
HPA scales if **any single metric** breaches its target.

### Requirements

* Deployment name: **`multi-hpa`**
* Image: `polinux/stress`
* Command:

  ```yaml
  ["sleep", "3600"]
  ```
* Resource requests:

  ```yaml
  cpu: 30m
  memory: 40Mi
  ```
* HPA rules:

  * CPU utilization > **60%**
  * OR memory utilization > **75%**
* Replica range: **1 → 5**

### Expected Behavior

* Either CPU or memory pressure alone can trigger scaling
* HPA uses the **largest calculated replica count** across metrics

### Load Generation

```bash
kubectl exec deploy/multi-hpa -it -- \
  stress --cpu 2 --vm 1 --vm-bytes 35M --timeout 600
```

### Observation

```bash
watch -n 15 '
kubectl describe hpa multi-hpa | grep -A12 "Metrics:"
'
```

---

## 🚀 VPA PRACTICE QUESTIONS

---

## Question 4: VPA Initial Mode

### Objective

Learn how VPA:

* Observes historical usage
* Builds recommendation profiles
* Injects resource requests **only at pod creation time**

### Requirements

* Deployment name: **`vpa-initial`**
* Image: `polinux/stress`
* Command:

  ```yaml
  ["sleep", "3600"]
  ```
* Initial requests:

  ```yaml
  cpu: 10m
  memory: 20Mi
  ```
* VPA configuration:

  * Update mode: `Initial`
  * Minimum allowed: `20m / 30Mi`
  * Maximum allowed: `100m / 100Mi`
  * Controlled resources: CPU and memory

### Expected Behavior

* Running pods remain unchanged
* VPA generates recommendations
* New pods receive injected requests

### Load Generation

```bash
kubectl exec deploy/vpa-initial -it -- \
  stress --cpu 1 --vm 1 --vm-bytes 25M --timeout 600
```

### Observation

```bash
watch -n 30 '
kubectl describe vpa vpa-initial | grep -A6 -B6 "Recommendation"
'
```

---

## Question 5: VPA Auto Mode

### Objective

Understand how VPA actively enforces resource sizing by **restarting pods**.

### Requirements

* Deployment name: **`vpa-auto`**
* Initial requests:

  ```yaml
  cpu: 15m
  memory: 25Mi
  ```
* VPA update mode: `Auto`
* Minimum allowed: `20m / 30Mi`
* Maximum allowed: `100m / 150Mi`

### Expected Behavior

* VPA detects sustained overuse
* Pods are evicted and recreated
* New pods have updated requests

### Load Generation

```bash
kubectl exec deploy/vpa-auto -it -- \
  stress --cpu 3 --vm 1 --vm-bytes 80M --timeout 300
```

### Observation

```bash
watch -n 20 '
kubectl get pods -l app=vpa-auto
'
```

---

## Question 6: VPA Off Mode

### Objective

Confirm that `Off` mode:

* Collects metrics
* Produces recommendations
* Never modifies running pods

### Requirements

* Deployment name: **`vpa-off`**
* Requests:

  ```yaml
  cpu: 20m
  memory: 30Mi
  ```
* VPA update mode: `Off`
* Minimum allowed: `30m / 40Mi`
* Maximum allowed: `200m / 200Mi`

### Expected Behavior

* No pod restarts
* No resource injection
* Recommendations visible only via VPA status

### Load Generation

```bash
kubectl exec deploy/vpa-off -it -- \
  stress --cpu 2 --vm 1 --vm-bytes 100M --timeout 600
```

### Observation

```bash
kubectl describe vpa vpa-off
```

---

## Question 7: Combined HPA + VPA

### Objective

Practice the **safe and recommended combination**:

* HPA controls replica count
* VPA controls initial resource sizing

### Requirements

* Deployment name: **`combined-app`**
* Requests:

  ```yaml
  cpu: 20m
  memory: 30Mi
  ```
* VPA:

  * Update mode: `Initial`
* HPA:

  * Metric: CPU
  * Target: **65%**
  * Replica range: **2 → 4**

### Expected Behavior

* VPA injects requests for new pods only
* HPA scales replicas independently
* No feedback loop or oscillation

### Load Generation

```bash
kubectl exec deploy/combined-app -it -- \
  stress --cpu 2 --vm 1 --vm-bytes 25M --timeout 600
```

### Observation

```bash
watch -n 10 '
kubectl get hpa,vpa,pods -l app=combined-app
'
```

---

## ⚙️ Running `stress` in the Background (Correct Ways)

### Method 1: Separate terminals

* Terminal 1 runs stress (blocking)
* Terminal 2 is used for monitoring

---

### Method 2: `nohup` inside the pod

```bash
kubectl exec deploy/app -it -- bash
nohup stress --vm 1 --vm-bytes 40M --timeout 600 > /dev/null 2>&1 &
exit
```

---

### Method 3: tmux / screen

```bash
tmux new-session -d -s stress-test \
  'kubectl exec deploy/app -it -- stress --cpu 2 --timeout 600'
```

---

### Method 4: Run stress on all replicas

```bash
for pod in $(kubectl get pods -l app=app -o name); do
  kubectl exec $pod -- stress --cpu 1 --timeout 300 &
done
```

---

## 📋 YAML TEMPLATES (FULL)

### Deployment Template

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  labels:
    app: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: stress
        image: polinux/stress
        command: ["sleep", "3600"]
        resources:
          requests:
            cpu: 50m
            memory: 50Mi
```

---

### HPA Template

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 1
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

---

### VPA Template

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: app-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  updatePolicy:
    updateMode: Initial
  resourcePolicy:
    containerPolicies:
    - containerName: stress
      minAllowed:
        cpu: 20m
        memory: 30Mi
      maxAllowed:
        cpu: 100m
        memory: 100Mi
      controlledResources:
      - cpu
      - memory
```

