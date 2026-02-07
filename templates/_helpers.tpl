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
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" (include "commonlib.name" .) (.Chart.Version | replace "+" "-") | quote }}
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
{{- range $k, $v := .Values.app.env }}
- name: {{ $k }}
  value: {{ $v | quote }}
{{- end }}
{{- end }}

{{/*
Env from secrets
*/}}
{{- define "commonlib.envFromSecrets" -}}
{{- range $k, $v := .Values.app.secrets.env }}
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
- name: tmp
  mountPath: {{ .Values.commonlib.volumes.tmp.mountPath }}
- name: logs
  mountPath: {{ .Values.commonlib.volumes.logs.mountPath }}
{{- end }}

{{/*
Base volumes
*/}}
{{- define "commonlib.volumes" -}}
- name: tmp
  emptyDir:
    sizeLimit: {{ .Values.commonlib.volumes.tmp.sizeLimit }}
- name: logs
  emptyDir:
    sizeLimit: {{ .Values.commonlib.volumes.logs.sizeLimit }}
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
