{{ define "ingress.services" }}
   {{ $base := . }}
   {{ range $serviceName, $service := .Values.services }}
      {{ $theDic := (dict "serviceName" $serviceName "service" $service "base" $base ) }}

      {{ if $service.canary }}{{ else }}


         {{ if $base.Values.traefik.rateLimitMiddlewares }}

            {{- /* Default */ -}}
            {{- $theDefaultRateLimitDic := dict "serviceName" $serviceName "service" $service "base" $base "priority" 1 "rateLimitName" "default-rate-limit" "rateLimitMiddleware" $base.Values.traefik.rateLimitMiddlewares.default.middleware "rateLimitMiddlewareV3" $base.Values.traefik.rateLimitMiddlewares.default.middlewareV3 }}
            {{ include "ingress.service" $theDefaultRateLimitDic }}

            {{- /* No Limit */ -}}
            {{ if $base.Values.traefik.rateLimitMiddlewares.noLimit }}
                {{- $theNoRateLimitDic := dict "serviceName" $serviceName "service" $service "base" $base "includeIps" $base.Values.traefik.rateLimitMiddlewares.noLimit "priority" 2 "rateLimitName" "no-rate-limit" }}
                {{ include "ingress.service" $theNoRateLimitDic }}
            {{ end }}

            {{- /* Limit Groups */ -}}
            {{ if $base.Values.traefik.rateLimitMiddlewares.groups }}
                {{ range $base.Values.traefik.rateLimitMiddlewares.groups }}
                    {{- $groupRateLimitDic := dict "serviceName" $serviceName "service" $service "base" $base "includeIps" .ips "priority" 3 "rateLimitName" (print .name "-rate-limit") "rateLimitMiddleware" .middleware "rateLimitMiddlewareV3" .middlewareV3 }}
                    {{ include "ingress.service" $groupRateLimitDic }}
                {{ end }}
            {{ end }}

         {{ else }}

            {{ include "ingress.service" $theDic }}

         {{ end }}
      {{ end }}

      {{ if $base.Values.traefik.certResolver }}
         {{ include "ingress.autoconfigure-https-redirect" $theDic }}
      {{ end }}
   {{ end }}
{{ end }}