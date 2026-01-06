# Kustomize Practice - Answers

---

## Answer 1 – Base Application Setup

```bash
# Create directory structure
mkdir -p base

# base/deployment.yaml
cat > base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: node-api
  template:
    metadata:
      labels:
        app: node-api
    spec:
      containers:
      - name: api
        image: node:18-alpine
        ports:
        - containerPort: 3000
EOF

# base/service.yaml
cat > base/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: node-api-svc
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 3000
  selector:
    app: node-api
EOF

# base/kustomization.yaml
cat > base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
EOF

# Verify
kustomize build base/
```

---

## Answer 2 – ConfigMap and Environment Variables

```bash
# base/configmap.yaml
cat > base/configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_NAME: myapp
  LOG_LEVEL: debug
  REDIS_HOST: redis-service
EOF

# Update base/deployment.yaml
cat > base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: node-api
  template:
    metadata:
      labels:
        app: node-api
    spec:
      containers:
      - name: api
        image: node:18-alpine
        ports:
        - containerPort: 3000
        envFrom:
        - configMapRef:
            name: app-config
EOF

# Update base/kustomization.yaml
cat > base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
- configmap.yaml
EOF

# Verify
kustomize build base/
```

---

## Answer 3 – Redis Sidecar Service

```bash
# base/redis-deployment.yaml
cat > base/redis-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
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
EOF

# base/redis-service.yaml
cat > base/redis-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: redis-service
spec:
  type: ClusterIP
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    app: redis
EOF

# Update base/kustomization.yaml
cat > base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
- configmap.yaml
- redis-deployment.yaml
- redis-service.yaml
EOF

# Verify
kustomize build base/
```

---

## Answer 4 – Development Overlay with Patches

```bash
# Create overlay structure
mkdir -p overlays/dev/patches

# overlays/dev/kustomization.yaml
cat > overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: dev

namePrefix: dev-

commonLabels:
  env: dev

patchesStrategicMerge:
- patches/deployment-patch.yaml
EOF

# overlays/dev/patches/deployment-patch.yaml
cat > overlays/dev/patches/deployment-patch.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-api
spec:
  replicas: 2
EOF

# Verify
kustomize build overlays/dev/
```

---

## Answer 5 – Production Overlay

```bash
# Create overlay structure
mkdir -p overlays/prod/patches

# overlays/prod/kustomization.yaml
cat > overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: prod

namePrefix: prod-

commonLabels:
  env: prod

patchesStrategicMerge:
- patches/deployment-patch.yaml
- patches/resources-patch.yaml
EOF

# overlays/prod/patches/deployment-patch.yaml
cat > overlays/prod/patches/deployment-patch.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-api
spec:
  replicas: 4
EOF

# overlays/prod/patches/resources-patch.yaml
cat > overlays/prod/patches/resources-patch.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-api
spec:
  template:
    spec:
      containers:
      - name: api
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
EOF

# Verify
kustomize build overlays/prod/
```

---

## Answer 6 – Image Tag Management

```bash
# Update overlays/dev/kustomization.yaml
cat > overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: dev
namePrefix: dev-
commonLabels:
  env: dev

patchesStrategicMerge:
- patches/deployment-patch.yaml

images:
- name: node
  newTag: 18-alpine
EOF

# Update overlays/prod/kustomization.yaml
cat > overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: prod
namePrefix: prod-
commonLabels:
  env: prod

patchesStrategicMerge:
- patches/deployment-patch.yaml
- patches/resources-patch.yaml

images:
- name: node
  newTag: 18.20.0-alpine
EOF

# Verify
kustomize build overlays/dev/
kustomize build overlays/prod/
```

---

## Answer 7 – ConfigMap Generator

```bash
# Create environment file
cat > overlays/dev/.env.config << 'EOF'
APP_NAME=myapp-dev
LOG_LEVEL=debug
REDIS_HOST=redis-service
EOF

# Update overlays/dev/kustomization.yaml
cat > overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: dev
namePrefix: dev-
commonLabels:
  env: dev

configMapGenerator:
- name: app-config
  files:
  - .env.config
  behavior: merge

patchesStrategicMerge:
- patches/deployment-patch.yaml
EOF

# Remove static configmap from base references if using generator
# Verify
kustomize build overlays/dev/
```

