## Comprehensive Helm Chart Practice: From Zero to Production Expert

**Chart Name:** `webapp` (use this name throughout all phases)

**Principle:** You build ONE chart progressively. Each phase adds features while maintaining backward compatibility.

---

## Phase 1: Foundation - Hello Helm

**Duration:** 15 minutes | **Difficulty:** Beginner

### Objective
Create the absolute minimum valid Helm chart and verify it renders.

### What You'll Learn
- Chart structure and metadata
- Basic templating syntax
- Helm template rendering

### Requirements

**Step 1.1 - Create Chart Structure**

```
webapp/
├── Chart.yaml
├── values.yaml
└── templates/
    └── configmap.yaml
```

**Step 1.2 - Chart.yaml**

```yaml
apiVersion: v2
name: webapp
description: Progressive Helm Learning Chart
type: application
version: 0.1.0
appVersion: "1.0"
keywords:
  - helm
  - practice
  - kubernetes
maintainers:
  - name: Your Name
    email: your@email.com
```

**Step 1.3 - values.yaml**

```yaml
appName: webapp
enabled: true
```

**Step 1.4 - templates/configmap.yaml**

Create a simple ConfigMap:

```yaml
{{- if .Values.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-config
  namespace: {{ .Release.Namespace }}
  labels:
    app: {{ .Values.appName }}
data:
  app-name: {{ .Values.appName }}
  chart-name: {{ .Chart.Name }}
  chart-version: {{ .Chart.Version }}
{{- end }}
```

### Validation

```bash
# Render the template
helm template my-release .

# Expected output: ConfigMap resource with metadata and data

# Verify disabling works
helm template my-release . --set enabled=false

# Expected: No output (resource not rendered)
```

### Concepts Introduced
- `.Chart.*` (chart metadata)
- `.Release.*` (release information)
- `.Values.*` (user-provided values)
- Basic conditional `if/end`
- String interpolation with `{{ }}`

---

## Phase 2: Workloads - Deployment & Service

**Duration:** 30 minutes | **Difficulty:** Beginner

### Objective
Deploy a functional application with Service exposure.

### What You'll Learn
- Deployment templating
- Service configuration
- Pod specification basics
- Value quoting and safety

### Requirements

**Step 2.1 - Update values.yaml**

```yaml
appName: webapp
enabled: true

replicaCount: 2
image: busybox:latest
imagePullPolicy: IfNotPresent

containerPort: 8080
servicePort: 8080
serviceType: ClusterIP

command:
  - /bin/sh
  - -c
  - echo "App started on port 8080" && sleep 3600

nameOverride: ""
fullnameOverride: ""
```

**Step 2.2 - Create templates/_helpers.tpl**

```gotemplate
{{/*
Generate common labels
*/}}
{{- define "webapp.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Generate selector labels
*/}}
{{- define "webapp.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Expand the name of the chart
*/}}
{{- define "webapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the full name
*/}}
{{- define "webapp.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}
```

**Step 2.3 - Create templates/deployment.yaml**

```yaml
{{- if .Values.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "webapp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "webapp.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: {{ .Values.image | quote }}
        imagePullPolicy: {{ .Values.imagePullPolicy }}
        ports:
        - name: http
          containerPort: {{ .Values.containerPort }}
          protocol: TCP
        command:
          {{- toYaml .Values.command | nindent 10 }}
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - ps aux | grep sleep || exit 1
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - ps aux | grep sleep || exit 1
          initialDelaySeconds: 5
          periodSeconds: 5
{{- end }}
```

**Step 2.4 - Create templates/service.yaml**

```yaml
{{- if .Values.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
spec:
  type: {{ .Values.serviceType }}
  ports:
    - port: {{ .Values.servicePort }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "webapp.selectorLabels" . | nindent 4 }}
{{- end }}
```

### Validation

```bash
# Verify template rendering
helm template my-app . --debug

# Dry-run install
helm install --dry-run my-app .

# Real install
helm install my-app .

# Verify resources
kubectl get deployment,service
kubectl logs deployment/my-app-webapp

# Scale up
helm upgrade my-app . --set replicaCount=3
kubectl get pods
```

### Concepts Introduced
- Named templates (helpers)
- `include` function
- `nindent` for proper indentation
- `toYaml` for array rendering
- `trunc`, `trimSuffix` string functions
- Deployment and Service specs
- Label management

---

## Phase 3: Configuration Management

**Duration:** 45 minutes | **Difficulty:** Beginner-Intermediate

### Objective
Handle configuration through ConfigMaps and environment variables dynamically.

### What You'll Learn
- ConfigMap templating
- Environment variable injection
- Looping with `range`
- Nested values

### Requirements

**Step 3.1 - Update values.yaml**

