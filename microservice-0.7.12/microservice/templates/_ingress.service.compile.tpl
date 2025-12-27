

{{- define "ingress.service.compile" -}}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $labels := include "microservice.labels" $base }}
{{ $extraLabels := include "microservice.extraLabels" $base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $theDic := (dict "serviceName" .serviceName "service" $service "base" $base "includeIps" .includeIps "priority" .priority "rateLimitMiddleware" .rateLimitMiddleware ) }}
{{ $theDicV3 := (dict "serviceName" .serviceName "service" $service "base" $base "includeIps" .includeIps "priority" .priority "rateLimitMiddleware" (default .rateLimitMiddleware .rateLimitMiddlewareV3) "useV3" true ) }}
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute{{ $service.ingress | default "" }}
metadata:
  name: {{ $fullName }}-{{ $serviceName }}{{ if .rateLimitName }}-{{ .rateLimitName }}{{ end }}
  namespace: {{ $base.Release.Namespace }}
  labels: {{ $extraLabels | nindent 4 }}{{ $labels | nindent 4 }}
spec:
  entryPoints:
    {{ if $base.Values.traefik.certResolver }}
    {{ include "ingress.service.compile.entrypoints.secure" $service | nindent 4 }}
    {{ else }}
    {{ include "ingress.service.compile.entrypoints.insecure" $service | nindent 4 }}
    {{ end }}
  routes:
    {{ include "ingress.service.compile.routes" $theDic | nindent 4 }}
    {{ include "ingress.service.compile.alt-domain.routes" $theDic | nindent 4 }}

  {{ include "ingress.service.compile.cert-resolver" $theDic | nindent 2 }}

{{- if $base.Values.traefik.v3.enabled }}
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute{{ $service.ingress | default "" }}
metadata:
  name: {{ $fullName }}-{{ $serviceName }}{{ if .rateLimitName }}-{{ .rateLimitName }}{{ end }}
  {{- if $base.Values.namespace }}
  namespace: {{ $base.Values.namespace }}
  {{- end }}
  labels: {{ $extraLabels | nindent 4 }}{{ $labels | nindent 4 }}
spec:
  entryPoints:
    {{ if $base.Values.traefik.certResolver }}
    {{ include "ingress.service.compile.entrypoints.secure" $service | nindent 4 }}
    {{ else }}
    {{ include "ingress.service.compile.entrypoints.insecure" $service | nindent 4 }}
    {{ end }}
  routes:
    {{ include "ingress.service.compile.routes" $theDicV3 | nindent 4 }}
    {{ include "ingress.service.compile.alt-domain.routes" $theDicV3 | nindent 4 }}

  {{ include "ingress.service.compile.cert-resolver" $theDicV3 | nindent 2 }}
{{- end }}
---
{{- end -}}