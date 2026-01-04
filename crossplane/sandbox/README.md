# Crossplane + LocalStack Sandbox

A minimal, production-ready setup for experimenting with Crossplane managing AWS resources via LocalStack.

**Three simple steps:**
1. Create a kind cluster
2. Start LocalStack 
3. Deploy Crossplane with LocalStack endpoint

**Then:** Apply an S3 bucket managed by Crossplane and watch it appear in LocalStack.

---

## Quick start

### 1. Create kind cluster

```bash
cd /mnt/c/Users/VikashKumar/Desktop/dev3/ops/kubequest/crossplane/sandbox

cat > kind-multinode.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

networking:
  ipFamily: ipv4
  kubeProxyMode: iptables

nodes:
- role: control-plane
- role: worker
EOF

kind create cluster --name=crossplane --config=kind-multinode.yaml --image kindest/node:v1.34.0
kubectl cluster-info --context kind-crossplane
```

> **Note for WSL users:** If you encounter networking issues, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for solutions.

### 2. Start LocalStack

```bash
cd localstack
docker compose up -d
curl http://localhost:4566/_localstack/health
```

See [localstack/README.md](../../localstack/README.md) for full LocalStack documentation.

### 3. Install Crossplane

```bash
kubectl create namespace crossplane-system
kubectl apply -f https://raw.githubusercontent.com/crossplane/crossplane/release-*/install.yaml
kubectl -n crossplane-system wait --for=condition=ready pod -l app.kubernetes.io/name=crossplane --timeout=300s
```

### 4. Install AWS provider

```bash
kubectl apply -f - <<EOF
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws
spec:
  package: crossplane/provider-aws:v0.39.0
EOF

kubectl -n crossplane-system wait --for=condition=Installed pkg provider-aws --timeout=300s
```

### 5. Apply secret + ProviderConfig

```bash
# Secret with LocalStack credentials
kubectl apply -f manifests/localstack-secret.yaml -n crossplane-system

# ProviderConfig with LocalStack endpoint
kubectl apply -f manifests/providerconfig-localstack.yaml
```

### 6. Deploy S3 bucket (managed by Crossplane)

```bash
kubectl apply -f manifests/s3-bucket.yaml

# Watch it sync
kubectl get buckets -A -w
kubectl describe bucket demo-bucket
```

### 7. Verify in LocalStack

```bash
# Check LocalStack has the bucket
curl http://localhost:4566/_localstack/health
aws --endpoint-url=http://localhost:4566 s3 ls

# Crossplane status
kubectl get buckets -A
kubectl describe bucket demo-bucket
```

---

## Files

- **manifests/localstack-secret.yaml** — AWS credentials for LocalStack
- **manifests/providerconfig-localstack.yaml** — ProviderConfig with endpoint URL
- **manifests/s3-bucket.yaml** — Example S3 bucket managed by Crossplane
- **docs/README.md** — Troubleshooting and advanced topics

---

## Cleanup

```bash
kubectl delete -f manifests/s3-bucket.yaml
cd localstack && docker compose down
kind delete cluster --name crossplane
```

---

**Next:** See `docs/README.md` for endpoint config, networking, and adding more resources (SQS, DynamoDB, etc.)
