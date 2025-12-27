{{ define "microservice.cron-job" }}
{{ $base := .base }}
{{ $cronJob := .cronJob }}
{{ $cronJobShortName := .cronJobShortName }}
{{- $microserviceFullName := include "microservice.fullname" $base -}}
{{ $podName := printf "%s-%s" $microserviceFullName $cronJobShortName }}
{{- $microserviceExtraLabels := include "microservice.extraLabels" $base -}}
{{- $microserviceLabels := include "microservice.labels" $base -}}
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ $podName }}
  namespace: {{ $base.Release.Namespace }}
  labels: {{ $microserviceExtraLabels | nindent 4 }}{{ $microserviceLabels | nindent 4 }}
    app.kubernetes.io/component: {{ $cronJobShortName }}
  {{- with $cronJob.annotations }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{ if $cronJob.suspend }}
  suspend: true
  {{ end }}
  schedule: "{{ $cronJob.schedule }}"
  {{ if $cronJob.concurrencyPolicy }}
  concurrencyPolicy: {{ $cronJob.concurrencyPolicy }}
  {{ end }}
  jobTemplate:
    spec:
      template:
        metadata:
          labels: {{ $microserviceExtraLabels | nindent 12 }}{{ $microserviceLabels | nindent 12 }}
            app.kubernetes.io/component: {{ $cronJobShortName }}
          {{- with $cronJob.annotations }}
          annotations: {{- toYaml . | nindent 12 }}
          {{- end }}
        spec:
{{ include "microservice.pod.spec" (dict "base" $base "pod" $cronJob "podName" $podName "podShortName" $cronJobShortName ) | nindent 10 }}
---
{{ end }}