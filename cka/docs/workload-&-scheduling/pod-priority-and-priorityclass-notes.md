# Pod Priority Using PriorityClass

---

### What was already present

The cluster already had multiple `PriorityClass` objects:

* `level2` with value `200000000`
* `level3` with value `300000000`
* System-reserved priorities:

  * `system-cluster-critical`
  * `system-node-critical`

All were non-default and used `PreemptLowerPriority`.

PriorityClass is a **cluster-scoped resource** and must exist before Pods reference it.

---

### How priority was added to the Pod

A Pod cannot set priority directly.
It must reference a `priorityClassName`.

In the Pod spec:

```yaml
spec:
  priorityClassName: level2
```

After scheduling, Kubernetes resolves this to:

```yaml
priority: 200000000
preemptionPolicy: PreemptLowerPriority
```

These fields are **computed by the scheduler**, not authored manually.

---

### What happened during Pod creation

* Pod `important` referenced `priorityClassName: level2`
* Scheduler assigned priority `200000000`
* Pod was scheduled successfully on `controlplane`
* No preemption occurred because no lower-priority Pods were blocking resources

---

### Key fields to recognize in Pod YAML

```yaml
priorityClassName: level2
priority: 200000000
preemptionPolicy: PreemptLowerPriority
```

* `priorityClassName` is user-defined
* `priority` is injected by the scheduler
* `preemptionPolicy` comes from the PriorityClass

---

### How priority actually works

* Scheduler prefers higher-priority Pods
* If resources are insufficient:

  * Lower-priority Pods may be evicted
* Priority does **not**:

  * Change CPU/memory limits
  * Affect runtime QoS directly
* Priority influences **scheduling and preemption only**

---

### Where priority applies

Priority is defined on the Pod template, so it is valid for:

* Pod
* Deployment
* StatefulSet
* DaemonSet
* Job / CronJob

Example for controllers:

```yaml
spec:
  template:
    spec:
      priorityClassName: level2
```

---

### Common mistakes to avoid

* Trying to set `priority:` manually in YAML
* Assuming labels or annotations affect scheduling priority
* Forgetting PriorityClass is cluster-scoped
* Using system priority classes for user workloads

---

### One-line exam rule

Pod priority is assigned **only** via `priorityClassName`, and enforced by the scheduler, not the Pod spec.
