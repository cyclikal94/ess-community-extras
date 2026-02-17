# matrix-appservice-irc Helm Chart

## Overview

This chart deploys matrix-appservice-irc with:

- bridge ConfigMap and Deployment
- bridge Service
- media proxy Ingress
- bundled Redis StatefulSet + Service (optional)
- bundled Postgres StatefulSet + Service + Secret (optional)
- registration ConfigMap in bridge namespace
- optional duplicate registration ConfigMap in Synapse namespace

## Prerequisites

- Kubernetes cluster
- Helm 3.x
- Synapse reachable from the chart namespace
- Ingress controller (defaults assume `traefik`)
- cert-manager ClusterIssuer `letsencrypt-prod` (or set `ingress.clusterIssuer`)

## Quick Start

Create a minimal values file:

```yaml
host: irc-media.example.com
registration:
  asToken: your_generated_as_token
  hsToken: your_generated_hs_token
```

Install:

```bash
helm upgrade --install irc-bridge ./helm/irc-bridge -f irc-bridge-values.yaml
```

Install from published Helm repository:

```bash
helm repo add ess-community-extras https://cyclikal94.github.io/ess-community-extras
helm repo update
helm install irc-bridge ess-community-extras/irc-bridge -n ircbridge --create-namespace --values irc-bridge-values.yaml
```

## Naming

- By default, resource names are release-scoped.
- Example: release `prod` renders names like `prod-irc-bridge`, `prod-irc-bridge-postgres`, `prod-irc-bridge-redis`.
- Set `nameOverride` or `fullnameOverride` only when you need fixed/custom names.

## Required Values

- `host` is required and used for media proxy ingress host.
- `registration.asToken` and `registration.hsToken` should be replaced with secure values.
- Validation is enforced by `values.schema.json`.

Generate secure tokens:

```bash
openssl rand -hex 32
openssl rand -hex 32
```

## Synapse Registration ConfigMap

By default, this chart creates a duplicate registration ConfigMap in `registration.synapseNamespace` (`ess` by default).

If your Synapse Helm values support appservice ConfigMaps, add:

```yaml
synapse:
  appservices:
    - configMap: <release>-irc-bridge-registration
      configMapKey: appservice-registration-irc.yaml
```

Set `registration.createSynapseConfigMap=false` if you do not want the duplicate ConfigMap.

## Bundled vs External Redis/Postgres

Default behavior uses bundled Redis and Postgres (`redis.enabled=true`, `postgres.enabled=true`).

To use external services, disable bundles and provide explicit connection values:

```yaml
postgres:
  enabled: false
redis:
  enabled: false
database:
  connectionString: postgres://user:pass@postgres.example:5432/matrix_irc
  url: redis://redis.example:6379/0
waitForRedis:
  host: redis.example
```

## Linting

Because `host` is required, lint with a values file:

```bash
helm lint ./helm/irc-bridge -f ./helm/irc-bridge/values.example.yaml
```

## Defaults

All optional values and defaults are in `values.yaml`.

View defaults directly with:

```bash
helm show values ./helm/irc-bridge
```

## Verify

```bash
kubectl -n <namespace> get pods,svc -l app.kubernetes.io/instance=<release>
kubectl -n <namespace> get ingress -l app.kubernetes.io/instance=<release>
```

## Docs

- [Bridge setup](https://matrix-org.github.io/matrix-appservice-irc/latest/bridge_setup.html)
- [Usage](https://matrix-org.github.io/matrix-appservice-irc/latest/usage.html)
- [Connection pooling](https://matrix-org.github.io/matrix-appservice-irc/latest/connection_pooling.html)
- [Config sample](https://github.com/matrix-org/matrix-appservice-irc/blob/develop/config.sample.yaml)
