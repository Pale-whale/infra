{{- define "radarr.name" -}}
{{- print "radarr" }}
{{- end }}

{{- define "radarr.fullname" -}}
{{ print "radarr" }}
{{- end }}

{{- define "radarr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "radarr.labels" -}}
helm.sh/chart: {{ include "radarr.chart" . }}
{{ include "radarr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "radarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "radarr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "radarr.serviceAccountName" -}}
{{- if .Values.transmission.serviceAccount.create }}
{{- default (include "radarr.fullname" .) .Values.transmission.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.transmission.serviceAccount.name }}
{{- end }}
{{- end }}
