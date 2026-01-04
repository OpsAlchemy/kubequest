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

## Level 4: Named Templates & Helper Functions

### 4.1 Create `_helpers.tpl` for Labels

**Objective:**
Extract common labels into reusable named templates.

**Create `templates/_helpers.tpl`:**

Define these named templates:

1. `simple-app.labels` - standard labels
2. `simple-app.selectorLabels` - selector labels only
3. `simple-app.name` - chart name
4. `simple-app.fullname` - full resource name

**Example Structure:**

```gotemplate
{{- define "simple-app.labels" -}}
app.kubernetes.io/name: {{ include "simple-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
```

**Requirements:**

* Update Deployment and Service to use:

  ```gotemplate
  labels:
    {{- include "simple-app.labels" . | nindent 4 }}
  ```
* Use proper `nindent` for alignment

---

### 4.2 String Manipulation Functions

**Objective:**
Practice Helm string functions.

**values.yaml additions:**

```yaml
appName: "My Demo App"
namespace: "production"
imageTag: "v1.2.3-alpha"
```

**Template Requirements:**

Create a ConfigMap that demonstrates:

* `upper` - convert appName to uppercase
* `lower` - convert namespace to lowercase
* `title` - title case the appName
* `trim` - remove whitespace
* `trimSuffix` - remove `-alpha` from tag
* `replace` - replace spaces with dashes
* `quote` - properly quote values

**Example Data:**

```yaml
data:
  APP_NAME_UPPER: {{ .Values.appName | upper | quote }}
  NAMESPACE_LOWER: {{ .Values.namespace | lower | quote }}
  TAG_CLEAN: {{ .Values.imageTag | trimSuffix "-alpha" | quote }}
  APP_SLUG: {{ .Values.appName | replace " " "-" | lower | quote }}
```

---

### 4.3 Default Values with `default` Function

**Objective:**
Handle missing or optional values gracefully.

**values.yaml:**

```yaml
service:
  type: ClusterIP
  # port is intentionally missing

resources: {}
  # limits and requests are optional
```

**Template Logic:**

In Service template:

```gotemplate
port: {{ default 8080 .Values.service.port }}
```

In Deployment template:

```gotemplate
resources:
  {{- if .Values.resources.limits }}
  limits:
    cpu: {{ default "100m" .Values.resources.limits.cpu }}
    memory: {{ default "128Mi" .Values.resources.limits.memory }}
  {{- end }}
  requests:
    cpu: {{ default "50m" .Values.resources.requests.cpu }}
    memory: {{ default "64Mi" .Values.resources.requests.memory }}
```

**Test:**

* Install without setting values → uses defaults
* Override specific values → uses overrides

---

## Level 5: Data Structures & Advanced Logic

### 5.1 Working with Lists and `range`

**Objective:**
Master iteration over lists and maps.

**values.yaml:**

```yaml
additionalLabels:
  cost-center: "engineering"
  project: "demo"
  owner: "platform-team"

volumes:
  - name: cache
    mountPath: /cache
    emptyDir: {}
  - name: data
    mountPath: /data
    emptyDir:
      sizeLimit: 1Gi
```

**Deployment Template:**

Add labels section:

```gotemplate
labels:
  {{- include "simple-app.labels" . | nindent 4 }}
  {{- range $key, $value := .Values.additionalLabels }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
```

Add volumes and volumeMounts:

```gotemplate
volumes:
{{- range .Values.volumes }}
- name: {{ .name }}
  emptyDir:
    {{- toYaml .emptyDir | nindent 4 }}
{{- end }}

volumeMounts:
{{- range .Values.volumes }}
- name: {{ .name }}
  mountPath: {{ .mountPath }}
{{- end }}
```

---

### 5.2 Conditionals with `and`, `or`, `not`

**Objective:**
Use logical operators for complex conditions.

**values.yaml:**

```yaml
monitoring:
  enabled: true
  prometheus: true
  grafana: false

security:
  enabled: true
  readOnlyRootFilesystem: true
  runAsNonRoot: true
```

**Template Logic:**

