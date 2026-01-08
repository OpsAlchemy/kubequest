#!/usr/bin/env bash
set -euo pipefail

########################################
# Environment setup
########################################
cd /home/azureuser/local/kubequest/cka/solutions/02-helm/session01
cd /mnt/c/Users/VikashKumar/Desktop/dev3/ops/kubequest/solutions/02-helm/session01

########################################
# KIND cluster
########################################

kind create cluster --name session01 --image kindest/node:v1.34.0 || true

### Solution 1

helm repo add bintami https://charts.bitnami.com/bitnami
helm repo list

helm search repo # Searches everything
helm search repo minio # Searches specific things
helm search repo minio --version # Searches specific things and all the versions

helm repo add wenerme https://charts.wener.tech # Adding repo which is a list of things
helm repo update # and then updating so we can search across the whole hub or index.

kubectl create ns storage
kubectl config set-context --current --namespace=storage

helm repo update
helm install minio-app bitnami/minio
helm upgrade --install minio-app bitnami/minio \
    --set auth.rootUser=minoadmin \
    --set auth.rootPassword=miniosecret \
    --set persistence.enabled=true \
    --set persistence.size=10Gi

# Question 2
helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl create ns database
helm search repo postgresql
helm install pg-app bintami/postgresql 
helm upgrade --install pg-app bi\
     --set auth.user=appuser \
    --set auth.passwd=apppass \
    --set auth.database=appdb \
    --set primary.persistence.size=5Gi

# Question 3
helm install redis-app bitnami/redis

helm upgrade --install redis-app bitnami/redis \
    --set auth.enabled=true \
    --set auth.password=redispass \
    --set primary.persistance.size=8Gi

# Question 4
helm install simple-release ./sol4 --create-namespace -n demo
helm upgrade --install simple-release ./sol4 --set replicas=1 -n demo


# Question 5
helm repo add minio-operator https://operator.min.io
helm install minio minio-operator/minio-operator
helm uninstall minio 

helm install minio-dev minio-operator/minio-operator --version v4.3.7 \
    --set operator.replicaCount=1 

helm install minio-staging minio-operator/minio-operator --version v4.3.7 \
    --set operator.replicaCount=2

helm install minio-prod minio-operator/minio-operator --version v4.3.7 \
    --set operator.replicaCount=4

# Question 6
helm search repo nginx
helm search repo postgresql
helm search repo postgresql --versions
helm show values bitnami/redis
helm show readme bitnami/postgresql
helm show chart bitnami/nginx

# Question 7
helm install new-nginx bitnami/nginx --set replicas=3
helm template my-rel bitnami/nginx --set replicas=3

helm template my-release bitnami/nginx \
  --set replicaCount=3 \
  --set service.type=LoadBalancer

helm template my-release bitnami/postgresql \
  --set auth.username=testuser > /tmp/postgresql-manifest.yaml

helm template my-release bitnami/redis \
  --namespace test-ns \
  --set auth.enabled=true

helm lint bitnami/nginx


# Question 8
# cleanup 
helm uninstall simple-release
# solution
helm install simple-release ./sol4 --set image=nginx --set replicas=2
helm upgrade --install simple-release ./sol4 --set image=nginx --set replicas=3
helm upgrade --install simple-release ./sol4 --set image=ngneix --set replicas=1
helm upgrade --install simple-release ./sol4 --set image=ngneix --set replicas=1 --force
helm history simple-release
helm rollback simple-release 2

helm get values simple-release
helm get all simple-release
helm get values simple-release --all
helm get values simple-release --revision 2
helm get values simple-release --revision 5

# Question 9
kind delete clusters session01

kind create cluster --name session01 --image kindest/node:v1.34.0 || true

helm repo add bintami https://charts.bitnami.com/bitnami
helm repo add minio-operator https://operator.min.io
helm repo add wenerme https://charts.wener.tech

helm repo list

helm repo update
helm repo remove bitnami


# Question 11
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

# ---
# Question 12
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