```yaml
# ... previous values ...

# Configuration Maps
configMaps:
  app-config:
    data:
      LOG_LEVEL: "INFO"
      APP_VERSION: "1.0"
      ENVIRONMENT: "dev"
  
  app-settings:
    data:
      MAX_CONNECTIONS: "100"
      TIMEOUT: "30"

# Environment variables from ConfigMap
envFromConfigMaps:
  - name: app-config
  - name: app-settings

# Direct environment variables
env:
  - name: POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: POD_NAMESPACE
    valueFrom:
      fieldRef:
        fieldPath: metadata.namespace
```

**Step 3.2 - Create templates/configmap.yaml**

```yaml
{{- if .Values.enabled }}
{{- range $cmName, $cmData := .Values.configMaps }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "webapp.fullname" $ }}-{{ $cmName }}
  namespace: {{ $.Release.Namespace }}
  labels:
    {{- include "webapp.labels" $ | nindent 4 }}
    config-type: {{ $cmName }}
data:
  {{- range $key, $value := $cmData.data }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
{{- end }}
{{- end }}
```

**Step 3.3 - Update templates/deployment.yaml**

Add envFrom section to containers:

```yaml
        envFrom:
        {{- range .Values.envFromConfigMaps }}
        - configMapRef:
            name: {{ include "webapp.fullname" . }}-{{ .name }}
        {{- end }}
        
        env:
        {{- range .Values.env }}
        - name: {{ .name }}
          valueFrom:
            fieldRef:
              fieldPath: {{ .valueFrom.fieldRef.fieldPath }}
        {{- end }}
```

### Validation

```bash
# Check ConfigMaps created
helm install my-app . --debug
kubectl get configmaps
kubectl get configmap my-app-webapp-app-config -o yaml

# Verify environment variables in pod
kubectl exec deployment/my-app-webapp -- env | grep APP

# Update config and restart
helm upgrade my-app . --set configMaps.app-config.data.LOG_LEVEL=DEBUG
kubectl rollout restart deployment/my-app-webapp
kubectl logs deployment/my-app-webapp
```

### Concepts Introduced
- `range` with maps and key-value pairs
- Multiple ConfigMaps from values
- `envFrom` and `env` injection
- Fieldref (metadata access)
- Variable scoping with `$`

---

## Phase 4: Conditional Features & Advanced Logic

**Duration:** 60 minutes | **Difficulty:** Intermediate

### Objective
Control feature availability and implement complex logic conditions.

### What You'll Learn
- Feature flags
- Multiple conditionals with `and`, `or`, `not`
- ServiceAccount and RBAC
- Ingress configuration

### Requirements

**Step 4.1 - Update values.yaml**

```yaml
# ... previous values ...

serviceAccount:
  create: true
  name: ""
  annotations: {}

rbac:
  create: true

ingress:
  enabled: false
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: webapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: webapp-tls
      hosts:
        - webapp.example.com

persistence:
  enabled: false
  storageClassName: ""
  size: 1Gi
  mountPath: /data

monitoring:
  enabled: false
  scrapeInterval: 30s
```

**Step 4.2 - Create templates/serviceaccount.yaml**

```yaml
{{- if and .Values.enabled .Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
```

**Step 4.3 - Create templates/role.yaml**

```yaml
{{- if and .Values.enabled .Values.rbac.create .Values.serviceAccount.create }}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list"]
{{- end }}
```

**Step 4.4 - Create templates/rolebinding.yaml**

```yaml
{{- if and .Values.enabled .Values.rbac.create .Values.serviceAccount.create }}
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ include "webapp.fullname" . }}
subjects:
- kind: ServiceAccount
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
{{- end }}
```

**Step 4.5 - Create templates/ingress.yaml**

```yaml
{{- if and .Values.enabled .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "webapp.fullname" $ }}
                port:
                  number: {{ $.Values.servicePort }}
          {{- end }}
    {{- end }}
{{- end }}
```

**Step 4.6 - Update templates/deployment.yaml**

Add ServiceAccount and monitoring annotations:

```yaml
spec:
  {{- if .Values.serviceAccount.create }}
  serviceAccountName: {{ include "webapp.fullname" . }}
  automountServiceAccountToken: true
  {{- end }}
  
  {{- if .Values.monitoring.enabled }}
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"
  {{- end }}
```

### Validation

```bash
# Enable features incrementally
helm install my-app . --set rbac.create=true

# Verify RBAC
kubectl get role,rolebinding

# Enable Ingress
helm upgrade my-app . --set ingress.enabled=true --set ingress.hosts[0].host=app.local
kubectl get ingress

# Verify conditional logic
helm template . --set rbac.create=false | grep -c "kind: Role"  # Should be 0
helm template . --set rbac.create=true | grep -c "kind: Role"   # Should be 1
```

### Concepts Introduced
- `and`, `or`, `not` operators
- `with` statement for scoping
- Multiple conditional levels
- RBAC templating
- Ingress with TLS
- Optional features pattern

---

## Phase 5: Secrets & Sensitive Data

**Duration:** 45 minutes | **Difficulty:** Intermediate

### Objective
Safely handle sensitive information and credential management.

### What You'll Learn
- Secret templating
- Best practices for sensitive data
- Base64 encoding
- Multiple secret sources

