
{{ define "ingress.service.compile.alt-domain.routes" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $theDic := (dict "serviceName" .serviceName "service" $service "base" $base "useV3" (.useV3 | default false) ) }}

{{ if $service.forwardAuth }}
{{ if $service.forwardAuth.unprotectedPaths }}
{{ include "ingress.service.compile.alt-domain.routes.forwardAuth.unprotectedPaths" $theDic }}
{{ end }}
{{ if $service.forwardAuth.unprotectedPathPrefixes }}
{{ include "ingress.service.compile.alt-domain.routes.forwardAuth.unprotectedPathPrefixes" $theDic }}
{{ end }}
{{ end }}
{{ include "ingress.service.compile.alt-domain.routes.paths" $theDic }}
{{ include "ingress.service.compile.alt-domain.routes.pathPrefixes" $theDic }}
{{ include "ingress.service.compile.alt-domain.routes.no-paths" $theDic }}
{{ include "ingress.service.compile.alt-domain.routes.websocket-upgrade" $theDic }}
{{ include "ingress.service.compile.alt-domain.routes.tcp" $theDic }}
{{ include "ingress.service.compile.alt-domain.routes.docs" $theDic }}

{{ end }}

{{ define "ingress.service.compile.alt-domain.routes.forwardAuth.unprotectedPaths" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $useV3 := (.useV3 | default false) }}

{{ $and := ternary "" " && " (kindIs "invalid" $service.domain) }}
{{- range $service.forwardAuth.unprotectedPaths }}
{{ $item := . }}
{{ $value := $item.value}}
{{ $renderVal := ternary (regexReplaceAll "\\{([^}]*)\\}" $value "$1") $value $useV3 }}
{{ $middlewares := $item.middlewares }}
{{- range $service.altDomains }}
{{ $altDomain := . }}
{{ $isRegex := or (regexMatch "[\\[\\]\\(\\)\\^\\$\\+\\*\\?\\{\\}\\|]" $value) (regexMatch "\\.\\*" $value) }}
{{ $pathFn := ternary "PathRegexp" "Path" (and $useV3 $isRegex) }}
{{ $renderSan := ternary (regexReplaceAll "\\$+$" (regexReplaceAll "^\\^+" $renderVal "") "") $renderVal (eq $pathFn "PathRegexp") }}
{{ $finalVal := ternary (printf "^%s$" $renderSan) $renderSan (eq $pathFn "PathRegexp") }}
- kind: Rule
  match: {{ if $altDomain }}Host(`{{ $altDomain }}`){{if or $service.prefix (and (not $service.disableServiceVersioning) $base.Values.service.version) }}{{ $and }}{{ end }}{{ $pathFn }}(`{{ if eq $pathFn "PathRegexp" }}^{{ end }}{{ if $service.prefix }}/{{ $service.prefix }}{{end}}{{ if (and (not $service.disableServiceVersioning) $base.Values.service.version) }}/{{ $base.Values.service.version }}{{ end }}{{ $renderSan }}{{ if eq $pathFn "PathRegexp" }}${{ end }}`){{ end }}{{ if $item.method }} && Method(`{{ $item.method }}`) {{ end }}
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: 80
  {{ if or (or $service.enableCorsInterceptor $middlewares) $service.middlewares }}
  middlewares: {{ range $middlewares }}
    - name: {{ tpl . $base }}{{ end }}
  {{ if $service.enableCorsInterceptor }}
    - name: {{ $fullName}}-cors-headers
  {{ end }}
  {{ range $service.middlewares }}
    - name: {{ tpl . $base }}
  {{ end }}
  {{ end }}
{{ end }}
{{ end }}

{{ end }}

{{ define "ingress.service.compile.alt-domain.routes.paths" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $useV3 := (.useV3 | default false) }}

