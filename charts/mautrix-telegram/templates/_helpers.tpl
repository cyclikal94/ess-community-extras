{{- define "mautrix-telegram.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mautrix-telegram.fullname" -}}
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

{{- define "mautrix-telegram.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mautrix-telegram.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mautrix-telegram.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "mautrix-telegram.name" . }}
{{- end -}}

{{- define "mautrix-telegram.componentSelectorLabels" -}}
{{ include "mautrix-telegram.selectorLabels" .context }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "mautrix-telegram.labels" -}}
helm.sh/chart: {{ include "mautrix-telegram.chart" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "mautrix-telegram.selectorLabels" . }}
{{- end -}}

{{- define "mautrix-telegram.componentLabels" -}}
{{ include "mautrix-telegram.labels" .context }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "mautrix-telegram.image" -}}
{{- if .Values.image.tag -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- else -}}
{{- .Values.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-telegram.postgresImage" -}}
{{- if .Values.postgres.image.tag -}}
{{- printf "%s:%s" .Values.postgres.image.repository .Values.postgres.image.tag -}}
{{- else -}}
{{- .Values.postgres.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-telegram.configSecretName" -}}
{{- printf "%s-config" (include "mautrix-telegram.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mautrix-telegram.registrationConfigMapName" -}}
{{- if .Values.registration.synapseConfigMapName -}}
{{- .Values.registration.synapseConfigMapName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-registration" (include "mautrix-telegram.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-telegram.registrationFileKey" -}}
appservice-registration-telegram.yaml
{{- end -}}

{{- define "mautrix-telegram.synapseNamespace" -}}
{{- default .Release.Namespace .Values.registration.synapseNamespace -}}
{{- end -}}

{{- define "mautrix-telegram.homeserverDomain" -}}
{{- required "values.homeserver.domain is required (example: matrix.example.com)" .Values.homeserver.domain -}}
{{- end -}}

{{- define "mautrix-telegram.telegramApiID" -}}
{{- $apiID := int64 .Values.telegram.apiID -}}
{{- if lt $apiID 1 -}}
{{- fail "values.telegram.apiID is required and must be greater than 0" -}}
{{- end -}}
{{- printf "%d" $apiID -}}
{{- end -}}

{{- define "mautrix-telegram.telegramApiHash" -}}
{{- required "values.telegram.apiHash is required" .Values.telegram.apiHash -}}
{{- end -}}

{{- define "mautrix-telegram.postgresFullname" -}}
{{- printf "%s-postgres" (include "mautrix-telegram.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mautrix-telegram.databaseConnectionString" -}}
{{- if .Values.database.connectionString -}}
{{- .Values.database.connectionString -}}
{{- else if .Values.postgres.enabled -}}
{{- printf "postgres://%s:%s@%s:%v/%s" .Values.database.user .Values.database.password (include "mautrix-telegram.postgresFullname" .) .Values.postgres.service.port .Values.database.name -}}
{{- else -}}
{{- required "values.database.connectionString is required when postgres.enabled=false" .Values.database.connectionString -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-telegram.appserviceAddress" -}}
{{- if .Values.appservice.address -}}
{{- .Values.appservice.address -}}
{{- else -}}
{{- printf "http://%s.%s.svc.cluster.local:%v" (include "mautrix-telegram.fullname" .) .Release.Namespace .Values.service.port -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-telegram.registrationServiceUrl" -}}
{{- if .Values.registration.serviceUrl -}}
{{- .Values.registration.serviceUrl -}}
{{- else -}}
{{- include "mautrix-telegram.appserviceAddress" . -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-telegram.runtimeSecretName" -}}
{{- if .Values.registration.existingSecret -}}
{{- .Values.registration.existingSecret -}}
{{- else if .Values.registration.managedSecret.name -}}
{{- .Values.registration.managedSecret.name -}}
{{- else -}}
{{- printf "%s-runtime-secrets" (include "mautrix-telegram.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-telegram.ensureRuntimeSecrets" -}}
{{- if not (hasKey .Values.registration "_computedRuntimeSecrets") -}}
{{- $useExistingSecret := ne (.Values.registration.existingSecret | default "") "" -}}
{{- $managedSecretEnabled := and (not $useExistingSecret) .Values.registration.managedSecret.enabled -}}
{{- $secretName := include "mautrix-telegram.runtimeSecretName" . -}}
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

{{- define "mautrix-telegram.registrationAsToken" -}}
{{- include "mautrix-telegram.ensureRuntimeSecrets" . -}}
{{- index (index .Values.registration "_computedRuntimeSecrets") "asToken" -}}
{{- end -}}

{{- define "mautrix-telegram.registrationHsToken" -}}
{{- include "mautrix-telegram.ensureRuntimeSecrets" . -}}
{{- index (index .Values.registration "_computedRuntimeSecrets") "hsToken" -}}
{{- end -}}

{{- define "mautrix-telegram.provisioningSharedSecret" -}}
{{- include "mautrix-telegram.ensureRuntimeSecrets" . -}}
{{- index (index .Values.registration "_computedRuntimeSecrets") "provisioningSharedSecret" -}}
{{- end -}}

{{- define "mautrix-telegram.registrationSenderLocalpart" -}}
{{- if .Values.registration.senderLocalpart -}}
{{- .Values.registration.senderLocalpart -}}
{{- else -}}
{{- .Values.appservice.botUsername -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-telegram.renderTemplateRegex" -}}
{{- $template := .template -}}
{{- $field := .field -}}
{{- $normalized := include "mautrix-telegram.normalizeBridgeTemplate" (dict "template" $template "field" $field "legacyReplacement" "{placeholder}") -}}
{{- regexReplaceAll "\\{[A-Za-z_][A-Za-z0-9_]*\\}" $normalized ".*" -}}
{{- end -}}

{{- define "mautrix-telegram.normalizeBridgeTemplate" -}}
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

{{- define "mautrix-telegram.registrationUserRegex" -}}
{{- if .Values.registration.userRegex -}}
{{- .Values.registration.userRegex -}}
{{- else -}}
{{- printf "@%s:%s" (include "mautrix-telegram.renderTemplateRegex" (dict "template" .Values.bridge.usernameTemplate "field" "bridge.usernameTemplate")) (include "mautrix-telegram.homeserverDomain" .) -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-telegram.registrationAliasRegex" -}}
{{- if .Values.registration.aliasRegex -}}
{{- .Values.registration.aliasRegex -}}
{{- else -}}
{{- printf "#%s:%s" (include "mautrix-telegram.renderTemplateRegex" (dict "template" .Values.bridge.aliasTemplate "field" "bridge.aliasTemplate")) (include "mautrix-telegram.homeserverDomain" .) -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-telegram.registrationConfig" -}}
id: {{ .Values.appservice.id | quote }}
url: {{ include "mautrix-telegram.registrationServiceUrl" . | quote }}
as_token: {{ include "mautrix-telegram.registrationAsToken" . | quote }}
hs_token: {{ include "mautrix-telegram.registrationHsToken" . | quote }}
sender_localpart: {{ include "mautrix-telegram.registrationSenderLocalpart" . | quote }}
rate_limited: {{ .Values.registration.rateLimited }}
de.sorunome.msc2409.push_ephemeral: {{ .Values.appservice.ephemeralEvents }}
namespaces:
  users:
    - exclusive: true
      regex: {{ include "mautrix-telegram.registrationUserRegex" . | squote }}
  aliases:
    - exclusive: true
      regex: {{ include "mautrix-telegram.registrationAliasRegex" . | squote }}
{{- end -}}
