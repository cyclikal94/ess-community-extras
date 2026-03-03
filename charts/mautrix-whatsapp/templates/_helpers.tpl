{{- define "mautrix-whatsapp.runtimeSecretKeys" -}}
asToken,hsToken
{{- end -}}

{{- define "mautrix-whatsapp.bridgeCommand" -}}
- mautrix-whatsapp
{{- end -}}

{{- define "mautrix-whatsapp.bridgeArgs" -}}
- -c
- /data/config.yaml
- --no-update
{{- end -}}

{{- define "mautrix-whatsapp.registrationFileKey" -}}
appservice-registration-whatsapp.yaml
{{- end -}}

{{- define "mautrix-whatsapp.defaultRegistrationUserRegex" -}}
{{- printf "@%s_.*:%s" .Values.appservice.id (include "mautrix-go-base.homeserverDomain" .) -}}
{{- end -}}

{{- define "mautrix-whatsapp.registrationConfig" -}}
{{ include "mautrix-go-base.registrationConfig" . }}
{{- end -}}

{{- define "mautrix-whatsapp.mergedConfig" -}}
{{- $extra := dict -}}
{{- if .Values.config.extra -}}
{{- $parsed := fromYaml .Values.config.extra -}}
{{- if and (kindIs "map" $parsed) (hasKey $parsed "Error") -}}
{{- fail "values.config.extra must be valid YAML mapping (object) at the top level" -}}
{{- end -}}
{{- if and $parsed (not (kindIs "map" $parsed)) -}}
{{- fail "values.config.extra must be a YAML mapping (object) at the top level" -}}
{{- end -}}
{{- if $parsed -}}
{{- $extra = $parsed -}}
{{- end -}}
{{- end -}}

{{- if hasKey $extra "homeserver" -}}
{{- $homeserver := index $extra "homeserver" -}}
{{- if not (kindIs "map" $homeserver) -}}
{{- fail "values.config.extra.homeserver must be a YAML mapping when set" -}}
{{- end -}}
{{- if or (hasKey $homeserver "address") (hasKey $homeserver "domain") -}}
{{- fail "values.config.extra cannot set homeserver.address or homeserver.domain; use values.homeserver.* instead" -}}
{{- end -}}
{{- end -}}

{{- if hasKey $extra "appservice" -}}
{{- $appservice := index $extra "appservice" -}}
{{- if not (kindIs "map" $appservice) -}}
{{- fail "values.config.extra.appservice must be a YAML mapping when set" -}}
{{- end -}}
{{- if or (hasKey $appservice "address") (hasKey $appservice "hostname") (hasKey $appservice "port") (hasKey $appservice "database") (hasKey $appservice "id") (hasKey $appservice "as_token") (hasKey $appservice "hs_token") -}}
{{- fail "values.config.extra cannot set appservice.{address,hostname,port,database,id,as_token,hs_token}; use first-class values instead" -}}
{{- end -}}
{{- if hasKey $appservice "bot" -}}
{{- $bot := index $appservice "bot" -}}
{{- if not (kindIs "map" $bot) -}}
{{- fail "values.config.extra.appservice.bot must be a YAML mapping when set" -}}
{{- end -}}
{{- if hasKey $bot "username" -}}
{{- fail "values.config.extra cannot set appservice.bot.username; use values.appservice.bot.username instead" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- if hasKey $extra "database" -}}
{{- $database := index $extra "database" -}}
{{- if not (kindIs "map" $database) -}}
{{- fail "values.config.extra.database must be a YAML mapping when set" -}}
{{- end -}}
{{- if or (hasKey $database "type") (hasKey $database "uri") -}}
{{- fail "values.config.extra cannot set database.type or database.uri; use values.database.* instead" -}}
{{- end -}}
{{- end -}}

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
{{- $merged := mustMergeOverwrite (dict) $extra $managed -}}
{{ toYaml $merged }}
{{- end -}}