```gotemplate
{{- if and .Values.monitoring.enabled .Values.monitoring.prometheus }}
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
{{- end }}

{{- if or .Values.security.enabled .Values.security.runAsNonRoot }}
securityContext:
  {{- if .Values.security.runAsNonRoot }}
  runAsNonRoot: true
  runAsUser: 1000
  {{- end }}
  {{- if .Values.security.readOnlyRootFilesystem }}
  readOnlyRootFilesystem: true
  {{- end }}
{{- end }}
```

---

### 5.3 Required Values Validation

**Objective:**
Ensure critical values are provided.

**values.yaml:**

```yaml
# image is required - no default
image: ""

database:
  # host is required
  host: ""
  port: 5432
```

**Template with Validation:**

```gotemplate
image: {{ required "A valid .Values.image is required!" .Values.image }}

env:
- name: DB_HOST
  value: {{ required "database.host is required!" .Values.database.host | quote }}
- name: DB_PORT
  value: {{ .Values.database.port | quote }}
```

**Test:**

* Install without image → should fail with error message
* Install with image → succeeds

---

## Level 6: YAML Formatting & Complex Types

### 6.1 Working with `toYaml` and `nindent`

**Objective:**
Properly render complex YAML structures.

**values.yaml:**

```yaml
podAnnotations:
  backup.velero.io/backup-volumes: data
  prometheus.io/scrape: "true"

tolerations:
  - key: "node.kubernetes.io/disk-pressure"
    operator: "Exists"
    effect: "NoSchedule"
  - key: "environment"
    operator: "Equal"
    value: "production"
    effect: "NoSchedule"

nodeSelector:
  disktype: ssd
  zone: us-west-1a
```

**Deployment Template:**

```gotemplate
{{- with .Values.podAnnotations }}
annotations:
  {{- toYaml . | nindent 2 }}
{{- end }}

spec:
  {{- with .Values.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  
  {{- with .Values.tolerations }}
  tolerations:
    {{- toYaml . | nindent 2 }}
  {{- end }}
```

**Key Concepts:**

* `with` for scoping
* `toYaml` for complex structures
* Correct `nindent` values for alignment

---

### 6.2 Merging Values with `merge` and `mustMerge`

**Objective:**
Combine multiple value sources.

**values.yaml:**

```yaml
commonLabels:
  team: platform
  managed-by: helm

deploymentLabels:
  component: backend

podLabels:
  version: v1
```

**Template:**

```gotemplate
{{- $labels := merge .Values.podLabels .Values.deploymentLabels .Values.commonLabels }}
labels:
  {{- range $key, $value := $labels }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
```

**Expected Result:**
All three label sets merged together (podLabels takes precedence).

---

### 6.3 Type Conversion Functions

**Objective:**
Convert between types safely.

**values.yaml:**

```yaml
replicas: "3"  # string instead of int
port: 8080     # int

features:
  caching: "true"  # string bool
  debug: false     # real bool
```

**Template:**

```gotemplate
replicas: {{ .Values.replicas | int }}

env:
- name: CACHE_ENABLED
  value: {{ .Values.features.caching | toString | quote }}
- name: DEBUG
  value: {{ .Values.features.debug | toString | quote }}
```

**Functions to Practice:**

* `int` - convert to integer
* `toString` - convert to string
* `float64` - convert to float

---

## Level 7: Production-Ready Patterns

### 7.1 Health Checks (Probes)

**Objective:**
Add comprehensive health checking.

**values.yaml:**

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3

startupProbe:
  httpGet:
    path: /startup
    port: http
  initialDelaySeconds: 0
  periodSeconds: 5
  failureThreshold: 30
```

**Deployment Template:**

```gotemplate
{{- if .Values.livenessProbe }}
livenessProbe:
  {{- toYaml .Values.livenessProbe | nindent 2 }}
{{- end }}

{{- if .Values.readinessProbe }}
readinessProbe:
  {{- toYaml .Values.readinessProbe | nindent 2 }}
{{- end }}

