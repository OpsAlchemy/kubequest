# Deployment Scheduling Failure Due to Hard-Coded `nodeName`

### Problem Summary

A Deployment (`management-frontend`) was imported from another Kubernetes cluster.
All Pods remained in **Pending** state and none became Ready.

```
READY   UP-TO-DATE   AVAILABLE
0/5     5            0
```

---

## Root Cause

The Pod template explicitly specified a node:

```
spec:
  template:
    spec:
      nodeName: staging-node1
```

This configuration **bypasses the Kubernetes scheduler entirely**.

---

## Why This Fails in Another Cluster

* `staging-node1` does not exist in the current cluster
* Pods with `nodeName` set:

  * Are not evaluated by the scheduler
  * Are bound directly to that node
* If the node does not exist or is NotReady:

  * Pods remain Pending indefinitely
  * No rescheduling occurs

---

## Fix Applied

The hard-coded node assignment was removed from the Deployment.

Command used:

```
kubectl edit deploy management-frontend
```

Change made:

```
spec:
  template:
    spec:
      nodeName: staging-node1   # removed
```

---

## What Happened After the Fix

1. Deployment spec changed → generation incremented
2. Deployment controller detected a new Pod template
3. A new ReplicaSet was created
4. Old ReplicaSet scaled down
5. New Pods were created without `nodeName`
6. Scheduler assigned Pods to available nodes
7. Pods transitioned:

   ```
   Pending → ContainerCreating → Running
   ```

All replicas became Ready.

---

## Scheduling Notes: nodeName vs Scheduler

### nodeName Behavior

* `nodeName` **completely bypasses the scheduler**
* Kubelet on the specified node is expected to run the Pod directly
* No feasibility checks are performed
* No fallback if the node does not exist

### Compared to Other Scheduling Controls

* `nodeSelector` → scheduler involved
* `nodeAffinity` → scheduler involved
* `taints/tolerations` → scheduler involved
* `nodeName` → scheduler skipped

---

## How Kubernetes Scheduling Works (Step-by-Step)

### 1. Deployment Update

* `kubectl edit` updates the Deployment object
* Change stored in **etcd**

### 2. Deployment Controller

* Watches Deployments via API server
* Detects template change
* Creates or updates a ReplicaSet

### 3. ReplicaSet Controller

* Ensures desired replica count
* Creates Pod objects
* Pods are stored in etcd with:

  ```
  spec.nodeName: ""
  ```

### 4. Scheduler

* Watches for Pods without `nodeName`
* Evaluates:

  * Node availability
  * Resource requests
  * Taints and tolerations
  * Affinity rules
* Selects a node
* Writes `spec.nodeName=<node>` back to etcd

### 5. Kubelet

* Watches for Pods assigned to its node
* Pulls images
* Creates containers
* Updates Pod status to `Running`

---

## What Happens During Rollout / Deletion

When the Deployment was edited:

1. Old ReplicaSet scaled down
2. Old Pods marked `Terminating`
3. Kubelet:

   * Stops containers
   * Cleans up volumes
   * Reports status
4. New Pods created and scheduled
5. RollingUpdate strategy ensures availability

---

## Key Takeaways

* Do not hard-code `nodeName` in portable manifests
* Imported workloads often fail due to:

  * nodeName
  * hostPath
  * cloud-specific labels
* If Pods are Pending:

  * Inspect `spec.nodeName` first
* `nodeName` is absolute and unschedulable
* Scheduler only operates when `nodeName` is empty

---
