
{{ define "ingress.service.compile.routes" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $theDic := (dict "serviceName" .serviceName "service" $service "base" $base "includeIps" .includeIps "priority" .priority "rateLimitMiddleware" .rateLimitMiddleware "useV3" (.useV3 | default false) ) }}

{{ include "ingress.service.compile.routes.paths" $theDic }}
{{ include "ingress.service.compile.routes.pathPrefixes" $theDic }}
{{ if $service.forwardAuth }}
{{ if $service.forwardAuth.unprotectedPaths }}
{{ include "ingress.service.compile.routes.forwardAuth.unprotectedPaths" $theDic }}
{{ end }}
{{ if $service.forwardAuth.unprotectedPathPrefixes }}
{{ include "ingress.service.compile.routes.forwardAuth.unprotectedPathPrefixes" $theDic }}
{{ end }}
{{ end }}
{{ include "ingress.service.compile.routes.no-paths" $theDic }}
{{ include "ingress.service.compile.routes.websocket-upgrade" $theDic }}
{{ include "ingress.service.compile.routes.tcp" $theDic }}
{{ include "ingress.service.compile.routes.docs" $theDic }}

{{ end }}

{{ define "ingress.service.compile.routes.forwardAuth.unprotectedPaths" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $rateLimitMiddleware := .rateLimitMiddleware }}
{{ $priority := .priority }}
{{ $includeIps := .includeIps }}
{{ $useV3 := (.useV3 | default false) }}
{{ $hdrRe := ternary "HeaderRegexp" "HeadersRegexp" $useV3 }}

{{ $and := ternary "" " && " (kindIs "invalid" $service.domain) }}
{{- range $service.forwardAuth.unprotectedPaths }}
{{ $item := . }}
{{ $value := $item.value}}
{{ $renderVal := ternary (regexReplaceAll "\\{([^}]*)\\}" $value "$1") $value $useV3 }}
{{ $middlewares := $item.middlewares }}
{{ $isRegex := or (regexMatch "[\\[\\]\\(\\)\\^\\$\\+\\*\\?\\{\\}\\|]" $value) (regexMatch "\\.\\*" $value) }}
{{ $pathFn := ternary "PathRegexp" "Path" (and $useV3 $isRegex) }}
{{ $renderSan := ternary (regexReplaceAll "\\$+$" (regexReplaceAll "^\\^+" $renderVal "") "") $renderVal (eq $pathFn "PathRegexp") }}
- kind: Rule{{ if $priority }}
  priority: {{ $priority }}{{ end }}
  match: {{ if $service.domain }}Host(`{{ $service.domain }}`){{ if or $service.prefix (and (not $service.disableServiceVersioning) $base.Values.service.version) }}{{ $and }}{{ end }}{{ $pathFn }}(`{{ if eq $pathFn "PathRegexp" }}^{{ end }}{{ if $service.prefix }}/{{ $service.prefix }}{{ end }}{{ if (and (not $service.disableServiceVersioning) $base.Values.service.version) }}/{{ $base.Values.service.version }}{{ end }}{{ $renderSan }}{{ if eq $pathFn "PathRegexp" }}${{ end }}`){{ end }}{{ if $item.method }} && Method(`{{ $item.method }}`){{ end }}{{ if $includeIps }} && ({{ range $index, $ip := $includeIps }}{{ if $index }} || {{ end }}ClientIP(`{{ $ip }}`) || {{$hdrRe}}(`X-Forwarded-For`, `^{{ $ip | replace "." "\\." }}(?:,.*)?$`){{ end }}){{ end }}
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: 80
  {{ if or (or $service.enableCorsInterceptor $middlewares) $service.middlewares }}
  middlewares: {{ range $middlewares }}
    - name: {{ tpl . $base }}{{ end }}{{ if $rateLimitMiddleware }}
    - name: {{ $rateLimitMiddleware }}{{ end }}
  {{ if $service.enableCorsInterceptor }}
    - name: {{ $fullName}}-cors-headers
  {{ end }}
  {{ range $service.middlewares }}
    - name: {{ tpl . $base }}
  {{ end }}
  {{ end }}
{{ end }}

{{ end }}

{{ define "ingress.service.compile.routes.paths" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $rateLimitMiddleware := .rateLimitMiddleware }}
{{ $priority := .priority }}
{{ $includeIps := .includeIps }}
{{ $useV3 := (.useV3 | default false) }}
{{ $hdrRe := ternary "HeaderRegexp" "HeadersRegexp" $useV3 }}

