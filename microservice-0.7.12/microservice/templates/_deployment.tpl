{{ define "microservice.deployment" }}
{{ $base := .base }}
{{ $deployment := .deployment }}
{{ $deploymentShortName := .deploymentShortName }}
{{- $microserviceFullName := include "microservice.fullname" $base -}}
{{ $deploymentName := printf "%s-%s" $microserviceFullName $deploymentShortName }}
{{- $microserviceExtraLabels := include "microservice.extraLabels" $base -}}
{{- $microserviceLabels := include "microservice.labels" $base -}}

apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $deploymentName }}{{ if $base.Values.service.canary }}-canary-{{ $base.Values.service.canary }}{{end}}
  namespace: {{ $base.Release.Namespace }}
  labels: {{ $microserviceExtraLabels | nindent 4 }}{{ if $base.Values.service.canary }}
    app.cryptexlabs.com/canary:{{ $base.Values.service.canary }}{{ end }}{{ $microserviceLabels | nindent 4 }}
    app.kubernetes.io/component: {{ $deploymentShortName }}
  {{- with $deployment.annotations }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  selector:
    matchLabels: {{ $microserviceLabels | nindent 6 }}{{ if $base.Values.service.canary }}
      app.cryptexlabs.com/canary:{{ $base.Values.service.canary }}{{ end }}
      app.kubernetes.io/component: {{ $deploymentShortName }}
  replicas: {{ if $base.Values.service.canary}}{{$base.Values.service.canaryReplicas}}{{else}}{{if $deployment.autoscaling.replicas}}{{ $deployment.autoscaling.replicas.min }}{{else}}{{ "1" }}{{end}}{{end}}
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: "{{ $deployment.maxSurge | default "25%"  }}"
      maxUnavailable: "{{ $deployment.maxUnavailable | default "25%"  }}"
  template:
    metadata:
      labels: {{ $microserviceExtraLabels | nindent 8 }}{{ $microserviceLabels | nindent 8 }}{{ if $base.Values.service.canary }}
        app.cryptexlabs.com/canary:{{ $base.Values.service.canary }}{{ end }}
        app.kubernetes.io/component: {{ $deploymentShortName }}
    {{- with $deployment.annotations }}
      annotations: {{- toYaml . | nindent 8 }}
    {{- end }}
    spec:
    {{ include "microservice.pod.spec" (dict "base" $base "pod" $deployment "podName" $deploymentName "podShortName" $deploymentShortName) | nindent 6}}
---
{{ end }}