{{- if .Values.startupProbe }}
startupProbe:
  {{- toYaml .Values.startupProbe | nindent 2 }}
{{- end }}
```

---

### 7.2 Resource Management

**Objective:**
Properly define resource requests and limits.

**values.yaml:**

```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
```

**Deployment:**

```gotemplate
resources:
  {{- toYaml .Values.resources | nindent 2 }}
```

**Create `hpa.yaml`:**

```gotemplate
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "simple-app.fullname" . }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "simple-app.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
  {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
  {{- end }}
  {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
  {{- end }}
{{- end }}
```

---

### 7.3 NOTES.txt Template

**Objective:**
Create helpful installation output.

**Create `templates/NOTES.txt`:**

```gotemplate
Thank you for installing {{ .Chart.Name }}!

Your release is named {{ .Release.Name }}.

To learn more about the release, try:

  $ helm status {{ .Release.Name }}
  $ helm get all {{ .Release.Name }}

{{- if .Values.service.type }}

Service Type: {{ .Values.service.type }}

{{- if eq .Values.service.type "NodePort" }}
  export NODE_PORT=$(kubectl get --namespace {{ .Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ include "simple-app.fullname" . }})
  export NODE_IP=$(kubectl get nodes --namespace {{ .Release.Namespace }} -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT
{{- else if eq .Values.service.type "LoadBalancer" }}
  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
  Watch the status with: 
    kubectl get --namespace {{ .Release.Namespace }} svc -w {{ include "simple-app.fullname" . }}
{{- else if eq .Values.service.type "ClusterIP" }}
  export POD_NAME=$(kubectl get pods --namespace {{ .Release.Namespace }} -l "app.kubernetes.io/name={{ include "simple-app.name" . }},app.kubernetes.io/instance={{ .Release.Name }}" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080"
  kubectl --namespace {{ .Release.Namespace }} port-forward $POD_NAME 8080:{{ .Values.service.port }}
{{- end }}
{{- end }}

{{- if .Values.autoscaling.enabled }}

Autoscaling is ENABLED:
  Min Replicas: {{ .Values.autoscaling.minReplicas }}
  Max Replicas: {{ .Values.autoscaling.maxReplicas }}
{{- else }}

Autoscaling is DISABLED. Using {{ .Values.replicaCount }} replica(s).
{{- end }}
```

---

## Final Challenge: Comprehensive Chart Package

**Objective:**
Combine everything into a production-ready chart.

### Requirements Checklist:

- [ ] Chart.yaml with proper metadata (name, version, description, keywords, maintainers)
- [ ] values.yaml with comprehensive defaults and comments
- [ ] _helpers.tpl with all named templates
- [ ] Deployment with:
  - [ ] Named template labels
  - [ ] ConfigMap/Secret mounts
  - [ ] Resource limits
  - [ ] All three probe types
  - [ ] Security context
  - [ ] Node selectors and tolerations
- [ ] Service with configurable type
- [ ] ConfigMap with templated content
- [ ] HorizontalPodAutoscaler (conditional)
- [ ] ServiceAccount (conditional)
- [ ] Ingress (conditional)
- [ ] NOTES.txt with helpful instructions
- [ ] Proper `toYaml`, `nindent`, `quote` usage throughout
- [ ] Required value validation
- [ ] No hardcoded values

### Validation Commands:

```bash
# Lint the chart
helm lint .

# Dry run with debug
helm install --dry-run --debug test-release .

# Template with different values
helm template test-release . -f values-prod.yaml

# Install and verify
helm install my-app .
kubectl get all
helm get values my-app

# Upgrade
helm upgrade my-app . --set replicaCount=3

# Check history
helm history my-app
```

---

## Recommended Practice Flow

1. **Level 1-2**: Get basic structure working
2. **Level 3**: Add templating and loops
3. **Level 4**: Create helpers and use functions
4. **Level 5-6**: Master data structures and YAML handling
5. **Level 7**: Production-ready features
6. **Final Challenge**: Package everything together

**Pro Tips:**

* Always use `helm lint` before installing
* Use `--dry-run --debug` to see rendered templates
* Test with `helm template` to avoid cluster pollution
* Validate YAML syntax with `yamllint`
* Keep templates readable with proper indentation
* Document values.yaml thoroughly
