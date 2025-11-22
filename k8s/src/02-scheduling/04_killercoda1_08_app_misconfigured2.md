The issue is **only** the `nodeName: staging-prod1` field. It bypasses the scheduler and forces the pod to that specific node.

**The fix is simple: remove the `nodeName` field entirely.**

This allows the Kubernetes scheduler to do its job and place the pod on any suitable node, instead of always trying to force it onto the non-existent or unavailable `staging-prod1` node.

No other changes are needed. The deployment will work correctly once this hardcoded node assignment is removed.