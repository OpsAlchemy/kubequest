### CreateContainerConfigError due to ConfigMap Key Mismatch

**Symptom**

* Pods in namespace `application1` stuck in `CreateContainerConfigError`.
* Deployment shows replicas created but containers never start.
* `kubectl logs` not available because container did not initialize.

**Cause**

* Deployment references an environment variable from a ConfigMap key:

  ```
  valueFrom:
    configMapKeyRef:
      name: configmap-category
      key: category
  ```
* The ConfigMap was updated and the key name was changed (e.g. from `category` to `configmap-category`).
* The referenced key no longer exists, so kubelet cannot build the container spec.

**Verification**

```
kubectl get cm configmap-category -n application1 -o yaml
```

**Fix**

* Ensure the key name in the ConfigMap matches what the Pod spec expects, or update the Deployment to reference the new key.
* After correction, restart pods:

```
kubectl rollout restart deploy api -n application1
```

**Key Note**

* `CreateContainerConfigError` commonly indicates missing ConfigMap/Secret keys, not image or runtime issues.
