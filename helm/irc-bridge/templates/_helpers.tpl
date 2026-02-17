{{- define "irc-bridge.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "irc-bridge.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "irc-bridge.selectorLabels" -}}
app.kubernetes.io/name: {{ include "irc-bridge.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "irc-bridge.name" . }}
{{- end -}}

{{- define "irc-bridge.componentSelectorLabels" -}}
{{ include "irc-bridge.selectorLabels" .context }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "irc-bridge.labels" -}}
helm.sh/chart: {{ include "irc-bridge.chart" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "irc-bridge.selectorLabels" . }}
{{- end -}}

{{- define "irc-bridge.componentLabels" -}}
{{ include "irc-bridge.labels" .context }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "irc-bridge.image" -}}
{{- if .Values.image.tag -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- else -}}
{{- .Values.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.poolImage" -}}
{{- if .Values.pool.image.tag -}}
{{- printf "%s:%s" .Values.pool.image.repository .Values.pool.image.tag -}}
{{- else -}}
{{- .Values.pool.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.postgresImage" -}}
{{- if .Values.postgres.image.tag -}}
{{- printf "%s:%s" .Values.postgres.image.repository .Values.postgres.image.tag -}}
{{- else -}}
{{- .Values.postgres.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.redisImage" -}}
{{- if .Values.redis.image.tag -}}
{{- printf "%s:%s" .Values.redis.image.repository .Values.redis.image.tag -}}
{{- else -}}
{{- .Values.redis.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.waitForRedisImage" -}}
{{- if .Values.waitForRedis.image.tag -}}
{{- printf "%s:%s" .Values.waitForRedis.image.repository .Values.waitForRedis.image.tag -}}
{{- else -}}
{{- .Values.waitForRedis.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.configMapName" -}}
{{- printf "%s-config" (include "irc-bridge.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "irc-bridge.registrationConfigMapName" -}}
{{- if .Values.registration.synapseConfigMapName -}}
{{- .Values.registration.synapseConfigMapName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-registration" (include "irc-bridge.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.ingressName" -}}
{{- if .Values.ingress.name -}}
{{- .Values.ingress.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-media-proxy" (include "irc-bridge.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.postgresFullname" -}}
{{- printf "%s-postgres" (include "irc-bridge.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "irc-bridge.redisFullname" -}}
{{- printf "%s-redis" (include "irc-bridge.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "irc-bridge.mediaProxyPublicUrl" -}}
{{- if .Values.mediaProxy.publicUrl -}}
{{- .Values.mediaProxy.publicUrl -}}
{{- else -}}
{{- printf "https://%s" (required "values.host is required (example: irc-media.example.com)" .Values.host) -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.registrationServiceUrl" -}}
{{- if .Values.registration.serviceUrl -}}
{{- .Values.registration.serviceUrl -}}
{{- else -}}
{{- printf "http://%s.%s.svc.cluster.local:%v" (include "irc-bridge.fullname" .) .Release.Namespace .Values.service.appservicePort -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.registrationUserRegex" -}}
{{- if .Values.registration.userRegex -}}
{{- .Values.registration.userRegex -}}
{{- else -}}
{{- printf "@irc_.*:%s" .Values.homeserver.domain -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.registrationAliasRegex" -}}
{{- if .Values.registration.aliasRegex -}}
{{- .Values.registration.aliasRegex -}}
{{- else -}}
{{- printf "#irc_.*:%s" .Values.homeserver.domain -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.databaseConnectionString" -}}
{{- if .Values.database.connectionString -}}
{{- .Values.database.connectionString -}}
{{- else if .Values.postgres.enabled -}}
{{- printf "postgres://%s:%s@%s:%v/%s" .Values.database.user .Values.database.password (include "irc-bridge.postgresFullname" .) .Values.postgres.service.port .Values.database.name -}}
{{- else -}}
{{- required "values.database.connectionString is required when postgres.enabled=false" .Values.database.connectionString -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.redisUrl" -}}
{{- if .Values.redis.url -}}
{{- .Values.redis.url -}}
{{- else if .Values.redis.enabled -}}
{{- printf "redis://%s:%v/0" (include "irc-bridge.redisFullname" .) .Values.redis.service.port -}}
{{- else -}}
{{- required "values.redis.url is required when redis.enabled=false" .Values.redis.url -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.waitForRedisHost" -}}
{{- if .Values.waitForRedis.host -}}
{{- .Values.waitForRedis.host -}}
{{- else if .Values.redis.enabled -}}
{{- include "irc-bridge.redisFullname" . -}}
{{- else -}}
{{- required "values.waitForRedis.host is required when redis.enabled=false and waitForRedis.enabled=true" .Values.waitForRedis.host -}}
{{- end -}}
{{- end -}}

{{- define "irc-bridge.registrationConfig" -}}
id: {{ .Values.registration.id }}
url: {{ include "irc-bridge.registrationServiceUrl" . | quote }}
as_token: {{ .Values.registration.asToken | quote }}
hs_token: {{ .Values.registration.hsToken | quote }}
sender_localpart: {{ .Values.registration.senderLocalpart | quote }}
rate_limited: {{ .Values.registration.rateLimited }}
namespaces:
  users:
    - exclusive: true
      regex: {{ include "irc-bridge.registrationUserRegex" . | squote }}
  aliases:
    - exclusive: true
      regex: {{ include "irc-bridge.registrationAliasRegex" . | squote }}
protocols:
{{- range .Values.registration.protocols }}
  - {{ . | quote }}
{{- end }}
{{- end -}}
