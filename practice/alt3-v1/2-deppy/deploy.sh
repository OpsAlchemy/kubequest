k create deploy deppy --image=nginx --dry-run=client -o yaml  > deploy.yaml
k create svc nodeport deepysvc --tcp=80:80 --dry-run=client -o yaml > svc.yaml
