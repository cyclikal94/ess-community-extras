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
- `homeserver.domain` is required.
- Validation is enforced by `values.schema.json`; Helm will fail fast when required values are missing or empty.
- `registration.asToken` and `registration.hsToken` are optional; when omitted, the chart auto-generates 64-hex-char tokens.

You can still provide tokens manually if desired:

```bash
openssl rand -hex 32
openssl rand -hex 32
```

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

You can supply multiple `values.yaml` files so you could also deploy with the `values.matrix.example.yaml `:

```bash
helm upgrade --install irc-bridge ./helm/irc-bridge \
  -f helm/irc-bridge/values.matrix.example.yaml \
  -f helm/irc-bridge/values.selfsigned.example.yaml
```

**Note:** Both examples define `host` so you should ensure both are correct (or the last provided will apply).

## Synapse Registration ConfigMap

By default, this chart creates a duplicate registration ConfigMap in `registration.synapseNamespace` (defaulting to the Helm release namespace when unset).

Set `registration.synapseNamespace` if your Synapse namespace is different (for example `ess`).

The same `as_token` and `hs_token` values are used in both registration ConfigMaps. If omitted, they are auto-generated and persisted in a Secret named `<release>-irc-bridge-registration-tokens`.

For ESS, simply add the appservice ConfigMap, by using a values file like so:

```yaml
synapse:
  appservices:
    - configMap: <release>-irc-bridge-registration
      configMapKey: appservice-registration-irc.yaml
```

Set `registration.createSynapseConfigMap=false` if you do not want the duplicate ConfigMap.

**Note**: You will still need to supply the app services file to Synapse another way.

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

## Matrix/ESS Example

Ready-to-use file: `values.matrix.example.yaml`

## Verify

```bash
kubectl get pods,svc -l app.kubernetes.io/instance=irc-bridge -n ircbridge
kubectl get ingress -l app.kubernetes.io/instance=irc-bridge -n nircbridgey
```
