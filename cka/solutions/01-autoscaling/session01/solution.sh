#!/usr/bin/env bash
set -euo pipefail

########################################
# Environment setup
########################################

cd /mnt/c/Users/VikashKumar/Desktop/dev3/ops/kubequest/solutions/01-autoscaling/session01

########################################
# KIND cluster
########################################

kind create cluster --name session01 --image kindest/node:v1.34.0 || true

########################################
# Metrics Server (Method 1: apply + patch)
########################################

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml

kubectl patch -n kube-system deployment metrics-server \
  --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

########################################
# Metrics Server (Method 2: Helm)
########################################

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ || true
helm repo update

helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --create-namespace \
  --set args={--kubelet-insecure-tls}

sleep 20

kubectl get pods -n kube-system -l app.kubernetes.io/name=metrics-server
kubectl top nodes || true
kubectl top pods || true
kubectl get apiservice v1beta1.metrics.k8s.io || true
kubectl logs -n kube-system deploy/metrics-server || true

########################################
# VPA Install
########################################

# Create namespace for VPA
kubectl create namespace vpa-system

# Add Helm repository
helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm repo update

# Install VPA into the dedicated namespace
helm install vpa cowboysysop/vertical-pod-autoscaler \
  --namespace vpa-system

# Verify CRDs
kubectl get crd | grep verticalpodautoscaler

# Verify VPA pods
kubectl get pods -n vpa-system | grep vpa

# Verify admission webhook
kubectl get mutatingwebhookconfigurations | grep vpa

# Verify webhook service and endpoints
kubectl get svc -n vpa-system | grep vpa
kubectl get endpoints -n vpa-system | grep vpa



########################################
# Question 1 – Prerequisite (Kustomize)
########################################

rm -rf prereq1
mkdir -p prereq1

# Patch MUST reference:
# - base Deployment name (before namePrefix)
# - base container name
cat <<'EOF' > prereq1/patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test
spec:
  template:
    spec:
      containers:
      - name: test
        command:
        - /bin/sh
        - -c
        - sleep 3600
        resources:
          requests:
            cpu: 100m
            memory: 45Mi
          limits:
            cpu: 200m
            memory: 100Mi
EOF

# namePrefix creates a NEW Deployment derived from base
# patch target ALWAYS matches base name (not prefixed name)
cat <<'EOF' > prereq1/kustomization.yaml
resources:
- ../../base

namePrefix: mem-hpa

patches:
- target:
    kind: Deployment
    name: test
  path: patch.yaml
EOF

kubectl apply -k prereq1/


########################################
# Question 1 – Alternative Methods
########################################

# Method 2 – Live patch
kubectl create deployment mem-hpa --image=polinux/stress || true

kubectl set resources deployment mem-hpa \
  --requests=cpu=100m,memory=45Mi \
  --limits=cpu=200m,memory=100Mi

kubectl patch deployment mem-hpa --patch '
spec:
  template:
    spec:
      containers:
      - name: mem-hpa-
        command:
        - /bin/sh
        - -c
        - sleep 3600
'

# Method 3 – Single-shot YAML generation
kubectl create deployment mem-hpa \
  --image=polinux/stress \
  --dry-run=client -o yaml \
| sed '/image:/a\
        command:\n\
        - /bin/sh\n\
        - -c\n\
        - sleep 3600\n\
        resources:\n\
          requests:\n\
            cpu: 100m\n\
            memory: 45Mi\n\
          limits:\n\
            cpu: 200m\n\
            memory: 100Mi' \
> prereq1.yaml

kubectl apply -f prereq1.yaml

# Method 4 – JSON patch (live object)
kubectl create deployment mem-hpa --image=polinux/stress || true

kubectl patch deployment mem-hpa \
  --type=json \
  -p='[
    {
      "op": "add",
      "path": "/spec/template/spec/containers/0/resources",
      "value": {
        "requests": {
          "cpu": "100m",
          "memory": "45Mi"
        },
        "limits": {
          "cpu": "200m",
          "memory": "100Mi"
        }
      }
    },
    {
      "op": "add",
      "path": "/spec/template/spec/containers/0/command",
      "value": ["/bin/sh", "-c", "sleep 3600"]
    }
  ]'

########################################
# Solution & Validation
########################################

kubectl top nodes || true
kubectl top pods || true

kubectl apply -f sol1.yaml

kubectl exec deploy/mem-hpa-test -it -- stress \
  --vm 1 \
  --vm-bytes 250M \
  --timeout 600 || true

########################################
# Cleanup
########################################

if [ -d "prereq1" ]; then
  kubectl delete -k prereq1/ \
    --grace-period=10 \
    --ignore-not-found
fi

if [ -f "prereq1.yaml" ] || [ -f "sol1.yaml" ]; then
  kubectl delete \
    $( [ -f "prereq1.yaml" ] && echo "-f prereq1.yaml" ) \
    $( [ -f "sol1.yaml" ] && echo "-f sol1.yaml" ) \
    --grace-period=10 \
    --ignore-not-found
fi

# rm -rf prereq1
# rm prereq1.yaml sol1.yaml
########################################
# Question 2 – Prerequisite
########################################

rm -rf prereq2
mkdir -p prereq2

