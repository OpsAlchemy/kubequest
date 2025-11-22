---

# Lab 01: Deploy nginx pod on controlplane only

Problem Statement:

* Create a pod named `nginxpod` using the `nginx` image.
* Ensure that the pod is scheduled specifically on the controlplane node.
* The pod must not run on worker nodes under any circumstances.

Solutions:

1. Taint Manipulation (learning/demo only)

   * By default, Kubernetes taints controlplane/master nodes with `NoSchedule` to prevent regular workloads from running there.
   * To allow a pod to run on the controlplane, you can remove this taint:
     `kubectl taint node k8s-master node-role.kubernetes.io/control-plane:NoSchedule-`
   * To ensure pods do not end up on worker nodes, you can apply a custom taint to them:
     `kubectl taint node k8s-worker worker=NoSchedule`
   * After these changes, the scheduler is free to place regular pods onto the controlplane node.
   * Drawback: This method changes the cluster’s scheduling behavior. In production environments, it is strongly discouraged to modify controlplane taints, since they exist to protect critical system components from resource contention.

2. Direct nodeName Assignment (preferred for exam)

   * Instead of modifying taints, you can directly assign the pod to the controlplane node using the `nodeName` field in the pod spec.
   * Example:

     ```
     spec:
       nodeName: controlplane
     ```
   * This bypasses the scheduler entirely, and the pod is bound directly to the specified node.
   * Advantage: Very quick and clean for exam practice, as it avoids changing node-level configurations.
   * Drawback: In production, this approach can reduce flexibility, since it hardcodes the pod to a specific node. If that node is unavailable, the pod will not be rescheduled elsewhere automatically.

Verification:

* Run `kubectl get pods -o wide` to check which node the pods are running on.
* `nginxpod-taint` should appear on the controlplane after applying taint adjustments.
* `nginxpod-nodename` will show up directly on the controlplane node without any taint modifications.
* `kubectl describe pod <podname>` can be used to confirm scheduling details.

Key Learnings:

* Controlplane nodes are tainted by default to protect them from general workloads.
* Taints and tolerations are the proper mechanism for controlling scheduling in a flexible way.
* The `nodeName` field forces a pod onto a specific node, bypassing scheduling logic.
* For exams and quick testing, using `nodeName` is the simplest approach.
* In real clusters, prefer tolerations, nodeSelectors, or affinity rules over hardcoding `nodeName`.

Cleanup:

* Delete pods after testing with:
  `kubectl delete -f manifest.yaml`
* If taints were modified, revert them to avoid affecting future labs:
  `kubectl taint node k8s-worker worker:NoSchedule-`

---