{{ $and := ternary "" " && " (kindIs "invalid" $service.domain) }}
{{- range $service.paths }}
{{ $item := . }}
{{ $value := $item.value}}
{{ $renderVal := ternary (regexReplaceAll "\\{([^}]*)\\}" $value "$1") $value $useV3 }}
{{ $middlewares := $item.middlewares }}
{{- range $service.altDomains }}
{{ $altDomain := . }}
{{ $isRegex := or (regexMatch "[\\[\\]\\(\\)\\^\\$\\+\\*\\?\\{\\}\\|]" $value) (regexMatch "\\.\\*" $value) }}
{{ $pathFn := ternary "PathRegexp" "Path" (and $useV3 $isRegex) }}
{{ $renderSan := ternary (regexReplaceAll "\\$+$" (regexReplaceAll "^\\^+" $renderVal "") "") $renderVal (eq $pathFn "PathRegexp") }}
- kind: Rule
  match: {{ if $altDomain }}Host(`{{ $altDomain }}`){{if or $service.prefix (and (not $service.disableServiceVersioning) $base.Values.service.version) }}{{ $and }}{{ end }}{{ $pathFn }}(`{{ if eq $pathFn "PathRegexp" }}^{{ end }}{{ if $service.prefix }}/{{ $service.prefix }}{{end}}{{ if (and (not $service.disableServiceVersioning) $base.Values.service.version) }}/{{ $base.Values.service.version }}{{ end }}{{ $renderSan }}{{ if eq $pathFn "PathRegexp" }}${{ end }}`){{ end }}{{ if $item.method }} && Method(`{{ $item.method }}`) {{ end }}
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: 80
  {{ if or (or (or $service.enableCorsInterceptor $middlewares) $service.middlewares) $base.Values.traefik.forwardAuth.address }}
  middlewares: {{ range $middlewares }}
    - name: {{ tpl . $base }}{{ end }}
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
{{ end }}


{{ define "ingress.service.compile.alt-domain.routes.forwardAuth.unprotectedPathPrefixes" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $useV3 := (.useV3 | default false) }}

{{ $and := ternary "" " && " (kindIs "invalid" $service.domain) }}
{{- range $service.forwardAuth.unprotectedPathPrefixes }}
{{ $item := . }}
{{ $value := $item.value}}
{{ $renderVal := ternary (regexReplaceAll "\\{([^}]*)\\}" $value "$1") $value $useV3 }}
{{ $middlewares := $item.middlewares }}
{{- range $service.altDomains }}
{{ $altDomain := . }}
{{ $isRegex := or (regexMatch "[\\[\\]\\(\\)\\^\\$\\+\\*\\?\\{\\}\\|]" $value) (regexMatch "\\.\\*" $value) }}
{{ $pathFn := ternary "PathRegexp" "PathPrefix" (and $useV3 $isRegex) }}
{{ $renderSan := ternary (regexReplaceAll "\\$+$" (regexReplaceAll "^\\^+" $renderVal "") "") $renderVal (eq $pathFn "PathRegexp") }}
{{ $finalVal := ternary $renderSan $renderVal (eq $pathFn "PathRegexp") }}
- kind: Rule
  match: {{ if $altDomain }}Host(`{{ $altDomain }}`){{ end }}{{if or $service.prefix (and (not $service.disableServiceVersioning) $base.Values.service.version) }}{{ $and }}{{ $pathFn }}(`{{ if eq $pathFn "PathRegexp" }}^{{ end }}{{ if $service.prefix }}/{{ $service.prefix }}{{end}}{{ if (and (not $service.disableServiceVersioning) $base.Values.service.version) }}/{{ $base.Values.service.version }}{{ end }}{{ $finalVal }}{{ if eq $pathFn "PathRegexp" }}.*{{ end }}`){{ end }}{{ if $item.method }} && Method(`{{ $item.method }}`) {{ end }}
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: {{ $service.port | default 80  }}
  {{ if or (or $service.enableCorsInterceptor $middlewares) $service.middlewares }}
  middlewares: {{ range $middlewares }}
    - name: {{ tpl . $base }}{{ end }}
  {{ if $service.enableCorsInterceptor }}
    - name: {{ $fullName}}-cors-headers
  {{ end }}
  {{ range $service.middlewares }}
    - name: {{ tpl . $base }}
  {{ end }}
  {{ end }}
{{ end }}
{{ end }}

{{ end }}

{{ define "ingress.service.compile.alt-domain.routes.pathPrefixes" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $useV3 := (.useV3 | default false) }}