{{ $and := ternary "" " && " (kindIs "invalid" $service.domain) }}
{{- range $service.paths }}
{{ $item := . }}
{{ $value := $item.value}}
{{ $renderVal := ternary (regexReplaceAll "\\{([^}]*)\\}" $value "$1") $value $useV3 }}
{{ $middlewares := $item.middlewares }}
{{ $isRegex := or (regexMatch "[\\[\\]\\(\\)\\^\\$\\+\\*\\?\\{\\}\\|]" $value) (regexMatch "\\.\\*" $value) }}
{{ $pathFn := ternary "PathRegexp" "Path" (and $useV3 $isRegex) }}
{{ $renderSan := ternary (regexReplaceAll "\\$+$" (regexReplaceAll "^\\^+" $renderVal "") "") $renderVal (eq $pathFn "PathRegexp") }}
- kind: Rule{{ if $priority }}
  priority: {{ $priority }}{{ end }}
  match: {{ if $service.domain }}Host(`{{ $service.domain }}`){{ if or $service.prefix (and (not $service.disableServiceVersioning) $base.Values.service.version) }}{{ $and }}{{ end }}{{ $pathFn }}(`{{ if eq $pathFn "PathRegexp" }}^{{ end }}{{ if $service.prefix }}/{{ $service.prefix }}{{ end }}{{ if (and (not $service.disableServiceVersioning) $base.Values.service.version) }}/{{ $base.Values.service.version }}{{ end }}{{ $renderSan }}{{ if eq $pathFn "PathRegexp" }}${{ end }}`){{ end }}{{ if $item.method }} && Method(`{{ $item.method }}`) {{ end }}{{ if $includeIps }} && ({{ range $index, $ip := $includeIps }}{{ if $index }} || {{ end }}ClientIP(`{{ $ip }}`) || {{$hdrRe}}(`X-Forwarded-For`, `^{{ $ip | replace "." "\\." }}(?:,.*)?$`){{ end }}){{ end }}
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: 80
  {{ if or (or (or $service.enableCorsInterceptor $middlewares) $service.middlewares) $base.Values.traefik.forwardAuth.address }}
  middlewares: {{ range $middlewares }}
    - name: {{ tpl . $base }}{{ end }}{{ if $rateLimitMiddleware }}
    - name: {{ $rateLimitMiddleware }}{{ end }}
  {{ if $service.enableCorsInterceptor }}
    - name: {{ $fullName}}-cors-headers
  {{ end }}
  {{ range $service.middlewares }}
    - name: {{ tpl . $base }}
  {{ end }}
  {{ if $base.Values.traefik.forwardAuth.address }}
    - name: {{ include "microservice.fullname" $base }}-forward-auth
  {{ end }}
  {{ end }}
{{ end }}

{{ end }}

{{ define "ingress.service.compile.routes.forwardAuth.unprotectedPathPrefixes" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $rateLimitMiddleware := .rateLimitMiddleware }}
{{ $priority := .priority }}
{{ $includeIps := .includeIps }}
{{ $useV3 := (.useV3 | default false) }}
{{ $hdrRe := ternary "HeaderRegexp" "HeadersRegexp" $useV3 }}

{{ $and := ternary "" " && " (kindIs "invalid" $service.domain) }}
{{- range $service.forwardAuth.unprotectedPathPrefixes }}
{{ $item := . }}
{{ $value := $item.value}}
{{ $renderVal := ternary (regexReplaceAll "\\{([^}]*)\\}" $value "$1") $value $useV3 }}
{{ $middlewares := $item.middlewares }}
{{ $isRegex := or (regexMatch "[\\[\\]\\(\\)\\^\\$\\+\\*\\?\\{\\}\\|]" $value) (regexMatch "\\.\\*" $value) }}
{{ $pathFn := ternary "PathRegexp" "PathPrefix" (and $useV3 $isRegex) }}
{{ $renderSan := ternary (regexReplaceAll "\\$+$" (regexReplaceAll "^\\^+" $renderVal "") "") $renderVal (eq $pathFn "PathRegexp") }}
{{ $finalVal := ternary $renderSan $renderVal (eq $pathFn "PathRegexp") }}
- kind: Rule{{ if $priority }}
  priority: {{ $priority }}{{ end }}
  match: {{ if $service.domain }}Host(`{{ $service.domain }}`){{ end }}{{ if or $service.prefix (and (not $service.disableServiceVersioning) $base.Values.service.version) }}{{ $and }}{{ $pathFn }}(`{{ if eq $pathFn "PathRegexp" }}^{{ end }}{{ if $service.prefix }}/{{ $service.prefix }}{{ end }}{{ if (and (not $service.disableServiceVersioning) $base.Values.service.version) }}/{{ $base.Values.service.version }}{{ end }}{{ $finalVal }}{{ if eq $pathFn "PathRegexp" }}.*{{ end }}`){{ end }}{{ if $item.method }} && Method(`{{ $item.method }}`) {{ end }}{{ if $includeIps }} && ({{ range $index, $ip := $includeIps }}{{ if $index }} || {{ end }}ClientIP(`{{ $ip }}`) || {{$hdrRe}}(`X-Forwarded-For`, `^{{ $ip | replace "." "\\." }}(?:,.*)?$`){{ end }}){{ end }}
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: {{ $service.port | default 80  }}
  {{ if or (or $service.enableCorsInterceptor $middlewares) $service.middlewares }}
  middlewares: {{ range $middlewares }}
    - name: {{ tpl . $base }}{{ end }}{{ if $rateLimitMiddleware }}
    - name: {{ $rateLimitMiddleware }}{{ end }}
  {{ if $service.enableCorsInterceptor }}
    - name: {{ $fullName}}-cors-headers
  {{ end }}
  {{ range $service.middlewares }}
    - name: {{ tpl . $base }}
  {{ end }}
  {{ end }}
{{ end }}

