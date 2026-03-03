{{- define "mautrix-bluesky.runtimeSecretKeys" -}}
asToken,hsToken
{{- end -}}

{{- define "mautrix-bluesky.bridgeCommand" -}}
- mautrix-bluesky
{{- end -}}

{{- define "mautrix-bluesky.bridgeArgs" -}}
- -c
- /data/config.yaml
- --no-update
{{- end -}}

{{- define "mautrix-bluesky.registrationFileKey" -}}
appservice-registration-bluesky.yaml
{{- end -}}

{{- define "mautrix-bluesky.defaultRegistrationUserRegex" -}}
{{- printf "@%s_.*:%s" .Values.appservice.id (include "mautrix-go-base.homeserverDomain" .) -}}
{{- end -}}

{{- define "mautrix-bluesky.registrationConfig" -}}
{{ include "mautrix-go-base.registrationConfig" . }}
{{- end -}}

{{- define "mautrix-bluesky.doublePuppetRegistrationFileKey" -}}
appservice-registration-doublepuppet.yaml
{{- end -}}

{{- define "mautrix-bluesky.doublePuppetUserRegex" -}}
{{- $domain := include "mautrix-go-base.homeserverDomain" . -}}
{{- printf "@.*:%s" (replace "." "\\." $domain) -}}
{{- end -}}

{{- define "mautrix-bluesky.reservedBasePaths" -}}
homeserver.address,homeserver.domain,appservice.address,appservice.hostname,appservice.port,appservice.id,appservice.bot.username,appservice.as_token,appservice.hs_token,database.type,database.uri
{{- end -}}

{{- define "mautrix-bluesky.reservedNetworkPaths" -}}
{{- end -}}

{{- define "mautrix-bluesky.managedConfig" -}}
{{- $bot := .Values.appservice.bot | default dict -}}
{{- $managed := dict
  "homeserver" (dict
    "address" .Values.homeserver.address
    "domain" (include "mautrix-go-base.homeserverDomain" .)
  )
  "appservice" (dict
    "address" (include "mautrix-go-base.appserviceAddress" .)
    "hostname" .Values.appservice.hostname
    "port" .Values.appservice.port
    "id" .Values.appservice.id
    "as_token" (include "mautrix-go-base.runtimeSecretValue" (dict "root" . "key" "asToken"))
    "hs_token" (include "mautrix-go-base.runtimeSecretValue" (dict "root" . "key" "hsToken"))
    "bot" (dict
      "username" ((get $bot "username") | default "")
    )
  )
  "database" (dict
    "type" "postgres"
    "uri" (include "mautrix-go-base.databaseConnectionString" .)
  )
-}}
{{ toYaml $managed }}
{{- end -}}

{{- define "mautrix-bluesky.mergedConfig" -}}
{{ include "mautrix-go-base.bridgev2MergedConfig" . }}
{{- end -}}
