# Horizontal Pod Autoscaler (HPA)

## 📊 **Metrics Server Installation & Configuration**

### **Purpose**
The Metrics Server collects resource utilization data (CPU/Memory) from Kubernetes nodes and pods, enabling the `kubectl top` command and providing metrics to the Horizontal Pod Autoscaler (HPA).

### **Core Issue in Labs**
Lab environments like KillerCoda often have self-signed or untrusted TLS certificates between components. Without bypassing TLS verification, the Metrics Server cannot scrape metrics from kubelets.

### **Recommended Installation Method (Helm)**

#### **Standard Installation**
```bash
# Add Helm repository
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

# Install with lab-friendly configuration
helm install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set 'args={--cert-dir=/tmp,--secure-port=4443,--kubelet-insecure-tls,--kubelet-preferred-address-types=InternalIP}' \
  --set containerPort=4443 \
  --set 'livenessProbe.httpGet.path=/livez' \
  --set 'livenessProbe.httpGet.port=4443' \
  --set 'livenessProbe.httpGet.scheme=HTTPS' \
  --set 'readinessProbe.httpGet.path=/readyz' \
  --set 'readinessProbe.httpGet.port=4443' \
  --set 'readinessProbe.httpGet.scheme=HTTPS' \
  --set service.port=4443 \
  --set service.targetPort=4443
```

#### **Key Configuration Parameters Explained**
| Parameter | Purpose | Why It's Needed |
|-----------|---------|-----------------|
| `--kubelet-insecure-tls` | Disables TLS verification | Lab environments have self-signed certs |
| `--kubelet-preferred-address-types=InternalIP` | Uses internal IPs | Ensures correct network connectivity |
| `containerPort: 4443` | Explicit port definition | Avoids conflicts with default ports |
| Port 4443 in probes | Consistent port usage | Health checks match actual listening port |
| HTTPS scheme | Secure connections | Required for metrics server security |

### **Verification Steps**
```bash
# Wait 20-30 seconds for initialization
sleep 20

# Check pod status
kubectl get pods -n kube-system -l app.kubernetes.io/name=metrics-server

# Test metrics collection
kubectl top nodes
kubectl top pods

# Verify API service
kubectl get apiservice v1beta1.metrics.k8s.io
# Should show: AVAILABLE=True
```

### **Troubleshooting Metrics Server**
```bash
# Check logs for connection issues
kubectl logs -n kube-system deployment/metrics-server

# If 'Failed to scrape node', verify network policies
kubectl get networkpolicies -A

# Test direct metrics API access
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | head -20
```

## ⚙️ **Horizontal Pod Autoscaler (HPA) - Complete Guide**

### **What HPA Does**
HPA automatically adjusts the number of pod replicas in a deployment based on observed metrics, maintaining your defined target utilization.

**Core Formula**: `desiredReplicas = ceil(currentReplicas × (currentMetricValue / desiredMetricValue))`

### **HPA Architecture Diagram**
```
┌─────────────────────────────────────────────────────────────────────┐
│                          HPA Controller                              │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐         │
│  │  Get Metrics │────▶│  Calculate   │────▶│  Update      │         │
│  │  from API    │     │  Desired     │     │  Deployment  │         │
│  │              │     │  Replicas    │     │  Replicas    │         │
│  └──────────────┘     └──────────────┘     └──────────────┘         │
└─────────────────────────────────────────────────────────────────────┘
         │                            │
         ▼                            ▼
┌─────────────────┐         ┌─────────────────┐
│   Metrics API   │         │   Deployment    │
│   (Metrics-     │         │   Controller    │
│    Server)      │         │                 │
└─────────────────┘         └─────────────────┘
         │
         ▼
┌─────────────────┐
│    Kubelet      │
│   (Nodes/Pods)  │
└─────────────────┘
```

### **Basic HPA Structure**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: your-app
  
  minReplicas: 1        # Minimum pods for availability
  maxReplicas: 10       # Maximum pods for cost control
  
  metrics:              # What to monitor
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70  # Target 70% CPU usage
  
  behavior:             # How to scale (optional but recommended)
    scaleUp:
      stabilizationWindowSeconds: 0
      policies: [...]
    scaleDown:
      stabilizationWindowSeconds: 300
      policies: [...]
