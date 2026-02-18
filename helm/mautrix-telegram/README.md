# mautrix-telegram Helm Chart

## Overview

This chart deploys `mautrix-telegram` with:

- Singleton bridge `StatefulSet` (replicas fixed at 1)
- Bridge `Service` with `publishNotReadyAddresses: true`
- Runtime config `Secret` (`config.yaml`)
- Registration ConfigMap in release namespace and optional duplicate in Synapse namespace
- Optional bundled Postgres `StatefulSet`

The bridge is started by running the main command directly with `--no-update`.

## Kubernetes behavior

This chart follows the mautrix Kubernetes guidance:

- No startup script usage
- No registration file mounted in bridge pod
- `--no-update` to avoid runtime config writes
- `/data` mounted read-only
- Singleton runtime (`StatefulSet`, 1 replica)
- `publishNotReadyAddresses: true`

## Quick Start

Create a minimal values file:

```yaml
homeserver:
  domain: matrix.example.com

telegram:
  apiID: 12345678
  apiHash: replace_with_telegram_api_hash
```

Install:

```bash
helm upgrade --install mautrix-telegram ./helm/mautrix-telegram -f mautrix-telegram-values.yaml
```

Install from published Helm repository:

```bash
helm repo add ess-community-extras https://cyclikal94.github.io/ess-community-extras
helm repo update
helm upgrade --install mautrix-telegram ess-community-extras/mautrix-telegram -n telegram --create-namespace --values mautrix-telegram-values.yaml
```

## Required values

- `homeserver.domain`
- `telegram.apiID`
- `telegram.apiHash`

Validation is enforced by `values.schema.json`.

## Registration ConfigMap model

The chart renders registration in release namespace as:

- ConfigMap: `<release>-mautrix-telegram-registration`
- Key: `appservice-registration-telegram.yaml`

By default, the chart also renders the same registration ConfigMap in `registration.synapseNamespace` when that namespace differs from the release namespace.

Values:

- `registration.createSynapseConfigMap` (default `true`)
- `registration.synapseNamespace` (default release namespace)
- `registration.synapseConfigMapName` (optional override)

For ESS Synapse values:

```yaml
synapse:
  appservices:
    - configMap: <release>-mautrix-telegram-registration
      configMapKey: appservice-registration-telegram.yaml
```

## Runtime secret generation

If unset, the chart auto-generates and persists these in `<release>-mautrix-telegram-runtime-secrets`:

- `registration.asToken`
- `registration.hsToken`
- `appservice.provisioning.sharedSecret`

Do not set these to `generate`; leave empty for chart-managed generation.

## Bridge config model

`config.extra` is merged into generated `config.yaml`.

The chart reserves and manages these paths:

- `homeserver.address`
- `homeserver.domain`
- `appservice.address`
- `appservice.hostname`
- `appservice.port`
- `appservice.database`
- `appservice.id`
- `appservice.bot_username`
- `appservice.as_token`
- `appservice.hs_token`
- `appservice.ephemeral_events`
- `appservice.provisioning.shared_secret`
- `bridge.username_template`
- `bridge.alias_template`
- `telegram.api_id`
- `telegram.api_hash`

If `config.extra` overlaps any managed path, template rendering fails.

## Postgres

Bundled Postgres is enabled by default.

Disable bundled Postgres and use external DB:

```yaml
postgres:
  enabled: false

database:
  connectionString: postgres://mautrix_telegram:replace_me@postgres.example.com:5432/mautrix_telegram
```

See: `values.external.example.yaml`

## Liveness/Readiness probes

Endpoints are available at:

- `/_matrix/mau/live`
- `/_matrix/mau/ready`

Probe configuration is optional and disabled by default:

- `probes.liveness.enabled`
- `probes.readiness.enabled`

## Linting

```bash
helm lint ./helm/mautrix-telegram -f ./helm/mautrix-telegram/values.example.yaml
```

## Verify

```bash
kubectl get pods,svc -l app.kubernetes.io/instance=mautrix-telegram -n telegram
kubectl get configmap <release>-mautrix-telegram-registration -n telegram
kubectl get configmap <release>-mautrix-telegram-registration -n <synapse-namespace>
```

## Docs

- [Bridge setup with Docker](https://docs.mau.fi/bridges/general/docker-setup.html?bridge=telegram)
- [Initial bridge config](https://docs.mau.fi/bridges/general/initial-config.html)
- [Registering appservices](https://docs.mau.fi/bridges/general/registering-appservices.html)
- [mautrix-telegram repository](https://github.com/mautrix/telegram)