### Requirements

**Step 5.1 - Update values.yaml**

```yaml
# ... previous values ...

secrets:
  create: false
  database:
    username: admin
    password: "changeme"
  api:
    key: "your-api-key-here"
    secret: "your-api-secret"

externalSecrets:
  enabled: false
  backend: vault
  secretStore: vault-backend
  secretPath: secret/data/webapp
```

**Step 5.2 - Create templates/secret.yaml**

```yaml
{{- if and .Values.enabled .Values.secrets.create }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
type: Opaque
data:
  {{- range $key, $secret := .Values.secrets }}
  {{- if and (not (eq $key "create")) (ne $secret nil) }}
  {{- range $subkey, $value := $secret }}
  {{ $key }}-{{ $subkey }}: {{ $value | b64enc | quote }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
```

**Step 5.3 - Create templates/externalsecrets.yaml**

```yaml
{{- if and .Values.enabled .Values.externalSecrets.enabled }}
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
spec:
  provider:
    vault:
      server: "https://vault.example.com"
      path: "{{ .Values.externalSecrets.secretPath }}"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "{{ .Release.Name }}"
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: {{ include "webapp.fullname" . }}
    kind: SecretStore
  target:
    name: {{ include "webapp.fullname" . }}-external
    creationPolicy: Owner
  data:
  - secretKey: database-password
    remoteRef:
      key: database
      property: password
  - secretKey: api-key
    remoteRef:
      key: api
      property: key
{{- end }}
```

**Step 5.4 - Update templates/deployment.yaml**

Add secret injection:

```yaml
        {{- if or .Values.secrets.create .Values.externalSecrets.enabled }}
        envFrom:
        - secretRef:
            {{- if .Values.externalSecrets.enabled }}
            name: {{ include "webapp.fullname" . }}-external
            {{- else }}
            name: {{ include "webapp.fullname" . }}
            {{- end }}
        {{- end }}
        
        volumeMounts:
        - name: secret-volume
          mountPath: /etc/secrets
          readOnly: true
        {{- end }}
      
      volumes:
      {{- if or .Values.secrets.create .Values.externalSecrets.enabled }}
      - name: secret-volume
        secret:
          {{- if .Values.externalSecrets.enabled }}
          secretName: {{ include "webapp.fullname" . }}-external
          {{- else }}
          secretName: {{ include "webapp.fullname" . }}
          {{- end }}
      {{- end }}
```

### Validation

```bash
# Create secrets in values
helm install my-app . --set secrets.create=true --set-string secrets.database.password='mysecretpass'

# Verify secret created
kubectl get secret my-app-webapp -o yaml | grep database-username

# Decode and verify
kubectl get secret my-app-webapp -o jsonpath='{.data.database-password}' | base64 -d

# Test external secrets
helm install my-app . --set externalSecrets.enabled=true
kubectl get externalsecrets
```

### Concepts Introduced
- `b64enc` function for base64 encoding
- Secret creation patterns
- External Secrets operator
- Conditional secret sources
- Volume mounting secrets

---

## Phase 6: Storage & Persistence

**Duration:** 45 minutes | **Difficulty:** Intermediate-Advanced

### Objective
Implement persistent storage and volume management.

### What You'll Learn
- PersistentVolumeClaim templating
- Storage class configuration
- StatefulSet basics
- Volume management patterns

### Requirements

**Step 6.1 - Update values.yaml**

```yaml
# ... previous values ...

persistence:
  enabled: false
  type: pvc  # pvc or emptyDir
  storageClassName: standard
  accessMode: ReadWriteOnce
  size: 5Gi
  mountPath: /data
  subPath: ""
  
  # For StatefulSet-style storage
  volumeClaimTemplates:
    - name: data
      size: 5Gi
      mountPath: /data

emptyDir:
  enabled: false
  sizeLimit: 1Gi
```

**Step 6.2 - Create templates/pvc.yaml**

```yaml
{{- if and .Values.enabled .Values.persistence.enabled (eq .Values.persistence.type "pvc") }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "webapp.fullname" . }}-data
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
spec:
  accessModes:
    - {{ .Values.persistence.accessMode }}
  storageClassName: {{ .Values.persistence.storageClassName }}
  resources:
    requests:
      storage: {{ .Values.persistence.size }}
{{- end }}
```

**Step 6.3 - Update templates/deployment.yaml**

Add volume mounts:

```yaml
        volumeMounts:
        {{- if .Values.persistence.enabled }}
        {{- if eq .Values.persistence.type "pvc" }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
        {{- end }}
        {{- end }}
        {{- if .Values.emptyDir.enabled }}
        - name: cache
          mountPath: /cache
        {{- end }}
      
      volumes:
      {{- if and .Values.persistence.enabled (eq .Values.persistence.type "pvc") }}
      - name: data
        persistentVolumeClaim:
          claimName: {{ include "webapp.fullname" . }}-data
      {{- end }}
      {{- if .Values.emptyDir.enabled }}
      - name: cache
        emptyDir:
          sizeLimit: {{ .Values.emptyDir.sizeLimit }}
      {{- end }}
```

