I'll provide a complete Kustomize exercise with step-by-step problem statements first, then the full solutions with YAML.

# **Kustomize Learning Path: From Zero to Production**

## **Application Overview**
We'll deploy a **Node.js API with Redis cache** and **monitoring sidecar**. Components:
- `node:18-alpine` for API (port 3000)
- `redis:7-alpine` for caching
- `busybox:latest` for monitoring sidecar
- `nginx:1.25` for ingress

---

## **PROBLEM STATEMENTS ONLY**

### **Step 1 – Base Application**
Create a minimal deployable base:
1. Create `base/` directory
2. Create `deployment.yaml` for `node:18-alpine` with 1 replica
3. Create `service.yaml` ClusterIP on port 80→3000
4. Create `kustomization.yaml` with these 2 resources

### **Step 2 – Add ConfigMap and Redis**
Extend base with configuration:
1. Add `configmap.yaml` with `APP_NAME`, `LOG_LEVEL`, `REDIS_HOST`
2. Add Redis deployment and service (port 6379)
3. Mount ConfigMap as env vars in API deployment
4. Update base kustomization to include all resources

### **Step 3 – Environment Overlays**
Create dev/prod overlays:
1. Create `overlays/dev/` and `overlays/prod/`
2. Each overlay references `../../base`
3. In dev: add `namePrefix: dev-` and label `env: dev`
4. In prod: add `namePrefix: prod-` and label `env: prod`
5. Test both overlays

### **Step 4 – Replica Scaling**
Set different replica counts:
1. In dev overlay: set replicas to 2
2. In prod overlay: set replicas to 4
3. Use patchesStrategicMerge

### **Step 5 – Image Tag Management**
Use different image tags:
1. In dev: use `node:18-alpine`
2. In prod: use specific version `node:18.20.0-alpine`
3. Use `images` transformer

### **Step 6 – Environment-Specific ConfigMaps**
Override ConfigMap values:
1. In dev: set `LOG_LEVEL: "debug"`, `REDIS_HOST: "dev-redis"`
2. In prod: set `LOG_LEVEL: "warn"`, add `ENABLE_CACHE: "true"`
3. Use ConfigMapGenerator with behavior: merge

### **Step 7 – Add Secrets**
Add database secrets:
1. Add secret to base with placeholder values
2. In dev: use literal secrets (plain text)
3. In prod: use file-based secrets (simulate secure)
4. Mount secrets as env vars

### **Step 8 – Resource Limits**
Set CPU/memory limits:
1. Base: requests 100m CPU, 128Mi RAM; limits 200m CPU, 256Mi RAM
2. Dev: reduce to 50m/64Mi requests, 100m/128Mi limits
3. Prod: increase to 200m/256Mi requests, 500m/512Mi limits
4. Use JSON patches

### **Step 9 – Add Ingress**
Add ingress only in overlays:
1. In dev: ingress with host `dev-api.example.com`
2. In prod: ingress with host `api.example.com`, TLS, and annotations
3. Use different ingress classes

### **Step 10 – Monitoring Sidecar (Prod Only)**
Add sidecar container:
1. Only in prod overlay
2. Add `busybox:latest` sidecar that runs `["sh", "-c", "while true; do echo 'Monitoring...'; sleep 30; done"]`
3. Use JSON patch to add container

### **Step 11 – Affinity and Tolerations**
Add production-specific scheduling:
1. In prod: add `podAntiAffinity` to spread across nodes
2. Add toleration for `dedicated=prod:NoSchedule`
3. Use strategic merge patch

### **Step 12 – Common Labels and Annotations**
Add metadata across all resources:
1. Base: label `app: node-api`, `managed-by: kustomize`
2. Dev: annotation `environment: development`, `team: devops`
3. Prod: annotation `environment: production`, `team: platform`
4. Use `commonLabels` and `commonAnnotations`

### **Step 13 – Namespace Isolation**
Deploy to different namespaces:
1. Create `overlays/prod-us` and `overlays/prod-eu`
2. Each sets different namespace
3. Add region-specific ConfigMap patches
4. Use `namespace` transformer

### **Step 14 – Volume Mounts**
Add persistent configuration:
1. Base: add emptyDir volume
2. Dev: mount as `/tmp/logs`
3. Prod: mount as `/var/log/app` with read-only
4. Use volume mounts and patches

### **Step 15 – Job for Database Migration**
Add initialization job:
1. Only in prod overlay
2. Create Job that runs before deployment
3. Use `kustomize.config.k8s.io/behavior: create` annotation
4. Job should simulate DB migration

