
{{ define "ingress.cors-headers-redirect" }}
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: {{ include "microservice.fullname" . }}-cors-headers
spec:
  headers:
    accessControlAllowMethods:
      - GET
      - POST
      - PUT
      - OPTIONS
      - PATCH
      - DELETE
      - HEAD
    accessControlAllowOriginList:
      - {{ printf "%s" .Values.star | quote }}
{{- if .Values.traefik.v3.enabled }}
---
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: {{ include "microservice.fullname" . }}-cors-headers
spec:
  headers:
    accessControlAllowMethods:
      - GET
      - POST
      - PUT
      - OPTIONS
      - PATCH
      - DELETE
      - HEAD
    accessControlAllowOriginList:
      - {{ printf "%s" .Values.star | quote }}
{{- end }}
{{ end }}