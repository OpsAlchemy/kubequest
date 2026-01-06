# Helm Practice - Answers

## Answer 1 – MinIO Helm Install

```bash
# Add repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# Create namespace
kubectl create namespace storage

# Install MinIO
helm install minio-app bitnami/minio \
  --set auth.rootUser=minioadmin \
  --set auth.rootPassword=miniosecret \
  --set persistence.enabled=true \
  --set persistence.size=10Gi \
  --namespace storage

# Verify
helm list -n storage
kubectl get pods -n storage
```

---

## Answer 2 – PostgreSQL Helm Install

```bash
# Add repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# Create namespace
kubectl create namespace databases

# Install PostgreSQL
helm install pg-app bitnami/postgresql \
  --set auth.username=appuser \
  --set auth.password=apppass \
  --set auth.database=appdb \
  --set primary.persistence.size=5Gi \
  --namespace databases

# Verify
helm list -n databases
kubectl get pvc -n databases
```

---

## Answer 3 – Redis Helm Upgrade

```bash
# Upgrade Redis with new settings
helm upgrade redis-app bitnami/redis \
  --set auth.enabled=true \
  --set auth.password=redispass \
  --set primary.persistence.size=8Gi \
  --namespace databases

# Check upgrade status
helm status redis-app -n databases
helm history redis-app -n databases

# Verify new settings
kubectl exec -it redis-app-0 -n databases -- redis-cli CONFIG GET requirepass
```

---

## Answer 4 – Create and Use a Simple Helm Chart

```bash
# Create chart
helm create simple-app

# Create namespace
kubectl create namespace demo

# Install chart
helm install simple-release ./simple-app \
  --set replicaCount=2 \
  --set image.repository=myorg/simple-app \
  --set image.tag=1.0.0 \
  --set service.port=8080 \
  --namespace demo

# Verify install
helm list -n demo
kubectl get deployments -n demo
kubectl get pods -n demo

# Upgrade image tag
helm upgrade simple-release ./simple-app \
  --set image.tag=1.1.0 \
  --namespace demo

# Check history
helm history simple-release -n demo

# Verify upgrade
kubectl describe deployment simple-release -n demo | grep Image
```

---

## Answer 5 – Multi-Environment Helm Deployment

```bash
# Add repo
helm repo add minio-operator https://operator.min.io

# Create namespaces
kubectl create namespace minio-dev
kubectl create namespace minio-staging
kubectl create namespace minio-prod

# Dev environment
helm install operator-dev minio-operator/minio-operator --version 4.3.7 \
  --set operator.replicaCount=1 \
  --set tenants[0].pools[0].servers=1 \
  --namespace minio-dev

# Staging environment
helm install operator-staging minio-operator/minio-operator --version 4.3.7 \
  --set operator.replicaCount=2 \
  --set tenants[0].pools[0].servers=2 \
  --namespace minio-staging

# Prod environment
helm install operator-prod minio-operator/minio-operator --version 4.3.7 \
  --set operator.replicaCount=3 \
  --set tenants[0].pools[0].servers=4 \
  --namespace minio-prod

# List all releases
helm list -A
```

---

## Answer 6 – Helm Search and Show Commands

```bash
# Search for charts in repo
helm search repo bitnami/nginx

# Search with specific version
helm search repo bitnami/postgresql --versions | head -10

# Show chart values
helm show values bitnami/nginx

# Show chart info
helm show chart bitnami/postgresql

# Show readme
helm show readme bitnami/redis
```

---

## Answer 7 – Helm Template Rendering

```bash
# Render templates locally without installing
helm template my-release bitnami/nginx \
  --set replicaCount=3 \
  --set service.type=LoadBalancer

# Save rendered output to file
helm template my-release bitnami/postgresql \
  --set auth.username=testuser > postgresql-manifest.yaml

# Render with namespace
helm template my-release bitnami/redis \
  --namespace test-ns \
  --set auth.enabled=true

# Check template syntax
helm lint bitnami/nginx
```

---

## Answer 8 – Helm Rollback

```bash
# View release history
helm history my-release -n default

# Rollback to previous version
helm rollback my-release -n default

# Rollback to specific revision
helm rollback my-release 2 -n default

# Verify rollback
helm status my-release -n default
helm get values my-release -n default
```

---

## Answer 9 – Helm Uninstall and Cleanup

```bash
# Uninstall a release
helm uninstall minio-app -n storage

# Uninstall and keep release history
helm uninstall pg-app -n databases --keep-history

# List all releases including uninstalled
helm list -a -n databases

# Delete namespace
kubectl delete namespace storage
```

---

## Answer 10 – Helm Repo Management

```bash
# Add multiple repos
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add minio-operator https://operator.min.io
helm repo add stable https://charts.helm.sh/stable

# List all repos
helm repo list

# Update repos
helm repo update

# Remove a repo
helm repo remove bitnami

# Search specific repo
helm search repo minio-operator/minio-operator
```

---

## Answer 11 – Helm Get Commands

```bash
# Get current values of release
helm get values minio-app -n storage

# Get all resources created by release
helm get manifest minio-app -n storage

# Get hooks from release
helm get hooks pg-app -n databases

# Get notes from release
helm get notes simple-release -n demo

# Get all info about release
helm get all operator-prod -n minio-prod
```

---

## Answer 12 – Multi-Value Files

```bash
# Create base values
cat > values.yaml << EOF
replicaCount: 1
image:
  tag: "1.0.0"
EOF

# Create dev overrides
cat > values-dev.yaml << EOF
replicaCount: 1
image:
  tag: "latest"
EOF

# Create prod overrides
cat > values-prod.yaml << EOF
replicaCount: 3
image:
  tag: "1.0.0"
EOF

# Install with multiple value files
helm install my-app ./my-chart \
  --values values.yaml \
  --values values-prod.yaml \
  --namespace production

# Values order: base → prod (prod overrides base)
```

---
