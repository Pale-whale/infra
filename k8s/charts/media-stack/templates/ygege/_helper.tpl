{{- define "ygege.name" -}}
{{- print "ygege" }}
{{- end }}

{{- define "ygege.fullname" -}}
{{ print "ygege" }}
{{- end }}

{{- define "ygege.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ygege.labels" -}}
helm.sh/chart: {{ include "ygege.chart" . }}
{{ include "ygege.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "ygege.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ygege.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "ygege.serviceAccountName" -}}
{{- if .Values.ygege.serviceAccount.create }}
{{- default (include "ygege.fullname" .) .Values.ygege.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.ygege.serviceAccount.name }}
{{- end }}
{{- end }}
