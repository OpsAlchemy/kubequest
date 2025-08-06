#!/bin/bash

# kubectl label node <node-name> <key>=<value>
kubectl label node aks-system-29192112-vmss000005 size=large
kubectl label node aks-application-41219774-vmss000000 size=small
