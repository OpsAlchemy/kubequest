## Practice Question 3: Build a Scalable Web Application Chart - Progressive Complexity

**Chart Name:** `scalable-web-app`

**Philosophy:** One chart. One application. Progressively add features, making it production-ready step by step.

---

---

## Phase 1: Basic Deployment

**Objective:** Create a simple Deployment with basic pod specifications.

### What You Have
- Application image: `scalable-web-app:latest`
- Need to deploy to Kubernetes

### What You Build
Create chart structure with:
- `templates/deployment.yaml` - simple Deployment with 1 replica
- `values.yaml` - image, tag, port configuration
- `Chart.yaml` with metadata
- `templates/service.yaml` - ClusterIP service for internal access

### Requirements
- Deployment creates 1 Pod running the application
- Service exposes the app internally
- `helm template` produces valid YAML
- `helm install` deploys successfully

### Validation
```bash
helm template scalable-web-app . | kubectl apply -f -
kubectl get deployment
kubectl get pods
kubectl port-forward svc/scalable-web-app 8080:8080
# Test: curl http://localhost:8080
```

---

## Phase 2: Configuration Management

**Objective:** Add ConfigMap for application configuration (not hardcoded).

### Current State
- Phase 1 is working (basic deployment)

### What You Add
- `templates/configmap.yaml` - application configuration file
- Update `values.yaml` with `config` section containing app settings
- Update `templates/deployment.yaml` to mount the ConfigMap as a volume
- Create `_helpers.tpl` for reusable template snippets

### Requirements
- ConfigMap contains application configuration (key-value pairs)
- Deployment mounts ConfigMap as a volume at `/etc/config`
- Application reads configuration from mounted file
- Configuration changes update ConfigMap without redeploying pod
- Helm values override default configuration

### Validation
```bash
# Check ConfigMap is created
kubectl get configmap

# Verify mount
kubectl exec <pod-name> -- cat /etc/config

# Update config and reinstall
helm upgrade scalable-web-app .
kubectl get configmap -o yaml
```

---

## Phase 3: Multi-Environment Support

**Objective:** Support different configurations for dev, staging, prod.

### Current State
- Phase 2 is working (configuration management)

### What You Add
- Create `values-dev.yaml`, `values-staging.yaml`, `values-prod.yaml`
- Each file overrides resource limits, replicas, etc.
- Update `values.yaml` with environment-specific sections
- Add conditional logic in templates to validate correct environment selected

### Requirements
- `helm install -f values-dev.yaml` deploys dev version (1 replica, small resources)
- `helm install -f values-prod.yaml` deploys prod version (3+ replicas, large resources)
- Cannot accidentally mix configurations
- Different storage classes per environment
- Different ingress rules per environment
- Chart validates that only one environment is selected

### Validation
```bash
# Deploy to dev
helm install scalable-web-app . -f values-dev.yaml
kubectl get deployment,configmap

# Verify: 1 replica, small resources
kubectl get deployment -o yaml | grep replicas

# Deploy to prod (different release)
helm install scalable-web-app-prod . -f values-prod.yaml

# Verify: 3+ replicas, large resources
kubectl get deployment scalable-web-app-prod -o yaml | grep replicas
```

---

## Phase 4: Scaling & Performance (HPA & PDB)

**Objective:** Auto-scale based on metrics and protect disruptions.

### Current State
- Phase 3 is working (multi-environment support)

### What You Add
- `templates/hpa.yaml` - HorizontalPodAutoscaler (scale based on CPU/memory)
- `templates/pdb.yaml` - PodDisruptionBudget (maintain availability during node maintenance)
- Update `values.yaml` with autoscaling config (min/max replicas, metrics)
- Metrics Server must be installed in cluster for HPA to work

### Requirements
- HPA scales between min (2) and max (10) replicas based on CPU usage
- PDB maintains at least 1 Pod available always
- Pods have resource requests/limits defined (required for HPA)
- HPA triggers when CPU exceeds threshold
- Scaling down respects graceful termination period

