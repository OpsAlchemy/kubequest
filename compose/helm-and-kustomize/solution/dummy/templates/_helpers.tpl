{{- define "simple-app.labels" -}}
app.kubernetes.io/name: {{ include "simple-app.name" .}}
app.kubernetes.io/instance: {{ .Release.name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "simple-app.name" -}}
{{ .Chart.Name }}
{{- end }}