---

## Answer 8 – Secret Generator

```bash
# Create secret files
mkdir -p overlays/dev overlays/prod

# overlays/dev/.env.secrets
cat > overlays/dev/.env.secrets << 'EOF'
DB_PASSWORD=devpass123
DB_USER=devuser
EOF

# overlays/prod/.env.secrets
cat > overlays/prod/.env.secrets << 'EOF'
DB_PASSWORD=prod-secure-pass-123!
DB_USER=produser
EOF

# Update overlays/dev/kustomization.yaml
cat > overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: dev
namePrefix: dev-
commonLabels:
  env: dev

secretGenerator:
- name: db-credentials
  files:
  - .env.secrets

patchesStrategicMerge:
- patches/deployment-patch.yaml
EOF

# Update overlays/prod/kustomization.yaml
cat > overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: prod
namePrefix: prod-
commonLabels:
  env: prod

secretGenerator:
- name: db-credentials
  files:
  - .env.secrets

patchesStrategicMerge:
- patches/deployment-patch.yaml
- patches/resources-patch.yaml
EOF

# Verify
kustomize build overlays/dev/
kustomize build overlays/prod/
```

---

## Answer 9 – PatchesStrategicMerge

```bash
# overlays/prod/patches/deployment-patch.yaml
cat > overlays/prod/patches/deployment-patch.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-api
spec:
  replicas: 4
  template:
    spec:
      containers:
      - name: api
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
EOF

# overlays/prod/patches/service-patch.yaml
cat > overlays/prod/patches/service-patch.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: node-api-svc
spec:
  type: LoadBalancer
EOF

# Update overlays/prod/kustomization.yaml
cat > overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: prod
namePrefix: prod-
commonLabels:
  env: prod

patchesStrategicMerge:
- patches/deployment-patch.yaml
- patches/service-patch.yaml
EOF

# Verify
kustomize build overlays/prod/
```

---

## Answer 10 – JSON Patches (RFC 6902)

```bash
# Create staging overlay
mkdir -p overlays/staging/patches

# overlays/staging/patches.yaml
cat > overlays/staging/patches.yaml << 'EOF'
- op: add
  path: /metadata/annotations
  value:
    stage: staging
    monitoring: enabled

- op: add
  path: /spec/template/metadata/annotations
  value:
    prometheus: scrape

- op: add
  path: /spec/template/spec/securityContext
  value:
    runAsNonRoot: true
    runAsUser: 1000
EOF

# overlays/staging/kustomization.yaml
cat > overlays/staging/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: staging
namePrefix: staging-
commonLabels:
  env: staging

patchesJson6902:
- target:
    kind: Deployment
    name: node-api
  patch: patches.yaml
EOF

# Verify
kustomize build overlays/staging/
```

---

## Answer 11 – Kustomization Bases & Cross-Overlay Composition

```bash
# Create QA overlay
mkdir -p overlays/qa

# overlays/qa/kustomization.yaml
cat > overlays/qa/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: qa
namePrefix: qa-
commonLabels:
  env: qa
  team: qa-team

commonAnnotations:
  automation: enabled
  retention-days: "7"
EOF

# Build all overlays
kustomize build overlays/dev/
kustomize build overlays/staging/
kustomize build overlays/prod/
kustomize build overlays/qa/

# Compare namespaces and prefixes
kustomize build overlays/dev/ | grep namespace
kustomize build overlays/prod/ | grep namespace
```

---

## Answer 12 – CommonLabels and CommonAnnotations