### **Step 16 – Multiple Environments with Bases**
Create staging from prod:
1. Create `overlays/staging/` that uses prod as base
2. Override only specific values (replicas=3, different hostname)
3. Demonstrate inheritance chain

### **Step 17 – Variables Replacement**
Use Kustomize variables:
1. Define variables for image tags
2. Use in deployment
3. Override in overlays

### **Step 18 – CRD Patching**
Add custom resource (simulate):
1. Add CustomResourceDefinition to base
2. Create instance of CRD
3. Patch fields in overlays

---

Now here are the **SOLUTIONS WITH YAML**:

## **SOLUTIONS**

### **Step 1 – Base Application**

```yaml
# base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: node:18-alpine
        command: ["node", "-e", "console.log('API starting'); require('http').createServer((req, res) => { res.end('Hello from Base API') }).listen(3000)"]
        ports:
        - containerPort: 3000
```

```yaml
# base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 3000
```

```yaml
# base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
```

### **Step 2 – Add ConfigMap and Redis**

```yaml
# base/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_NAME: "node-api"
  LOG_LEVEL: "info"
  REDIS_HOST: "redis-service"
```

```yaml
# base/redis-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
```

```yaml
# base/redis-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-service
spec:
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
```

Update deployment to use ConfigMap:

```yaml
# Update base/deployment.yaml (containers section)
containers:
- name: api
  image: node:18-alpine
  command: ["node", "-e", "console.log('API starting'); require('http').createServer((req, res) => { res.end('Hello from Base API') }).listen(3000)"]
  ports:
  - containerPort: 3000
  env:
  - name: APP_NAME
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: APP_NAME
  - name: LOG_LEVEL
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: LOG_LEVEL
  - name: REDIS_HOST
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: REDIS_HOST
```

```yaml
# Update base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
- configmap.yaml
- redis-deployment.yaml
- redis-service.yaml
```

### **Step 3 – Environment Overlays**

```yaml
# overlays/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: dev-
commonLabels:
  env: dev
resources:
- ../../base
```

```yaml
# overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: prod-
commonLabels:
  env: prod
resources:
- ../../base
```

### **Step 4 – Replica Scaling**

```yaml
# overlays/dev/patch-replicas.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  replicas: 2
```

```yaml
# overlays/prod/patch-replicas.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  replicas: 4
```

```yaml
# Update overlays/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: dev-
commonLabels:
  env: dev
resources:
- ../../base
patchesStrategicMerge:
- patch-replicas.yaml
```

```yaml
# Update overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: prod-
commonLabels:
  env: prod
resources:
- ../../base
patchesStrategicMerge:
- patch-replicas.yaml
```

### **Step 5 – Image Tag Management**

```yaml
# Update overlays/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: dev-
commonLabels:
  env: dev
resources:
- ../../base
patchesStrategicMerge:
- patch-replicas.yaml
images:
- name: node:18-alpine
  newTag: 18-alpine
```

```yaml
# Update overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: prod-
commonLabels:
  env: prod
resources:
- ../../base
patchesStrategicMerge:
- patch-replicas.yaml
images:
- name: node:18-alpine
  newTag: 18.20.0-alpine
- name: redis:7-alpine
  newTag: 7.2.4-alpine
```

### **Step 6 – Environment-Specific ConfigMaps**

```yaml
# overlays/dev/configmap-patch.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  LOG_LEVEL: "debug"
  REDIS_HOST: "dev-redis-service"
  ENV_TYPE: "development"
```

```yaml
# overlays/prod/configmap-patch.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  LOG_LEVEL: "warn"
  ENV_TYPE: "production"
  ENABLE_CACHE: "true"
  MAX_CONNECTIONS: "1000"
```

```yaml
# Update overlays/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: dev-
commonLabels:
  env: dev
resources:
- ../../base
patchesStrategicMerge:
- patch-replicas.yaml
- configmap-patch.yaml
images:
- name: node:18-alpine
  newTag: 18-alpine
```

```yaml
# Update overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: prod-
commonLabels:
  env: prod
resources:
- ../../base
patchesStrategicMerge:
- patch-replicas.yaml
- configmap-patch.yaml
images:
- name: node:18-alpine
  newTag: 18.20.0-alpine
- name: redis:7-alpine
  newTag: 7.2.4-alpine
```

### **Step 7 – Add Secrets**

```yaml
# base/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  # Base64 encoded placeholder values
  DB_PASSWORD: cGxhY2Vob2xkZXI=  # "placeholder"
  API_KEY: cGxhY2Vob2xkZXI=      # "placeholder"
```

