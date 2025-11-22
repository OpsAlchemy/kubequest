#!/usr/bin/env bash
set -euo pipefail

DR="--dry-run=client -o yaml | kubectl apply -f -"

eval "kubectl create ns world $DR"
eval "kubectl create deploy secure --image=hashicorp/http-echo $DR"

kubectl -n world patch deploy secure --type='json' --patch='
[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args",
    "value": ["-text", "This is Secure Application", "-listen", ":80"]
  }
]
'

eval "kubectl -n world expose deploy secure --name=secure-svc --port=80 --target-port=80 --type=ClusterIP $DR"