### Validation
```bash
# Check HPA status
kubectl get hpa
kubectl describe hpa scalable-web-app

# Check PDB
kubectl get pdb

# Simulate load (in separate terminal)
kubectl run -it --rm load-generator --image=busybox -- /bin/sh
# Inside pod: while sleep 0.01; do wget -q -O- http://scalable-web-app:8080; done

# Watch scaling in progress
kubectl get hpa -w
kubectl get pods -w
```

---

## Phase 5: Security Hardening

**Objective:** Apply security best practices (RBAC, SecurityContext, NetworkPolicy).

### Current State
- Phase 4 is working (HPA & PDB)

### What You Add
- `templates/serviceaccount.yaml` - ServiceAccount for the app
- `templates/role.yaml` - RBAC Role with minimal permissions
- `templates/rolebinding.yaml` - Bind role to ServiceAccount
- Update `templates/deployment.yaml` with SecurityContext:
  - Non-root user (runAsUser: 1000)
  - Read-only root filesystem
  - No privileged container
  - Drop unnecessary capabilities
- `templates/networkpolicy.yaml` - Deny all ingress by default, allow from ingress controller only

### Requirements
- Pod runs as non-root user
- Pod cannot write to root filesystem
- Pod has minimal RBAC permissions (only needed APIs)
- NetworkPolicy blocks unauthorized traffic
- No secrets in environment variables (will add later)
- Container cannot escalate privileges

### Validation
```bash
# Verify SecurityContext
kubectl get deployment -o yaml | grep -A 10 securityContext

# Verify ServiceAccount
kubectl get sa

# Verify RBAC
kubectl auth can-i list pods --as=system:serviceaccount:default:scalable-web-app

# Verify NetworkPolicy
kubectl get networkpolicy
kubectl describe networkpolicy scalable-web-app

# Test: Pod cannot execute as root
kubectl exec <pod-name> -- id  # Should show uid=1000
```

---

## Phase 6: Storage & Persistence

**Objective:** Add persistent data storage with PVC.

### Current State
- Phase 5 is working (security)

### What You Add
- `templates/pvc.yaml` - PersistentVolumeClaim for application data
- Update `templates/deployment.yaml` to mount PVC as volume
- Update `values.yaml` with storage size and storage class name
- Add support for different storage classes per environment (dev: hostPath, prod: EBS/Azure Disk)

### Requirements
- PVC is created from appropriate storage class
- Deployment mounts PVC at `/data`
- Application can write to `/data` persistently
- Pod restart doesn't lose data
- Storage size is configurable per environment
- StatefulSet (not Deployment) used if multiple replicas need separate PVCs

### Validation
```bash
# Check PVC
kubectl get pvc
kubectl describe pvc scalable-web-app-data

# Verify mount
kubectl exec <pod-name> -- ls -la /data

# Write test file
kubectl exec <pod-name> -- sh -c "echo 'test' > /data/test.txt"

# Delete pod and verify data persists
kubectl delete pod <pod-name>
# Wait for new pod
kubectl exec <new-pod-name> -- cat /data/test.txt  # Should show "test"
```

---

## Phase 7: Networking & Exposure (Service, Ingress)

**Objective:** Expose app to external traffic securely.

### Current State
- Phase 6 is working (storage)

### What You Add
- Update `templates/service.yaml` to type: LoadBalancer (or NodePort for dev)
- `templates/ingress.yaml` - expose app via Ingress with:
  - TLS/HTTPS configuration (self-signed cert for dev, real cert for prod)
  - Path-based routing
  - Host-based routing (environment-specific domains)
  - Authentication/authorization (basic auth for dev, OAuth for prod)
- Update `values.yaml` with ingress domain, TLS cert config

### Requirements
- Service exposes pod on port 8080
- Ingress exposes app on domain (ingress-class: nginx)
- HTTPS/TLS works with proper certificate
- Traffic routing works to correct pod
- Different ingress configs for dev vs prod (TLS required only in prod)

