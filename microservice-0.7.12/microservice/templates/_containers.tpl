{{ define "microservice.containers" }}
{{ $pod := .pod }}
{{ $base := .base }}
{{ $podName := .podName }}
{{ $podShortName := .podShortName }}
{{- $microserviceFullName := include "microservice.fullname" $base -}}

- name: {{ $base.Chart.Name }}
  {{ if $base.Values.image.image }}
  image: "{{ $base.Values.image.image }}"{{else}}
  image: "{{ $base.Values.image.repository }}:{{ $base.Values.image.tag }}"{{ $base.Values.image.image }}{{ end }}{{ if $pod.container }}{{ if $pod.container.command }}
  command:{{- range $pod.container.command }}
    - {{ . }}{{ end }}{{ end }}{{ end }}
  imagePullPolicy: {{ $base.Values.image.pullPolicy }}
  {{ if $pod.container.privileged }}
  securityContext:
    privileged: true
  {{ end }}
  {{ if or $pod.lifecycle $pod.container.lifecycle }}
  lifecycle:
    {{ if or (and $pod.lifecycle $pod.lifecycle.preStop) (and $pod.container.lifecycle $pod.container.lifecycle.preStop) }}
    preStop:
      {{ $preStop := default (default dict $pod.lifecycle).preStop (default (default dict $pod.container.lifecycle).preStop) }}
      {{ if $preStop.exec }}
      exec:
        command:{{- range $preStop.exec.command }}
          - {{ . }}{{ end }}
      {{ end }}
      {{ if $preStop.httpGet }}
      httpGet:
        path: {{ $preStop.httpGet.path }}
        port: {{ $preStop.httpGet.port }}
        {{ if $preStop.httpGet.host }}
        host: {{ $preStop.httpGet.host }}
        {{ end }}
        {{ if $preStop.httpGet.scheme }}
        scheme: {{ $preStop.httpGet.scheme }}
        {{ end }}
        {{ if $preStop.httpGet.httpHeaders }}
        httpHeaders:{{- toYaml $preStop.httpGet.httpHeaders | nindent 10 }}
        {{ end }}
      {{ end }}
      {{ if $preStop.tcpSocket }}
      tcpSocket:
        port: {{ $preStop.tcpSocket.port }}
        {{ if $preStop.tcpSocket.host }}
        host: {{ $preStop.tcpSocket.host }}
        {{ end }}
      {{ end }}
      {{ if $preStop.sleep }}
      sleep:
        seconds: {{ $preStop.sleep.seconds }}
      {{ end }}
    {{ end }}
  {{ end }}
  {{ if $pod.autoscaling }}
  resources:
    requests:
      cpu: {{ $pod.autoscaling.resources.requests.cpu }}
      memory: {{ $pod.autoscaling.resources.requests.memory }}
    limits:
      cpu: {{ $pod.autoscaling.resources.limits.cpu }}
      memory: {{ $pod.autoscaling.resources.limits.memory }}
  {{ end }}
  {{ if $pod.container.port }}
  ports:
    - name: "http"
      containerPort: {{ $pod.container.port }}
  {{ end }}
    {{ range $serviceName, $service := $base.Values.services }}
    {{ range $service.extraPorts }}
    {{ if eq $service.deploymentName $podShortName }}
    - name: {{ .name }}
      containerPort: {{ .containerPort }}
    {{ end }}
    {{ end }}
    {{ end }}

  {{ if $pod.probes }}
  {{ if $pod.probes.enabled }}
  startupProbe:{{- toYaml $pod.probes.startup | nindent 12 }}
  readinessProbe:{{- toYaml $pod.probes.readiness | nindent 12 }}
  livenessProbe:{{- toYaml $pod.probes.liveness | nindent 12 }}
  {{ end }}
  {{ end }}

  env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: HOST_IP
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: status.hostIP
    - name: APP_VERSION
      value: "{{ $base.Values.image.tag }}"
    {{- range $base.Values.env.valueFrom }}
    - name: {{ .var }}
      valueFrom:
        configMapKeyRef:
          name: {{ $microserviceFullName }}-{{ .name }}
          key: {{ .key }}
    {{- end }}
    {{- range $base.Values.env.secretFrom }}
    - name: {{ .var }}
      valueFrom:
        secretKeyRef:
          name: {{ $microserviceFullName }}-{{ .name }}
          key: {{ .key }}
    {{- end }}
    {{- range $base.Values.env.value }}
    - name: {{ .name }}
      value: "{{ tpl (.value | toString) $base }}"
    {{- end }}
    {{- range $key, $value := $base.Values.env.map }}
    - name: {{ $key }}
      value: "{{ tpl ($value | toString) $base }}"
    {{- end }}
    {{ if $pod.env }}
    {{- range $pod.env.value }}
    - name: {{ .name }}
      value: "{{ tpl (.value | toString) $base }}"{{- end }}{{ range $key, $value := $pod.env.map }}
    - name: {{ $key }}
      value: "{{ tpl $value $base }}"{{ end }}{{ end }}{{ if $base.Values.env.from }}
  envFrom:{{ if or $base.Values.env.from }}{{- tpl (toYaml $base.Values.env.from) $base | nindent 12 }}{{ end }}{{ end }}{{ if or $base.Values.fileMounts $base.Values.secretFileMounts $base.Values.persistentVolumes $pod.hostMounts }}
  volumeMounts:{{ end }}
    {{ range $pod.hostMounts }}
    - name: host-mount-{{ .name }}
      mountPath: {{ .containerPath }}
    {{ end }}
    {{ range $base.Values.persistentVolumes }}
    {{ if and .name .enabled }}
    - name: {{ .name }}
      mountPath: {{ .mountPath }}
      readOnly: {{ default true .readOnly }}
    {{ end }}
    {{ end }}
    {{- range $base.Values.fileMounts }}
    {{- range .mounts }}
    - name: {{ .name }}
      mountPath: {{ .fileDirectory }}
    {{- end }}
    {{- end }}
    {{- range $base.Values.secretFileMounts }}
    {{- $secretName := (tpl .name $base) -}}
    {{- range .mounts }}
    - name: {{ $secretName }}
      mountPath: {{ .fileDirectory }}
    {{- end }}
    {{- end }}
{{ end }}