

{{- define "ingress.service.compile.cert-resolver" -}}
{{ $base := .base }}
{{ $service := .service }}

{{ if $base.Values.traefik.certResolver }}
tls:
  certResolver: {{ $base.Values.traefik.certResolver }}
{{ end }}

{{ if and $base.Values.traefik.certResolver (eq ($service.ingress | default "HTTP") "HTTP") $service.domain }}

{{ end }}

{{- end -}}