### Validation
```bash
# Check Service
kubectl get svc
kubectl describe svc scalable-web-app

# Check Ingress
kubectl get ingress
kubectl describe ingress scalable-web-app

# Test routing (if minikube/local cluster)
curl http://scalable-web-app.example.com  # Should route to pod
curl -k https://scalable-web-app.example.com  # Should work with TLS

# Verify certificate
kubectl get ingress -o yaml | grep cert
```

---

## Phase 8: Observability (Prometheus & Logging)

**Objective:** Collect metrics and logs for monitoring.

### Current State
- Phase 7 is working (networking)

### What You Add
- `templates/servicemonitor.yaml` - Prometheus ServiceMonitor for metrics scraping
- Update `templates/deployment.yaml` to expose `/metrics` endpoint (port 9090)
- Structured logging configuration (JSON format logs)
- Update `values.yaml` with observability config (enable metrics, log level)
- `templates/prometheusrule.yaml` - Alert rules for SLA violations
- Dashboard definition (as ConfigMap) for Grafana

### Requirements
- Pod exposes Prometheus metrics on `/metrics` port 9090
- ServiceMonitor tells Prometheus where to scrape metrics
- Application logs are in JSON format (structured)
- Logs include request ID for tracing
- Alert rules fire when:
  - Pod restarts frequently (>3 restarts/hour)
  - Error rate exceeds 5%
  - Response time exceeds SLA (e.g., 500ms p99)
- Metrics show: request count, latency, errors, resource usage

### Validation
```bash
# Check ServiceMonitor
kubectl get servicemonitor

# Verify metrics endpoint
kubectl port-forward <pod-name> 9090:9090
curl http://localhost:9090/metrics | grep requests_total

# Check logs
kubectl logs <pod-name>  # Should be JSON formatted

# If Prometheus running, check scrape config
kubectl exec -it prometheus-pod -c prometheus -- cat /etc/prometheus/prometheus.yml

# Check alerts are defined
kubectl get prometheusrule
kubectl describe prometheusrule scalable-web-app
```

---

## Phase 9: Deployment Strategies

**Objective:** Safely roll out updates with zero downtime.

### Current State
- Phase 8 is working (observability)

### What You Add
- Multiple deployment strategies as values option:
  - **Rolling Update** (default): gradual pod replacement with maxSurge/maxUnavailable
  - **Blue-Green**: two deployments, instant traffic switch
  - **Canary**: gradual traffic shift to new version (requires ServiceMesh or Ingress rules)
- Add pre-upgrade job to backup data
- Add post-upgrade job to verify deployment health
- Update `values.yaml` to select strategy

### Requirements
- Rolling update: maxUnavailable=1, maxSurge=1 (always 1-2 pods running)
- Blue-green: create both v1 and v2 deployments, switch service selector
- Canary: gradually route traffic (10% → 50% → 100%) to new version
- Old pods gracefully shutdown (preStop hook, 30s termination grace)
- Automatic rollback if health checks fail
- Zero-downtime upgrades (no traffic loss)

### Validation
```bash
# Simulate deployment update
helm upgrade scalable-web-app . --set image.tag=v2

# Watch rolling update
kubectl rollout status deployment/scalable-web-app
kubectl get pods -w

# Verify zero downtime (in separate terminal, hit endpoint)
while true; do curl http://scalable-web-app:8080; sleep 1; done
# Should see continuous responses, no connection errors

# Rollback if needed
helm rollback scalable-web-app

# Blue-green test
helm install scalable-web-app . --set deploymentStrategy=blue-green --set image.tag=v1
helm upgrade scalable-web-app . --set image.tag=v2
# Verify both deployments exist, traffic switches to v2
```

---

## Phase 10: Production Readiness

**Objective:** Validate chart quality, documentation, and operational readiness.

### Current State
- Phase 9 is working (deployment strategies)

