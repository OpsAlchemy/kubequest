# Autoscaling Practice

---

## QUESTIONS

---

## 🔥 Question 1 — Memory-based HPA with Custom Behavior

### Objective

Configure a Horizontal Pod Autoscaler that scales **only on memory utilization** and uses **custom scaling behavior**.

### Requirements

- Deployment name: `mem-hpa`
- Image: `polinux/stress`
- Command:
  ```yaml
  ["sleep", "3600"]
  ```
- Resource requests:
  ```yaml
  memory: 50Mi
  ```

**HPA configuration:**

  * Metric: memory utilization
  * Target: **80%**
  * Min replicas: **1**
  * Max replicas: **5** 

**Behavior:**

  * Scale up: **+2 pods per 30 seconds**
  * Scale down: **−1 pod per 60 seconds**
  * Scale-down stabilization window: **300 seconds**

### Load Generation

```bash
POD=$(kubectl get pods -l app=mem-hpa -o name | shuf -n 1) && \
echo "Running stress in: $POD" && \
kubectl exec "$POD" -- sh -c \
'nohup stress --vm 1 --vm-bytes 200Mi --timeout 600 > /dev/null 2>&1 &'
```

### Observation

```bash
watch -n 5 '
kubectl top po;
echo "-----";
kubectl get po -l app=mem-hpa
'
```

---

## 🔥 Question 2 — CPU + Memory HPA with Complex Custom Behavior

### Objective

Configure a **multi-metric HPA** that scales on **CPU OR memory**, using **asymmetric, production-style behavior rules**.

### Requirements

- Deployment name: `multi-hpa`
- Image: `polinux/stress`
- Command:
  ```yaml
  ["sleep", "3600"]
  ```
- Resource requests:
  ```yaml
  cpu: 40m
  memory: 60Mi
  ```

**HPA configuration:**

- CPU target: **65%**
- Memory target: **75%**
- Min replicas: **2**
- Max replicas: **8**

**Behavior:**

  * Scale up:
    * **Max of 4 pods OR 50% per 30 seconds**
    * Select policy: **Max**
  
  * Scale down:
    * **−1 pod per 90 seconds**
    * Stabilization window: **300 seconds**

### Load Generation

```bash
POD=$(kubectl get pods -l app=multi-hpa -o name | shuf -n 1) && \
echo "Running stress in: $POD" && \
kubectl exec "$POD" -- sh -c \
'nohup stress --cpu 2 --vm 1 --vm-bytes 180Mi --timeout 600 > /dev/null 2>&1 &'
```

### Observation

```bash
watch -n 10 '
kubectl describe hpa multi-hpa | grep -A15 "Metrics:";
echo "-----";
kubectl get po -l app=multi-hpa
'
```

---

## 🚀 Question 3 — VPA in Off Mode

### Objective

Validate that **VPA Off mode** only observes usage and never mutates pods.

### Requirements

* Deployment name: `vpa-off`
* Image: `polinux/stress`
* Command:

  ```yaml
  ["sleep", "3600"]
  ```
* Initial requests:

  ```yaml
  cpu: 20m
  memory: 30Mi
  ```
* VPA configuration:

  * Update mode: `Off`
  * Min allowed: `30m / 40Mi`
  * Max allowed: `200m / 200Mi`

### Load Generation

```bash
kubectl exec deploy/vpa-off -- sh -c \
'stress --cpu 2 --vm 1 --vm-bytes 100Mi --timeout 600'
```

### Observation

```bash
kubectl describe vpa vpa-off
```

---

## 🚀 Question 4 — VPA in Initial Mode

### Objective

Understand how **VPA Initial mode injects requests only at pod creation time**.

### Requirements

* Deployment name: `vpa-initial`
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
  * Min allowed: `20m / 30Mi`
  * Max allowed: `100m / 100Mi`

### Load Generation

```bash
kubectl exec deploy/vpa-initial -- sh -c \
'stress --cpu 1 --vm 1 --vm-bytes 60Mi --timeout 600'
```

### Observation

```bash
watch -n 30 '
kubectl describe vpa vpa-initial | grep -A8 -B6 "Recommendation"
'
```

---

## 🚀 Question 5 — VPA in Auto Mode (Fully Configured)

### Objective

Observe **automatic pod eviction and recreation** when VPA actively enforces sizing.

### Requirements

* Deployment name: `vpa-auto`
* Image: `polinux/stress`
* Command:

  ```yaml
  ["sleep", "3600"]
  ```
* Initial requests:

  ```yaml
  cpu: 15m
  memory: 25Mi
  ```
* VPA configuration:

  * Update mode: `Auto`
  * Min allowed: `20m / 30Mi`
  * Max allowed: `150m / 200Mi`
  * Controlled resources: CPU and memory

### Load Generation

```bash
POD=$(kubectl get pods -l app=vpa-auto -o name | shuf -n 1) && \
echo "Running stress in: $POD" && \
kubectl exec "$POD" -- sh -c \
'nohup stress --cpu 3 --vm 1 --vm-bytes 150Mi --timeout 300 > /dev/null 2>&1 &'
```

### Observation

```bash
watch -n 15 '
kubectl get po -l app=vpa-auto
'
```

---

