# Kustomize Practice Answers (Compressed 3 Questions)

---

## Answer 1 – Multi-Environment Base + Overlays with Patches

### Base Setup

```bash
# Create directory structure
mkdir -p kustomize-demo/base kustomize-demo/overlays/{dev,prod}/patches
cd kustomize-demo/base

# base/deployment.yaml
cat > deployment.yaml << 'YAML'
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
YAML

# base/service.yaml
cat > service.yaml << 'YAML'
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
YAML

# base/configmap.yaml
cat > configmap.yaml << 'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_NAME: myapp
  LOG_LEVEL: info
  REDIS_HOST: redis-service
YAML

# base/redis-deployment.yaml
cat > redis-deployment.yaml << 'YAML'
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
YAML

# base/redis-service.yaml
cat > redis-service.yaml << 'YAML'
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
YAML

# base/kustomization.yaml
cat > kustomization.yaml << 'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
- configmap.yaml
- redis-deployment.yaml
- redis-service.yaml
YAML

# Verify base
kustomize build .
```

### Dev Overlay

```bash
cd ../overlays/dev

# overlays/dev/patches/deployment-patch.yaml
cat > patches/deployment-patch.yaml << 'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-api
spec:
  replicas: 2
YAML

# overlays/dev/kustomization.yaml
cat > kustomization.yaml << 'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../base

namespace: dev
namePrefix: dev-

labels:
- includeSelectors: true
  pairs:
    env: dev

patches:
- path: patches/deployment-patch.yaml
  target:
    kind: Deployment
    name: node-api
YAML

# Test
kustomize build .
```

### Prod Overlay

```bash
cd ../prod

# overlays/prod/patches/deployment-patch.yaml
cat > patches/deployment-patch.yaml << 'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-api
spec:
  replicas: 4
YAML

# overlays/prod/patches/resources-patch.yaml
cat > patches/resources-patch.yaml << 'YAML'
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
YAML

# overlays/prod/kustomization.yaml
cat > kustomization.yaml << 'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../base

namespace: prod
namePrefix: prod-

labels:
- includeSelectors: true
  pairs:
    env: prod

patches:
- path: patches/deployment-patch.yaml
  target:
    kind: Deployment
    name: node-api
- path: patches/resources-patch.yaml
  target:
    kind: Deployment
    name: node-api
YAML

# Test
kustomize build .
```

---

## Answer 2 – ConfigMap/Secret Generators + Image Patching

**Build on your Q1 solution directory.**

```bash
cd overlays/dev

# Create .env files
cat > .env.config << 'ENV'
APP_NAME=myapp-dev
LOG_LEVEL=debug
REDIS_HOST=redis-service
ENV

cat > .env.secrets << 'ENV'
DB_PASSWORD=devpass123
DB_USER=dev
ENV

# Update overlays/dev/kustomization.yaml
cat > kustomization.yaml << 'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../base

namespace: dev
namePrefix: dev-

labels:
- includeSelectors: true
  pairs:
    env: dev

patches:
- path: patches/deployment-patch.yaml
  target:
    kind: Deployment
    name: node-api

configMapGenerator:
- name: app-config
  files:
  - .env.config
  behavior: merge

secretGenerator:
- name: db-credentials
  files:
  - .env.secrets

images:
- name: node
  newTag: 18-alpine
YAML

# Test
kustomize build . | grep -A 2 "^apiVersion: v1"
kustomize build . | grep "image:"
```

### Prod Overlay

```bash
cd ../prod

# Create .env files
cat > .env.config << 'ENV'
APP_NAME=myapp-prod
LOG_LEVEL=info
REDIS_HOST=redis-service
ENV

cat > .env.secrets << 'ENV'
DB_PASSWORD=prod-secure-xyz-2024
DB_USER=prod
ENV

# Update overlays/prod/kustomization.yaml
cat > kustomization.yaml << 'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../base

namespace: prod
namePrefix: prod-

labels:
- includeSelectors: true
  pairs:
    env: prod

patches:
- path: patches/deployment-patch.yaml
  target:
    kind: Deployment
    name: node-api
- path: patches/resources-patch.yaml
  target:
    kind: Deployment
    name: node-api

configMapGenerator:
- name: app-config
  files:
  - .env.config
  behavior: merge

secretGenerator:
- name: db-credentials
  files:
  - .env.secrets

images:
- name: node
  newTag: 18.20.0-alpine
YAML

# Test
kustomize build . | grep ConfigMap
kustomize build . | grep image:
```

---

## Answer 3 – Advanced: Multi-Base + JSON Patches

```bash
# Create fresh project
mkdir -p advanced-kustomize/bases/{core,monitoring,security}/
mkdir -p advanced-kustomize/overlays/{staging,prod}
cd advanced-kustomize

# bases/core/deployment.yaml
cat > bases/core/deployment.yaml << 'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
YAML

# bases/core/service.yaml
cat > bases/core/service.yaml << 'YAML'
apiVersion: v1
kind: Service
metadata:
  name: webapp-svc
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: webapp
YAML

# bases/core/kustomization.yaml
cat > bases/core/kustomization.yaml << 'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
YAML

# bases/monitoring/servicemonitor.yaml (Prometheus)
cat > bases/monitoring/servicemonitor.yaml << 'YAML'
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: webapp-monitor
spec:
  selector:
    matchLabels:
      app: webapp
  endpoints:
  - port: metrics
YAML

# bases/monitoring/kustomization.yaml
cat > bases/monitoring/kustomization.yaml << 'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- servicemonitor.yaml
YAML

# bases/security/networkpolicy.yaml
cat > bases/security/networkpolicy.yaml << 'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: webapp-netpol
spec:
  podSelector:
    matchLabels:
      app: webapp
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
  egress:
  - to:
    - namespaceSelector: {}
YAML

# bases/security/kustomization.yaml
cat > bases/security/kustomization.yaml << 'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- networkpolicy.yaml
YAML

# overlays/staging/patches.json
cat > overlays/staging/patches.json << 'JSON'
[
  {
    "op": "add",
    "path": "/metadata/annotations",
    "value": {
      "monitoring": "true",
      "environment": "staging"
    }
  },
  {
    "op": "add",
    "path": "/spec/template/metadata/annotations",
    "value": {
      "monitoring": "enabled"
    }
  },
  {
    "op": "add",
    "path": "/spec/type",
    "value": "LoadBalancer"
  }
]
JSON

# overlays/staging/kustomization.yaml
cat > overlays/staging/kustomization.yaml << 'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../bases/core
- ../../bases/monitoring

namespace: staging
namePrefix: staging-

labels:
- includeSelectors: true
  pairs:
    env: staging

patchesJson6902:
- target:
    kind: Deployment
    name: staging-webapp
  patch: |-
    [
      {
        "op": "add",
        "path": "/metadata/annotations",
        "value": {
          "monitoring": "true"
        }
      }
    ]
YAML

# overlays/prod/kustomization.yaml
cat > overlays/prod/kustomization.yaml << 'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../bases/core
- ../../bases/monitoring
- ../../bases/security

namespace: prod
namePrefix: prod-

labels:
- includeSelectors: true
  pairs:
    env: prod
YAML

# Test
kustomize build overlays/staging/
kustomize build overlays/prod/ | grep NetworkPolicy
```

---

## Key Concepts Covered:

1. **Q1**: Base → overlays, namespace isolation, namePrefix, patches, labels
2. **Q2**: ConfigMap/Secret generators, image tag management, hash suffixes
3. **Q3**: Multi-base composition, JSON patches (RFC 6902), cross-cutting concerns

All three questions are **production-ready patterns** commonly used in real Kubernetes projects.
