{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "saikirannginx.name" }}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
*/}}
{{- define "saikirannginx.fullname" }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Calculate nginx certificate
*/}}
{{- define "saikirannginx.nginx-certificate" }}
{{- if (not (empty .Values.ingress.nginx.certificate)) }}
{{- printf .Values.ingress.nginx.certificate }}
{{- else }}
{{- printf "%s-nginx-letsencrypt" (include "saikirannginx.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate pgadmin certificate
*/}}
{{- define "saikirannginx.pgadmin-certificate" }}
{{- if (not (empty .Values.ingress.pgadmin.certificate)) }}
{{- printf .Values.ingress.pgadmin.certificate }}
{{- else }}
{{- printf "%s-pgadmin-letsencrypt" (include "saikirannginx.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate nginx hostname
*/}}
{{- define "saikirannginx.nginx-hostname" }}
{{- if (and .Values.config.nginx.hostname (not (empty .Values.config.nginx.hostname))) }}
{{- printf .Values.config.nginx.hostname }}
{{- else }}
{{- if .Values.ingress.nginx.enabled }}
{{- printf .Values.ingress.nginx.hostname }}
{{- else }}
{{- printf "%s-nginx" (include "saikirannginx.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate nginx base url
*/}}
{{- define "saikirannginx.nginx-base-url" }}
{{- if (and .Values.config.nginx.baseUrl (not (empty .Values.config.nginx.baseUrl))) }}
{{- printf .Values.config.nginx.baseUrl }}
{{- else }}
{{- if .Values.ingress.nginx.enabled }}
{{- $hostname := ((empty (include "saikirannginx.nginx-hostname" .)) | ternary .Values.ingress.nginx.hostname (include "saikirannginx.nginx-hostname" .)) }}
{{- $path := (eq .Values.ingress.nginx.path "/" | ternary "" .Values.ingress.nginx.path) }}
{{- $protocol := (.Values.ingress.nginx.tls | ternary "https" "http") }}
{{- printf "%s://%s%s" $protocol $hostname $path }}
{{- else }}
{{- printf "http://%s" (include "saikirannginx.nginx-hostname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate postgres url
*/}}
{{- define "saikirannginx.postgres-url" }}
{{- $postgres := .Values.config.postgres }}
{{- if $postgres.internal }}
{{- $credentials := (printf "%s:%s" $postgres.username $postgres.password) }}
{{- printf "postgresql://%s@%s-postgres:5432/%s" $credentials (include "saikirannginx.fullname" .) $postgres.database }}
{{- else }}
{{- if $postgres.url }}
{{- printf $postgres.url }}
{{- else }}
{{- printf "postgresql://%s@%s:%s/%s" $credentials $postgres.host $postgres.port $postgres.database }}
{{- end }}
{{- end }}
{{- end }}