# Patch MUST reference:
# - base Deployment name (before namePrefix)
# - base container name
cat <<'EOF' > prereq2/patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test
spec:
  template:
    spec:
      containers:
      - name: test
        command:
        - /bin/sh
        - -c
        - sleep 3600
        resources:
          requests:
            cpu: 30m
            memory: 30Mi
          limits:
            cpu: 200m
            memory: 100Mi
EOF

# namePrefix creates a NEW Deployment derived from base
# patch target ALWAYS matches base name (not prefixed name)
cat <<'EOF' > prereq2/kustomization.yaml
resources:
- ../../base

namePrefix: multi-hpa-

patches:
- target:
    kind: Deployment
    name: test
  path: patch.yaml
EOF

kubectl apply -k prereq2/

########################################
# Solution & Validation ( Question 2 )
########################################

kubectl top nodes || true
kubectl top pods || true

kubectl apply -f sol2.yaml

POD=$(kubectl get pods -l app=multi-hpa-test -o name | shuf -n 1) && \
echo "Running stress in: $POD" && \
kubectl exec "$POD" -- sh -c \
'nohup stress --cpu 2 --vm 1 --vm-bytes 180Mi --timeout 600 > /dev/null 2>&1 &'


watch -n 5 '
kubectl top po;
echo "-----";
kubectl get po -l app=test
'

########################################
# Cleanup ( Question 2)
########################################

if [ -d "prereq2" ]; then
  kubectl delete -k prereq2/ \
    --grace-period=10 \
    --ignore-not-found
fi

if [ -f "prereq2.yaml" ] || [ -f "sol1.yaml" ]; then
  kubectl delete \
    $( [ -f "prereq2.yaml" ] && echo "-f prereq2.yaml" ) \
    $( [ -f "sol1.yaml" ] && echo "-f sol2.yaml" ) \
    --grace-period=10 \
    --ignore-not-found
fi

# rm -rf prereq2
# rm prereq2.yaml sol2.yaml

########################################
# Question 3 – Prerequisite
########################################

rm -rf prereq3
mkdir -p prereq3

# Patch MUST reference:
# - base Deployment name (before namePrefix)
# - base container name
cat <<'EOF' > prereq3/patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test
spec:
  template:
    spec:
      containers:
      - name: test
        command:
        - /bin/sh
        - -c
        - sleep 3600
        resources:
          requests:
            cpu: 30m
            memory: 30Mi
          limits:
            cpu: 200m
            memory: 100Mi
EOF

# namePrefix creates a NEW Deployment derived from base
# patch target ALWAYS matches base name (not prefixed name)
cat <<'EOF' > prereq3/kustomization.yaml
resources:
- ../../base

namePrefix: vpa-off-

patches:
- target:
    kind: Deployment
    name: test
  path: patch.yaml
EOF

kubectl apply -k prereq3/

########################################
# Solution & Validation ( Question 2 )
########################################

kubectl top nodes || true
kubectl top pods || true

kubectl apply -f sol3.yaml

POD=$(kubectl get pods -l app=multi-hpa -o name | shuf -n 1) && \
echo "Running stress in: $POD" && \
kubectl exec "$POD" -- sh -c \
'nohup stress --cpu 2 --vm 1 --vm-bytes 180Mi --timeout 600 > /dev/null 2>&1 &'


kubectl describe vpa vpa-off


########################################
# Cleanup ( Question 2)
########################################

if [ -d "prereq3" ]; then
  kubectl delete -k prereq3/ \
    --grace-period=10 \
    --ignore-not-found
fi

if [ -f "prereq3.yaml" ] || [ -f "sol1.yaml" ]; then
  kubectl delete \
    $( [ -f "prereq3.yaml" ] && echo "-f prereq3.yaml" ) \
    $( [ -f "sol1.yaml" ] && echo "-f sol2.yaml" ) \
    --grace-period=10 \
    --ignore-not-found
fi

# rm -rf prereq3
# rm prereq3.yaml sol2.yaml


########################################
# Mega Cleanup
########################################
kind delete cluster --name session01 || true
cd /mnt/c/Users/VikashKumar/Desktop/dev3/ops/kubequest/solutions/01-autoscaling/session01
SOL="sol.yaml"

########################################
# MERGE: sol<N>.yaml → sol.yaml
########################################

echo "" > "$SOL"

found=false
for f in sol[0-9]*.yaml; do
  if [ -f "$f" ]; then
    found=true
    cat "$f" >> "$SOL"
    echo -e "\n---" >> "$SOL"
    echo "" > "$f"
  fi
done

if [ "$found" = true ]; then
  head -n -1 "$SOL" > "${SOL}.tmp" && mv "${SOL}.tmp" "$SOL"
else
  echo "No sol<N>.yaml files found"
  exit 1
fi

########################################
# RESTORE: sol.yaml → sol<N>.yaml
########################################

SOL=sol.yaml

i=1
echo "" > "sol${i}.yaml"

while IFS= read -r line || [ -n "$line" ]; do
  if [ "$line" = "---" ]; then
    i=$((i+1))
    echo "" > "sol${i}.yaml"
  else
    echo "$line" >> "sol${i}.yaml"
  fi
done < sol.yaml

: > sol.yaml


echo "" > "$SOL"

