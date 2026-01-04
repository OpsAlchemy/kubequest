# Crossplane + LocalStack Sandbox

A minimal, production-ready setup for experimenting with Crossplane managing AWS resources via LocalStack.

**Three simple steps:**
1. Create a kind cluster
2. Start LocalStack 
3. Deploy Crossplane with LocalStack endpoint

**Then:** Apply AWS resources (S3 bucket, EC2 instance) managed by Crossplane and watch them appear in LocalStack.

---

## Quick start

### 1. Create kind cluster

```bash
cd /home/vagabond/peak/kubequest/crossplane/sandbox

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

helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update

helm install crossplane --namespace crossplane-system crossplane-stable/crossplane

kubectl -n crossplane-system get pods
```

### 4. Install AWS provider

```bash
kubectl apply -f - <<EOF
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws
spec:
  package: xpkg.upbound.io/crossplane-contrib/provider-aws:v0.55.0
EOF

kubectl wait \
  --for=condition=Installed \
  provider.pkg.crossplane.io/provider-aws \
  --timeout=300s
```

### 5. Apply secret + ProviderConfig

```bash
# Secret with LocalStack credentials
kubectl apply -f manifests/localstack-secret.yaml -n crossplane-system

# ProviderConfig with LocalStack endpoint
kubectl apply -f manifests/providerconfig-localstack.yaml
```

```bash
kubectl get providers.pkg.crossplane.io
kubectl get providerrevisions.pkg.crossplane.io
```

### 6. Deploy S3 bucket (managed by Crossplane)

```bash
kubectl apply -f manifests/s3-bucket.yaml

# Watch it sync
kubectl get buckets -A -w
kubectl describe bucket localstack-crossplane-bucket
```

### 7. Verify in LocalStack

```bash
# Check S3 bucket
curl http://localhost:4566/_localstack/health
aws --endpoint-url=http://localhost:4566 s3 ls

# Check EC2 instances
aws --endpoint-url=http://localhost:4566 ec2 describe-instances

# Crossplane resource status
kubectl get buckets -A
kubectl get instances -A
```

---

## Files

- **manifests/localstack-secret.yaml** — AWS credentials for LocalStack
- **manifests/providerconfig-localstack.yaml** — ProviderConfig with endpoint URL
- **manifests/s3-bucket.yaml** — S3 bucket managed by Crossplane
- **manifests/ec2.yaml** — EC2 instance managed by Crossplane
- **manifests/secretsmanager.yaml** — Secrets Manager resource (optional)
- **docs/README.md** — Troubleshooting and advanced topics

---

## Cleanup

```bash
# Delete all Crossplane-managed resources
kubectl delete -f manifests/s3-bucket.yaml
kubectl delete -f manifests/ec2.yaml
kubectl delete -f manifests/secretsmanager.yaml

# Stop LocalStack
cd localstack && docker compose down

# Delete kind cluster
kind delete cluster --name crossplane
```

---

## Testing S3 Bucket with LocalStack

After deploying the S3 bucket via Crossplane, you can test it with the AWS CLI:

```bash
# Set LocalStack credentials
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-west-2
export AWS_EC2_METADATA_DISABLED=true

# Verify bucket exists
aws --endpoint-url=http://localhost:4566 s3 ls
aws --endpoint-url=http://localhost:4566 s3api head-bucket \
  --bucket localstack-crossplane-bucket

# Get bucket encryption and access block settings
aws --endpoint-url=http://localhost:4566 s3api get-bucket-encryption \
  --bucket localstack-crossplane-bucket
aws --endpoint-url=http://localhost:4566 s3api get-public-access-block \
  --bucket localstack-crossplane-bucket

# Upload a test file
echo "hello from crossplane" > /tmp/test.txt
aws --endpoint-url=http://localhost:4566 s3 cp /tmp/test.txt \
  s3://localstack-crossplane-bucket/test.txt

# Download and verify
aws --endpoint-url=http://localhost:4566 s3 cp \
  s3://localstack-crossplane-bucket/test.txt -

# Clean up the test file
aws --endpoint-url=http://localhost:4566 s3 rm \
  s3://localstack-crossplane-bucket/test.txt
```

---

## Verify LocalStack Status

```bash
# Health check
curl http://localhost:4566/_localstack/health

# Get caller identity (verify AWS credentials work)
aws --endpoint-url=http://localhost:4566 sts get-caller-identity
```

---

## Next Steps

**Next:** See `docs/README.md` for endpoint config, networking, and adding more resources (SQS, DynamoDB, etc.)
