#!/usr/bin/env bash
set -euo pipefail

DR="--dry-run=client -o yaml | kubectl apply -f -"

eval "kubectl create ns world $DR"
eval "kubectl create deploy red-app --image=hashicorp/http-echo $DR"
eval "kubectl create deploy blue-app --image=hashicorp/http-echo $DR"

kubectl -n world patch deploy red-app --type='json' --patch='
[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args",
    "value": ["-text", "This is red app", "-listen", ":80"]
  }
]
'

kubectl -n world patch deploy blue-app --type='json' --patch='
[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args",
    "value": ["-text", "hello, this is blue app", "-listen", ":80"]
  }
]
'

eval "kubectl -n world expose deploy red-app --name=red-svc --port=80 --target-port=80 --type=ClusterIP $DR"
eval "kubectl -n world expose deploy blue-app --name=blue-svc --port=80 --target-port=80 --type=ClusterIP $DR"