### Validation

```bash
# Enable persistence
helm install my-app . --set persistence.enabled=true

# Verify PVC
kubectl get pvc
kubectl describe pvc my-app-webapp-data

# Check volume mounted in pod
kubectl exec deployment/my-app-webapp -- ls -la /data

# Write data and verify persistence
kubectl exec deployment/my-app-webapp -- sh -c 'echo "test" > /data/test.txt'
kubectl delete pod -l app.kubernetes.io/instance=my-app
kubectl exec deployment/my-app-webapp -- cat /data/test.txt  # Should still exist
```

### Concepts Introduced
- PersistentVolumeClaim templates
- Storage class configuration
- EmptyDir volumes
- Volume mounting patterns
- Data persistence verification

---

## Phase 7: Scaling & Performance

**Duration:** 60 minutes | **Difficulty:** Intermediate-Advanced

### Objective
Implement autoscaling, resource management, and performance tuning.

### What You'll Learn
- HorizontalPodAutoscaler
- Resource requests and limits
- PodDisruptionBudget
- Pod affinity

### Requirements

**Step 7.1 - Update values.yaml**

```yaml
# ... previous values ...

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80

podDisruptionBudget:
  enabled: false
  minAvailable: 1
  # maxUnavailable: 1

affinity:
  podAntiAffinity: soft  # soft or hard
  nodeAffinity: {}
  # Example nodeAffinity:
  #   requiredDuringSchedulingIgnoredDuringExecution:
  #     nodeSelectorTerms:
  #     - matchExpressions:
  #       - key: node-role.kubernetes.io/master
  #         operator: DoesNotExist

topologySpreadConstraints:
  enabled: false
  maxSkew: 1
  topologyKey: kubernetes.io/hostname
```

**Step 7.2 - Create templates/hpa.yaml**

```yaml
{{- if and .Values.enabled .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "webapp.fullname" . }}
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
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
{{- end }}
```

**Step 7.3 - Create templates/pdb.yaml**

```yaml
{{- if and .Values.enabled .Values.podDisruptionBudget.enabled }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
spec:
  {{- if .Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ .Values.podDisruptionBudget.minAvailable }}
  {{- end }}
  {{- if .Values.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ .Values.podDisruptionBudget.maxUnavailable }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "webapp.selectorLabels" . | nindent 6 }}
{{- end }}
```

**Step 7.4 - Update templates/deployment.yaml**

Add resource limits, affinity, and topology spread:

```yaml
spec:
  replicas: {{ .Values.replicaCount }}
  
  selector:
    matchLabels:
      {{- include "webapp.selectorLabels" . | nindent 6 }}
  
  template:
    metadata:
      labels:
        {{- include "webapp.selectorLabels" . | nindent 8 }}
    spec:
      {{- if .Values.affinity.podAntiAffinity }}
      affinity:
        podAntiAffinity:
          {{- if eq .Values.affinity.podAntiAffinity "hard" }}
          requiredDuringSchedulingIgnoredDuringExecution:
          {{- else }}
          preferredDuringSchedulingIgnoredDuringExecution:
          {{- end }}
          - podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app.kubernetes.io/name
                  operator: In
                  values:
                  - {{ .Chart.Name }}
              topologyKey: kubernetes.io/hostname
            {{- if eq .Values.affinity.podAntiAffinity "soft" }}
            weight: 100
            {{- end }}
        {{- with .Values.affinity.nodeAffinity }}
        nodeAffinity:
          {{- toYaml . | nindent 10 }}
        {{- end }}
      {{- end }}
      
      {{- if .Values.topologySpreadConstraints.enabled }}
      topologySpreadConstraints:
      - maxSkew: {{ .Values.topologySpreadConstraints.maxSkew }}
        topologyKey: {{ .Values.topologySpreadConstraints.topologyKey }}
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            {{- include "webapp.selectorLabels" . | nindent 12 }}
      {{- end }}
      
      containers:
      - name: {{ .Chart.Name }}
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
```

### Validation

```bash
# Enable autoscaling
helm install my-app . --set autoscaling.enabled=true --set autoscaling.minReplicas=2

# Verify HPA
kubectl get hpa
kubectl describe hpa my-app-webapp

# Enable PDB
helm upgrade my-app . --set podDisruptionBudget.enabled=true

# Check resource requests
kubectl get pods -o json | jq '.items[0].spec.containers[0].resources'

# Simulate load and watch HPA scale
kubectl run -it --rm load-generator --image=busybox /bin/sh
# Inside: while true; do wget -q -O- http://my-app-webapp:8080; done

# Watch HPA respond
kubectl get hpa -w
```

### Concepts Introduced
- HorizontalPodAutoscaler (v2)
- Resource requests and limits
- PodDisruptionBudget
- Pod affinity and anti-affinity
- Topology spread constraints
- Scaling policies and behavior

---

## Phase 8: Monitoring & Observability

