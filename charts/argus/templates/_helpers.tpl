{{/*
Expand the name of the chart.
*/}}
{{- define "argus.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "argus.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "argus.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "argus.labels" -}}
helm.sh/chart: {{ include "argus.chart" . }}
{{ include "argus.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "argus.selectorLabels" -}}
app.kubernetes.io/name: {{ include "argus.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "argus.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "argus.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Define shared environment variables */}}
{{- define "argus.env" -}}
- name: PORT
  value: {{ .Values.argus.port | quote }}
- name: STATIC_ROOT
  value: {{ .Values.argus.staticRoot | quote }}
- name: ARGUS_FRONTEND_URL
  value: {{ .Values.argus.frontendUrl | quote }}
- name: TIME_ZONE
  value: {{ .Values.argus.timeZone | quote }}
- name: EMAIL_HOST
  value: {{ .Values.argus.emailHost | quote }}
- name: EMAIL_PORT
  value: {{ .Values.argus.emailPort | quote }}
- name: DEFAULT_FROM_EMAIL
  value: {{ .Values.argus.defaultFromEmail | quote }}
- name: EMAIL_USE_TLS
  value: {{ .Values.argus.emailUseTLS | quote }}
- name: DEBUG
  value: {{ .Values.argus.debug | quote }}
- name: DJANGO_SETTINGS_MODULE
  value: {{ .Values.argus.djangoSettingsModule | quote }}
- name: DATABASE_NAME
  value: {{ .Values.argus.databaseName | quote }}
- name: DATABASE_PORT
  value: {{ .Values.argus.databasePort | quote }}
- name: DJANGO_LOGGING_MODULE
  value: {{ .Values.argus.djangoLoggingModule | quote }}
- name: ARGUS_EMAIL
  value: {{ .Values.argus.argusEmail | quote }}
- name: ARGUS_SEND_NOTIFICATIONS
  value: {{ .Values.argus.sendNotifications | quote }}
{{ if and .Values.argus.argusExistingSecret .Values.argus.secretKeys.djangoSecretKey }}
- name: SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.argusExistingSecret | quote }}
      key: {{ .Values.argus.secretKeys.djangoSecretKey | quote }}
{{ else }}
- name: SECRET_KEY
  value: {{ .Values.argus.djangoSecret | quote }}
{{ end }}
{{ if and .Values.argus.argusExistingSecret .Values.argus.secretKeys.argusUsernameKey .Values.argus.secretKeys.argusPasswordKey }}
- name: ADMIN_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.argusExistingSecret | quote }}
      key: {{ .Values.argus.secretKeys.argusUsernameKey | quote }}
- name: ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.argusExistingSecret | quote }}
      key: {{ .Values.argus.secretKeys.argusPasswordKey | quote }}
{{ else if and .Values.argus.argusUsername .Values.argus.argusPassword }}
- name: ADMIN_USERNAME
  value: {{ .Values.argus.argusUsername | quote }}
- name: ADMIN_PASSWORD
  value: {{ .Values.argus.argusPassword | quote }}
{{ end }}
{{ if .Values.postgresql.enabled }}
- name: DATABASE_HOST
  value: {{ .Release.Name }}-postgresql
{{ else }}
- name: DATABASE_HOST
  value: {{ .Values.argus.databaseHost | quote }}
{{ end }}

{{ if and .Values.argus.databaseExistingSecret .Values.argus.secretKeys.databaseUrlKey }}
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.databaseExistingSecret | quote }}
      key: {{ .Values.argus.secretKeys.databaseUrlKey | quote }}
{{ else if .Values.argus.databaseUrl }}
- name: DATABASE_URL
  value: {{ .Values.argus.databaseUrl | quote }}
{{ else }}
{{ if and .Values.argus.databaseExistingSecret .Values.argus.secretKeys.databaseUsernameKey }}
- name: DATABASE_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.databaseExistingSecret | quote }}
      key: {{ .Values.argus.secretKeys.databaseUsernameKey | quote }}
{{ else }}
- name: DATABASE_USERNAME
  value: {{ .Values.argus.databaseUsername | quote }}
{{ end }}
{{ if and .Values.argus.databaseExistingSecret .Values.argus.secretKeys.databasePasswordKey }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.databaseExistingSecret | quote }}
      key: {{ .Values.argus.secretKeys.databasePasswordKey | quote }}
{{ else }}
- name: DATABASE_PASSWORD
  value: {{ .Values.argus.databasePassword | quote }}
{{ end }}
- name: DATABASE_URL
  value: postgresql://$(DATABASE_USERNAME):$(DATABASE_PASSWORD)@$(DATABASE_HOST):$(DATABASE_PORT)/$(DATABASE_NAME)
{{ end }}

