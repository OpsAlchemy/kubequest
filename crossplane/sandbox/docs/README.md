# Crossplane + LocalStack Troubleshooting

## Endpoint configuration

The ProviderConfig uses `endpoint.url.static: http://host.docker.internal:4566` which works on Docker Desktop (macOS/Windows).

**For Linux:**
- Replace `host.docker.internal` with the host machine IP or `localhost` (if Docker is configured appropriately).
- Example:
  ```yaml
  endpoint:
    url:
      type: Static
      static: http://172.17.0.1:4566  # Linux bridge gateway
  ```

## Verify provider controller is ready

```bash
kubectl -n crossplane-system get pods
kubectl -n crossplane-system logs -l app.kubernetes.io/name=provider-aws-controller -f
```

## Check ProviderConfig

```bash
kubectl get providerconfig
kubectl describe providerconfig localstack
```

## Troubleshoot bucket creation

```bash
# Watch bucket status
kubectl get buckets -A -w

# Describe for errors
kubectl describe bucket demo-bucket

# Check provider controller logs
kubectl -n crossplane-system logs -l app.kubernetes.io/name=provider-aws-controller | grep -i bucket
```

## LocalStack health

```bash
curl http://localhost:4566/_localstack/health
aws --endpoint-url=http://localhost:4566 s3 ls
```

## Common issues

- **"Connection refused"** — LocalStack not running or endpoint URL wrong. Verify `docker compose up -d` in localstack folder.
- **"Unsupported bucket location"** — Some S3 operations require specific regions. Keep region as `us-east-1`.
- **Pod stays in Pending** — Check if kind cluster has enough resources; run `kubectl top nodes` or `kubectl describe node`.

## Adding more resources

Once S3 works, try:
- SQS Queue (s3.aws.crossplane.io/Queue)
- DynamoDB Table (dynamodb.aws.crossplane.io/Table)
- IAM Role (iam.aws.crossplane.io/Role)

Same pattern: add secret, ProviderConfig, resource YAML.
