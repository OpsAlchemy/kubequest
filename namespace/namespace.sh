#!/bin/bash

kaf <something>.yaml --namespace=dev

kubectl config set-context $(kubectl config current-context) --namespace=dev
