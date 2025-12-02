#!/usr/bin/env bash
set -euo pipefail

K="kubectl"
DR="--dry-run=client -o yaml | ${K} apply -f -"

eval "${K} create deploy frontend --image=hashicorp/http-echo --replicas 2 ${DR}"
eval "${K} create deploy backend --image=hashicorp/http-echo  --replicas 2 ${DR}"
eval "${K} create deploy database --image=hashicorp/http-echo --replicas 2 ${DR}"

eval "${K} label deploy frontend app=acme tier=frontend --overwrite"
eval "${K} label deploy backend app=acme tier=backend --overwrite"
eval "${K} label deploy database app=acme tier=database --overwrite"

${K} patch deploy frontend --type='json' --patch='[ { "op": "add", "path": "/spec/template/spec/containers/0/args", "value": ["-text", "This is frontend", "-listen", ":80"] } ]'

${K} patch deploy backend --type='json' --patch='[ { "op": "add", "path": "/spec/template/spec/containers/0/args", "value": ["-text", "This is backend", "-listen", ":80"] } ]'

${K} patch deploy database --type='json' --patch='[ { "op": "add", "path": "/spec/template/spec/containers/0/args", "value": ["-text", "This is database", "-listen", ":80"] } ]'

eval "${K} expose deploy frontend --port=80 --target-port=5678 --name=frontend ${DR}"
eval "${K} expose deploy backend --port=80 --target-port=5678 --name=backend ${DR}"
eval "${K} expose deploy database --port=80 --target-port=5678 --name=database ${DR}"

${K} get deploy frontend -o yaml | sed -n '1,200p'