{{ $and := ternary "" " && " (kindIs "invalid" $service.domain) }}
{{- range $service.pathPrefixes }}
{{ $item := . }}
{{ $value := $item.value}}
{{ $renderVal := ternary (regexReplaceAll "\\{([^}]*)\\}" $value "$1") $value $useV3 }}
{{ $middlewares := $item.middlewares }}
{{- range $service.altDomains }}
{{ $altDomain := . }}
{{ $isRegex := or (regexMatch "[\\[\\]\\(\\)\\^\\$\\+\\*\\?\\{\\}\\|]" $value) (regexMatch "\\.\\*" $value) }}
{{ $pathFn := ternary "PathRegexp" "PathPrefix" (and $useV3 $isRegex) }}
{{ $renderSan := ternary (regexReplaceAll "\\$+$" (regexReplaceAll "^\\^+" $renderVal "") "") $renderVal (eq $pathFn "PathRegexp") }}
{{ $finalVal := ternary $renderSan $renderVal (eq $pathFn "PathRegexp") }}
- kind: Rule
  match: {{ if $altDomain }}Host(`{{ $altDomain }}`){{ end }}{{if or $service.prefix (and (not $service.disableServiceVersioning) $base.Values.service.version) }}{{ $and }}{{ $pathFn }}(`{{ if eq $pathFn "PathRegexp" }}^{{ end }}{{ if $service.prefix }}/{{ $service.prefix }}{{end}}{{ if (and (not $service.disableServiceVersioning) $base.Values.service.version) }}/{{ $base.Values.service.version }}{{ end }}{{ $finalVal }}{{ if eq $pathFn "PathRegexp" }}.*{{ end }}`){{ end }}{{ if $item.method }} && Method(`{{ $item.method }}`) {{ end }}
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: {{ $service.port | default 80  }}
  {{ if or (or (or $service.enableCorsInterceptor $middlewares) $service.middlewares) $base.Values.traefik.forwardAuth.address }}
  middlewares: {{ range $middlewares }}
    - name: {{ tpl . $base }}{{ end }}
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
{{ end }}

{{ define "ingress.service.compile.alt-domain.routes.no-paths" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}

{{ end }}

{{ define "ingress.service.compile.alt-domain.routes.websocket-upgrade" }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}

{{ range $service.altDomains }}
{{ $altDomain := . }}
{{ if and $service.websocketHttpUpgradeEnabled $altDomain }}
- kind: Rule
  match: Host(`{{ $altDomain }}`)
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: 80
  {{ if $service.enableCorsInterceptor }}
  middlewares:
    - name: {{ $fullName}}-cors-headers
  {{ end }}
{{ end }}
{{ end }}
{{ end }}

{{ define "ingress.service.compile.alt-domain.routes.tcp" }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}

{{ if or (eq ($service.ingress | default "HTTP") "UDP") (eq ($service.ingress | default "HTTP") "TCP") }}
{{ range $service.altDomains }}
{{ $altDomain := . }}
- kind: Rule {{ if $altDomain }}
  match: HostSNI(`{{ $altDomain }}`){{ end }}
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: 80
{{ end }}
{{ end }}

{{ end }}

{{ define "ingress.service.compile.alt-domain.routes.docs" }}
{{ $base := .base }}
{{ $fullName := include "microservice.fullname" .base }}
{{ $service := .service }}
{{ $serviceName := .serviceName }}
{{ $useV3 := (.useV3 | default false) }}

{{ range $service.altDomains }}
{{ $altDomain := . }}
{{ $and := ternary "" " && " (kindIs "invalid" $altDomain) }}
{{ if $service.docs }}
{{ if and $service.docs.prefix $service.docs.path }}
{{ $val := printf "%s%s" (printf "%s" $service.docs.prefix) (printf "%s" $service.docs.path) }}
{{ $isRegex := or (regexMatch "[\\[\\]\\(\\)\\^\\$\\+\\*\\?\\{\\}\\|]" $val) (regexMatch "\\.\\*" $val) }}
{{ $pathFn := ternary "PathRegexp" "PathPrefix" (and $useV3 $isRegex) }}
{{ $fullPath := printf "%s%s%s" (printf "%s" $service.docs.prefix) (ternary (printf "/%s" $base.Values.service.version) "" (and (not $service.disableServiceVersioning) (not (empty $base.Values.service.version)))) (printf "%s" $service.docs.path) }}
{{ $renderVal := ternary (regexReplaceAll "\\{([^}]*)\\}" $fullPath "$1") $fullPath $useV3 }}
- kind: Rule
  match: {{ if $altDomain }}Host(`{{ $altDomain }}`){{ $and }}{{ end }}{{ $pathFn }}(`{{ if eq $pathFn "PathRegexp" }}^{{ end }}{{ $renderVal }}{{ if eq $pathFn "PathRegexp" }}.*{{ end }}`)
  services:
    - name: {{ $fullName }}-{{ $serviceName }}
      port: {{ $service.port | default 80  }}
  {{ if $service.enableCorsInterceptor }}
  middlewares:
    - name: {{ $fullName}}-cors-headers
  {{ end }}
{{ end }}
{{ end }}
{{ end }}
{{ end }}