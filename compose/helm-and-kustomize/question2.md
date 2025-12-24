## Single Chart Evolution: Beginner → Expert (Helm-Only)

**Chart name (constant across all stages):** `master-chart`
**Rule:** You never create a new chart. You only evolve this one.

Each stage introduces **exactly one new Helm concept category**.
Earlier stages must continue to work unchanged.

---

## Stage 1 — Absolute Minimum Chart

### Objective

Establish the smallest valid Helm chart and confirm rendering.

### Values

```yaml
enabled: true
```

### Templates

* **ConfigMap**

  * Name: `{{ .Release.Name }}-config`
  * Data:

    ```yaml
    app-name: {{ .Chart.Name }}
    ```

### Conditions

* ConfigMap is created **only if** `.Values.enabled` is true.

### Verification

* `helm template`
* `helm install`
* Confirm ConfigMap exists.

### Helm Concepts Introduced

* `.Chart.*`
* `.Release.*`
* Basic `if` condition

---

## Stage 2 — Deployment and Service

### Objective

Introduce workload rendering and basic value usage.

### New Values

```yaml
replicaCount: 1
image: busybox:latest
command:
  - sleep
  - "3600"
```

### Templates

* **Deployment**

  * Replicas from `.Values.replicaCount`
  * Image rendered using:

    ```gotemplate
    {{ .Values.image | quote }}
    ```
  * Command from values
* **Service**

  * Type: `ClusterIP`
  * Port: `8080`

### Verification

* Pods scale correctly
* Service created

### Helm Concepts Introduced

* Value interpolation
* Safe string handling with `quote`
* Basic workload templating

---

## Stage 3 — Conditional Resources

### Objective

Control resource creation via values.

### New Values

```yaml
ingress:
  enabled: false
  host: example.com

serviceAccount:
  create: false
  name: default
```

### Templates

* **Ingress**

  * Rendered only when `.Values.ingress.enabled`
* **ServiceAccount**

  * Created only when `.Values.serviceAccount.create`
  * Otherwise Deployment references `.Values.serviceAccount.name`

### Verification

* Enable both flags
* Confirm resources appear
* Disable again and confirm removal

### Helm Concepts Introduced

* Feature flags
* Optional resource ownership
* Conditional branching

---

## Stage 4 — Environment Configuration

### Objective

Handle dynamic environment variables and config injection.

### New Values

```yaml
env:
  - name: ENV_VAR_1
    value: "test"
  - name: ENV_VAR_2
    valueFrom:
      configMapKeyRef:
        name: config
        key: key1

configMaps:
  config:
    data:
      key1: value1
      key2: value2
```

### Templates

* Generate **multiple ConfigMaps** from `.Values.configMaps`
* Use `range` to inject env vars
* Mount ConfigMap as volume

### Verification

* ConfigMaps rendered dynamically
* Pod environment variables correct

### Helm Concepts Introduced

* `range`
* Nested value structures
* Dynamic resource generation

---

## Stage 5 — Advanced Templating Mechanics

### Objective

Apply structured YAML safely and reuse logic.

### New Values

```yaml
podAnnotations:
  monitoring: enabled
  team: platform

affinity:
  nodeSelector:
    type: high-memory

tolerations:
  - key: dedicated
    operator: Equal
    value: app
    effect: NoSchedule
```

### Templates

* Use `toYaml | nindent` for:

  * Annotations
  * Affinity
  * Tolerations
* Create `_helpers.tpl`:

  * Selector labels
  * Common metadata blocks

### Verification

* Rendered YAML is valid
* No indentation errors

### Helm Concepts Introduced

* `toYaml`
* `nindent`
* Named templates
* Helpers

---

## Stage 6 — Multi-Component Architecture

### Objective

Support multiple workloads from one chart.

### New Values

```yaml
components:
  frontend:
    enabled: true
    replicas: 2
    image: nginx:alpine
    ports: [80]

  backend:
    enabled: false
    replicas: 3
    image: api:latest
    ports: [3000, 3001]
```

### Templates

* Loop over components:

  ```gotemplate
  {{ range $name, $component := .Values.components }}
  ```
* Generate:

  * Deployment per component
  * Service per component
* Naming:

  ```gotemplate
  {{ $.Release.Name }}-{{ $name }}-svc
  ```

### Verification

* Only enabled components deploy
* Naming remains stable

### Helm Concepts Introduced

* Root context `$`
* Dynamic resource sets
* Multi-workload charts

---

## Stage 7 — Lifecycle Hooks

### Objective

Control install, upgrade, and test behavior.

### New Values

```yaml
hooks:
  preInstall:
    enabled: true
    image: busybox
    command: ["echo", "Pre-install check"]

  postInstall:
    enabled: false
```

### Templates

* Hooked Jobs with:

  * `pre-install`
  * `post-install`
  * `pre-upgrade`
* Add Helm test hook for connectivity checks

### Verification

* Observe hook execution order
* Confirm hooks do not persist unnecessarily

### Helm Concepts Introduced

* Hook annotations
* Hook weights
* Lifecycle phases

---

## Stage 8 — Security and RBAC

### Objective

Introduce security hardening and permissions.

### New Values

```yaml
security:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 2000

rbac:
  create: true
  rules:
    - apiGroups: [""]
      resources: ["pods"]
      verbs: ["get", "list"]
```

### Templates

* Apply PodSecurityContext
* Create Role and RoleBinding
* Control `automountServiceAccountToken`

### Verification

* RBAC objects created only when enabled
* Pod runs with expected UID/GID

### Helm Concepts Introduced

* Security contexts
* RBAC templating
* Optional privilege surfaces

---

## Stage 9 — CRDs and Custom Resources

### Objective

Template extensibility beyond core Kubernetes.

### New Values

```yaml
customResources:
  - apiVersion: example.com/v1
    kind: Database
    metadata:
      name: app-db
    spec:
      type: postgresql
      size: small
```

### Templates

* CRD definition (simplified)
* Render CustomResources from values
* Use `required` for schema enforcement

### Verification

* CRDs install correctly
* CR instances render without errors

### Helm Concepts Introduced

* CRDs
* Schema enforcement
* Non-core APIs

---

## Stage 10 — Production-Grade Chart

### Objective

Combine all patterns into a real platform-ready chart.

### Final Value Model

(unchanged from your input — already well structured)

### Mandatory Implementations

1. HPA
2. PodDisruptionBudget
3. Canary deployment flag
4. Resource quotas (namespace-scoped)
5. Validation with `required`
6. Upgrade-safe changes
7. Comprehensive `NOTES.txt`
8. Backward compatibility guarantees

### Helm Concepts Mastered

* Chart architecture
* Upgrade safety
* Extensibility
* Reusability
* Production constraints

---

## Progression Rules (Strict)

1. One chart only
2. No breaking previous stages
3. Test at every stage:

   * `helm template`
   * `helm install --dry-run`
   * real install
4. Version bump **only when behavior changes**
5. Document breaking changes explicitly