**Duration:** 60 minutes | **Difficulty:** Intermediate-Advanced

### Objective
Integrate monitoring, logging, and observability features.

### What You'll Learn
- Prometheus integration
- Service Monitor templating
- Logging configuration
- Tracing support

### Requirements

**Step 8.1 - Update values.yaml**

```yaml
# ... previous values ...

monitoring:
  enabled: false
  serviceMonitor:
    enabled: false
    interval: 30s
    scrapeTimeout: 10s
  prometheus:
    rules:
      enabled: false

logging:
  enabled: false
  level: INFO
  format: json
  
tracing:
  enabled: false
  jaeger:
    enabled: false
    agent: jaeger-agent
    port: 6831
```

**Step 8.2 - Create templates/servicemonitor.yaml**

```yaml
{{- if and .Values.enabled .Values.monitoring.serviceMonitor.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "webapp.selectorLabels" . | nindent 6 }}
  endpoints:
  - port: http
    interval: {{ .Values.monitoring.serviceMonitor.interval }}
    scrapeTimeout: {{ .Values.monitoring.serviceMonitor.scrapeTimeout }}
    path: /metrics
{{- end }}
```

**Step 8.3 - Create templates/prometheusrule.yaml**

```yaml
{{- if and .Values.enabled .Values.monitoring.prometheus.rules.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {{ include "webapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
    prometheus: kube-prometheus
spec:
  groups:
  - name: {{ include "webapp.fullname" . }}
    interval: {{ .Values.monitoring.serviceMonitor.interval }}
    rules:
    - alert: {{ include "webapp.name" . | upper }}HighErrorRate
      expr: |
        (sum(rate(http_requests_total{job="{{ include "webapp.fullname" . }}", status=~"5.."}[5m])) 
        / 
        sum(rate(http_requests_total{job="{{ include "webapp.fullname" . }}"}[5m]))) > 0.05
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate detected"
        description: "{{ include "webapp.name" . }} error rate is above 5%"
{{- end }}
```

**Step 8.4 - Update templates/deployment.yaml**

Add monitoring annotations and environment:

```yaml
    metadata:
      {{- if .Values.monitoring.enabled }}
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "{{ .Values.containerPort }}"
        prometheus.io/path: "/metrics"
      {{- end }}
      labels:
        {{- include "webapp.selectorLabels" . | nindent 8 }}

    spec:
      containers:
      - name: {{ .Chart.Name }}
        
        {{- if or .Values.logging.enabled .Values.tracing.enabled }}
        env:
        {{- if .Values.logging.enabled }}
        - name: LOG_LEVEL
          value: {{ .Values.logging.level | quote }}
        - name: LOG_FORMAT
          value: {{ .Values.logging.format | quote }}
        {{- end }}
        {{- if and .Values.tracing.enabled .Values.tracing.jaeger.enabled }}
        - name: JAEGER_AGENT_HOST
          value: {{ .Values.tracing.jaeger.agent | quote }}
        - name: JAEGER_AGENT_PORT
          value: {{ .Values.tracing.jaeger.port | quote }}
        {{- end }}
        {{- end }}
```

### Validation

```bash
# Enable monitoring
helm install my-app . --set monitoring.enabled=true --set monitoring.serviceMonitor.enabled=true

# Verify ServiceMonitor
kubectl get servicemonitor
kubectl describe servicemonitor my-app-webapp

# Enable logging
helm upgrade my-app . --set logging.enabled=true --set logging.level=DEBUG

# Verify pod annotations
kubectl get pods -o jsonpath='{.items[0].metadata.annotations}' | jq .

# Check prometheus targets (if Prometheus is running)
kubectl port-forward -n prometheus svc/prometheus 9090:9090
# Visit http://localhost:9090/targets
```

### Concepts Introduced
- ServiceMonitor for Prometheus
- PrometheusRule for alerting
- Monitoring annotations
- Logging configuration
- Tracing integration
- Custom Resource integration

---

## Phase 9: Lifecycle & Hooks

**Duration:** 45 minutes | **Difficulty:** Advanced

### Objective
Control application lifecycle with pre/post hooks and tests.

### What You'll Learn
- Helm hooks (pre-install, post-install, etc.)
- Hook weights and deletion policies
- Helm tests
- Job templates

### Requirements

**Step 9.1 - Update values.yaml**

```yaml
# ... previous values ...

hooks:
  preInstall:
    enabled: false
    image: busybox
    command: ["sh", "-c", "echo 'Pre-install checks'"]
  
  postInstall:
    enabled: false
    image: busybox
    command: ["sh", "-c", "echo 'Post-install setup'"]
  
  preUpgrade:
    enabled: false
    image: busybox
    command: ["sh", "-c", "echo 'Pre-upgrade validation'"]

tests:
  enabled: false
  image: busybox
```

**Step 9.2 - Create templates/hooks/pre-install.yaml**