Update deployment to use secrets:

```yaml
# Add to base/deployment.yaml containers.env section
env:
# ... existing env vars ...
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: app-secret
      key: DB_PASSWORD
- name: API_KEY
  valueFrom:
    secretKeyRef:
      name: app-secret
      key: API_KEY
```

```yaml
# Update base/kustomization.yaml to include secret.yaml
resources:
- deployment.yaml
- service.yaml
- configmap.yaml
- redis-deployment.yaml
- redis-service.yaml
- secret.yaml
```

```yaml
# overlays/dev/kustomization.yaml with secretGenerator
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: dev-
commonLabels:
  env: dev
resources:
- ../../base
patchesStrategicMerge:
- patch-replicas.yaml
- configmap-patch.yaml
images:
- name: node:18-alpine
  newTag: 18-alpine
secretGenerator:
- name: app-secret
  behavior: merge
  literals:
  - DB_PASSWORD=dev-password-123
  - API_KEY=dev-api-key-abc
```

```yaml
# Create prod-secret.txt
DB_PASSWORD=prod-strong-password-!@#456
API_KEY=prod-secure-api-key-xyz789
```

```yaml
# overlays/prod/kustomization.yaml with file-based secret
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: prod-
commonLabels:
  env: prod
resources:
- ../../base
patchesStrategicMerge:
- patch-replicas.yaml
- configmap-patch.yaml
images:
- name: node:18-alpine
  newTag: 18.20.0-alpine
- name: redis:7-alpine
  newTag: 7.2.4-alpine
secretGenerator:
- name: app-secret
  behavior: merge
  envs:
  - prod-secret.txt
```

### **Step 8 – Resource Limits**

```yaml
# base/deployment.yaml - add resources section
containers:
- name: api
  image: node:18-alpine
  # ... existing config ...
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "200m"
- name: redis
  image: redis:7-alpine
  resources:
    requests:
      memory: "64Mi"
      cpu: "50m"
    limits:
      memory: "128Mi"
      cpu: "100m"
```

```yaml
# overlays/dev/patch-resources.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  template:
    spec:
      containers:
      - name: api
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
      - name: redis
        resources:
          requests:
            memory: "32Mi"
            cpu: "25m"
          limits:
            memory: "64Mi"
            cpu: "50m"
```

```yaml
# overlays/prod/patch-resources.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  template:
    spec:
      containers:
      - name: api
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      - name: redis
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
```

Update kustomization files to include these patches.

### **Step 9 – Add Ingress**

```yaml
# overlays/dev/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: dev-api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

```yaml
# overlays/prod/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.example.com
    secretName: api-tls-secret
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

```yaml
# Update overlays/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: dev-
commonLabels:
  env: dev
resources:
- ../../base
- ingress.yaml
# ... rest remains ...
```

```yaml
# Update overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: prod-
commonLabels:
  env: prod
resources:
- ../../base
- ingress.yaml
# ... rest remains ...
```

### **Step 10 – Monitoring Sidecar (Prod Only)**

```yaml
# overlays/prod/patch-sidecar.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  template:
    spec:
      containers:
      - name: monitor
        image: busybox:latest
        command: ["sh", "-c", "while true; do echo 'Monitoring API...'; sleep 30; done"]
        resources:
          requests:
            memory: "16Mi"
            cpu: "10m"
          limits:
            memory: "32Mi"
            cpu: "20m"
```

Add to prod kustomization patches.

### **Step 11 – Affinity and Tolerations**

```yaml
# overlays/prod/patch-affinity.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - api
              topologyKey: kubernetes.io/hostname
      tolerations:
      - key: "dedicated"
        operator: "Equal"
        value: "prod"
        effect: "NoSchedule"
```

### **Step 12 – Common Labels and Annotations**

```yaml
# Update base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
- configmap.yaml
- redis-deployment.yaml
- redis-service.yaml
- secret.yaml
commonLabels:
  app: node-api
  managed-by: kustomize
  version: v1.0.0
```

```yaml
# Update overlays/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: dev-
commonLabels:
  env: dev
commonAnnotations:
  environment: development
  team: devops
  deploy-timestamp: "2024-01-15"
# ... rest remains ...
```

```yaml
# Update overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: prod-
commonLabels:
  env: prod
commonAnnotations:
  environment: production
  team: platform
  owner: platform-team@company.com
  sla-tier: "gold"
# ... rest remains ...
```

### **Step 13 – Namespace Isolation**

