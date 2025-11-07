{{/*
Expand the name of the chart.
*/}}
{{- define "transmission-openvpn.name" -}}
{{- default .Chart.Name .Values.transmission.nameOverride | printf "transmission-%s" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "transmission-openvpn.fullname" -}}
{{- if .Values.transmission.fullnameOverride }}
{{- .Values.transmission.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.transmission.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | printf "transmission-%s" | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "transmission-%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "transmission-openvpn.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "transmission-openvpn.labels" -}}
helm.sh/chart: {{ include "transmission-openvpn.chart" . }}
{{ include "transmission-openvpn.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "transmission-openvpn.selectorLabels" -}}
app.kubernetes.io/name: {{ include "transmission-openvpn.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "transmission-openvpn.serviceAccountName" -}}
{{- if .Values.transmission.serviceAccount.create }}
{{- default (include "transmission-openvpn.fullname" .) .Values.transmission.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.transmission.serviceAccount.name }}
{{- end }}
{{- end }}