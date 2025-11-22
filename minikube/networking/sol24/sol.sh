#!/usr/bin/bash

kubectl create deploy api --image hashicorp/http-echo --dry-run=client -o yaml | kubectl apply -f -
kubectl create deploy ui --image hashicorp/http-echo --dry-run=client -o yaml | kubectl apply -f -

kubectl patch deploy api --type='json' --patch='
  [
    {
      "op":"add","path":"/spec/template/spec/containers/0/args","value":["-text","API Response","-listen",":80"]
    }
  ]	
'

kubectl patch deploy ui --type='json' --patch='
  [
    {
      "op":"add","path":"/spec/template/spec/containers/0/args","value":["-text","UI Response","-listen",":80"]
    }
  ]
'

kubectl expose deploy/api --port=80 --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deploy/ui --port=80 --dry-run=client -o yaml | kubectl apply -f -

