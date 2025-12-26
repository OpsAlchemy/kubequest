{{- }}

{{ .Values.my.custome.data }}
{{ .Chart.Name }}
{{ .Chart.Version }}
{{ .Chart.AppVersion }}
{{ .Chart.Annotation }}


{{.Release.Name}}
{{.Release.Namespace}}
{{.Release.IsInstall}}
{{.Release.IsUpgrade}}
{{.Release.Service}}

{{Template.Name}}
{{Template.BasePath}}

--- Pipeline ---

 output of one command -> passed as input to right side

 {{ .Values.my.custom.data | default "testdefault" | upper | quote }}