```yaml
{{- if and .Values.enabled .Values.hooks.preInstall.enabled }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "webapp.fullname" . }}-pre-install
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  template:
    metadata:
      labels:
        {{- include "webapp.selectorLabels" . | nindent 8 }}
    spec:
      serviceAccountName: {{ include "webapp.fullname" . }}
      containers:
      - name: pre-install
        image: {{ .Values.hooks.preInstall.image }}
        command: {{ .Values.hooks.preInstall.command | toJson }}
      restartPolicy: Never
  backoffLimit: 3
{{- end }}
```

**Step 9.3 - Create templates/tests/test-connection.yaml**

```yaml
{{- if and .Values.enabled .Values.tests.enabled }}
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "webapp.fullname" . }}-test-connection
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "webapp.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  containers:
  - name: wget
    image: {{ .Values.tests.image }}
    command: ['wget']
    args: ['{{ include "webapp.fullname" . }}:{{ .Values.servicePort }}']
  restartPolicy: Never
{{- end }}
```

### Validation

```bash
# Enable hooks
helm install my-app . --set hooks.preInstall.enabled=true

# Watch hook execution
kubectl get jobs
kubectl logs job/my-app-webapp-pre-install

# Enable tests
helm install my-app . --set tests.enabled=true

# Run tests
helm test my-app

# Check test pod status
kubectl get pods -l app.kubernetes.io/instance=my-app
```

### Concepts Introduced
- Helm hooks (pre-install, post-install, pre-upgrade, etc.)
- Hook weights and execution order
- Hook deletion policies
- Helm test pods
- Job templates for hooks

---

## Phase 10: Production Readiness & Best Practices

**Duration:** 90 minutes | **Difficulty:** Advanced

### Objective
Implement complete production-grade features and best practices.

### What You'll Learn
- Chart validation and linting
- NOTES.txt documentation
- Chart values schema
- Security best practices
- Upgrade strategies

### Requirements

**Step 10.1 - Create Chart.yaml enhancements**

```yaml
apiVersion: v2
name: webapp
description: Production-Grade Web Application Helm Chart
type: application
version: 1.0.0
appVersion: "1.0"

keywords:
  - helm
  - practice
  - kubernetes
  - production

home: https://github.com/example/webapp
sources:
  - https://github.com/example/webapp
  
maintainers:
  - name: Your Name
    email: your@email.com
    url: https://github.com/yourname

dependencies: []

annotations:
  category: Application
  licenses: MIT
```

**Step 10.2 - Create values.schema.json**

```json
{
  "$schema": "https://json-schema.org/draft-07/schema",
  "type": "object",
  "required": ["enabled", "replicaCount", "image"],
  "properties": {
    "enabled": {
      "type": "boolean",
      "description": "Enable or disable the chart"
    },
    "replicaCount": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100,
      "description": "Number of replicas"
    },
    "image": {
      "type": "string",
      "pattern": "^[a-z0-9-]+:[a-zA-Z0-9.-]+$",
      "description": "Docker image in format: name:tag"
    },
    "servicePort": {
      "type": "integer",
      "minimum": 1,
      "maximum": 65535,
      "description": "Service port number"
    },
    "resources": {
      "type": "object",
      "properties": {
        "limits": {
          "type": "object",
          "properties": {
            "cpu": {
              "type": "string",
              "pattern": "^[0-9]+m?$"
            },
            "memory": {
              "type": "string",
              "pattern": "^[0-9]+Mi$|^[0-9]+Gi$"
            }
          }
        }
      }
    },
    "autoscaling": {
      "type": "object",
      "properties": {
        "enabled": {
          "type": "boolean"
        },
        "minReplicas": {
          "type": "integer",
          "minimum": 1
        },
        "maxReplicas": {
          "type": "integer",
          "minimum": 1
        }
      }
    }
  }
}
```

**Step 10.3 - Create templates/NOTES.txt**

