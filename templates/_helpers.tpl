{{/*
Name, labels and annotations
*/}}
{{- define "commonlib.name" -}}
{{- default .Chart.Name .Values.commonlib.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "commonlib.selectorLabels" -}}
app.kubernetes.io/name: {{ include "commonlib.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "commonlib.labels" -}}
{{- include "commonlib.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" (include "commonlib.name" .) .Chart.Version }}
{{- end }}

{{/*
Pod security context
*/}}
{{- define "commonlib.podSecurityContext" -}}
fsGroup: 10001
fsGroupChangePolicy: OnRootMismatch
seccompProfile:
  type: RuntimeDefault
runAsUser: 10001
runAsGroup: 10001
runAsNonRoot: true
{{- end }}

{{/*
Container security context
*/}}
{{- define "commonlib.containerSecurityContext" -}}
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true
capabilities:
  drop: ["ALL"]
{{- end }}

{{/*
Env from values
*/}}
{{- define "commonlib.envFromValues" -}}
{{- $app := default dict .Values.app -}}
{{- range $k, $v := $app.env }}
- name: {{ $k }}
  value: {{ $v | quote }}
{{- end }}
{{- end }}

{{/*
Env from secrets
*/}}
{{- define "commonlib.envFromSecrets" -}}
{{- $app := default dict .Values.app -}}
{{- $secrets := default dict $app.secrets -}}
{{- range $k, $v := $secrets.env }}
- name: {{ $k }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Release.Name }}-env
      key: {{ $k }}
{{- end }}
{{- end }}

{{/*
Base volume mounts
*/}}
{{- define "commonlib.volumeMounts" -}}
{{- $commonlib := default dict $.Values.commonlib -}}
{{- $volumes := default dict $commonlib.volumes -}}
{{- $tmp := default dict (index $volumes "tmp") -}}
{{- $logs := default dict (index $volumes "logs") -}}
- name: tmp
  mountPath: {{ default "/tmp" $tmp.mountPath }}
- name: logs
  mountPath: {{ default "/logs" $logs.mountPath }}
{{- end }}

{{/*
Base volumes
*/}}
{{- define "commonlib.volumes" -}}
{{- $commonlib := default dict $.Values.commonlib -}}
{{- $volumes := default dict $commonlib.volumes -}}
{{- $tmp := default dict (index $volumes "tmp") -}}
{{- $logs := default dict (index $volumes "logs") -}}
- name: tmp
  emptyDir:
    sizeLimit: {{ default "128Mi" $tmp.sizeLimit }}
- name: logs
  emptyDir:
    sizeLimit: {{ default "128Mi" $logs.sizeLimit }}
{{- end }}

{{/*
Pod anti-affinity
*/}}
{{- define "commonlib.podAntiAffinity" -}}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: "app.kubernetes.io/instance"
          operator: In
          values:
            - {{ .Release.Name }}
      topologyKey: "kubernetes.io/hostname"
{{- end }}
