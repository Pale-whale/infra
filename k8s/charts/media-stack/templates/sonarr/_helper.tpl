{{- define "sonarr.name" -}}
{{- print "sonarr" }}
{{- end }}

{{- define "sonarr.fullname" -}}
{{ print "sonarr" }}
{{- end }}

{{- define "sonarr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "sonarr.labels" -}}
helm.sh/chart: {{ include "sonarr.chart" . }}
{{ include "sonarr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "sonarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sonarr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "sonarr.serviceAccountName" -}}
{{- if .Values.sonarr.serviceAccount.create }}
{{- default (include "sonarr.fullname" .) .Values.sonarr.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.sonarr.serviceAccount.name }}
{{- end }}
{{- end }}