```
1. Get the application URL by running these commands:
{{- if .Values.ingress.enabled }}
  {{- range .Values.ingress.hosts }}
  {{- range .paths }}
  http{{ if $.Values.ingress.tls }}s{{ end }}://{{ .host }}{{ .path }}
  {{- end }}
  {{- end }}
{{- else if contains "NodePort" .Values.serviceType }}
  export NODE_PORT=$(kubectl get --namespace {{ .Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ include "webapp.fullname" . }})
  export NODE_IP=$(kubectl get nodes --namespace {{ .Release.Namespace }} -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT
{{- else if contains "LoadBalancer" .Values.serviceType }}
  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
  You can watch the status of by running 'kubectl get svc -w {{ include "webapp.fullname" . }}'
  export SERVICE_IP=$(kubectl get svc --namespace {{ .Release.Namespace }} {{ include "webapp.fullname" . }} --template "{{"{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}"}}")
  echo http://$SERVICE_IP:{{ .Values.servicePort }}
{{- else if eq .Values.serviceType "ClusterIP" }}
  export POD_NAME=$(kubectl get pods --namespace {{ .Release.Namespace }} -l "app.kubernetes.io/name={{ include "webapp.name" . }},app.kubernetes.io/instance={{ .Release.Name }}" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace {{ .Release.Namespace }} $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace {{ .Release.Namespace }} port-forward $POD_NAME 8080:$CONTAINER_PORT
{{- end }}

2. Watch the deployment rollout status:
  kubectl rollout status deployment/{{ include "webapp.fullname" . }} --namespace {{ .Release.Namespace }}

3. Check the pod logs:
  kubectl logs -f deployment/{{ include "webapp.fullname" . }} --namespace {{ .Release.Namespace }}

4. Get more information:
  kubectl get deployment --namespace {{ .Release.Namespace }}
  kubectl get service --namespace {{ .Release.Namespace }}
  helm status {{ .Release.Name }}

{{- if .Values.autoscaling.enabled }}

5. Autoscaling is enabled:
  kubectl get hpa {{ include "webapp.fullname" . }} --namespace {{ .Release.Namespace }} -w
{{- end }}

{{- if .Values.ingress.enabled }}

6. Ingress is enabled:
  kubectl get ingress {{ include "webapp.fullname" . }} --namespace {{ .Release.Namespace }}
{{- end }}

{{- if .Values.persistence.enabled }}

7. Persistence is enabled:
  kubectl get pvc --namespace {{ .Release.Namespace }} -l app.kubernetes.io/instance={{ .Release.Name }}
{{- end }}

For help and documentation, visit:
  https://github.com/example/webapp
```

**Step 10.4 - Update values.yaml with comprehensive defaults**

Ensure complete, documented values.yaml with:

```yaml
# Application Configuration
appName: webapp
enabled: true
nameOverride: ""
fullnameOverride: ""

# Deployment Configuration
replicaCount: 2
image: busybox:latest
imagePullPolicy: IfNotPresent

containerPort: 8080
servicePort: 8080
serviceType: ClusterIP

command:
  - /bin/sh
  - -c
  - echo "App started" && sleep 3600

# ConfigMaps and Secrets
configMaps:
  app-config:
    data:
      LOG_LEVEL: "INFO"

secrets:
  create: false
  database:
    username: admin
    password: "changeme"

# Service Account & RBAC
serviceAccount:
  create: true
  name: ""
  annotations: {}

rbac:
  create: true

# Ingress
ingress:
  enabled: false
  className: "nginx"
  annotations: {}
  hosts:
    - host: webapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls: []

# Storage
persistence:
  enabled: false
  type: pvc
  storageClassName: standard
  accessMode: ReadWriteOnce
  size: 5Gi
  mountPath: /data
  subPath: ""

emptyDir:
  enabled: false
  sizeLimit: 1Gi

# Resource Management
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

# Scaling
autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80

podDisruptionBudget:
  enabled: false
  minAvailable: 1

# Affinity
affinity:
  podAntiAffinity: soft
  nodeAffinity: {}

topologySpreadConstraints:
  enabled: false
  maxSkew: 1
  topologyKey: kubernetes.io/hostname

# Monitoring
monitoring:
  enabled: false
  serviceMonitor:
    enabled: false
    interval: 30s
    scrapeTimeout: 10s
  prometheus:
    rules:
      enabled: false

# Logging
logging:
  enabled: false
  level: INFO
  format: json

# Tracing
tracing:
  enabled: false
  jaeger:
    enabled: false
    agent: jaeger-agent
    port: 6831

# Hooks
hooks:
  preInstall:
    enabled: false
    image: busybox
    command: ["echo", "Pre-install"]
  postInstall:
    enabled: false
    image: busybox
    command: ["echo", "Post-install"]
  preUpgrade:
    enabled: false
    image: busybox
    command: ["echo", "Pre-upgrade"]

# Tests
tests:
  enabled: false
  image: busybox
```

**Step 10.5 - Create README.md**

```markdown
# Webapp Helm Chart

Production-ready Helm chart for deploying web applications on Kubernetes.

## Prerequisites

- Kubernetes 1.21+
- Helm 3.0+

## Installation

```bash
helm repo add myrepo https://example.com/charts
helm repo update
helm install my-app myrepo/webapp
```

## Configuration

See [values.yaml](values.yaml) for all available options.

Quick start:

```bash
# Basic installation
helm install my-app .

# With autoscaling
helm install my-app . --set autoscaling.enabled=true

# With ingress
helm install my-app . --set ingress.enabled=true --set ingress.hosts[0].host=app.example.com

# With persistence
helm install my-app . --set persistence.enabled=true
```

## Features

- ✅ ConfigMap and Secret management
- ✅ ServiceAccount and RBAC
- ✅ Horizontal Pod Autoscaler
- ✅ Pod Disruption Budget
- ✅ Ingress support
- ✅ Persistent storage
- ✅ Prometheus monitoring
- ✅ Health checks (liveness, readiness, startup)
- ✅ Helm tests
- ✅ Lifecycle hooks

## Upgrading

```bash
helm upgrade my-app . --values new-values.yaml
```

## Uninstalling

```bash
helm uninstall my-app
```

## Validation

```bash
# Lint the chart
helm lint .

