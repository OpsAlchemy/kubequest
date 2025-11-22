https://killercoda.com/chadmcrowell/course/cka/change-deployment-image



Here are clean notes from your session, with copy-paste commands.

Create a Deployment

```bash
kubectl create deploy apache --image=httpd:2.4.54 --replicas=3
```

List multiple resource kinds (no space after the comma)

```bash
kubectl get deploy,po
```

Scale a Deployment

```bash
kubectl scale deployment.apps/apache --replicas=5
# short form also works:
kubectl scale deploy/apache --replicas=5
```

Update container image in a Deployment

```bash
# Syntax: kubectl set image TYPE/NAME CONTAINER=IMAGE[:TAG]
kubectl set image deployment.apps/apache httpd=httpd:alpine
# update all containers in a workload (wildcard)
kubectl set image deploy/apache '*=httpd:alpine'
# update by label selector
kubectl set image deploy -l app=apache httpd=httpd:alpine
```

Common pitfalls you hit and the fixes

1. Don’t use a non-existent flag `--image` with `kubectl set image`; instead specify CONTAINER=IMAGE.
2. Resource type must be correct; `deployment` or `deploy`, not `deploymen`.
3. When listing multiple types, don’t put a space after the comma; use `deploy,po`, not `deploy, po`.

Watch the rolling update

```bash
kubectl get pods -w
# or:
kubectl rollout status deploy/apache
```

Verify the image and replica count

```bash
kubectl get deploy/apache -o wide
kubectl describe deploy/apache | grep -i image
kubectl get rs -l app=apache
kubectl get pods -l app=apache -o wide
```

Inspect the full spec after changes

```bash
kubectl get deployments.apps apache -o yaml
```

Rollback and history (useful follow-ups)

```bash
kubectl rollout history deploy/apache
kubectl rollout undo deploy/apache
```

Quick reference syntax cheatsheet

```text
kubectl set image TYPE/NAME CONTAINER=IMAGE[:TAG]
kubectl scale TYPE/NAME --replicas=N
kubectl get TYPE1,TYPE2
kubectl rollout status|history|undo TYPE/NAME
```

If you want, I can turn these into a one-page “kubectl deploy operations” cheat sheet with only the working forms you used here.
 