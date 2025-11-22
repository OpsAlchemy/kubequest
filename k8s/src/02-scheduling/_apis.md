## Complete Scheduling Control Scope

### **1. Pod-Level Scheduling Controls**

#### **Direct Pod Fields:**
- **`spec.nodeName`** - Direct node assignment (bypasses scheduler)
- **`spec.nodeSelector`** - Node label requirements
- **`spec.affinity`** - Advanced affinity/anti-affinity rules
  - `nodeAffinity` - Node selection rules
  - `podAffinity` - Pod co-location rules
  - `podAntiAffinity` - Pod separation rules
- **`spec.tolerations`** - Tolerate node taints
- **`spec.topologySpreadConstraints`** - Spread across domains (zones, nodes, etc.)
- **`spec.schedulerName`** - Custom scheduler selection
- **`spec.priorityClassName`** / **`spec.priority`** - Scheduling priority
- **`spec.preemptionPolicy`** - Preemption behavior
- **`spec.runtimeClassName`** - Runtime requirements

#### **Resource Requirements:**
- **`spec.containers[].resources.requests`** - Minimum resources needed
- **`spec.containers[].resources.limits`** - Maximum resources allowed
- **`spec.overhead`** - Runtime overhead resources

### **2. Node-Level Controls**

#### **Node Attributes:**
- **Labels** - For nodeSelector and nodeAffinity
- **Taints** - Repel pods without matching tolerations
- **Capacity/Allocatable** - Resource availability
- **Conditions** - Node readiness, disk pressure, etc.
- **Node Addresses** - Internal/External IPs, hostname

#### **Node Objects:**
- **`spec.unschedulable`** - Cordoning (draining)
- **`spec.taints`** - Node taints array
- **`status.allocatable`** - Available resources
- **`status.capacity`** - Total resources

### **3. Cluster-Level Objects**

#### **Priority Classes:**
- **`value`** - Priority value (higher = more important)
- **`globalDefault`** - Default priority class
- **`preemptionPolicy`** - Never/PreemptLowerPriority

#### **Runtime Classes:**
- **`handler`** - Runtime handler (containerd, kata, etc.)
- **`overhead`** - Resource overhead for runtime
- **`scheduling`** - Node selector for runtime

#### **Resource Quotas:**
- **Namespace-level resource limits**
- **Scope selectors** - Apply to specific pods

### **4. Policy Objects**

#### **Pod Disruption Budgets (PDBs):**
- **`minAvailable`** - Minimum pods that must be available
- **`maxUnavailable`** - Maximum pods that can be unavailable

#### **Network Policies:**
- Indirectly affect scheduling through network requirements

### **5. Custom Resources & Extensions**

#### **Scheduler Configuration:**
- **`profiles`** - Multiple scheduler profiles
- **`extenders`** - External scheduler extenders
- **`pluginConfig`** - Plugin configurations

#### **Custom Schedulers:**
- Alternative schedulers with different policies

#### **Scheduling Framework Plugins:**
- **QueueSort** - Pod sorting
- **PreFilter** - Pre-check feasibility
- **Filter** - Node filtering
- **PostFilter** - Preemption logic
- **Score** - Node scoring
- **Reserve** - Resource reservation
- **Permit** - Scheduling hold
- **PreBind** - Pre-binding operations
- **Bind** - Binding to node
- **PostBind** - Post-binding operations

### **6. Storage & Volume Constraints**

#### **Volume Requirements:**
- **`spec.volumes[].persistentVolumeClaim.claimName`** - PVC binding
- **Storage Class** - Volume provisioning constraints
- **Volume topology** - Volume zone/node constraints

#### **CSI Drivers:**
- **Node topology** - Storage accessibility
- **Volume binding modes** - Immediate vs WaitForFirstConsumer

### **7. Security Constraints**

#### **Security Context:**
- **`securityContext.runAsUser`** - User ID requirements
- **`securityContext.selinuxOptions`** - SELinux constraints
- **`securityContext.seccompProfile`** - Seccomp requirements

#### **Pod Security Standards:**
- **Privileged** - Privilege requirements
- **Host namespaces** - Host network/pid/ipc requirements
- **Capabilities** - Linux capability requirements

### **8. API Extensions**

#### **Validating/Mutating Webhooks:**
- Can modify pod spec before scheduling
- Can reject pods based on policies

#### **Custom Resource Definitions (CRDs):**
- **ClusterResourceSets** - Cluster-level requirements
- **Scheduling Policies** - Custom scheduling rules

## Scope Definition for Your Scheduling Project

### **Core Scope (Essential):**
1. Pod: nodeSelector, affinity, tolerations
2. Node: Labels, taints, resources
3. Priority Classes
4. Resource requests/limits

### **Intermediate Scope:**
5. Topology spread constraints
6. Pod disruption budgets
7. Runtime classes
8. Storage constraints

### **Advanced Scope:**
9. Custom schedulers
10. Scheduler framework plugins
11. Webhook modifications
12. Extended resources

### **Out of Scope (for now):**
- Network policies (indirect affect)
- Detailed security contexts
- Complex storage topologies
- Custom resource definitions

## Quick Reference Cheatsheet

```yaml
# Pod Scheduling Controls:
spec:
  nodeName: ""          # Direct assignment
  nodeSelector: {}       # Label matching
  affinity: {}           # Advanced affinity
  tolerations: []        # Taint toleration
  topologySpreadConstraints: [] # Spread across topology
  schedulerName: ""      # Custom scheduler
  priorityClassName: ""  # Scheduling priority
  containers:
  - resources:
      requests: {}       # Minimum resources
      limits: {}         # Maximum resources

# Node Controls:
kubectl label nodes <node> <key>=<value>
kubectl taint nodes <node> <key>=<value>:<effect>
```
