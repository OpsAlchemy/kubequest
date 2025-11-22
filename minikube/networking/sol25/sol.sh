#!/usr/bin/bash

kubectl create deploy web-v1 --image hashicorp/http-echo --dry-run=client -o yaml | kubectl apply -f -
kubectl create deploy web-v2 --image hashicorp/http-echo --dry-run=client -o yaml | kubectl apply -f -

kubectl patch deploy web-v1 --type='json' --patch='
  [
    {
      "op":"add","path":"/spec/template/spec/containers/0/args","value":["-text","Web V1 Response","-listen",":80"]
    }
  ]	
'

kubectl patch deploy web-v2 --type='json' --patch='
  [
    {
      "op":"add","path":"/spec/template/spec/containers/0/args","value":["-text","Web V2 Response","-listen",":80"]
    }
  ]
'

kubectl expose deploy/web-v1 --port=80 --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deploy/web-v2 --port=80 --dry-run=client -o yaml | kubectl apply -f -

