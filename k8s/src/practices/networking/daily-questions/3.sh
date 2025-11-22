#!/usr/bin/env bash
set -euo pipefail

K=kubectl
NS="${1:-playground}"
IMAGE=hashicorp/http-echo
PORT=5678

$K get ns "$NS" >/dev/null 2>&1 || $K create ns "$NS"

$K create deployment api-deploy --image="$IMAGE" --dry-run=client -o yaml | $K apply -n "$NS" -f -
$K create deployment ui-deploy  --image="$IMAGE" --dry-run=client -o yaml | $K apply -n "$NS" -f -

for d in api-deploy ui-deploy; do
  until $K get deploy "$d" -n "$NS" >/dev/null 2>&1; do sleep 1; done
done

if ! $K patch deployment api-deploy -n "$NS" --type='json' -p='[{"op":"replace","path":"/spec/template/spec/containers/0/args","value":["-text","Hello from api"]}]' 2>/dev/null; then
  $K patch deployment api-deploy -n "$NS" --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args","value":["-text","Hello from api"]}]'
fi

if ! $K patch deployment ui-deploy -n "$NS" --type='json' -p='[{"op":"replace","path":"/spec/template/spec/containers/0/args","value":["-text","Hello from ui"]}]' 2>/dev/null; then
  $K patch deployment ui-deploy -n "$NS" --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args","value":["-text","Hello from ui"]}]'
fi

$K expose deployment api-deploy --name=api-svc --port="$PORT" --target-port="$PORT" --type=ClusterIP --dry-run=client -o yaml | $K apply -n "$NS" -f -
$K expose deployment ui-deploy  --name=ui-svc  --port="$PORT" --target-port="$PORT" --type=ClusterIP --dry-run=client -o yaml | $K apply -n "$NS" -f -

$K rollout status deployment/api-deploy -n "$NS"
$K rollout status deployment/ui-deploy -n "$NS"

$K get deploy,svc -n "$NS" -o wide

$K create ing multi-app-ingress --class=nginx --rule=ui.api.com/api*=api-svc:5678 --rule=ui.api.com/ui*=ui-svc:5678 --dry-run=client -o yaml | $K -n "$NS" apply -f -

