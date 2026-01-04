# DaemonSet

---

### Purpose

Ensure that **one Pod instance runs on each eligible node** in a cluster, automatically tracking node membership changes. DaemonSets solve the problem of **node-scoped workloads** that must exist wherever compute exists.

---

### Core Concept

A **DaemonSet** is a workload API that instructs the control plane to maintain **exactly one Pod per eligible node**.

* It is implemented as an `apps/v1` API object.
* It is reconciled by the DaemonSet controller.
* Pod placement is **node-driven**, not replica-driven.
* Pods are created and bound directly to nodes as they appear.
* It does **not** manage horizontal scaling, traffic routing, or service-level availability.

DaemonSets are intended for **infrastructure agents**, not application replicas.

---

### Mental Model

* **Control plane responsibility**: Ensure Pod presence per node.
* **Data plane behavior**: Pod runs continuously on its node.
* **Declarative**: Desired state = “one Pod on every eligible node”.
* **Reconciliation loop**:

  * Node added → Pod created
  * Node removed → Pod deleted
  * Node becomes ineligible → Pod removed

Scaling equals **number of nodes**, not user-defined replicas.

---

### Key Components

* **DaemonSet (apps/v1)**
* **DaemonSet Controller**
* **Pod Template**
* **Node Eligibility Controls**

  * `nodeSelector`
  * `nodeAffinity`
  * `tolerations`

---

### Lifecycle / Flow

1. User creates a DaemonSet.
2. API server persists it.
3. Controller evaluates all nodes.
4. One Pod is created per eligible node.
5. Continuous reconciliation on node or spec changes.

---

### Configuration Structure

**Required**

* `spec.selector`
* `spec.template`

**Behavior-altering**

* `nodeSelector`, `nodeAffinity`
* `tolerations`
* `updateStrategy`
* Host access fields (`hostNetwork`, `hostPath`, `privileged`)

---

### Full YAML Examples

#### Example 1: Basic DaemonSet (All Nodes)

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: simple-agent
  namespace: default
spec:
  selector:
    matchLabels:
      app: simple-agent
  template:
    metadata:
      labels:
        app: simple-agent
    spec:
      containers:
      - name: agent
        image: busybox
        command: ["sh", "-c", "while true; do echo running; sleep 60; done"]
```

---

#### Example 2: Run Only on Worker Nodes (nodeSelector)

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: worker-only-agent
  namespace: default
spec:
  selector:
    matchLabels:
      app: worker-agent
  template:
    metadata:
      labels:
        app: worker-agent
    spec:
      nodeSelector:
        node-role.kubernetes.io/worker: "true"
      containers:
      - name: agent
        image: busybox
        command: ["sh", "-c", "sleep infinity"]
```

---

#### Example 3: Run on Control Plane Nodes (Tolerations)

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: control-plane-agent
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: cp-agent
  template:
    metadata:
      labels:
        app: cp-agent
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      containers:
      - name: agent
        image: busybox
        command: ["sh", "-c", "sleep infinity"]
```

---

#### Example 4: DaemonSet with Node Affinity (Zone Restricted)

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: zone-agent
  namespace: default
spec:
  selector:
    matchLabels:
      app: zone-agent
  template:
    metadata:
      labels:
        app: zone-agent
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: topology.kubernetes.io/zone
                operator: In
                values:
                - us-east-1a
      containers:
      - name: agent
        image: busybox
        command: ["sh", "-c", "sleep infinity"]
```

---

#### Example 5: Privileged DaemonSet with Host Access (Security / Monitoring)

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: privileged-agent
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: privileged-agent
  template:
    metadata:
      labels:
        app: privileged-agent
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: agent
        image: busybox
        securityContext:
          privileged: true
        volumeMounts:
        - name: rootfs
          mountPath: /host
          readOnly: true
        command: ["sh", "-c", "sleep infinity"]
      volumes:
      - name: rootfs
        hostPath:
          path: /
```

---

#### Example 6: DaemonSet with Rolling Update Control

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: rolling-agent
  namespace: default
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  selector:
    matchLabels:
      app: rolling-agent
  template:
    metadata:
      labels:
        app: rolling-agent
    spec:
      containers:
      - name: agent
        image: busybox
        command: ["sh", "-c", "sleep infinity"]
```

---

### Behavior and Guarantees

**Guaranteed**

* One Pod per eligible node.
* Automatic reconciliation on node add/remove.
* Controlled rollout via `updateStrategy`.

**Not guaranteed**

* Ordering across nodes.
* Zero-downtime updates.
* Traffic exposure or service availability.

---

### Common Variants

* System-level DaemonSets
* Worker-only DaemonSets
* Privileged security agents
* Zone- or hardware-specific DaemonSets

---

### Failure Modes and Debugging

* Pod missing → node taints or affinity mismatch
* Update stuck → readiness or `maxUnavailable`

```bash
kubectl describe daemonset <name>
kubectl get pods -o wide
kubectl describe node <node>
```

---

### Constraints and Limitations

* No `replicas` field.
* Namespace-scoped.
* Not suitable for application workloads.
* Host access increases security risk.

---

### Exam-Relevant Notes (CKA/CKAD/CKS)

* One Pod per node is enforced by controller logic.
* Tolerations are mandatory for tainted nodes.
* Selector and template labels must match exactly.
* DaemonSets fully support rolling updates.

---

### Related Concepts

* Deployment
* Static Pods
* Node Affinity
* Taints and Tolerations
* CNI / CSI plugins
