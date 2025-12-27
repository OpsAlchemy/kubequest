{{ define "microservice.volumes" }}
{{ $pod := .pod }}
{{ $base := .base }}
{{- $microserviceFullName := include "microservice.fullname" $base -}}

{{ range $pod.hostMounts }}
- name: host-mount-{{ .name }}
  hostPath:
    path: {{ .hostPath }}
    type: {{ .type }}
{{ end }}
{{ range $base.Values.persistentVolumes }}
{{ if and .name .enabled }}
- name: {{ .name }}
  persistentVolumeClaim:
    claimName: {{ $microserviceFullName }}-{{ .name }}
{{ end }}
{{ end }}
{{- range $base.Values.fileMounts }}
- name: {{ .volumeName }}
  configMap:
    name: {{ tpl .configMap $base }}
{{- end }}

{{- range $base.Values.secretFileMounts }}
- name: {{ tpl .name $base }}
  secret:
    secretName: {{ tpl .name $base }}{{ if .defaultMode }}
    defaultMode: {{ .defaultMode }}{{ end }}
 {{- end }}
{{ end }}