```bash
# Update overlays/prod/kustomization.yaml
cat > overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: prod
namePrefix: prod-

commonLabels:
  app: myapp
  env: prod
  version: "1.0.0"
  team: backend

commonAnnotations:
  description: Production deployment
  owner: platform-team
  last-updated: "2024-01-06"
  environment: production

patchesStrategicMerge:
- patches/deployment-patch.yaml
- patches/service-patch.yaml
EOF

# Update overlays/dev/kustomization.yaml
cat > overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: dev
namePrefix: dev-

commonLabels:
  app: myapp
  env: dev
  version: "0.1.0"
  team: backend

commonAnnotations:
  description: Development deployment
  owner: dev-team

patchesStrategicMerge:
- patches/deployment-patch.yaml
EOF

# Verify labels and annotations
kustomize build overlays/prod/ | grep labels
kustomize build overlays/dev/ | grep labels
```

---

## Answer 13 – Namespace Management

```bash
# overlays/dev/kustomization.yaml
cat > overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: dev
namePrefix: dev-
EOF

# overlays/staging/kustomization.yaml
cat > overlays/staging/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: staging
namePrefix: staging-
EOF

# overlays/prod/kustomization.yaml
cat > overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: prod
namePrefix: prod-
EOF

# Verify namespaces
kustomize build overlays/dev/ | grep -A 2 namespace
kustomize build overlays/staging/ | grep -A 2 namespace
kustomize build overlays/prod/ | grep -A 2 namespace
```

---

## Answer 14 – Resource Composition with Multiple Bases

```bash
# base/monitoring.yaml
cat > base/monitoring.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: monitoring-config
data:
  scrape_interval: 15s
  prometheus_enabled: "true"
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus-sd
spec:
  clusterIP: None
  selector:
    app: node-api
EOF

# Update base/kustomization.yaml
cat > base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
- configmap.yaml
- redis-deployment.yaml
- redis-service.yaml
- monitoring.yaml
EOF

# overlays/prod/kustomization.yaml keeps monitoring
# overlays/dev/kustomization.yaml excludes it if needed

# Verify
kustomize build overlays/prod/ | grep monitoring
```

---

## Answer 15 – Ingress with Custom Hosts

```bash
# base/ingress.yaml
cat > base/ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: node-api-svc
            port:
              number: 80
EOF

# overlays/dev/patches/ingress-patch.yaml
cat > overlays/dev/patches/ingress-patch.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
spec:
  rules:
  - host: dev.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: node-api-svc
            port:
              number: 80
EOF

# overlays/prod/patches/ingress-patch.yaml
cat > overlays/prod/patches/ingress-patch.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
spec:
  tls:
  - hosts:
    - api.example.com
    secretName: api-tls-cert
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: node-api-svc
            port:
              number: 80
EOF

# Add to base/kustomization.yaml
# Add to overlays/dev and prod kustomization

# Verify
kustomize build overlays/dev/ | grep host
kustomize build overlays/prod/ | grep host
```

---

## Answer 16 – PersistentVolume and StatefulSet

```bash
# base/statefulset.yaml
cat > base/statefulset.yaml << 'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      storageClassName: standard
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
EOF

# overlays/dev/patches/statefulset-patch.yaml
cat > overlays/dev/patches/statefulset-patch.yaml << 'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      resources:
        requests:
          storage: 5Gi
EOF

# overlays/prod/patches/statefulset-patch.yaml
cat > overlays/prod/patches/statefulset-patch.yaml << 'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  replicas: 3
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      resources:
        requests:
          storage: 100Gi
EOF

# Verify
kustomize build overlays/dev/ | grep -A 5 storage
kustomize build overlays/prod/ | grep -A 5 storage
```

---

## Answer 17 – Environment-Specific Files with SecretGenerator

```bash
# overlays/dev/.env.secrets
cat > overlays/dev/.env.secrets << 'EOF'
DB_PASSWORD=dev-insecure-pass
API_KEY=dev-key-12345
ENCRYPTION_KEY=dev-encryption-key
EOF

# overlays/prod/.env.secrets
cat > overlays/prod/.env.secrets << 'EOF'
DB_PASSWORD=$(openssl rand -base64 32)
API_KEY=$(head -c 32 /dev/urandom | base64)
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
EOF

# overlays/dev/kustomization.yaml
cat > overlays/dev/kustomization.yaml << 'EOF'
secretGenerator:
- name: app-secrets
  envs:
  - .env.secrets
  behavior: create
EOF

# overlays/prod/kustomization.yaml
cat > overlays/prod/kustomization.yaml << 'EOF'
secretGenerator:
- name: app-secrets
  envs:
  - .env.secrets
  behavior: create
EOF

# Verify
kustomize build overlays/dev/
kustomize build overlays/prod/
```

