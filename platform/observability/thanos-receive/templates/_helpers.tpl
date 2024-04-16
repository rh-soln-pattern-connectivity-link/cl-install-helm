{{/*
Expand the name of the chart.
*/}}
{{- define "thanos-receive.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "thanos-receive.fullname" -}}
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
{{- define "thanos-receive.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "thanos-receive.ingestor.labels" -}}
helm.sh/chart: {{ include "thanos-receive.chart" . }}
{{ include "thanos-receive.ingestor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
controller.receive.thanos.io: {{ include "thanos-receive.name" . }}-controller
{{- end }}

{{/*
Selector labels
*/}}
{{- define "thanos-receive.ingestor.selectorLabels" -}}
app.kubernetes.io/component: database-write-hashring
app.kubernetes.io/name: {{ include "thanos-receive.name" . }}
app.kubernetes.io/instance: {{ include "thanos-receive.name" . }}-ingestor-default
controller.receive.thanos.io/hashring: default
{{- end }}

{{/*
Common labels
*/}}
{{- define "thanos-receive.router.labels" -}}
helm.sh/chart: {{ include "thanos-receive.chart" . }}
{{ include "thanos-receive.router.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "thanos-receive.router.selectorLabels" -}}
app.kubernetes.io/component: thanos-receive-router
app.kubernetes.io/name: {{ include "thanos-receive.name" . }}
app.kubernetes.io/instance: {{ include "thanos-receive.name" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "thanos-receive.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "thanos-receive.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
