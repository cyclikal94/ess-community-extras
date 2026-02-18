# matrix-appservice-irc Helm Chart

## Overview

This chart deploys matrix-appservice-irc with a ConfigMap, Service, Deployment(s), optional bundled Redis/Postgres StatefulSets, and media proxy Ingress.

## Prerequisites

- Kubernetes cluster
- Helm 3.x
- Ingress controller (defaults assume `traefik`)

## Quick Start

Create a minimal values file:

```yaml
host: irc-media.example.com
homeserver:
  url: http://ess-synapse.ess.svc.cluster.local:8008
  domain: matrix.example.com
```

Install:

```bash
helm upgrade --install irc-bridge ./helm/irc-bridge -f irc-bridge-values.yaml
```

Install from published Helm repository:

```bash
helm repo add ess-community-extras https://cyclikal94.github.io/ess-community-extras
helm repo update
helm upgrade --install irc-bridge ess-community-extras/irc-bridge -n ircbridge --create-namespace --values irc-bridge-values.yaml
```

## Naming

- By default, resource names are release-scoped.
- Example: release `prod` renders names like `prod-irc-bridge`, `prod-irc-bridge-media-proxy`, and `prod-irc-bridge-registration`.
- Set `nameOverride` or `fullnameOverride` only when you need fixed/custom names.

## Required Values

- `host` is required.
- `homeserver.domain` is required and should match Synapse `server_name`.
- Validation is enforced by `values.schema.json`; Helm will fail fast when required values are missing or empty.
- `registration.asToken` and `registration.hsToken` are optional; when omitted, the chart auto-generates 64-hex-char tokens and persists them in `<release>-irc-bridge-registration-tokens`.

You can still provide tokens manually if desired:

```bash
openssl rand -hex 32
openssl rand -hex 32
```

## Bridge Config Model

`config.extra` is parsed as YAML and merged into generated `config.yaml`.

This lets users supply bridge-specific preferences (for example `ircService.servers`) in upstream config format without the chart needing to expose every bridge option as first-class Helm values.

The chart always manages these paths and reserves them:

- `homeserver.url`
- `homeserver.domain`
- `ircService.mediaProxy.signingKeyPath`
- `ircService.mediaProxy.ttlSeconds`
- `ircService.mediaProxy.bindPort`
- `ircService.mediaProxy.publicUrl`
- `database.engine`
- `database.connectionString`
- `ircClients.mode`
- `connectionPool.redisUrl`
- `connectionPool.persistConnectionsOnShutdown`

If `config.extra` overlaps any reserved path above, template rendering fails.

## Linting

Because some configuration options are required, lint with a values file:

```bash
helm lint ./helm/irc-bridge -f ./helm/irc-bridge/values.example.yaml
```

Or lint with your own values file containing at least:

```yaml
host: irc-media.example.com
homeserver:
  domain: matrix.example.com
```

## Example Values Files

- `values.example.yaml`: absolute minimal chart input (`host` + `homeserver`).
- `values.matrix.example.yaml`: recommended Matrix/ESS-focused matrix-appservice-irc config example.
- `values.selfsigned.example.yaml`: self-signed/custom TLS secret example; typically merged with the Matrix example.
- `values.external.example.yaml`: external Redis/Postgres example.

## Defaults

- All optional values and defaults are in `values.yaml`.
- View defaults directly with:

```bash
helm show values ./helm/irc-bridge
```

## TLS Options

### cert-manager (default)

By default, the chart adds this ingress annotation:

`cert-manager.io/cluster-issuer: letsencrypt-prod`

You can change issuer:

```yaml
host: irc-media.example.com
ingress:
  clusterIssuer: letsencrypt-staging
```

### Self-signed or custom certificate secret

Create a TLS secret in the target namespace:

```bash
kubectl -n <namespace> create secret tls matrix-irc-bridge-media-proxy-tls --cert=tls.crt --key=tls.key
```

Then disable issuer annotation and use your secret:

```yaml
host: irc-media.example.com
ingress:
  clusterIssuer: ""
  tls:
    enabled: true
    secretName: matrix-irc-bridge-media-proxy-tls
```

Ready-to-use file: `values.selfsigned.example.yaml`

You can supply multiple `values.yaml` files so you could also deploy with the `values.matrix.example.yaml`:

```bash
helm upgrade --install irc-bridge ./helm/irc-bridge \
  -f helm/irc-bridge/values.matrix.example.yaml \
  -f helm/irc-bridge/values.selfsigned.example.yaml
```

**Note:** Both examples define `host` so you should ensure both are correct (or the last provided will apply).

## Synapse Registration ConfigMap

By default, this chart creates a duplicate registration ConfigMap in `registration.synapseNamespace` (defaulting to the Helm release namespace when unset).

Set `registration.synapseNamespace` if your Synapse namespace is different (for example `ess`).

For ESS, add the appservice ConfigMap in Synapse values:

```yaml
synapse:
  appservices:
    - configMap: <release>-irc-bridge-registration
      configMapKey: appservice-registration-irc.yaml
```

Set `registration.createSynapseConfigMap=false` if you do not want the duplicate ConfigMap.

## External Redis/Postgres Example

Ready-to-use file: `values.external.example.yaml`

Equivalent inline values:

```yaml
postgres:
  enabled: false
redis:
  enabled: false
  url: redis://redis.example.com:6379/0
database:
  connectionString: postgres://matrix_irc:replace_me@postgres.example.com:5432/matrix_irc
```

## Verify

```bash
kubectl get pods,svc -l app.kubernetes.io/instance=irc-bridge -n ircbridge
kubectl get ingress -l app.kubernetes.io/instance=irc-bridge -n ircbridge
kubectl get configmap <release>-irc-bridge-registration -n <synapse-namespace>
```

## Troubleshooting

If bridge logs show `No mapped channels` or `IGNORE not mapped`, Synapse/appservice wiring is likely working, but no Matrix<->IRC channel mapping exists yet. Create/join mappings via the bot commands (`!help`) and mapped aliases/rooms.

## Docs

- [Bridge setup](https://matrix-org.github.io/matrix-appservice-irc/latest/bridge_setup.html)
- [Usage](https://matrix-org.github.io/matrix-appservice-irc/latest/usage.html)
- [Connection pooling](https://matrix-org.github.io/matrix-appservice-irc/latest/connection_pooling.html)
- [Config sample](https://github.com/matrix-org/matrix-appservice-irc/blob/develop/config.sample.yaml)
