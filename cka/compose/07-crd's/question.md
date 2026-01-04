## Question 1 — Reading and reasoning

You are given the following CRD:

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: accesspolicies.security.example.com
spec:
  group: security.example.com
  scope: Namespaced
  names:
    plural: accesspolicies
    singular: accesspolicy
    kind: AccessPolicy
  versions:
    - name: v1
      served: true
      storage: true
```

Tasks:

1. Write the correct `apiVersion` for a Custom Resource
2. Write the correct `kubectl get` command
3. State whether a namespace is required when creating a CR
4. State the correct CRD name format

---

## Question 2 — Fix the broken CRD

The following CRD fails to apply:

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: policies.security.example.com
spec:
  group: security.example.com
  scope: Namespaced
  names:
    plural: accesspolicies
    singular: accesspolicy
    kind: AccessPolicy
  versions:
    - name: v1
      served: true
      storage: true
```

Tasks:

1. Identify what is wrong
2. Fix the CRD
3. Explain why Kubernetes rejects the original

---

## Question 3 — FeatureToggle CRD

Create a **namespaced CRD** with:

* Kind: `FeatureToggle`
* Group: `config.example.com`
* Version: `v1`
* Plural: `featuretoggles`
* Spec fields:

  * `enabled` (boolean)
  * `description` (string)

Then create a Custom Resource:

* Name: `new-ui`
* Namespace: `default`
* enabled: `true`

---

## Question 4 — Schema validation failure

You apply the following CR:

```yaml
apiVersion: config.example.com/v1
kind: FeatureToggle
metadata:
  name: broken-toggle
  namespace: default
spec:
  enabled: "true"
```

Tasks:

1. Explain why this CR is rejected
2. Identify the exact field causing the issue
3. State the correct value type

---

## Question 5 — kubectl explain

Assume the CRD `featuretoggles.config.example.com` exists.

Tasks:

1. Inspect the Custom Resource using `kubectl explain`
2. Inspect the `spec.enabled` field
3. Explain why this is useful in the exam

---

## Question 6 — Cluster vs Namespaced trap

You are given a CRD with:

```yaml
spec:
  scope: Cluster
```

But the CR YAML contains:

```yaml
metadata:
  namespace: default
```

Tasks:

1. State what will go wrong
2. Explain how to fix it
3. Identify which object is incorrect

---

## Question 7 — Fast recognition drill

Given:

```text
CRD name: backups.storage.example.com
```

Answer:

1. Group
2. Plural
3. Kind
4. `kubectl get` command
