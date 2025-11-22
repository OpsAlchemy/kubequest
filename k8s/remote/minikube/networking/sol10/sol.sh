#!/usr/bin/env bash
set -euo pipefail

K=kubectl
NS="${1:-playground}"
IMAGE=hashicorp/http-echo
PORT=5678

$K get ns "$NS" >/dev/null 2>&1 || $K create ns "$NS"

$K create deployment web-v1 --image="$IMAGE" --dry-run=client -o yaml | $K apply -n "$NS" -f -
$K create deployment web-v2  --image="$IMAGE" --dry-run=client -o yaml | $K apply -n "$NS" -f -

for d in web-v1 web-v2; do
  until $K get deploy "$d" -n "$NS" >/dev/null 2>&1; do sleep 1; done
done

if ! $K patch deployment web-v1 -n "$NS" --type='json' -p='[{"op":"replace","path":"/spec/template/spec/containers/0/args","value":["-text","Hello from web-v1"]}]' 2>/dev/null; then
  $K patch deployment web-v1 -n "$NS" --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args","value":["-text","Hello from web-v1"]}]'
fi

if ! $K patch deployment web-v2 -n "$NS" --type='json' -p='[{"op":"replace","path":"/spec/template/spec/containers/0/args","value":["-text","Hello from web-v2"]}]' 2>/dev/null; then
  $K patch deployment web-v2 -n "$NS" --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args","value":["-text","Hello from web-v2"]}]'
fi

$K expose deployment web-v1 --name=web-v1-svc --port=80 --target-port="$PORT" --type=ClusterIP --dry-run=client -o yaml | $K apply -n "$NS" -f -
$K expose deployment web-v2  --name=web-v2-svc  --port=80 --target-port="$PORT" --type=ClusterIP --dry-run=client -o yaml | $K apply -n "$NS" -f -

$K rollout status deployment/web-v1 -n "$NS"
$K rollout status deployment/web-v2 -n "$NS"

$K get deploy,svc -n "$NS" -o wide