{{ end }}

{{ define "ingress.service.compile.routes.pathPrefixes" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $rateLimitMiddleware := .rateLimitMiddleware }}
{{ $priority := .priority }}
{{ $includeIps := .includeIps }}
{{ $useV3 := (.useV3 | default false) }}
{{ $hdrRe := ternary "HeaderRegexp" "HeadersRegexp" $useV3 }}

{{ $and := ternary "" " && " (kindIs "invalid" $service.domain) }}
{{- range $service.pathPrefixes }}
{{ $item := . }}
{{ $value := $item.value}}
{{ $renderVal := ternary (regexReplaceAll "\\{([^}]*)\\}" $value "$1") $value $useV3 }}
{{ $middlewares := $item.middlewares }}
{{ $isRegex := or (regexMatch "[\\[\\]\\(\\)\\^\\$\\+\\*\\?\\{\\}\\|]" $value) (regexMatch "\\.\\*" $value) }}
{{ $pathFn := ternary "PathRegexp" "PathPrefix" (and $useV3 $isRegex) }}
{{ $renderSan := ternary (regexReplaceAll "\\$+$" (regexReplaceAll "^\\^+" $renderVal "") "") $renderVal (eq $pathFn "PathRegexp") }}
{{ $finalVal := ternary $renderSan $renderVal (eq $pathFn "PathRegexp") }}
- kind: Rule{{ if $priority }}
  priority: {{ $priority }}{{ end }}
  match: {{ if $service.domain }}Host(`{{ $service.domain }}`){{ end }}{{if or $service.prefix (and (not $service.disableServiceVersioning) $base.Values.service.version) }}{{ $and }}{{ $pathFn }}(`{{ if eq $pathFn "PathRegexp" }}^{{ end }}{{ if $service.prefix }}/{{ $service.prefix }}{{ end }}{{ if (and (not $service.disableServiceVersioning) $base.Values.service.version) }}/{{ $base.Values.service.version }}{{ end }}{{ $finalVal }}{{ if eq $pathFn "PathRegexp" }}.*{{ end }}`){{ end }}{{ if $item.method }} && Method(`{{ $item.method }}`) {{ end }}{{ if $includeIps }} && ({{ range $index, $ip := $includeIps }}{{ if $index }} || {{ end }}ClientIP(`{{ $ip }}`) || {{$hdrRe}}(`X-Forwarded-For`, `^{{ $ip | replace "." "\\." }}(?:,.*)?$`){{ end }}){{ end }}
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: {{ $service.port | default 80  }}
  {{ if or (or (or $service.enableCorsInterceptor $middlewares) $service.middlewares) $base.Values.traefik.forwardAuth.address }}
  middlewares: {{ range $middlewares }}
    - name: {{ tpl . $base }}{{ end }}{{ if $rateLimitMiddleware }}
    - name: {{ $rateLimitMiddleware }}{{ end }}
  {{ if $service.enableCorsInterceptor }}
    - name: {{ $fullName}}-cors-headers
  {{ end }}
  {{ range $service.middlewares }}
    - name: {{ tpl . $base }}
  {{ end }}
  {{ if $base.Values.traefik.forwardAuth.address }}
    - name: {{ include "microservice.fullname" $base }}-forward-auth
  {{ end }}
  {{ end }}
{{ end }}

{{ end }}

