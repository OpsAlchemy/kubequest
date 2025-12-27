{{ define "microservice.pod" }}
{{ $base := .base }}
{{ $pod := .pod }}
{{ $podShortName := .podShortName }}
{{- $microserviceFullName := include "microservice.fullname" $base -}}
{{ $podName := printf "%s-%s" $microserviceFullName $podShortName }}
{{- $microserviceExtraLabels := include "microservice.extraLabels" $base -}}
{{- $microserviceLabels := include "microservice.labels" $base -}}
apiVersion: v1
kind: Pod
metadata:
  name: {{ $podName }}
  namespace: {{ $base.Release.Namespace }}
  labels: {{ $microserviceExtraLabels | nindent 4 }}{{ $microserviceLabels | nindent 4 }}
    app.kubernetes.io/component: {{ $podShortName }}
  {{- with $pod.annotations }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{ include "microservice.pod.spec" (dict "base" $base "pod" $pod "podName" $podName "podShortName" $podShortName ) | nindent 2}}
---
{{ end }}