```

### **Prerequisite: Resource Requests**
**Critical**: Pods must have resource requests for HPA to calculate utilization percentages.
```yaml
# In your deployment template
resources:
  requests:
    memory: "256Mi"    # HPA uses: (actual usage / 256Mi) × 100%
    cpu: "250m"        # Requested = 0.25 CPU cores
  limits:
    memory: "512Mi"
    cpu: "500m"
```

**Common Mistake**: Using wrong units
- ❌ CPU: `"256Mi"` (Mi is for memory!)
- ✅ CPU: `"250m"` (millicores) or `"0.25"`
- ✅ Memory: `"256Mi"` (mebibytes) or `"512Mi"`

## 🎛️ **HPA Behavior Configuration - Complete Details**

### **Purpose of Behavior Settings**
Control the **timing**, **speed**, and **magnitude** of scaling operations to prevent rapid oscillations ("flapping") and ensure stable application performance.

### **Core Components Explained**

#### **1. `stabilizationWindowSeconds`**
A waiting period after a metric change before taking scaling action.

```yaml
scaleDown:
  stabilizationWindowSeconds: 300  # Wait 5 minutes of low usage before scaling down
```

| Use Case | Recommended Value |
|----------|-------------------|
| Scale Up (responsive) | 0-30 seconds |
| Scale Down (conservative) | 300-600 seconds |
| Stateful applications | 600+ seconds |

#### **2. `policies` - Scaling Rules**
Define how many pods can be added/removed in a time window.

```yaml
policies:
- type: Pods        # Fixed number of pods
  value: 2          # Add/remove 2 pods max
  periodSeconds: 60 # Every 60 seconds
  
- type: Percent     # Percentage of current pods
  value: 50         # Add/remove 50% of current pods
  periodSeconds: 30 # Every 30 seconds
```

**Policy Types Comparison**:
| Type | Best For | Example | Result (10 pods → ?) |
|------|----------|---------|----------------------|
| `Pods` | Predictable scaling | `value: 3` | Add/remove exactly 3 pods |
| `Percent` | Proportional scaling | `value: 50` | Add/remove 5 pods (50% of 10) |

#### **3. `selectPolicy` - Choosing Between Policies**
When multiple policies exist, which one to apply?

```yaml
selectPolicy: Max  # Use the policy allowing the BIGGEST change
```

| Policy | Behavior | Use Case |
|--------|----------|----------|
| `Max` | Uses policy allowing largest change | Fast scaling response |
| `Min` | Uses policy allowing smallest change | Conservative, safe scaling |
| `Disabled` | No scaling in this direction | Disable scale-up/down |

**Example with `Max`**:
```yaml
policies:
- type: Pods
  value: 2          # Can change 2 pods
- type: Percent
  value: 100        # Can change 100% of pods (all of them!)

# With selectPolicy: Max → Uses Percent: 100 (bigger change)
# With selectPolicy: Min → Uses Pods: 2 (smaller change)
```

### **Complete Behavior Configuration Examples**

#### **1. Web Application Pattern (Responsive)**
```yaml
behavior:
  scaleUp:
    stabilizationWindowSeconds: 0      # React immediately to traffic spikes
    policies:
    - type: Pods
      value: 4
      periodSeconds: 15
    - type: Percent
      value: 100
      periodSeconds: 15
    selectPolicy: Max                  # Scale aggressively during spikes
  
  scaleDown:
    stabilizationWindowSeconds: 300    # Wait 5 minutes before scaling down
    policies:
    - type: Percent
      value: 50
      periodSeconds: 60
    selectPolicy: Max
```

#### **2. Batch Processing Pattern (Conservative)**
```yaml
behavior:
  scaleUp:
    stabilizationWindowSeconds: 60     # Wait 1 minute to confirm need
    policies:
    - type: Pods
      value: 1
      periodSeconds: 90
    selectPolicy: Max
  
  scaleDown:
    stabilizationWindowSeconds: 600    # Wait 10 minutes (long jobs)
    policies:
    - type: Pods
      value: 1
      periodSeconds: 180
    selectPolicy: Min                  # Scale down very slowly
