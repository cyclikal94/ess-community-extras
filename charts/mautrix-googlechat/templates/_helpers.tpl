{{- define "mautrix-googlechat.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mautrix-googlechat.fullname" -}}
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

{{- define "mautrix-googlechat.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mautrix-googlechat.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mautrix-googlechat.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "mautrix-googlechat.name" . }}
{{- end -}}

{{- define "mautrix-googlechat.componentSelectorLabels" -}}
{{ include "mautrix-googlechat.selectorLabels" .context }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "mautrix-googlechat.labels" -}}
helm.sh/chart: {{ include "mautrix-googlechat.chart" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "mautrix-googlechat.selectorLabels" . }}
{{- end -}}

{{- define "mautrix-googlechat.componentLabels" -}}
{{ include "mautrix-googlechat.labels" .context }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "mautrix-googlechat.image" -}}
{{- if .Values.image.tag -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- else -}}
{{- .Values.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-googlechat.postgresImage" -}}
{{- if .Values.postgres.image.tag -}}
{{- printf "%s:%s" .Values.postgres.image.repository .Values.postgres.image.tag -}}
{{- else -}}
{{- .Values.postgres.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-googlechat.configSecretName" -}}
{{- printf "%s-config" (include "mautrix-googlechat.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mautrix-googlechat.registrationConfigMapName" -}}
{{- if .Values.registration.synapseConfigMapName -}}
{{- .Values.registration.synapseConfigMapName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-registration" (include "mautrix-googlechat.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-googlechat.registrationFileKey" -}}
appservice-registration-googlechat.yaml
{{- end -}}

{{- define "mautrix-googlechat.homeserverDomain" -}}
{{- required "values.homeserver.domain is required (example: matrix.example.com)" .Values.homeserver.domain -}}
{{- end -}}

{{- define "mautrix-googlechat.postgresFullname" -}}
{{- printf "%s-postgres" (include "mautrix-googlechat.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mautrix-googlechat.databasePostgresDatabase" -}}
{{- $postgres := .Values.database.postgres | default dict -}}
{{- $database := (get $postgres "database") | default "" -}}
{{- required "values.database.postgres.database is required" $database -}}
{{- end -}}

{{- define "mautrix-googlechat.databasePostgresUser" -}}
{{- $postgres := .Values.database.postgres | default dict -}}
{{- $user := (get $postgres "user") | default "" -}}
{{- required "values.database.postgres.user is required" $user -}}
{{- end -}}

{{- define "mautrix-googlechat.databasePostgresPassword" -}}
{{- $postgres := .Values.database.postgres | default dict -}}
{{- $passwordCfg := (get $postgres "password") | default dict -}}
{{- $password := (get $passwordCfg "value") | default "" -}}
{{- required "values.database.postgres.password.value is required" $password -}}
{{- end -}}

{{- define "mautrix-googlechat.databaseConnectionString" -}}
{{- $postgres := .Values.database.postgres | default dict -}}
{{- $host := (get $postgres "host") | default "" -}}
{{- $port := (get $postgres "port") | default 5432 -}}
{{- if and (eq $host "") .Values.postgres.enabled -}}
{{- $host = include "mautrix-googlechat.postgresFullname" . -}}
{{- $port = .Values.postgres.service.port -}}
{{- end -}}
{{- if eq $host "" -}}
{{- fail "values.database.postgres.host is required when postgres.enabled=false" -}}
{{- end -}}
{{- $database := include "mautrix-googlechat.databasePostgresDatabase" . -}}
{{- $user := include "mautrix-googlechat.databasePostgresUser" . -}}
{{- $password := include "mautrix-googlechat.databasePostgresPassword" . -}}
{{- $sslMode := (get $postgres "sslMode") | default "" -}}
{{- $connectionString := printf "postgres://%s:%s@%s:%v/%s" ($user | urlquery) ($password | urlquery) $host $port ($database | urlquery) -}}
{{- if ne $sslMode "" -}}
{{- printf "%s?sslmode=%s" $connectionString ($sslMode | urlquery) -}}
{{- else -}}
{{- $connectionString -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-googlechat.appserviceAddress" -}}
{{- if .Values.appservice.address -}}
{{- .Values.appservice.address -}}
{{- else -}}
{{- printf "http://%s.%s.svc.cluster.local:%v" (include "mautrix-googlechat.fullname" .) .Release.Namespace .Values.service.port -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-googlechat.registrationServiceUrl" -}}
{{- if .Values.registration.serviceUrl -}}
{{- .Values.registration.serviceUrl -}}
{{- else -}}
{{- include "mautrix-googlechat.appserviceAddress" . -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-googlechat.runtimeSecretName" -}}
{{- if .Values.registration.existingSecret -}}
{{- .Values.registration.existingSecret -}}
{{- else if .Values.registration.managedSecret.name -}}
{{- .Values.registration.managedSecret.name -}}
{{- else -}}
{{- printf "%s-runtime-secrets" (include "mautrix-googlechat.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-googlechat.ensureRuntimeSecrets" -}}
{{- if not (hasKey .Values.registration "_computedRuntimeSecrets") -}}
{{- $useExistingSecret := ne (.Values.registration.existingSecret | default "") "" -}}
{{- $managedSecretEnabled := and (not $useExistingSecret) .Values.registration.managedSecret.enabled -}}
{{- $secretName := include "mautrix-googlechat.runtimeSecretName" . -}}
{{- $existing := lookup "v1" "Secret" .Release.Namespace $secretName -}}
{{- $asToken := .Values.registration.asToken | default "" -}}
{{- $hsToken := .Values.registration.hsToken | default "" -}}
{{- $provisioning := .Values.appservice.provisioning.sharedSecret | default "" -}}
{{- if eq $asToken "generate" -}}
{{- fail "values.registration.asToken must not be set to 'generate'; leave empty for auto-generation" -}}
{{- end -}}
{{- if eq $hsToken "generate" -}}
{{- fail "values.registration.hsToken must not be set to 'generate'; leave empty for auto-generation" -}}
{{- end -}}
{{- if eq $provisioning "generate" -}}
{{- fail "values.appservice.provisioning.sharedSecret must not be set to 'generate'; leave empty for auto-generation" -}}
{{- end -}}
{{- if and (eq $asToken "") $existing (hasKey $existing.data "asToken") -}}
{{- $asToken = (index $existing.data "asToken" | b64dec) -}}
{{- end -}}
{{- if and (eq $hsToken "") $existing (hasKey $existing.data "hsToken") -}}
{{- $hsToken = (index $existing.data "hsToken" | b64dec) -}}
{{- end -}}
{{- if and (eq $provisioning "") $existing (hasKey $existing.data "provisioningSharedSecret") -}}
{{- $provisioning = (index $existing.data "provisioningSharedSecret" | b64dec) -}}
{{- end -}}
{{- if eq $asToken "" -}}
{{- if and .Values.registration.autoGenerate $managedSecretEnabled -}}
{{- $asToken = (randAlphaNum 64 | sha256sum) -}}
{{- else -}}
{{- fail (printf "registration.asToken is required when missing from secret %q (set registration.asToken, set registration.existingSecret to a populated Secret, or enable registration.autoGenerate with registration.managedSecret.enabled=true)" $secretName) -}}
{{- end -}}
{{- end -}}
{{- if eq $hsToken "" -}}
{{- if and .Values.registration.autoGenerate $managedSecretEnabled -}}
{{- $hsToken = (randAlphaNum 64 | sha256sum) -}}
{{- else -}}
{{- fail (printf "registration.hsToken is required when missing from secret %q (set registration.hsToken, set registration.existingSecret to a populated Secret, or enable registration.autoGenerate with registration.managedSecret.enabled=true)" $secretName) -}}
{{- end -}}
{{- end -}}
{{- if eq $provisioning "" -}}
{{- if and .Values.registration.autoGenerate $managedSecretEnabled -}}
{{- $provisioning = (randAlphaNum 64 | sha256sum) -}}
{{- else -}}
{{- fail (printf "appservice.provisioning.sharedSecret is required when missing from secret %q (set appservice.provisioning.sharedSecret, set registration.existingSecret to a populated Secret, or enable registration.autoGenerate with registration.managedSecret.enabled=true)" $secretName) -}}
{{- end -}}
{{- end -}}
{{- $_ := set .Values.registration "_computedRuntimeSecrets" (dict "asToken" $asToken "hsToken" $hsToken "provisioningSharedSecret" $provisioning) -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-googlechat.registrationAsToken" -}}
{{- include "mautrix-googlechat.ensureRuntimeSecrets" . -}}
{{- index (index .Values.registration "_computedRuntimeSecrets") "asToken" -}}
{{- end -}}

{{- define "mautrix-googlechat.registrationHsToken" -}}
{{- include "mautrix-googlechat.ensureRuntimeSecrets" . -}}
{{- index (index .Values.registration "_computedRuntimeSecrets") "hsToken" -}}
{{- end -}}

{{- define "mautrix-googlechat.provisioningSharedSecret" -}}
{{- include "mautrix-googlechat.ensureRuntimeSecrets" . -}}
{{- index (index .Values.registration "_computedRuntimeSecrets") "provisioningSharedSecret" -}}
{{- end -}}

{{- define "mautrix-googlechat.registrationSenderLocalpart" -}}
{{- if .Values.registration.senderLocalpart -}}
{{- .Values.registration.senderLocalpart -}}
{{- else -}}
{{- .Values.appservice.botUsername -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-googlechat.renderTemplateRegex" -}}
{{- $template := .template -}}
{{- $field := .field -}}
{{- $normalized := include "mautrix-googlechat.normalizeBridgeTemplate" (dict "template" $template "field" $field "legacyReplacement" "{placeholder}") -}}
{{- regexReplaceAll "\\{[A-Za-z_][A-Za-z0-9_]*\\}" $normalized ".*" -}}
{{- end -}}

{{- define "mautrix-googlechat.normalizeBridgeTemplate" -}}
{{- $template := .template -}}
{{- $field := .field -}}
{{- $legacyReplacement := .legacyReplacement -}}
{{- if contains "{{.}}" $template -}}
{{- replace "{{.}}" $legacyReplacement $template -}}
{{- else if regexMatch "\\{[A-Za-z_][A-Za-z0-9_]*\\}" $template -}}
{{- $template -}}
{{- else -}}
{{- fail (printf "values.%s must contain either '{{.}}' (legacy) or '{placeholder}'" $field) -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-googlechat.registrationUserRegex" -}}
{{- if .Values.registration.userRegex -}}
{{- .Values.registration.userRegex -}}
{{- else -}}
{{- printf "@%s:%s" (include "mautrix-googlechat.renderTemplateRegex" (dict "template" .Values.bridge.usernameTemplate "field" "bridge.usernameTemplate")) (include "mautrix-googlechat.homeserverDomain" .) -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-googlechat.registrationAliasRegex" -}}
{{- if .Values.registration.aliasRegex -}}
{{- .Values.registration.aliasRegex -}}
{{- else -}}
{{- printf "#%s:%s" (include "mautrix-googlechat.renderTemplateRegex" (dict "template" .Values.bridge.aliasTemplate "field" "bridge.aliasTemplate")) (include "mautrix-googlechat.homeserverDomain" .) -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-googlechat.registrationConfig" -}}
id: {{ .Values.appservice.id | quote }}
url: {{ include "mautrix-googlechat.registrationServiceUrl" . | quote }}
as_token: {{ include "mautrix-googlechat.registrationAsToken" . | quote }}
hs_token: {{ include "mautrix-googlechat.registrationHsToken" . | quote }}
sender_localpart: {{ include "mautrix-googlechat.registrationSenderLocalpart" . | quote }}
rate_limited: {{ .Values.registration.rateLimited }}
de.sorunome.msc2409.push_ephemeral: {{ .Values.appservice.ephemeralEvents }}
namespaces:
  users:
    - exclusive: true
      regex: {{ include "mautrix-googlechat.registrationUserRegex" . | squote }}
  aliases:
    - exclusive: true
      regex: {{ include "mautrix-googlechat.registrationAliasRegex" . | squote }}
{{- end -}}
