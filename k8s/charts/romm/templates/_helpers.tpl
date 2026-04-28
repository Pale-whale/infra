{{/* Chart name (e.g. "romm") */}}
{{- define "romm.name" -}}
{{- default .Chart.Name .Values.romm.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully-qualified release-scoped name. If the release already starts with the
chart name, return it as-is to avoid the duplicated "romm-romm" prefix.
*/}}
{{- define "romm.fullname" -}}
{{- $name := default .Chart.Name .Values.romm.fullnameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{- define "romm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "romm.labels" -}}
helm.sh/chart: {{ include "romm.chart" . }}
{{ include "romm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "romm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "romm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: app
{{- end }}

{{- define "romm.serviceAccountName" -}}
{{- if .Values.romm.serviceAccount.create }}
{{- default (include "romm.fullname" .) .Values.romm.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.romm.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* MariaDB-related names. */}}
{{- define "romm.mariadb.fullname" -}}
{{- printf "%s-mariadb" (include "romm.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "romm.mariadb.labels" -}}
helm.sh/chart: {{ include "romm.chart" . }}
{{ include "romm.mariadb.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "romm.mariadb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "romm.name" . }}-mariadb
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: database
{{- end }}

{{/*
Resolve the database host the romm pod should connect to.
Falls back to the in-cluster MariaDB service when type is embedded/operator.
*/}}
{{- define "romm.database.host" -}}
{{- if .Values.database.connection.host -}}
{{ .Values.database.connection.host }}
{{- else if eq .Values.database.type "embedded" -}}
{{ include "romm.mariadb.fullname" . }}
{{- else if eq .Values.database.type "operator" -}}
{{ include "romm.mariadb.fullname" . }}
{{- else -}}
{{- fail "database.connection.host must be set when database.type=external" -}}
{{- end -}}
{{- end }}

{{/*
Name of the secret holding the database user password.
Either user-provided (auth.existingSecret.name) or the one this chart creates.
*/}}
{{- define "romm.database.userPasswordSecretName" -}}
{{- if .Values.database.auth.existingSecret.name -}}
{{ .Values.database.auth.existingSecret.name }}
{{- else -}}
{{ include "romm.fullname" . }}-db
{{- end -}}
{{- end }}

{{- define "romm.database.userPasswordSecretKey" -}}
{{- default "password" .Values.database.auth.existingSecret.key }}
{{- end }}

{{/*
Name of the secret holding the MariaDB root password.
Only meaningful when type=embedded or type=operator.
*/}}
{{- define "romm.database.rootPasswordSecretName" -}}
{{- if .Values.database.auth.rootExistingSecret.name -}}
{{ .Values.database.auth.rootExistingSecret.name }}
{{- else -}}
{{ include "romm.fullname" . }}-db-root
{{- end -}}
{{- end }}

{{- define "romm.database.rootPasswordSecretKey" -}}
{{- default "password" .Values.database.auth.rootExistingSecret.key }}
{{- end }}

{{/*
Name of the secret holding the romm auth secret key.
*/}}
{{- define "romm.auth.secretName" -}}
{{- if .Values.romm.auth.existingSecret.name -}}
{{ .Values.romm.auth.existingSecret.name }}
{{- else if .Values.romm.auth.externalSecret.enabled -}}
{{ include "romm.fullname" . }}-auth
{{- else -}}
{{- fail "romm.auth.existingSecret.name or romm.auth.externalSecret.enabled must be set" -}}
{{- end -}}
{{- end }}

{{- define "romm.auth.secretKey" -}}
{{- if .Values.romm.auth.existingSecret.key -}}
{{ .Values.romm.auth.existingSecret.key }}
{{- else -}}
secret-key
{{- end -}}
{{- end }}

{{/*
Name of the secret holding the OIDC client secret.
*/}}
{{- define "romm.oidc.clientSecretName" -}}
{{- if .Values.romm.oidc.clientSecret.existingSecret.name -}}
{{ .Values.romm.oidc.clientSecret.existingSecret.name }}
{{- else if .Values.romm.oidc.clientSecret.externalSecret.enabled -}}
{{ include "romm.fullname" . }}-oidc
{{- else -}}
{{- fail "romm.oidc.clientSecret.existingSecret.name or romm.oidc.clientSecret.externalSecret.enabled must be set when oidc is enabled" -}}
{{- end -}}
{{- end }}

{{- define "romm.oidc.clientSecretKey" -}}
{{- if .Values.romm.oidc.clientSecret.existingSecret.key -}}
{{ .Values.romm.oidc.clientSecret.existingSecret.key }}
{{- else -}}
client-secret
{{- end -}}
{{- end }}

{{/*
romm.providerCredEnv — render a single env var from a provider credential.
Args (dict): envName, ref, providerKey, ctx
  - envName     : the env variable name (e.g. IGDB_CLIENT_SECRET)
  - ref         : the credential value struct ({value, existingSecret, externalSecret})
  - providerKey : provider id, used to derive chart-managed Secret names
  - ctx         : root context (for include "romm.fullname")
Resolution order: existingSecret > externalSecret > value.
*/}}
{{- define "romm.providerCredEnv" -}}
{{- $ref := .ref -}}
- name: {{ .envName }}
{{- if $ref.existingSecret.name }}
  valueFrom:
    secretKeyRef:
      name: {{ $ref.existingSecret.name }}
      key: {{ default "value" $ref.existingSecret.key }}
{{- else if $ref.externalSecret.enabled }}
  valueFrom:
    secretKeyRef:
      name: {{ printf "%s-%s" (include "romm.fullname" .ctx) .providerKey }}
      key: value
{{- else if $ref.value }}
  value: {{ $ref.value | quote }}
{{- else }}
{{- fail (printf "providers.%s requires one of: value, existingSecret.name, or externalSecret.enabled" .providerKey) -}}
{{- end }}
{{- end }}

{{/*
romm.providerEnvVars — render all env vars contributed by enabled metadata
providers. Output is a list of YAML env entries (no leading indent); call site
should `nindent` to the right column.
*/}}
{{- define "romm.providerEnvVars" -}}
{{- $p := .Values.romm.providers -}}
{{- if $p.igdb.enabled }}
- name: IGDB_CLIENT_ID
  value: {{ required "providers.igdb.clientId is required when igdb is enabled" $p.igdb.clientId | quote }}
{{ include "romm.providerCredEnv" (dict "envName" "IGDB_CLIENT_SECRET" "ref" $p.igdb.clientSecret "providerKey" "igdb" "ctx" .) }}
{{- end }}
{{- if $p.screenscraper.enabled }}
- name: SCREENSCRAPER_USER
  value: {{ required "providers.screenscraper.username is required when screenscraper is enabled" $p.screenscraper.username | quote }}
{{ include "romm.providerCredEnv" (dict "envName" "SCREENSCRAPER_PASSWORD" "ref" $p.screenscraper.password "providerKey" "screenscraper" "ctx" .) }}
{{- end }}
{{- if $p.mobygames.enabled }}
{{ include "romm.providerCredEnv" (dict "envName" "MOBYGAMES_API_KEY" "ref" $p.mobygames.apiKey "providerKey" "mobygames" "ctx" .) }}
{{- end }}
{{- if $p.steamgriddb.enabled }}
{{ include "romm.providerCredEnv" (dict "envName" "STEAMGRIDDB_API_KEY" "ref" $p.steamgriddb.apiKey "providerKey" "steamgriddb" "ctx" .) }}
{{- end }}
{{- if $p.retroachievements.enabled }}
{{ include "romm.providerCredEnv" (dict "envName" "RETROACHIEVEMENTS_API_KEY" "ref" $p.retroachievements.apiKey "providerKey" "retroachievements" "ctx" .) }}
{{- with $p.retroachievements.refreshCacheDays }}
- name: REFRESH_RETROACHIEVEMENTS_CACHE_DAYS
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- if $p.launchbox.enabled }}
- name: LAUNCHBOX_API_ENABLED
  value: "true"
{{- if $p.launchbox.scheduledUpdate.enabled }}
- name: ENABLE_SCHEDULED_UPDATE_LAUNCHBOX_METADATA
  value: "true"
{{- with $p.launchbox.scheduledUpdate.cron }}
- name: SCHEDULED_UPDATE_LAUNCHBOX_METADATA_CRON
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- if $p.hasheous.enabled }}
- name: HASHEOUS_API_ENABLED
  value: "true"
{{- end }}
{{- if $p.playmatch.enabled }}
- name: PLAYMATCH_API_ENABLED
  value: "true"
{{- end }}
{{- if $p.flashpoint.enabled }}
- name: FLASHPOINT_API_ENABLED
  value: "true"
{{- end }}
{{- if $p.hltb.enabled }}
- name: HLTB_API_ENABLED
  value: "true"
{{- end }}
{{- end }}