```

#### **3. Real-time/Streaming Pattern (Aggressive)**
```yaml
behavior:
  scaleUp:
    stabilizationWindowSeconds: 0
    policies:
    - type: Percent
      value: 200      # Can double pod count
      periodSeconds: 10
    selectPolicy: Max
  
  scaleDown:
    stabilizationWindowSeconds: 60
    policies:
    - type: Percent
      value: 100      # Can remove all extra pods
      periodSeconds: 30
    selectPolicy: Max
```

## 🧪 **Load Testing with `stress` Command**

### **Purpose of Load Testing**
- Verify HPA triggers at correct thresholds
- Test scaling behavior under controlled conditions
- Identify optimal resource requests and limits

### **Using the `polinux/stress` Image**

#### **Basic Test Pod**
```bash
# Create a pod for testing
kubectl run stress-test --image=polinux/stress --command -- sleep 3600

# Run stress commands inside the pod
kubectl exec stress-test -- stress --vm 1 --vm-bytes 100M --timeout 60
```

#### **Memory Stress Testing**
```bash
# 1. Memory Stress Only
# Syntax: --vm N (workers) --vm-bytes X (memory per worker) --timeout T (seconds)
kubectl exec <pod> -- stress --vm 2 --vm-bytes 150M --timeout 120

# 2. Heavy Memory Load
kubectl exec <pod> -- stress --vm 4 --vm-bytes 500M --timeout 180

# 3. Continuous Memory Stress (background)
kubectl exec <pod> -- stress --vm 1 --vm-bytes 100M --timeout 600 &
```

#### **CPU Stress Testing**
```bash
# 1. CPU Stress Only
# Syntax: --cpu N (workers) --timeout T (seconds)
kubectl exec <pod> -- stress --cpu 4 --timeout 90

# 2. Heavy CPU Load (all cores)
kubectl exec <pod> -- stress --cpu 8 --timeout 120

# 3. Mixed CPU Load (varying intensity)
kubectl exec <pod> -- stress --cpu 2 --timeout 60 & \
kubectl exec <pod> -- stress --cpu 4 --timeout 60
```

#### **Combined Stress Testing**
```bash
# 1. Memory + CPU Combined Stress
kubectl exec <pod> -- stress --vm 1 --vm-bytes 200M --cpu 2 --timeout 180

# 2. Heavy Combined Load
kubectl exec <pod> -- stress --vm 2 --vm-bytes 300M --cpu 4 --timeout 240

# 3. Sequential Stress Testing
kubectl exec <pod> -- stress --cpu 4 --timeout 60
kubectl exec <pod> -- stress --vm 2 --vm-bytes 100M --timeout 60
kubectl exec <pod> -- stress --cpu 2 --vm 1 --vm-bytes 150M --timeout 90
```

#### **Testing HPA with Memory Metrics**
```bash
# Given: HPA target is 70% memory utilization
# Given: Pod requests 128Mi memory
# Calculation: Need ~90Mi usage to trigger scaling (128Mi × 70% = 89.6Mi)

# Trigger scaling
kubectl exec deployment/your-app -- stress --vm 1 --vm-bytes 100M --timeout 300

# Monitor scaling
watch -n 5 'kubectl get hpa,pods && echo "---" && kubectl top pods'
```

#### **Testing HPA with CPU Metrics**
```bash
# Given: HPA target is 50% CPU utilization  
# Given: Pod requests 500m CPU (0.5 cores)
# Calculation: Need ~250m usage to trigger scaling (500m × 50% = 250m)

# Trigger CPU scaling
kubectl exec deployment/your-app -- stress --cpu 2 --timeout 300

# Monitor CPU-based scaling
watch -n 3 'kubectl get hpa && echo "CPU Usage:" && kubectl top pods | grep your-app'
```

#### **Multi-Metric HPA Testing**
```bash
# Create HPA watching both CPU and Memory
cat <<EOF | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: multi-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: your-app
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
EOF

# Test both resources
kubectl exec deployment/your-app -- stress --cpu 4 --vm 2 --vm-bytes 200M --timeout 300
```

## 🔍 **HPA Status Interpretation**

### **Checking HPA Status**
```bash
kubectl get hpa
# Output shows: REFERENCE, TARGETS, MINPODS, MAXPODS, REPLICAS

