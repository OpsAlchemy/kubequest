

{{- define "ingress.service" -}}
{{ $base := .base }}
{{ $service := .service }}
{{ $isTCPOrUDP := (or (eq ($service.ingress | default "HTTP")  "TCP") (eq ($service.ingress | default "HTTP") "UDP"))}}
{{ $pathIsSet := $service.paths }}
{{ $pathPrefixIsSet := $service.pathPrefixes }}
{{ $theDic := (dict "serviceName" .serviceName "service" $service "base" $base "includeIps" .includeIps "priority" .priority "rateLimitName" .rateLimitName "rateLimitMiddleware" .rateLimitMiddleware "rateLimitMiddlewareV3" .rateLimitMiddlewareV3 ) }}
{{ if and (or $pathIsSet $pathPrefixIsSet $isTCPOrUDP $service.domain $service.websocketHttpUpgradeEnabled ) $service.enabled }}
   {{ include "ingress.service.compile" $theDic }}
{{ end }}

---
{{- end -}}