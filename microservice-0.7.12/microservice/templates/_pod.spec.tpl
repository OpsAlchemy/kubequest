
{{ define "microservice.pod.spec" }}
{{ $pod := .pod }}
{{ $base := .base }}
{{ $podName := .podName }}
{{ $podShortName := .podShortName }}
{{ $indent := .indent }}
{{- $microserviceFullName := include "microservice.fullname" $base -}}

{{ if $pod.nodeSelectors }}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            {{ range $pod.nodeSelectors }}
            - key: {{ .key }}
              operator: In
              values:
                - {{ .value }}
            {{ end }}
{{ end }}{{ if $pod.runtimeClassName }}
runtimeClassName: {{ $pod.runtimeClassName }}
{{ end }}
{{- with $base.Values.imagePullSecrets }}
imagePullSecrets: {{- toYaml . | nindent 8 }}
{{- end }}{{ if $base.Values.rbac.enabled }}
serviceAccountName: {{ $microserviceFullName }}{{ end }}{{ if $pod.initContainers }}
initContainers: {{- tpl (toYaml $pod.initContainers) $base | nindent 8 }}{{ end }}
{{ if $pod.restartPolicy }}
restartPolicy: {{ $pod.restartPolicy }}
{{ end }}
containers:
{{ include "microservice.containers" (dict "base" $base "pod" $pod "podName" $podName "podShortName" $podShortName ) | nindent 2}}
{{ if or $base.Values.fileMounts $base.Values.secretFileMounts $base.Values.persistentVolumes $pod.hostMounts }}
volumes:
{{ include "microservice.volumes" (dict "base" $base "pod" $pod) | nindent 2 }}
{{ end }}
{{ end }}