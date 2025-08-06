#!/bin/bash

# kubectl taint nodes node-name color=blue:<taint-effect>

# taint-effect = ["NoSchedule", "PreferNoSchedule", "NoExecute"]

kubectl taint nodes aks-application-41219774-vmss000001 app=blue:NoSchedule
kubectl get node aks-application-41219774-vmss000001 -o json | jq '.spec.taints'
