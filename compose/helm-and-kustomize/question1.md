## Helm Practice Exercise - 1

These exercises are designed to help you **master Helm mechanics only**—chart structure, templating, values, conditionals, hooks, dependencies, upgrades, and reuse—using **simple dummy workloads** (`busybox`, `sleep`, `echo`).

There is **no application logic complexity** involved.

---

## Level 1: Basic Chart Structure

### 1.1 Simple Dummy Application

**Objective:**
Create a Helm chart named `simple-app` that deploys a container which only sleeps.

**Requirements:**

* Chart metadata:

  * `name`: `simple-app`
  * `version`: `0.1.0`
  * `appVersion`: `1.0`
* One `Deployment`

  * `replicas: 1`
  * Image: `busybox:latest`
  * Command:

    ```yaml
    ["sh", "-c", "echo 'App started' && sleep 3600"]
    ```
* One `Service`

  * Exposes port `8080` (even if unused)

**Constraint:**

* All configuration must be **hardcoded** in the manifests.
* No `values.yaml` usage yet.

---

### 1.2 Add Configuration Values

**Objective:**
Parameterize the chart using `values.yaml`.

**Requirements:**
Create `values.yaml` with:

```yaml
replicaCount: 2

image: busybox:latest

command:
  - sh
  - -c
  - echo 'Default command' && sleep 3600

service:
  port: 8080
```

**Template Expectations:**

* All values must be referenced using `{{ .Values.* }}`

**Test:**

```bash
helm install test simple-app --set replicaCount=3
```

Verify that **3 Pods** are created.

---

## Level 2: Template Logic

### 2.1 Conditional Sidecar Container

**Objective:**
Add a sidecar container conditionally.

**Requirements (values.yaml):**

```yaml
sidecar:
  enabled: false
  image: nginx:alpine
  port: 80
```

**Template Logic:**

* Use:

  ```gotemplate
  {{- if .Values.sidecar.enabled }}
  ```
* Add a second container:

  * Name: `sidecar`
  * Image: from values
  * Exposes `containerPort`

**Test:**

* Install normally → no sidecar
* Install with:

  ```bash
  --set sidecar.enabled=true
  ```

---

### 2.2 Dynamic Names and Labels

**Objective:**
Generate labels and names dynamically.

**Requirements (values.yaml):**

```yaml
environment: dev
team: platform
```

**Deployment Labels:**

* `environment: <value>`
* `team: <value>`
* `fullname: <release-name>-<chart-name>`

**Additional Resource:**
Create a `ConfigMap`:

* Name:

  ```gotemplate
  {{ .Release.Name }}-config
  ```
* Data:

  ```yaml
  environment: <value>
  ```

**Key Challenge:**

* Proper quoting and sanitization of label values.

---

## Level 3: Advanced Templating

### 3.1 Looping Environment Variables

**Objective:**
Dynamically inject environment variables.

**values.yaml:**

```yaml
env:
  - name: LOG_LEVEL
    value: "INFO"
  - name: TIMEOUT
    value: "30"

envSecrets: []
```

**Requirements:**

* Use:

  ```gotemplate
  {{- range .Values.env }}
  ```

  to render environment variables.
* Create a **demo Secret** with a similar structure.
* Conditionally mount secrets **only if** `envSecrets` is non-empty.

---

### 3.2 ConfigMap from File with `tpl`

**Objective:**
Render templated config content stored in values.

**values.yaml:**

```yaml
configData: |
  app.name: {{ .Chart.Name }}
  app.version: {{ .Chart.Version }}
```

**templates/config.yaml:**

* Use:

  ```gotemplate
  {{ tpl .Values.configData . }}
  ```

**Mounting:**

* Mount ConfigMap at:

  ```
  /app/config/app.conf
  ```

**Test:**

* Verify rendered ConfigMap shows **actual chart name and version**, not template text.

---

## Level 4: Dependencies and Hooks

### 4.1 Chart Dependency (Subchart)

**Objective:**
Create a parent chart with a dependency.

**Parent Chart:**

* Name: `parent-app`
* Type: `application`

**Dependency:**

* `mysql` from Bitnami repo

**Chart.yaml:**

```yaml
dependencies:
  - name: mysql
    version: "*"
    repository: https://charts.bitnami.com/bitnami
```

**Parent values.yaml:**

```yaml
mysql:
  auth:
    rootPassword: root123
    database: appdb
```

**Template Requirement:**

* Create a ConfigMap referencing:

  ```gotemplate
  {{ .Release.Name }}-mysql
  ```

**Test:**

* Verify MySQL subchart deploys with supplied values.

---

### 4.2 Pre-Install Hook

**Objective:**
Add a pre-install validation job.

**Requirements:**

* Create a `Job` template
* Annotations:

  ```yaml
  "helm.sh/hook": pre-install
  "helm.sh/hook-weight": "-5"
  ```
* Container:

  * Image: `busybox`
  * Command:

    ```sh
    echo "Checking cluster resources..."
    ```

**Test:**

* Observe Job execution **before** main resources.

---

## Level 5: Real-World Patterns

### 5.1 Multi-Environment Values

**Base values.yaml:**

```yaml
replicaCount: 1
image: busybox:1.0
```

**values.prod.yaml:**

```yaml
replicaCount: 3
image: busybox:stable
resources:
  limits:
    cpu: "500m"
```

**values.dev.yaml:**

```yaml
replicaCount: 1
image: busybox:latest
debug: true
```

**Template Logic:**

* Add a debug container **only when** `.Values.debug` is true.

**Test:**

```bash
helm install prod-app . -f values.prod.yaml
```

---

### 5.2 Library (Shared) Templates

**Objective:**
Create reusable templates using a library chart.

**Library Chart:**

* Name: `shared-lib`
* Type: `library`

**_helpers.tpl:**
Define template:

```gotemplate
{{- define "shared-lib.container" }}
{{- end }}
```

Parameters:

* `name`
* `image`
* `command`

**Consumer Chart:**

* Name: `my-service`
* Depends on `shared-lib`

**Usage:**

```gotemplate
{{ include "shared-lib.container" (dict
  "name" "main"
  "image" .Values.image
  "command" .Values.command
) }}
```

**Key Concept:**

* Passing dictionaries to named templates.

---

### 5.3 Upgrade and Rollback

**Objective:**
Practice Helm release lifecycle.

**versioned-app:**

* ConfigMap value:

  ```yaml
  appConfig: v1
  ```

**Steps:**

1. Install `0.1.0`
2. Upgrade to `0.2.0` (`appConfig: v2`)
3. Add post-upgrade hook Job validating config
4. Perform:

   ```bash
   helm rollback <release> <revision>
   ```

**Focus:**

* Release history
* Revision tracking
* Hook behavior on upgrade

---

## Final Challenge: Full Helm Chart

### Chart Name: `full-demo`

**Requirements:**

1. Deployment with sleeping `busybox`
2. Values-based configuration
3. Conditional ConfigMap (`config.enabled`)
4. Redis dependency
5. Hooks:

   * Pre-install: namespace validation
   * Post-install: curl service
6. Multi-environment values
7. Shared label templates
8. Generated Secret
9. Pod annotations from values
10. Optional ServiceAccount

**Constraints:**

* No real application logic
* Only echo/sleep containers
* Helm features are the focus

---

## Recommended Workflow

1. Start with **Level 1.1**
2. Use `helm create` or manual scaffolding
3. Implement exactly one objective at a time
4. Validate with:

   ```bash
   helm install --dry-run --debug
   ```
5. Install and inspect resources
6. Move to the next level
