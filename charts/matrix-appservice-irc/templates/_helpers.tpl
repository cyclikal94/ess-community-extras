{{- define "matrix-appservice-irc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "matrix-appservice-irc.fullname" -}}
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

{{- define "matrix-appservice-irc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "matrix-appservice-irc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "matrix-appservice-irc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "matrix-appservice-irc.name" . }}
{{- end -}}

{{- define "matrix-appservice-irc.componentSelectorLabels" -}}
{{ include "matrix-appservice-irc.selectorLabels" .context }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "matrix-appservice-irc.labels" -}}
helm.sh/chart: {{ include "matrix-appservice-irc.chart" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "matrix-appservice-irc.selectorLabels" . }}
{{- end -}}

{{- define "matrix-appservice-irc.componentLabels" -}}
{{ include "matrix-appservice-irc.labels" .context }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "matrix-appservice-irc.image" -}}
{{- if .Values.image.tag -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- else -}}
{{- .Values.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "matrix-appservice-irc.poolImage" -}}
{{- if .Values.pool.image.tag -}}
{{- printf "%s:%s" .Values.pool.image.repository .Values.pool.image.tag -}}
{{- else -}}
{{- .Values.pool.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "matrix-appservice-irc.postgresImage" -}}
{{- if .Values.postgres.image.tag -}}
{{- printf "%s:%s" .Values.postgres.image.repository .Values.postgres.image.tag -}}
{{- else -}}
{{- .Values.postgres.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "matrix-appservice-irc.redisImage" -}}
{{- if .Values.redis.image.tag -}}
{{- printf "%s:%s" .Values.redis.image.repository .Values.redis.image.tag -}}
{{- else -}}
{{- .Values.redis.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "matrix-appservice-irc.waitForRedisImage" -}}
{{- if .Values.waitForRedis.image.tag -}}
{{- printf "%s:%s" .Values.waitForRedis.image.repository .Values.waitForRedis.image.tag -}}
{{- else -}}
{{- .Values.waitForRedis.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "matrix-appservice-irc.configMapName" -}}
{{- printf "%s-config" (include "matrix-appservice-irc.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "matrix-appservice-irc.registrationConfigMapName" -}}
{{- if .Values.registration.synapseConfigMapName -}}
{{- .Values.registration.synapseConfigMapName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-registration" (include "matrix-appservice-irc.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "matrix-appservice-irc.ingressName" -}}
{{- if .Values.ingress.name -}}
{{- .Values.ingress.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-media-proxy" (include "matrix-appservice-irc.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "matrix-appservice-irc.postgresFullname" -}}
{{- printf "%s-postgres" (include "matrix-appservice-irc.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "matrix-appservice-irc.redisFullname" -}}
{{- printf "%s-redis" (include "matrix-appservice-irc.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "matrix-appservice-irc.mediaProxyPublicUrl" -}}
{{- if .Values.mediaProxy.publicUrl -}}
{{- .Values.mediaProxy.publicUrl -}}
{{- else -}}
{{- printf "https://%s" (required "values.host is required (example: irc-media.example.com)" .Values.host) -}}
{{- end -}}
{{- end -}}

{{- define "matrix-appservice-irc.homeserverDomain" -}}
{{- required "values.homeserver.domain is required (example: matrix.example.com)" .Values.homeserver.domain -}}
{{- end -}}

{{- define "matrix-appservice-irc.synapseNamespace" -}}
{{- default .Release.Namespace .Values.registration.synapseNamespace -}}
{{- end -}}

{{- define "matrix-appservice-irc.registrationServiceUrl" -}}
{{- if .Values.registration.serviceUrl -}}
{{- .Values.registration.serviceUrl -}}
{{- else -}}
{{- printf "http://%s.%s.svc.cluster.local:%v" (include "matrix-appservice-irc.fullname" .) .Release.Namespace .Values.service.appservicePort -}}
{{- end -}}
{{- end -}}

{{- define "matrix-appservice-irc.registrationUserRegex" -}}
{{- printf "@irc_.*:%s" (include "matrix-appservice-irc.homeserverDomain" .) -}}
{{- end -}}

{{- define "matrix-appservice-irc.registrationAliasRegex" -}}
{{- printf "#irc_.*:%s" (include "matrix-appservice-irc.homeserverDomain" .) -}}
{{- end -}}

{{- define "matrix-appservice-irc.databaseConnectionString" -}}
{{- if .Values.database.connectionString -}}
{{- .Values.database.connectionString -}}
{{- else if .Values.postgres.enabled -}}
{{- printf "postgres://%s:%s@%s:%v/%s" .Values.database.user .Values.database.password (include "matrix-appservice-irc.postgresFullname" .) .Values.postgres.service.port .Values.database.name -}}
{{- else -}}
{{- required "values.database.connectionString is required when postgres.enabled=false" .Values.database.connectionString -}}
{{- end -}}
{{- end -}}

{{- define "matrix-appservice-irc.redisUrl" -}}
{{- if .Values.redis.url -}}
{{- .Values.redis.url -}}
{{- else if .Values.redis.enabled -}}
{{- printf "redis://%s:%v/0" (include "matrix-appservice-irc.redisFullname" .) .Values.redis.service.port -}}
{{- else -}}
{{- required "values.redis.url is required when redis.enabled=false" .Values.redis.url -}}
{{- end -}}
{{- end -}}

{{- define "matrix-appservice-irc.waitForRedisHost" -}}
{{- include "matrix-appservice-irc.redisFullname" . -}}
{{- end -}}

{{- define "matrix-appservice-irc.registrationTokenSecretName" -}}
{{- printf "%s-registration-tokens" (include "matrix-appservice-irc.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "matrix-appservice-irc.ensureRegistrationTokens" -}}
{{- if not (hasKey .Values.registration "_computedTokens") -}}
{{- $secretName := include "matrix-appservice-irc.registrationTokenSecretName" . -}}
{{- $existing := lookup "v1" "Secret" .Release.Namespace $secretName -}}
{{- $asToken := .Values.registration.asToken | default "" -}}
{{- $hsToken := .Values.registration.hsToken | default "" -}}
{{- if and (eq $asToken "") $existing (hasKey $existing.data "asToken") -}}
{{- $asToken = (index $existing.data "asToken" | b64dec) -}}
{{- end -}}
{{- if and (eq $hsToken "") $existing (hasKey $existing.data "hsToken") -}}
{{- $hsToken = (index $existing.data "hsToken" | b64dec) -}}
{{- end -}}
{{- if eq $asToken "" -}}
{{- $asToken = (randAlphaNum 64 | sha256sum) -}}
{{- end -}}
{{- if eq $hsToken "" -}}
{{- $hsToken = (randAlphaNum 64 | sha256sum) -}}
{{- end -}}
{{- $_ := set .Values.registration "_computedTokens" (dict "asToken" $asToken "hsToken" $hsToken) -}}
{{- end -}}
{{- end -}}

{{- define "matrix-appservice-irc.registrationAsToken" -}}
{{- include "matrix-appservice-irc.ensureRegistrationTokens" . -}}
{{- index (index .Values.registration "_computedTokens") "asToken" -}}
{{- end -}}

{{- define "matrix-appservice-irc.registrationHsToken" -}}
{{- include "matrix-appservice-irc.ensureRegistrationTokens" . -}}
{{- index (index .Values.registration "_computedTokens") "hsToken" -}}
{{- end -}}

{{- define "matrix-appservice-irc.registrationConfig" -}}
id: {{ .Values.registration.id }}
url: {{ include "matrix-appservice-irc.registrationServiceUrl" . | quote }}
as_token: {{ include "matrix-appservice-irc.registrationAsToken" . | quote }}
hs_token: {{ include "matrix-appservice-irc.registrationHsToken" . | quote }}
sender_localpart: {{ .Values.registration.senderLocalpart | quote }}
rate_limited: {{ .Values.registration.rateLimited }}
namespaces:
  users:
    - exclusive: true
      regex: {{ include "matrix-appservice-irc.registrationUserRegex" . | squote }}
  aliases:
    - exclusive: true
      regex: {{ include "matrix-appservice-irc.registrationAliasRegex" . | squote }}
protocols:
{{- range .Values.registration.protocols }}
  - {{ . | quote }}
{{- end }}
{{- end -}}