---

## Answer 18 – Post-Renderer and Replacements

```bash
# base/configmap.yaml
cat > base/configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  CLUSTER_NAME: REPLACE_ME
  ENVIRONMENT: REPLACE_ENVIRONMENT
EOF

# overlays/dev/kustomization.yaml
cat > overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

replacements:
- source:
    kind: ConfigMap
    name: app-config
    fieldPath: data.CLUSTER_NAME
  targets:
  - select:
      kind: ConfigMap
      name: app-config
    fieldPaths:
    - data.CLUSTER_NAME
  replacement: dev-cluster

- source:
    kind: ConfigMap
    name: app-config
    fieldPath: data.ENVIRONMENT
  targets:
  - select:
      kind: ConfigMap
      name: app-config
    fieldPaths:
    - data.ENVIRONMENT
  replacement: development
EOF

# overlays/prod/kustomization.yaml
cat > overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

replacements:
- source:
    kind: ConfigMap
    name: app-config
    fieldPath: data.CLUSTER_NAME
  targets:
  - select:
      kind: ConfigMap
      name: app-config
    fieldPaths:
    - data.CLUSTER_NAME
  replacement: prod-cluster

- source:
    kind: ConfigMap
    name: app-config
    fieldPath: data.ENVIRONMENT
  targets:
  - select:
      kind: ConfigMap
      name: app-config
    fieldPaths:
    - data.ENVIRONMENT
  replacement: production
EOF

# Verify
kustomize build overlays/dev/ | grep CLUSTER_NAME
kustomize build overlays/prod/ | grep CLUSTER_NAME
```

---

## Answer 19 – Full End-to-End Build and Deploy

```bash
# Build all overlays
kustomize build overlays/dev/ > dev-manifest.yaml
kustomize build overlays/staging/ > staging-manifest.yaml
kustomize build overlays/prod/ > prod-manifest.yaml

# Verify manifests
echo "=== DEV MANIFEST ==="
cat dev-manifest.yaml | grep -E "namespace|replicas|image|name" | head -20

echo "=== PROD MANIFEST ==="
cat prod-manifest.yaml | grep -E "namespace|replicas|image|name" | head -20

# Count resources
echo "Dev resources: $(cat dev-manifest.yaml | grep -c 'kind:')"
echo "Prod resources: $(cat prod-manifest.yaml | grep -c 'kind:')"

# Check for duplicates
grep -c "name: " dev-manifest.yaml
grep -c "name: " prod-manifest.yaml
```

---

## Answer 20 – Kustomization Best Practices

```bash
# Final directory structure
tree -L 3

# Organized structure:
# .
# ├── base/
# │   ├── kustomization.yaml
# │   ├── deployment.yaml
# │   ├── service.yaml
# │   ├── configmap.yaml
# │   ├── redis-deployment.yaml
# │   ├── redis-service.yaml
# │   ├── monitoring.yaml
# │   ├── ingress.yaml
# │   └── statefulset.yaml
# └── overlays/
#     ├── dev/
#     │   ├── kustomization.yaml
#     │   ├── .env.config
#     │   ├── .env.secrets
#     │   └── patches/
#     ├── staging/
#     │   ├── kustomization.yaml
#     │   └── patches.yaml
#     ├── prod/
#     │   ├── kustomization.yaml
#     │   ├── .env.config
#     │   ├── .env.secrets
#     │   └── patches/
#     └── qa/
#         └── kustomization.yaml

# Best practices validation
echo "=== Checking for duplicates ==="
kustomize build overlays/dev/ | grep "^  name:" | sort | uniq -d

echo "=== Validating all builds ==="
for env in dev staging prod qa; do
  echo "Building $env..."
  kustomize build overlays/$env/ > /dev/null && echo "✓ $env OK" || echo "✗ $env FAILED"
done

echo "=== Final manifests ready ==="
ls -la *manifest.yaml
```
