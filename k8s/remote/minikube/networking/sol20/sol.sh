#!/usr/bin/env bash
set -euo pipefail

DR="--dry-run=client -o yaml | kubectl apply -f -"

eval "kubectl create ns world $DR"
eval "kubectl create deploy europe --image=hashicorp/http-echo $DR"
eval "kubectl create deploy asia --image=hashicorp/http-echo $DR"

kubectl -n world patch deploy europe --type='json' --patch='
[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args",
    "value": ["-text", "hello, you reached EUROPE", "-listen", ":80"]
  }
]
'

kubectl -n world patch deploy asia --type='json' --patch='
[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args",
    "value": ["-text", "hello, you reached ASIA", "-listen", ":80"]
  }
]
'

eval "kubectl -n world expose deploy europe --name=europe --port=80 --target-port=80 --type=ClusterIP $DR"
eval "kubectl -n world expose deploy asia --name=asia --port=80 --target-port=80 --type=ClusterIP $DR"

