
{{ define "ingress.autoconfigure-https-redirect" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" $base }}
{{ $labels := include "microservice.labels" $base }}
{{ $extraLabels := include "microservice.extraLabels" $base }}
{{ $microserviceChart := include "microservice.chart" $base }}
{{ $traefik := $base.Values.traefik }}
---
{{ $serviceName := .serviceName }}
{{ $service := .service }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ $base.Release.Name }}-{{ $serviceName }}-configure-https-redirect
spec:
  template:
    metadata:
      name: {{ $base.Release.Name }}-{{ $serviceName }}-configure-https-redirect
    spec:
      serviceAccountName: {{ $fullName }}-traefik-configurator
      containers:
        - name: kubectl
          image: {{ .Values.kubectlImage.repository }}/{{ .Values.kubectlImage.image }}:{{ .Values.kubectlImage.tag }}
          command:
            - sh
            - -c
            - |
              /bin/sh <<EOF
              set -e
              sleep 60
              kubectl apply -f /etc/config/ingressroute.yaml
              EOF
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config
      volumes:
        - name: config-volume
          configMap:
            name: "{{ $base.Release.Name}}-{{ $serviceName }}-https-redirect-configmap"
      restartPolicy: Never
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $base.Release.Name}}-{{ $serviceName }}-https-redirect-configmap
data:
  ingressroute.yaml: |-
    apiVersion: traefik.containo.us/v1alpha1
    kind: IngressRoute{{ $service.ingress | default "" }}
    metadata:
      name: {{ $fullName }}-{{ $serviceName }}-https-redirect
      namespace: {{ $base.Release.Namespace }}
      labels: {{ $extraLabels | nindent 4 }}{{ $labels | nindent 4 }}
    spec:
      entryPoints:
        - web
      routes:
    {{ $and := ternary "" " && " (kindIs "invalid" $service.domain) }}
    {{- range $service.paths }}
        - kind: Rule
          match: {{ if $service.domain }}Host(`{{ $service.domain }}`){{if or $service.prefix $base.Values.service.version }}{{ $and }}{{ end }}Path(`{{ if $service.prefix }}/{{ $service.prefix }}{{end}}{{ if $base.Values.service.version }}/{{ $base.Values.service.version }}{{ end }}{{ . }}`){{ end }}
          services:
            - name: {{ $fullName }}-{{ $serviceName }}
              port: {{ $service.port | default 80  }}
          middlewares:
            - name: {{ $fullName }}-{{ $serviceName }}-https-redirect
    {{ end }}
    {{- range $service.paths }}
    {{ $path := . }}
    {{- range $service.altDomains }}
    {{ $altDomain := . }}
        - kind: Rule
          match: {{ if $altDomain }}Host(`{{ $altDomain }}`){{if or $service.prefix $base.Values.service.version }}{{ $and }}{{ end }}Path(`{{ if $service.prefix }}/{{ $service.prefix }}{{end}}{{ if $base.Values.service.version }}/{{ $base.Values.service.version }}{{ end }}{{ $path }}`){{ end }}
          services:
            - name: {{ $fullName }}-{{ $serviceName }}
              port: {{ $service.port | default 80  }}
          middlewares:
            - name: {{ $fullName }}-{{ $serviceName }}-https-redirect
    {{ end }}
    {{ end }}

    {{- range $service.pathPrefixes }}
        - kind: Rule
          match: {{ if $service.domain }}Host(`{{ $service.domain }}`){{ end }}{{if or $service.prefix $base.Values.service.version }}{{ $and }}PathPrefix(`{{ if $service.prefix }}/{{ $service.prefix }}{{end}}{{ if $base.Values.service.version }}/{{ $base.Values.service.version }}{{ end }}{{ . }}`){{ end }}
          services:
            - name: {{ $fullName }}-{{ $serviceName }}
              port: {{ $service.port | default 80  }}
          middlewares:
            - name: {{ $fullName }}-{{ $serviceName }}-https-redirect
    {{ end }}
    {{- range $service.pathPrefixes }}
    {{ $pathPrefix := . }}
    {{- range $service.altDomains }}
    {{ $altDomain := . }}
        - kind: Rule
          match: {{ if $altDomain }}Host(`{{ $altDomain }}`){{ end }}{{if or $service.prefix $base.Values.service.version }}{{ $and }}PathPrefix(`{{ if $service.prefix }}/{{ $service.prefix }}{{end}}{{ if $base.Values.service.version }}/{{ $base.Values.service.version }}{{ end }}{{ $pathPrefix }}`){{ end }}
          services:
            - name: {{ $fullName }}-{{ $serviceName }}
              port: {{ $service.port | default 80  }}
          middlewares:
            - name: {{ $fullName }}-{{ $serviceName }}-https-redirect
    {{ end }}
    {{ end }}

    {{ if $service.docs }}
    {{ if and $service.docs.prefix $service.docs.path }}
        - kind: Rule
          match: {{ if $service.domain }}Host(`{{ $service.domain }}`){{ $and }}{{ end }}PathPrefix(`{{ $service.docs.prefix }}{{ if $base.Values.service.version }}/{{ $base.Values.service.version }}{{ end }}{{ $service.docs.path }}`)
          services:
            - name: {{ $fullName }}-{{ $serviceName }}
              port: {{ $service.port | default 80  }}
          middlewares:
            - name: {{ $fullName }}-{{ $serviceName }}-https-redirect
        {{- range $service.altDomains }}
        {{ $altDomain := . }}
        - kind: Rule
          match: {{ if $altDomain }}Host(`{{ $altDomain }}`){{ $and }}{{ end }}PathPrefix(`{{ $service.docs.prefix }}{{ if $base.Values.service.version }}/{{ $base.Values.service.version }}{{ end }}{{ $service.docs.path }}`)
          services:
            - name: {{ $fullName }}-{{ $serviceName }}
              port: {{ $service.port | default 80  }}
          middlewares:
            - name: {{ $fullName }}-{{ $serviceName }}-https-redirect
         {{ end }}
    {{ end }}
  {{ end }}
{{- if $base.Values.traefik.v3.enabled }}
    ---
    apiVersion: traefik.io/v1alpha1
    kind: IngressRoute{{ $service.ingress | default "" }}
    metadata:
      name: {{ $fullName }}-{{ $serviceName }}-https-redirect{{ if $base.Values.namespace }}
      namespace: {{ $base.Values.namespace }}{{ end }}
      labels: {{ $extraLabels | nindent 4 }}{{ $labels | nindent 4 }}
    spec:
      entryPoints:
        - web
      routes:
    {{ $and := ternary "" " && " (kindIs "invalid" $service.domain) }}
    {{- range $service.paths }}
        - kind: Rule
          match: {{ if $service.domain }}Host(`{{ $service.domain }}`){{if or $service.prefix $base.Values.service.version }}{{ $and }}{{ end }}Path(`{{ if $service.prefix }}/{{ $service.prefix }}{{end}}{{ if $base.Values.service.version }}/{{ $base.Values.service.version }}{{ end }}{{ . }}`){{ end }}
          services:
            - name: {{ $fullName }}-{{ $serviceName }}
              port: {{ $service.port | default 80  }}
          middlewares:
            - name: {{ $fullName }}-{{ $serviceName }}-https-redirect
    {{ end }}
    {{- range $service.paths }}
    {{ $path := . }}
    {{- range $service.altDomains }}
    {{ $altDomain := . }}
        - kind: Rule
          match: {{ if $altDomain }}Host(`{{ $altDomain }}`){{if or $service.prefix $base.Values.service.version }}{{ $and }}{{ end }}Path(`{{ if $service.prefix }}/{{ $service.prefix }}{{end}}{{ if $base.Values.service.version }}/{{ $base.Values.service.version }}{{ end }}{{ $path }}`){{ end }}
          services:
            - name: {{ $fullName }}-{{ $serviceName }}
              port: {{ $service.port | default 80  }}
          middlewares:
            - name: {{ $fullName }}-{{ $serviceName }}-https-redirect
    {{ end }}
    {{ end }}

    {{- range $service.pathPrefixes }}
        - kind: Rule
          match: {{ if $service.domain }}Host(`{{ $service.domain }}`){{ end }}{{if or $service.prefix $base.Values.service.version }}{{ $and }}PathPrefix(`{{ if $service.prefix }}/{{ $service.prefix }}{{end}}{{ if $base.Values.service.version }}/{{ $base.Values.service.version }}{{ end }}{{ . }}`){{ end }}
          services:
            - name: {{ $fullName }}-{{ $serviceName }}
              port: {{ $service.port | default 80  }}
          middlewares:
            - name: {{ $fullName }}-{{ $serviceName }}-https-redirect
    {{ end }}
    {{- range $service.pathPrefixes }}
    {{ $pathPrefix := . }}
    {{- range $service.altDomains }}
    {{ $altDomain := . }}
        - kind: Rule
          match: {{ if $altDomain }}Host(`{{ $altDomain }}`){{ end }}{{if or $service.prefix $base.Values.service.version }}{{ $and }}PathPrefix(`{{ if $service.prefix }}/{{ $service.prefix }}{{end}}{{ if $base.Values.service.version }}/{{ $base.Values.service.version }}{{ end }}{{ $pathPrefix }}`){{ end }}
          services:
            - name: {{ $fullName }}-{{ $serviceName }}
              port: {{ $service.port | default 80  }}
          middlewares:
            - name: {{ $fullName }}-{{ $serviceName }}-https-redirect
    {{ end }}
    {{ end }}

    {{ if $service.docs }}
    {{ if and $service.docs.prefix $service.docs.path }}
        - kind: Rule
          match: {{ if $service.domain }}Host(`{{ $service.domain }}`){{ $and }}{{ end }}PathPrefix(`{{ $service.docs.prefix }}{{ if $base.Values.service.version }}/{{ $base.Values.service.version }}{{ end }}{{ $service.docs.path }}`)
          services:
            - name: {{ $fullName }}-{{ $serviceName }}
              port: {{ $service.port | default 80  }}
          middlewares:
            - name: {{ $fullName }}-{{ $serviceName }}-https-redirect
        {{- range $service.altDomains }}
        {{ $altDomain := . }}
        - kind: Rule
          match: {{ if $altDomain }}Host(`{{ $altDomain }}`){{ $and }}{{ end }}PathPrefix(`{{ $service.docs.prefix }}{{ if $base.Values.service.version }}/{{ $base.Values.service.version }}{{ end }}{{ $service.docs.path }}`)
          services:
            - name: {{ $fullName }}-{{ $serviceName }}
              port: {{ $service.port | default 80  }}
          middlewares:
            - name: {{ $fullName }}-{{ $serviceName }}-https-redirect
         {{ end }}
    {{ end }}
  {{ end }}
{{- end }}
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: {{ $fullName }}-{{ $serviceName }}-https-redirect
  labels: {{ $extraLabels | nindent 4 }}{{ $labels | nindent 4 }}
spec:
  redirectScheme:
    scheme: https
    permanent: true
{{- if $base.Values.traefik.v3.enabled }}
---
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: {{ $fullName }}-{{ $serviceName }}-https-redirect
  labels: {{ $extraLabels | nindent 4 }}{{ $labels | nindent 4 }}
spec:
  redirectScheme:
    scheme: https
    permanent: true
{{- end }}
{{ end }}