{{ define "ingress.service.compile.routes.no-paths" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $rateLimitMiddleware := .rateLimitMiddleware }}
{{ $priority := .priority }}
{{ $includeIps := .includeIps }}

{{ if $service.domain }}
{{ if not $service.pathPrefixes }}
{{ if not $service.paths }}
{{ if or (not $service.forwardAuth) (and (not $service.forwardAuth.unprotectedPaths) (not $service.forwardAuth.unprotectedPathPrefixes)) }}
- kind: Rule{{ if $priority }}
  priority: {{ $priority }}{{ end }}
  match: Host(`{{ $service.domain }}`)
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: {{ $service.port | default 80  }}
  {{ if $service.enableCorsInterceptor }}
  middlewares:
    - name: {{ $fullName}}-cors-headers{{ if $rateLimitMiddleware }}
    - name: {{ $rateLimitMiddleware }}{{ end }}
  {{ end }}
{{ end }}
{{ end }}
{{ end }}
{{ end }}
{{ end }}

{{ define "ingress.service.compile.routes.websocket-upgrade" }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $base := .base }}
{{ $rateLimitMiddleware := .rateLimitMiddleware }}
{{ $priority := .priority }}
{{ $includeIps := .includeIps }}

{{ if and $service.websocketHttpUpgradeEnabled $service.domain }}
- kind: Rule{{ if $priority }}
  priority: {{ $priority }}{{ end }}
  match: Host(`{{ $service.domain }}`)
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: 80
  {{ if $service.enableCorsInterceptor }}
  middlewares:
    - name: {{ $fullName}}-cors-headers{{ if $rateLimitMiddleware }}
    - name: {{ $rateLimitMiddleware }}{{ end }}
  {{ end }}
{{ end }}

{{ end }}

{{ define "ingress.service.compile.routes.tcp" }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}

{{ if or (eq ($service.ingress | default "HTTP") "UDP") (eq ($service.ingress | default "HTTP") "TCP") }}
- kind: Rule {{ if $service.domain }}
  match: HostSNI(`{{ $service.domain }}`){{ end }}
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: 80
{{ end }}

{{ end }}

{{ define "ingress.service.compile.routes.docs" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $rateLimitMiddleware := .rateLimitMiddleware }}
{{ $priority := .priority }}
{{ $includeIps := .includeIps }}
{{ $useV3 := (.useV3 | default false) }}
{{ $hdrRe := ternary "HeaderRegexp" "HeadersRegexp" $useV3 }}

{{ $and := ternary "" " && " (kindIs "invalid" $service.domain) }}
{{ if $service.docs }}
{{ if and $service.docs.prefix $service.docs.path }}
{{ $val := printf "%s%s" (printf "%s" $service.docs.prefix) (printf "%s" $service.docs.path) }}
{{ $isRegex := or (regexMatch "[\\[\\]\\(\\)\\^\\$\\+\\*\\?\\{\\}\\|]" $val) (regexMatch "\\.\\*" $val) }}
{{ $pathFn := ternary "PathRegexp" "PathPrefix" (and $useV3 $isRegex) }}
{{ $fullPath := printf "%s%s%s" (printf "%s" $service.docs.prefix) (ternary (printf "/%s" $base.Values.service.version) "" (and (not $service.disableServiceVersioning) (not (empty $base.Values.service.version)))) (printf "%s" $service.docs.path) }}
{{ $renderVal := ternary (regexReplaceAll "\\{([^}]*)\\}" $fullPath "$1") $fullPath $useV3 }}
- kind: Rule{{ if $priority }}
  priority: {{ $priority }}{{ end }}
  match: {{ if $service.domain }}Host(`{{ $service.domain }}`){{ $and }}{{ end }}{{ $pathFn }}(`{{ if eq $pathFn "PathRegexp" }}^{{ end }}{{ $renderVal }}{{ if eq $pathFn "PathRegexp" }}.*{{ end }}`){{ if $includeIps }} && ({{ range $index, $ip := $includeIps }}{{ if $index }} || {{ end }}ClientIP(`{{ $ip }}`) || {{$hdrRe}}(`X-Forwarded-For`, `^{{ $ip | replace "." "\\." }}(?:,.*)?$`){{ end }}){{ end }}
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: {{ $service.port | default 80  }}
  {{ if $service.enableCorsInterceptor }}
  middlewares:
    - name: {{ $fullName}}-cors-headers{{ if $rateLimitMiddleware }}
    - name: {{ $rateLimitMiddleware }}{{ end }}
  {{ end }}
{{ end }}
{{ end }}

{{ end }}


