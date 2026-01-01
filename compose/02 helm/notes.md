### `sed` (surface newlines, no duplicates)

```bash
helm template . | sed -n 'l'
```

Shows line endings explicitly (`$` = `\n`, `\r$` = CRLF) without printing each line twice; works consistently on Linux, WSL, and macOS.

---

### yamllint

Validates rendered output for basic YAML syntax and indentation errors before Kubernetes processing.

---

### kubeconform

Validates rendered manifests against Kubernetes API schemas to catch invalid kinds, fields, or apiVersions.

Output only the final content. No preface, no acknowledgements, no closing remarks.

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