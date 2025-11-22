# Kube Controller Manager Troubleshooting

## Problem
Custom controller manager image reverted to default, but pod won't start.

## Error
```
Error: unknown flag: --project-sidecar-insertion
```

## Root Cause
Custom flag `--project-sidecar-insertion=true` in manifest is invalid for default image.

## Quick Fix

**1. Check pod status:**
```bash
kubectl get pods -n kube-system
```

**2. Check logs:**
```bash
kubectl logs kube-controller-manager-controlplane
```

**3. Edit manifest:**
```bash
vi /etc/kubernetes/manifests/kube-controller-manager.yaml
```

**4. Remove invalid flag:**
```yaml
# DELETE THIS LINE:
- --project-sidecar-insertion=true
```

**5. Force restart (if needed):**
```bash
cd /etc/kubernetes/manifests
mv kube-controller-manager.yaml ..
sleep 5
mv ../kube-controller-manager.yaml .
```

## Verification
Pod should show `Running` status and `1/1` ready state.

## Alternative Log Locations
- `/var/log/pods/kube-system_kube-controller-manager-controlplane_*/`
- `crictl ps && crictl logs <container-id>`
- `journalctl` for kubelet logs

## Key Points
- Static pods auto-restart when manifests change
- Invalid flags prevent container startup
- Moving manifest out/in forces recreation
- Always verify pod readiness after changes