{{ if and .Values.argus.rtExistingSecret .Values.argus.secretKeys.rtTokenKey }}
- name: ARGUS_RT_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.rtExistingSecret | quote }}
      key: {{ .Values.argus.secretKeys.rtTokenKey | quote }}
{{ else }}
- name: ARGUS_RT_TOKEN
  value: {{ .Values.argus.rtToken | quote }}
{{ end }}
- name: SOCIAL_AUTH_REDIRECT_IS_HTTPS
  value: {{ .Values.argus.sso.redirectIsHTTPS | quote }}
- name: SOCIAL_AUTH_OIDC_ENDPOINT
  value: {{ .Values.argus.sso.OIDCEndpoint | quote }}
- name: SOCIAL_AUTH_OIDC_USERNAME_KEY
  value: {{ .Values.argus.sso.OIDCUsernameKey | quote }}
- name: SOCIAL_AUTH_OIDC_SCOPE
  value: {{ .Values.argus.sso.OIDCScope | quote }}

{{ if and .Values.argus.sso.existingSecret .Values.argus.sso.secretKeys.dataportenKeyKey }}
- name: SOCIAL_AUTH_DATAPORTEN_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.sso.existingSecret | quote }}
      key: {{ .Values.argus.sso.secretKeys.dataportenKeyKey | quote }}
{{ else }}
- name: SOCIAL_AUTH_DATAPORTEN_KEY
  value: {{ .Values.argus.sso.dataportenKey | quote }}
{{ end }}

{{ if and .Values.argus.sso.existingSecret .Values.argus.sso.secretKeys.dataportenSecretKey }}
- name: SOCIAL_AUTH_DATAPORTEN_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.sso.existingSecret | quote }}
      key: {{ .Values.argus.sso.secretKeys.dataportenSecretKey | quote }}
{{ else }}
- name: SOCIAL_AUTH_DATAPORTEN_SECRET
  value: {{ .Values.argus.sso.dataportenSecret | quote }}
{{ end }}

{{ if and .Values.argus.sso.existingSecret .Values.argus.sso.secretKeys.dataportenEmailKeyKey }}
- name: SOCIAL_AUTH_DATAPORTEN_EMAIL_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.sso.existingSecret | quote }}
      key: {{ .Values.argus.sso.secretKeys.dataportenEmailKeyKey | quote }}
{{ else }}
- name: SOCIAL_AUTH_DATAPORTEN_EMAIL_KEY
  value: {{ .Values.argus.sso.dataportenEmailKey | quote }}
{{ end }}

{{ if and .Values.argus.sso.existingSecret .Values.argus.sso.secretKeys.dataportenEmailSecretKey }}
- name: SOCIAL_AUTH_DATAPORTEN_EMAIL_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.sso.existingSecret | quote }}
      key: {{ .Values.argus.sso.secretKeys.dataportenEmailSecretKey | quote }}
{{ else }}
- name: SOCIAL_AUTH_DATAPORTEN_EMAIL_SECRET
  value: {{ .Values.argus.sso.dataportenEmailSecret | quote }}
{{ end }}

{{ if and .Values.argus.sso.existingSecret .Values.argus.sso.secretKeys.dataportenFeideKeyKey }}
- name: SOCIAL_AUTH_DATAPORTEN_FEIDE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.sso.existingSecret | quote }}
      key: {{ .Values.argus.sso.secretKeys.dataportenFeideKeyKey | quote }}
{{ else }}
- name: SOCIAL_AUTH_DATAPORTEN_FEIDE_KEY
  value: {{ .Values.argus.sso.dataportenFeideKey | quote }}
{{ end }}

{{ if and .Values.argus.sso.existingSecret .Values.argus.sso.secretKeys.dataportenFeideSecretKey }}
- name: SOCIAL_AUTH_DATAPORTEN_FEIDE_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.sso.existingSecret | quote }}
      key: {{ .Values.argus.sso.secretKeys.dataportenFeideSecretKey | quote }}
{{ else }}
- name: SOCIAL_AUTH_DATAPORTEN_FEIDE_SECRET
  value: {{ .Values.argus.sso.dataportenFeideSecret | quote }}
{{ end }}

{{ if and .Values.argus.sso.existingSecret .Values.argus.sso.secretKeys.OIDCKeyKey }}
- name: SOCIAL_AUTH_OIDC_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.sso.existingSecret | quote }}
      key: {{ .Values.argus.sso.secretKeys.OIDCKeyKey | quote }}
{{ else }}
- name: SOCIAL_AUTH_OIDC_KEY
  value: {{ .Values.argus.sso.OIDCKey | quote }}
{{ end }}

{{ if and .Values.argus.sso.existingSecret .Values.argus.sso.secretKeys.OIDCSecretKey }}
- name: SOCIAL_AUTH_OIDC_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.argus.sso.existingSecret | quote }}
      key: {{ .Values.argus.sso.secretKeys.OIDCSecretKey | quote }}
{{ else }}
- name: SOCIAL_AUTH_OIDC_SECRET
  value: {{ .Values.argus.sso.OIDCSecret | quote }}
{{ end }}
{{- end -}}