# Dry-run installation
helm install my-app . --dry-run --debug

# Validate values
helm template my-app . --validate

# Run tests
helm test my-app
```

## License

MIT
```

### Validation

```bash
# Lint the chart
helm lint .

# Validate against schema
helm template . --validate

# Dry-run comprehensive install with all features
helm install my-app . \
  --set autoscaling.enabled=true \
  --set persistence.enabled=true \
  --set monitoring.enabled=true \
  --set ingress.enabled=true \
  --set rbac.create=true \
  --set secrets.create=true \
  --dry-run --debug

# Real installation
helm install my-app .

# Verify all resources
kubectl get all -l app.kubernetes.io/instance=my-app

# Run tests
helm test my-app

# Check release info
helm history my-app
helm get values my-app
helm get manifest my-app
```

### Concepts Introduced
- Chart linting and validation
- JSON schema validation
- NOTES.txt template
- README documentation
- Chart versioning strategy
- Production-grade defaults
- Comprehensive testing

---

## Summary & Mastery Checklist

### What You've Built

A single, production-ready Helm chart that:

✅ Starts from absolute basics (Phase 1)
✅ Grows to include complex features (Phase 2-9)
✅ Implements best practices (Phase 10)
✅ Maintains backward compatibility throughout
✅ Validates with `helm lint` and `helm template`
✅ Includes comprehensive documentation
✅ Supports real-world deployment patterns

### Helm Concepts Mastered

**Templating:**
- `{{ }}` interpolation
- `|` piping and filters
- `if/else/end` conditionals
- `range` iteration
- Named templates (`define`)
- Template helpers

**Functions:**
- `quote`, `nindent`, `toYaml`, `tojson`
- `upper`, `lower`, `title`, `trimSuffix`
- `default`, `required`
- `include` for template reuse
- `b64enc` for encoding
- `trunc` for string truncation

**Advanced Patterns:**
- Conditional resources (feature flags)
- Dynamic resource generation
- Multi-tier templating with helpers
- Scoping with `$` and `with`
- Proper YAML indentation

**Kubernetes Objects:**
- Deployment, Service, ConfigMap, Secret
- ServiceAccount, Role, RoleBinding
- Ingress, PersistentVolumeClaim
- HorizontalPodAutoscaler, PodDisruptionBudget
- ServiceMonitor, PrometheusRule (CRDs)
- Jobs (for hooks)

**Helm-Specific:**
- Chart metadata and versioning
- Release management
- Hooks (pre-install, post-install, etc.)
- Tests
- Values schema validation
- Chart linting

### Practice Goals

By completing all phases, you can:

1. ✅ Create charts from scratch
2. ✅ Use proper templating patterns
3. ✅ Implement feature flags and conditionals
4. ✅ Manage configuration and secrets safely
5. ✅ Scale applications with HPA
6. ✅ Implement health checks
7. ✅ Add persistence to applications
8. ✅ Integrate monitoring and observability
9. ✅ Control application lifecycle with hooks
10. ✅ Deploy production-grade applications

---

## Testing & Validation Throughout

At **every phase**, use:

```bash
# Template rendering
helm template my-release .

# Dry-run installation (no actual deployment)
helm install --dry-run --debug my-release .

# Linting
helm lint .

# Actual deployment
helm install my-release .

# Verification
kubectl get all -l app.kubernetes.io/instance=my-release
kubectl describe deployment my-release-webapp
kubectl logs deployment/my-release-webapp

# Upgrades
helm upgrade my-release . --set replicaCount=5

# Check history
helm history my-release
helm get values my-release
helm get manifest my-release
```

---

## Pro Tips for Success

1. **Go slowly** - Complete one phase before moving to the next
2. **Test constantly** - Use `helm template` and `--dry-run` liberally
3. **Read error messages** - They guide you to the problem
4. **Keep helpers organized** - Use `_helpers.tpl` for all named templates
5. **Document your values** - Add comments explaining each value
6. **Use meaningful names** - Make resource names clear and descriptive
7. **Validate YAML** - Use `yamllint` to check output
8. **Version your chart** - Bump version when behavior changes
9. **Test upgrades** - Ensure each phase works with upgrades
10. **Commit to git** - Track all changes and understand evolution

---

## Learning Path Summary

```
Phase 1: Foundation (15 min)
    ↓
Phase 2: Workloads (30 min)
    ↓
Phase 3: Configuration (45 min)
    ↓
Phase 4: Advanced Logic (60 min)
    ↓
Phase 5: Secrets (45 min)
    ↓
Phase 6: Storage (45 min)
    ↓
Phase 7: Scaling (60 min)
    ↓
Phase 8: Observability (60 min)
    ↓
Phase 9: Lifecycle (45 min)
    ↓
Phase 10: Production Ready (90 min)
```

**Total Time:** ~6 hours of hands-on learning

**Outcome:** Complete mastery of Helm chart development for production applications.

Good luck! 🚀
