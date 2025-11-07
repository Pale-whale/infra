{{- define "prowlarr.name" -}}
{{- print "prowlarr" }}
{{- end }}

{{- define "prowlarr.fullname" -}}
{{ print "prowlarr" }}
{{- end }}

{{- define "prowlarr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "prowlarr.labels" -}}
helm.sh/chart: {{ include "prowlarr.chart" . }}
{{ include "prowlarr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "prowlarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prowlarr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "prowlarr.serviceAccountName" -}}
{{- if .Values.transmission.serviceAccount.create }}
{{- default (include "prowlarr.fullname" .) .Values.transmission.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.transmission.serviceAccount.name }}
{{- end }}
{{- end }}
