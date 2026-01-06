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