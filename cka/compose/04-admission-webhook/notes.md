*![Image](https://kubernetes.io/images/blog/2019-03-21-a-guide-to-kubernetes-admission-controllers/admission-controller-phases.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AVE3P8Kf4d7gwK3AU)

![Image](https://slack.engineering/wp-content/uploads/sites/7/2021/12/sequence-diagram.jpg?w=688)

# Admission Webhooks (Kubernetes) — Practical Notes

Admission webhooks sit **between authentication/authorization and object persistence**. They are **API-server extensions**, not runtime components, and they execute **on every matching API request** (create, update, delete, connect).

---

## 1. Where Admission Webhooks Execute (Critical Mental Model)

```
kubectl / client
   ↓
Authentication
   ↓
Authorization (RBAC)
   ↓
Admission Controllers
   ├─ MutatingAdmissionWebhook
   └─ ValidatingAdmissionWebhook
   ↓
etcd (object persisted)
```

**Key implication**
If an admission webhook fails or times out (depending on failurePolicy), **the API request may be rejected even if RBAC allows it**.

---

## 2. Mutating vs Validating (Operational Difference)

### MutatingAdmissionWebhook

* **Can modify** the incoming object
* Runs **first**
* Typical use:

  * Inject sidecars
  * Add labels/annotations
  * Set defaults not handled by API schema

### ValidatingAdmissionWebhook

* **Cannot modify** the object
* Runs **after mutation**
* Typical use:

  * Enforce policies
  * Block non-compliant resources

**Golden rule**
Mutation makes objects *convenient*. Validation makes clusters *safe*.

---

## 3. What Actually Triggers a Webhook

A webhook triggers when **ALL** of these match:

* API group (e.g., `apps`, `""` for core)
* API version (e.g., `v1`)
* Resource (e.g., `pods`, `deployments`)
* Operation (`CREATE`, `UPDATE`, `DELETE`, `CONNECT`)
* Namespace selector (optional)
* Object selector (optional)

This is why webhooks can be **surgically precise** or **dangerously broad**.

---

## 4. Real-World Use Cases (Practical, Not Theoretical)

### 4.1 Enforce “No :latest Image”

**Type**: Validating
**Why**: Prevents non-reproducible deployments

* Trigger: `CREATE`, `UPDATE` on `pods`
* Logic: Reject if any container image ends with `:latest`

Outcome:
`kubectl apply` fails immediately with a validation error.

---

### 4.2 Auto-Inject Sidecar

**Type**: Mutating
**Why**: Avoid developers manually adding boilerplate

* Trigger: `CREATE` on `pods`
* Condition: Namespace has label `mesh=enabled`
* Mutation: Append sidecar container spec

Outcome:
Pod spec stored in etcd already includes the sidecar.

---

### 4.3 Enforce Required Labels

**Type**: Validating
**Why**: Governance, cost allocation, ownership

* Require labels like:

  * `app`
  * `owner`
  * `environment`

Outcome:
Objects without labels never reach the cluster state.

---

### 4.4 Block Privileged Containers

**Type**: Validating
**Why**: Security hardening

* Reject if:

  * `securityContext.privileged: true`
  * `hostPath` volumes used

Outcome:
Security enforced **before** workload starts.

---

## 5. Failure Modes You Must Understand

### failurePolicy

* `Fail`
  API request fails if webhook is unreachable
  Use for **security-critical** controls
* `Ignore`
  API request continues if webhook fails
  Use for **non-critical mutation**

**Production guidance**
Validating webhooks enforcing security should almost always be `Fail`.

---

### timeoutSeconds

* Default: 10 seconds
* API server blocks waiting for response

**Anti-pattern**
Slow webhook = cluster-wide deployment slowdown.

---

## 6. Operational Risks (Exam + Real World)

### 6.1 Self-Inflicted Cluster Outage

* Webhook applies to:

  * `pods`
  * `deployments`
* Webhook service is **down**
* failurePolicy = `Fail`

Result:
No pods can be created, including webhook itself.

**Mitigation**

* Narrow selectors
* Use namespace exclusion
* Careful bootstrapping order

---

### 6.2 Infinite Mutation Loops

* Webhook mutates object
* Mutation changes something webhook re-triggers on

**Mitigation**

* Add idempotent markers (e.g., annotation `mutated=true`)
* Exit early if already processed

---

## 7. How Admission Webhooks Are Deployed (Practically)

### Components

1. **Webhook server**

   * Runs as a Pod
   * Exposes HTTPS endpoint
2. **Service**

   * Stable DNS for API server
3. **TLS**

   * Mandatory (API server only talks HTTPS)
4. **WebhookConfiguration**

   * MutatingWebhookConfiguration or ValidatingWebhookConfiguration

---

## 8. AdmissionReview Request / Response (Conceptual)

Webhook receives:

* Full object (`oldObject` for updates)
* User info
* Namespace
* Operation

Webhook returns:

* `allowed: true | false`
* Optional status message
* Optional JSON patch (mutation only)

This is **synchronous** and **blocking**.

---

## 9. Admission Webhooks vs Other Controls (Exam-Relevant)

| Mechanism              | When it Acts            | Can Modify    | Can Block |
| ---------------------- | ----------------------- | ------------- | --------- |
| RBAC                   | Before admission        | No            | Yes       |
| Admission Webhook      | Before persistence      | Mutating: Yes | Yes       |
| Pod Security Admission | Admission               | No            | Yes       |
| OPA / Gatekeeper       | Admission (via webhook) | No            | Yes       |
| Runtime security       | After pod runs          | N/A           | No        |

---

## 10. Key Takeaways to Remember

* Admission webhooks operate **before objects exist**
* They are **synchronous and blocking**
* Mutating runs **before** validating
* A broken webhook can **break the cluster**
* Always scope selectors tightly
* Prefer validation for safety, mutation for convenience

---

## 11. One-Line Exam Summary

**Admission webhooks intercept API requests after RBAC but before persistence, allowing mutation or rejection of Kubernetes objects based on custom logic.**

If you want, the next extension can cover:

* Step-by-step webhook deployment
* Common CKA traps
* Admission vs Pod Security Admission
* Debugging webhook failures in production
## 12. Minimal, Practical Code Examples (Incremental Add-on)

The sections below **extend** the existing notes by adding **working YAML and logic fragments** that correspond directly to the use cases already described. Nothing earlier is replaced.

---

## 12.1 Validating Webhook — Block `:latest` Images

### Webhook Configuration (Validating)

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: deny-latest-tag
webhooks:
  - name: deny-latest.images.example.com
    admissionReviewVersions: ["v1"]
    sideEffects: None
    failurePolicy: Fail
    timeoutSeconds: 5
    rules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
    clientConfig:
      service:
        name: image-policy-webhook
        namespace: admission
        path: /validate-images
      caBundle: <BASE64_CA_CERT>
```

### Admission Logic (Pseudo-code)

```text
for each container in pod.spec.containers:
  if image ends with ":latest":
    deny("image tag ':latest' is not allowed")
allow()
```

**Practical effect**
`kubectl apply` fails immediately if any container uses `:latest`.

---

## 12.2 Mutating Webhook — Sidecar Injection

### Webhook Configuration (Mutating)

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: inject-sidecar
webhooks:
  - name: sidecar.inject.example.com
    admissionReviewVersions: ["v1"]
    sideEffects: None
    failurePolicy: Ignore
    rules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
    namespaceSelector:
      matchLabels:
        mesh: enabled
    clientConfig:
      service:
        name: sidecar-webhook
        namespace: admission
        path: /mutate-pod
      caBundle: <BASE64_CA_CERT>
```

### JSON Patch Returned by Webhook

```json
[
  {
    "op": "add",
    "path": "/spec/containers/-",
    "value": {
      "name": "mesh-proxy",
      "image": "envoyproxy/envoy:v1.30.0"
    }
  }
]
```

**Practical effect**
Developers deploy normal pods; sidecars appear automatically in stored objects.

---

## 12.3 Validating Webhook — Required Labels

### Webhook Rule

```yaml
rules:
  - apiGroups: ["apps"]
    apiVersions: ["v1"]
    operations: ["CREATE", "UPDATE"]
    resources: ["deployments"]
```

### Validation Logic

```text
required = ["app", "owner", "environment"]

for key in required:
  if key not in metadata.labels:
    deny("missing required label: " + key)
allow()
```

**Practical effect**
Governance enforced before workloads exist.

---

## 12.4 Validating Webhook — Block Privileged Pods

### Validation Logic

```text
for container in pod.spec.containers:
  if container.securityContext.privileged == true:
    deny("privileged containers are not allowed")

for volume in pod.spec.volumes:
  if volume.hostPath exists:
    deny("hostPath volumes are not allowed")
allow()
```

**Practical effect**
Security policy enforced independently of RBAC.

---

## 12.5 Webhook Server (Skeleton)

### HTTPS Server (Conceptual)

```text
POST /validate
  decode AdmissionReview
  inspect request.object
  build AdmissionReview response:
    allowed: true | false
    status.message (if denied)
  return response
```

**Key requirement**

* HTTPS only
* Valid certificate trusted by API server

---

## 12.6 Bootstrap-Safe Selector Example (Outage Prevention)

```yaml
namespaceSelector:
  matchExpressions:
    - key: kubernetes.io/metadata.name
      operator: NotIn
      values:
        - kube-system
        - admission
```

**Why this matters**
Prevents the webhook from blocking its own Pods or system components.

---

## 12.7 Debugging a Failing Webhook (Operational)

```bash
kubectl get validatingwebhookconfigurations
kubectl describe validatingwebhookconfiguration deny-latest-tag

kubectl logs -n admission deploy/image-policy-webhook
```

Typical symptoms:

* `context deadline exceeded`
* `no endpoints available for service`
* TLS trust errors

---

## 12.8 Exam-Focused Code Recognition Checklist

* `MutatingWebhookConfiguration` → JSON Patch present
* `ValidatingWebhookConfiguration` → allow/deny only
* `failurePolicy: Fail` → cluster safety risk if misused
* `namespaceSelector` → blast-radius control
* HTTPS + CA bundle mandatory

---

## 12.9 One-Line Extension Summary

Admission webhooks are implemented as HTTPS services registered via webhook configurations that synchronously mutate or reject Kubernetes API objects before persistence, with selectors and failure policies determining their operational safety.