kubectl describe hpa your-hpa
# Shows conditions, events, and detailed metrics
```

### **Key HPA Conditions**
| Condition | Status | Meaning | Action Required |
|-----------|--------|---------|-----------------|
| `AbleToScale` | True/False | Can HPA modify replicas? | Check permissions if False |
| `ScalingActive` | True/False | Getting metrics successfully? | Fix metrics server if False |
| `ScalingLimited` | True/False | Hit min/max replica limits? | Adjust min/max if True |

### **Common HPA Events**
```bash
kubectl describe hpa | grep -A5 "Events:"
```

| Event | Meaning | Typical Cause |
|-------|---------|---------------|
| `SuccessfulRescale` | HPA changed replica count | Normal operation |
| `FailedGetResourceMetric` | Can't fetch metrics | Metrics server down |
| `FailedComputeMetricsReplicas` | Can't calculate desired replicas | Invalid metric configuration |

## 🚨 **Troubleshooting Common Issues**

### **Issue 1: HPA shows `<unknown>` targets**
**Cause**: Metrics Server not working
**Solution**:
```bash
# Check metrics-server pod
kubectl get pods -n kube-system | grep metrics-server

# Check logs
kubectl logs -n kube-system deployment/metrics-server

# Reinstall if needed (with correct flags)
helm upgrade metrics-server --reuse-values --set 'args={--kubelet-insecure-tls}'
```

### **Issue 2: HPA not scaling when expected**
**Checklist**:
1. Verify pod has resource requests (`kubectl get pod -o yaml | grep requests`)
2. Check current vs target metrics (`kubectl describe hpa`)
3. Verify HPA is not limited (`ScalingLimited` condition)
4. Ensure metrics are above target threshold

### **Issue 3: Rapid scaling oscillations ("flapping")**
**Solution**: Adjust behavior settings
```yaml
behavior:
  scaleDown:
    stabilizationWindowSeconds: 600  # Increase from 300 to 600
    policies:
    - type: Percent
      value: 20  # Reduce from 50% to 20%
      periodSeconds: 120
```

## 📋 **Quick Reference Commands**

### **HPA Management**
```bash
# Create HPA with kubectl
kubectl autoscale deployment/my-app --cpu-percent=50 --min=1 --max=5

# Get HPA information
kubectl get hpa
kubectl describe hpa <name>
kubectl get hpa <name> -o yaml

# Edit HPA
kubectl edit hpa <name>

# Delete HPA
kubectl delete hpa <name>
```

### **Monitoring & Testing**
```bash
# Watch scaling in real-time
watch -n 2 'kubectl get hpa,deploy,pods && echo "---" && kubectl top pods 2>/dev/null || echo "Metrics loading..."'

# Generate memory load for testing
kubectl exec deployment/<name> -- stress --vm 1 --vm-bytes 150M --timeout 120

# Generate CPU load for testing
kubectl exec deployment/<name> -- stress --cpu 4 --timeout 120

# Check resource usage
kubectl top pods
kubectl top pods --containers  # Show container-level usage
```

### **Debugging**
```bash
# Check HPA events
kubectl get events --field-selector involvedObject.kind=HorizontalPodAutoscaler --sort-by=.metadata.creationTimestamp

# Verify API access
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq '.items[0].usage'

# Check pod details
kubectl describe pod <pod-name> | grep -A10 "Resources:"
```

## 💡 **Best Practices Summary**

1. **Always set resource requests** in deployments (required for HPA calculations)
2. **Start with conservative behavior** and adjust based on observations
3. **Test both CPU and memory scaling** before production deployment
4. **Monitor HPA events** for failed scaling attempts
5. **Use appropriate min/max values** based on application needs and cluster capacity
6. **Regularly review metrics** to ensure targets are appropriate
7. **Consider combining with VPA** (Vertical Pod Autoscaler) for right-sizing requests

## ⚠️ **Common Pitfalls to Avoid**

- ❌ Forgetting to install/configure Metrics Server
- ❌ Not setting resource requests in pods
- ❌ Setting `minReplicas` to 0 for stateful applications
- ❌ Too aggressive scale-down causing application instability
- ❌ Incorrect metric units (using `Mi` for CPU, `m` for memory)
- ❌ Not monitoring HPA events for failures
- ❌ Testing only one resource type (CPU or Memory) when both matter

