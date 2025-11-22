kubectl -n playground delete ingress multi-app-ingress --ignore-not-found
kubectl -n playground delete svc api-svc ui-svc --ignore-not-found
kubectl -n playground delete deployment api-deploy ui-deploy --ignore-not-found