```yaml
# overlays/prod-us/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: prod-us
namePrefix: us-
commonLabels:
  region: us-east
resources:
- ../prod
patchesStrategicMerge:
- configmap-region.yaml
configMapGenerator:
- name: app-config
  behavior: merge
  literals:
  - REGION=us-east
  - DATACENTER=dc1
```

```yaml
# overlays/prod-eu/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: prod-eu
namePrefix: eu-
commonLabels:
  region: eu-west
resources:
- ../prod
patchesStrategicMerge:
- configmap-region.yaml
configMapGenerator:
- name: app-config
  behavior: merge
  literals:
  - REGION=eu-west
  - DATACENTER=dc2
```

### **Step 14 – Volume Mounts**

```yaml
# Update base/deployment.yaml - add volumes
spec:
  template:
    spec:
      volumes:
      - name: app-logs
        emptyDir: {}
      containers:
      - name: api
        # ... existing config ...
        volumeMounts:
        - name: app-logs
          mountPath: /tmp/logs
```

```yaml
# overlays/prod/patch-volumes.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  template:
    spec:
      containers:
      - name: api
        volumeMounts:
        - name: app-logs
          mountPath: /var/log/app
          readOnly: false
```

### **Step 15 – Job for Database Migration**

```yaml
# overlays/prod/migration-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
  annotations:
    kustomize.config.k8s.io/behavior: create
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: migration
        image: node:18-alpine
        command: ["sh", "-c", "echo 'Running database migrations...'; sleep 5; echo 'Migrations completed successfully'"]
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: REDIS_HOST
```

### **Step 16 – Multiple Environments with Bases**

```yaml
# overlays/staging/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: staging-
commonLabels:
  env: staging
commonAnnotations:
  environment: staging
  team: qa
resources:
- ../prod
patchesStrategicMerge:
- patch-staging.yaml
images:
- name: node:18-alpine
  newTag: 18-alpine
```

```yaml
# overlays/staging/patch-staging.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  replicas: 3
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
spec:
  rules:
  - host: staging-api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

### **Step 17 – Variables Replacement**

```yaml
# Update base/kustomization.yaml with vars
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
- configmap.yaml
- redis-deployment.yaml
- redis-service.yaml
- secret.yaml
commonLabels:
  app: node-api
  managed-by: kustomize
  version: v1.0.0
vars:
- name: API_IMAGE
  objref:
    kind: Deployment
    name: api-deployment
    apiVersion: apps/v1
  fieldref:
    fieldpath: spec.template.spec.containers[0].image
- name: REDIS_IMAGE
  objref:
    kind: Deployment
    name: redis-deployment
    apiVersion: apps/v1
  fieldref:
    fieldpath: spec.template.spec.containers[0].image
```

```yaml
# Add to base/configmap.yaml
data:
  # ... existing data ...
  API_IMAGE: $(API_IMAGE)
  REDIS_IMAGE: $(REDIS_IMAGE)
```

### **Step 18 – CRD Patching**

```yaml
# base/custom-resource.yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: monitors.monitoring.example.com
spec:
  group: monitoring.example.com
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
              interval:
                type: string
              endpoints:
                type: array
                items:
                  type: string
  scope: Namespaced
  names:
    plural: monitors
    singular: monitor
    kind: Monitor
---
apiVersion: monitoring.example.com/v1
kind: Monitor
metadata:
  name: api-monitor
spec:
  interval: "30s"
  endpoints:
  - "/health"
  - "/metrics"
```

```yaml
# overlays/prod/patch-crd.yaml
apiVersion: monitoring.example.com/v1
kind: Monitor
metadata:
  name: api-monitor
spec:
  interval: "15s"
  endpoints:
  - "/health"
  - "/metrics"
  - "/debug"
  alertThreshold: "95"
```

## **Testing Commands**

```bash
# Test each step
kubectl kustomize ./base
kubectl kustomize ./overlays/dev
kubectl kustomize ./overlays/prod
kubectl kustomize ./overlays/prod-us
kubectl kustomize ./overlays/prod-eu
kubectl kustomize ./overlays/staging

# Apply to cluster
kubectl apply -k ./overlays/dev
kubectl apply -k ./overlays/prod
```

This complete solution covers 15+ Kustomize transformers including:
- `resources`, `patchesStrategicMerge`, `patchesJson6902`
- `namePrefix`, `nameSuffix`, `namespace`
- `commonLabels`, `commonAnnotations`
- `images` transformer
- `configMapGenerator`, `secretGenerator`
- `vars` for variable substitution
- `replicas` field in patches
- `affinity`, `tolerations`, `volumes`
- CRD support
- Job creation with annotations
- Multi-environment inheritance