
kind create cluster --name session01 --image kindest/node:v1.34.0 || true
cd cka/solutions/03-kustomize/sol1
kubectl kustomize base/ 