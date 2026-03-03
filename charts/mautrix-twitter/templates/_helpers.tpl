{{- define "mautrix-twitter.runtimeSecretKeys" -}}
asToken,hsToken
{{- end -}}

{{- define "mautrix-twitter.bridgeCommand" -}}
- mautrix-twitter
{{- end -}}

{{- define "mautrix-twitter.bridgeArgs" -}}
- -c
- /data/config.yaml
- --no-update
{{- end -}}

{{- define "mautrix-twitter.registrationFileKey" -}}
appservice-registration-twitter.yaml
{{- end -}}

{{- define "mautrix-twitter.defaultRegistrationUserRegex" -}}
{{- printf "@%s_.*:%s" .Values.appservice.id (include "mautrix-go-base.homeserverDomain" .) -}}
{{- end -}}

{{- define "mautrix-twitter.registrationConfig" -}}
{{ include "mautrix-go-base.registrationConfig" . }}
{{- end -}}

{{- define "mautrix-twitter.doublePuppetRegistrationFileKey" -}}
appservice-registration-doublepuppet.yaml
{{- end -}}

{{- define "mautrix-twitter.doublePuppetUserRegex" -}}
{{- $domain := include "mautrix-go-base.homeserverDomain" . -}}
{{- printf "@.*:%s" (replace "." "\\." $domain) -}}
{{- end -}}

{{- define "mautrix-twitter.reservedBasePaths" -}}
homeserver.address,homeserver.domain,appservice.address,appservice.hostname,appservice.port,appservice.id,appservice.bot.username,appservice.as_token,appservice.hs_token,database.type,database.uri
{{- end -}}

{{- define "mautrix-twitter.reservedNetworkPaths" -}}
{{- end -}}

{{- define "mautrix-twitter.managedConfig" -}}
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

{{- define "mautrix-twitter.mergedConfig" -}}
{{ include "mautrix-go-base.bridgev2MergedConfig" . }}
{{- end -}}
