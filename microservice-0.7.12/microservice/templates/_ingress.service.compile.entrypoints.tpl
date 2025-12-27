
{{ define "ingress.service.compile.entrypoints.secure" }}
{{ if eq (.ingress | default "HTTP") "HTTP" }}
- websecure
{{ end }}
{{ if eq (.ingress | default "HTTP") "TCP" }}
- wss
{{ end }}
{{ if eq (.ingress | default "HTTP") "UDP" }}
- udps
{{ end }}
{{ end }}

{{ define "ingress.service.compile.entrypoints.insecure" }}
{{ if eq (.ingress | default "HTTP") "HTTP" }}
- web
{{ end }}
{{ if eq (.ingress | default "HTTP") "TCP" }}
- ws
{{ end }}
{{ if eq (.ingress | default "HTTP") "UDP" }}
- udp
{{ end }}
{{ end }}