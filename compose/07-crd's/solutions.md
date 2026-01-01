## Solutions

---

## Solution 1 — Reading and reasoning

1. Custom Resource `apiVersion`:

```yaml
apiVersion: security.example.com/v1
```

2. kubectl get command:

```bash
kubectl get accesspolicies
```

3. Namespace requirement:

* Yes. The CRD scope is `Namespaced`, so `metadata.namespace` is required.

4. Correct CRD name format:

```text
<plural>.<group> → accesspolicies.security.example.com
```

---

## Solution 2 — Fix the broken CRD

1. What is wrong:

* `metadata.name` does not match `spec.names.plural + "." + spec.group`.

2. Fixed CRD:

```yaml
metadata:
  name: accesspolicies.security.example.com
```

3. Why Kubernetes rejects the original:

* Kubernetes requires the CRD name to be exactly `plural.group`; otherwise the API cannot be registered.

---

## Solution 3 — FeatureToggle CRD and CR

### CustomResourceDefinition

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: featuretoggles.config.example.com
spec:
  group: config.example.com
  scope: Namespaced
  names:
    plural: featuretoggles
    singular: featuretoggle
    kind: FeatureToggle
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                enabled:
                  type: boolean
                description:
                  type: string
```

### Custom Resource

```yaml
apiVersion: config.example.com/v1
kind: FeatureToggle
metadata:
  name: new-ui
  namespace: default
spec:
  enabled: true
```

---

## Solution 4 — Schema validation failure

1. Why the CR is rejected:

* The value type does not match the CRD schema.

2. Field causing the issue:

```text
spec.enabled
```

3. Correct value type:

```text
boolean (true or false)
```

---

## Solution 5 — kubectl explain

1. Inspect the Custom Resource:

```bash
kubectl explain featuretoggles
```

2. Inspect the `spec.enabled` field:

```bash
kubectl explain featuretoggles.spec.enabled
```

3. Why this is useful in the exam:

* It shows field names, types, and descriptions without opening YAML files.

---

## Solution 6 — Cluster vs Namespaced trap

1. What will go wrong:

* The CR will be rejected because cluster-scoped resources cannot have a namespace.

2. How to fix it:

* Remove `metadata.namespace` from the CR.

3. Which object is incorrect:

* The Custom Resource (CR), not the CRD.

---

## Solution 7 — Fast recognition drill

Given:

```text
CRD name: backups.storage.example.com
```

1. Group:
    ```text
    storage.example.com
    ```
2. Plural:
    ```text
    backups
    ```

3. Kind:
    ```text
    Backup
    ```

4. kubectl get command:
    ```bash
    kubectl get backups
    ```
