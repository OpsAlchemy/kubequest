Understood. You didn't ask for the full manifests to be generated — just a **clean formatting** of the scenario description you had already written.

Here's the **same challenge**, properly formatted and structured so it's readable, scannable, and clear — **but without generating any YAML or solutions**.

---

## 🧩 Scenario: Puzzle Portal – Kubernetes Design Challenge

### Objective

Design a secure, multi-container Kubernetes app that simulates a real-world production pattern and exercises these concepts:

* ConfigMap and Secret usage
* Volume mounts (including `emptyDir`)
* Init and sidecar containers
* Custom `command` and `args`
* Readiness probes
* ServiceAccounts + RBAC
* NetworkPolicy
* ConfigMap-driven rollout behavior

---

### 1. 🌐 App Overview

You are shipping an internal tool called **Puzzle Portal**. It:

* Serves a generated HTML file via `nginx`
* Exposes a `/healthz` endpoint
* Provides a version file showing the `ConfigMap` resource version
* Can only be accessed from an **approved test namespace**

---

### 2. 🧩 Components

#### Images to use

* **Main Web Server**: `nginx:1.25-alpine`
* **Init Container**: `alpine:3.20`
* **Sidecar**: `curlimages/curl:8.8.0`

#### Namespaces

* App runs in: `default`
* Create a test namespace: `qa`

  * Label: `access=allowed`

---

### 3. 🔐 Secrets and ConfigMaps

#### ConfigMap `web-config`

Includes:

* `app.message: greetings from puzzle`
* `feature_flags.json: {"beta":true,"max_clients":5}`
* `nginx.conf`:
  Should:

  * Listen on port `8080`
  * Serve `/usr/share/nginx/html`
  * Expose `/healthz` returning HTTP 200

#### Secret `web-secret`

Includes:

* `api_token: s3cr3t-3491`
* `admin_password: P@ssw0rd123`

---

### 4. 📦 Volume Mounts

| Mount Type | Mount Path              | What’s Mounted                           |
| ---------- | ----------------------- | ---------------------------------------- |
| ConfigMap  | `/config`               | `app.message`, `feature_flags.json`      |
| ConfigMap  | `/etc/nginx`            | `nginx.conf`                             |
| Secret     | `/secrets`              | `api_token`, `admin_password`            |
| `emptyDir` | `/usr/share/nginx/html` | Final HTML content (from init container) |

---

### 5. 👤 ServiceAccount + RBAC

* Create `puzzle-sa` in `default` namespace
* Role: allow `get` on ConfigMaps
* RoleBinding: bind Role to `puzzle-sa`

---

### 6. 🚀 Deployment Requirements

* Name: `puzzle-web`
* Replicas: `2`
* `serviceAccountName: puzzle-sa`

**Init Container**:

* Image: `alpine:3.20`
* Reads from `/config`, `/secrets`
* Writes `index.html` to `/usr/share/nginx/html`
* Required HTML content:

  ```
  Message: greetings from puzzle
  Flags: beta=true max_clients=5
  Token suffix: 3491
  Password length: 12
  ```

> 🔒 Must **not** print full token, only suffix.

**Main Container**:

* Image: `nginx:1.25-alpine`
* Command: `nginx`
* Args: `-g daemon off; -c /etc/nginx/nginx.conf`
* Readiness Probe:

  * HTTP GET `/healthz`
  * Port: 8080
  * Initial delay: 5s
  * Period: 2s
  * Failure threshold: 3

**Sidecar Container**:

* Image: `curlimages/curl:8.8.0`
* Every 20 seconds:

  * Fetches `web-config` from API
  * Writes `.metadata.resourceVersion` to `/usr/share/nginx/html/version.txt`
* Should fail fast on missing API access (RBAC catch)

---

### 7. 📡 Service

* Type: `ClusterIP`
* Name: `puzzle-svc`
* Port: `8080`
* Selector: app = `puzzle-web`

---

### 8. 🔒 NetworkPolicies

#### Ingress

* Default deny all ingress in `default` namespace
* Allow ingress to Pods with `app=puzzle-web`:

  * From namespace `qa` **if** it has label `access=allowed`
  * Or from Pods in `default` with label `role=smoke-tester`

#### Egress

* Allow only:

  * UDP 53 (DNS)
  * TCP 443 (Kubernetes API server)

---

### 9. 🔁 Rolling ConfigMap Updates

* Update to `web-config` should reflect in:

  * `version.txt` (within 40s)
  * Without deleting Pods
* App must stay `Ready`
* Achieve this via sidecar polling and writing version

---

### 10. ✅ Acceptance Checks

| Check                         | Command                                                                                                                                      |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Health OK from `qa`           | `kubectl -n qa run ok --rm -it --image=curlimages/curl --restart=Never -- curl -sS http://puzzle-svc.default.svc.cluster.local:8080/healthz` |
| Health BLOCKED from untrusted | `kubectl run no --rm -it --image=curlimages/curl --restart=Never -- curl -m 3 -sS http://puzzle-svc:8080/healthz`                            |
| Page shows expected content   | `kubectl -n qa run page --rm -it --image=curlimages/curl --restart=Never -- curl -sS http://puzzle-svc.default.svc.cluster.local:8080/`      |
| Version stamping works        | `curl /version.txt`, then patch ConfigMap, and check it updates                                                                              |
| DNS resolution works          | `kubectl exec -it deploy/puzzle-web -- getent hosts kubernetes.default.svc`                                                                  |

---

### 11. 🧯 Failure Conditions to Debug

* **Readiness fails:** Likely due to nginx not reading correct config or missing `/healthz`
* **version.txt missing:** RBAC issue in sidecar
* **Untrusted access working:** NetworkPolicy selectors wrong
* **qa blocked:** Namespace label or policy error
* **Token unmasked:** Init logic faulty

---

Let me know if you want this broken down into sub-tasks, a diagram, or converted into YAMLs.