### What You Add
- `values.schema.json` - JSON Schema for values validation
- `NOTES.txt` - deployment instructions and next steps
- `README.md` - comprehensive documentation
  - Architecture overview
  - Installation instructions
  - Configuration reference
  - Troubleshooting guide
  - Performance tuning recommendations
- Chart tests in `templates/tests/` directory
  - Verify pod is running
  - Verify service is accessible
  - Verify ingress works
  - Verify configmap was created
  - Verify metrics endpoint responds
- Update Chart.yaml with proper metadata (description, keywords, maintainers)

### Requirements
- `helm lint` passes without errors/warnings
- `helm template` produces valid YAML for all environments
- `helm install --dry-run --debug` succeeds
- Chart values validate against schema (invalid values rejected)
- All 10 phases are working together cohesively
- Documentation answers: What? How? Why? When to use?
- Tests verify critical functionality automatically
- Chart follows Helm best practices

### Validation
```bash
# Lint chart
helm lint .

# Validate against schema
helm template . | kubectl apply -f - --dry-run=client

# Run tests
helm test scalable-web-app

# Verify all resources created
kubectl get all
kubectl get configmap,pvc,networkpolicy,ingress,servicemonitor

# Check NOTES output
helm install scalable-web-app .
# Should print helpful next steps

# Verify documentation
# README.md should be comprehensive and clear
# values.schema.json should validate all settings

# Final check: can delete and redeploy cleanly
helm uninstall scalable-web-app
helm install scalable-web-app .
```

---

## Progression Summary

| Phase | Focus | Key Concepts |
|-------|-------|--------------|
| 1 | Basics | Deployment, Service, templates |
| 2 | Config | ConfigMap, volumes, helper functions |
| 3 | Environments | values files, conditionals, validation |
| 4 | Scaling | HPA, PDB, resource requests/limits |
| 5 | Security | RBAC, SecurityContext, NetworkPolicy |
| 6 | Storage | PVC, persistent data, StatefulSet |
| 7 | Networking | Ingress, TLS, routing |
| 8 | Observability | Prometheus, ServiceMonitor, alerts |
| 9 | Deployments | Rolling, Blue-Green, Canary strategies |
| 10 | Production | Schema validation, tests, documentation |

---

## What You're Building

By end of Phase 10, you have:

- ✅ Chart that deploys a complete application
- ✅ Multi-environment support (dev/staging/prod)
- ✅ Auto-scaling based on metrics
- ✅ High availability (PDB maintains availability)
- ✅ Persistent storage for application data
- ✅ HTTPS/TLS secured external access
- ✅ Security hardening (RBAC, SecurityContext, NetworkPolicy)
- ✅ Full observability (metrics, alerts, logs)
- ✅ Safe deployment strategies (zero downtime)
- ✅ Production-quality documentation and validation

**Total Implementation Time:** 25-35 hours

---

## Key Helm Concepts You'll Learn

1. **Chart Structure** - metadata, templates, values hierarchy
2. **Templating** - conditionals, loops, range, variables, functions
3. **Helper Functions** - DRY principle, _helpers.tpl, named templates
4. **Values Management** - defaults, overrides, precedence, schema validation
5. **Reusability** - composing complex configs from simple building blocks
6. **Kubernetes Patterns** - RBAC, NetworkPolicy, Deployments, StatefulSets
7. **Observability** - metrics, logging, alerting at chart level
8. **Deployment Strategies** - safe rollouts, health checks, rollbacks
9. **Best Practices** - documentation, testing, linting, security
10. **Advanced Templating** - computed values, dynamic resource generation

---

## Notes

- Each phase depends on previous phases
- You'll iterate and refine as you discover edge cases
- Real-world constraints matter (actual cluster limitations, quotas)
- Documentation is as important as code
- Chart should be idempotent (safe to run multiple times)

Good luck! Build incrementally, test thoroughly, and focus on one feature at a time.
