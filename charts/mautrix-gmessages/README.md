# mautrix-gmessages

A Matrix-Google Messages puppeting bridge. See [mautrix/gmessages](https://github.com/mautrix/gmessages) for details.

## Overview

This chart deploys `mautrix-gmessages` with:

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
```

Install:

```bash
helm upgrade --install mautrix-gmessages ./charts/mautrix-gmessages -f mautrix-gmessages-values.yaml
```

Install from published Helm repository:

```bash
helm repo add matrix-helm-charts https://cyclikal94.github.io/matrix-helm-charts
helm repo update
helm upgrade --install mautrix-gmessages matrix-helm-charts/mautrix-gmessages -n mautrix-gmessages --create-namespace --values mautrix-gmessages-values.yaml
```

## Required values

- `homeserver.domain`

Validation is enforced by `values.schema.json`.

## Registration ConfigMap model

The chart renders registration in release namespace as:

- ConfigMap: `<release>-mautrix-gmessages-registration`
- Key: `appservice-registration-gmessages.yaml`

Set `registration.synapseNamespace` if Synapse runs in a different namespace (for example `ess`).
An additional registration ConfigMap copy is created only when `registration.synapseNamespace` is non-empty and different from the release namespace.

For ESS, add the appservice ConfigMap in Synapse values:

```yaml
synapse:
  appservices:
    - configMap: <release>-mautrix-gmessages-registration
      configMapKey: appservice-registration-gmessages.yaml
```

## Runtime secret generation

If unset, the chart resolves these in this order:

- from `registration.existingSecret` (keys `asToken`, `hsToken`, `provisioningSharedSecret`) when set
- from chart-managed Secret (default `<release>-mautrix-gmessages-runtime-secrets`) when it already exists
- auto-generated 64-hex-char values when `registration.autoGenerate=true` and `registration.managedSecret.enabled=true` (default behavior)

The resolved values are used for:

- `registration.asToken`
- `registration.hsToken`
- `appservice.provisioning.sharedSecret`

Do not set these to `generate`; leave empty for chart-managed generation.

For deterministic GitOps rendering, set `registration.autoGenerate=false` and provide secrets directly or via a pre-created `registration.existingSecret`.

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

If `config.extra` overlaps any managed path, template rendering fails.

## Postgres

Bundled Postgres is enabled by default.

Disable bundled Postgres and use external DB:

```yaml
postgres:
  enabled: false

database:
  connectionString: postgres://mautrix_gmessages:replace_me@postgres.example.com:5432/mautrix_gmessages
```

See: `values.external.example.yaml`

## Example Values Files

- `values.example.yaml`: absolute minimal chart input.
- `values.matrix.example.yaml`: recommended Matrix/ESS-focused mautrix-gmessages config example.
- `values.external.example.yaml`: external Postgres example.
- `values.secrets.yaml`: external Secret example for runtime secrets.

## Liveness/Readiness probes

Endpoints are available at:

- `/_matrix/mau/live`
- `/_matrix/mau/ready`

Probe configuration is optional and disabled by default:

- `probes.liveness.enabled`
- `probes.readiness.enabled`

## Linting

```bash
helm lint ./charts/mautrix-gmessages -f ./charts/mautrix-gmessages/values.example.yaml
```

## Verify

```bash
kubectl get pods,svc -l app.kubernetes.io/instance=mautrix-gmessages -n gmessages
kubectl get configmap <release>-mautrix-gmessages-registration -n gmessages
kubectl get configmap <release>-mautrix-gmessages-registration -n <synapse-namespace>
```

## Docs

- [Bridge setup with Docker](https://docs.mau.fi/bridges/general/docker-setup.html?bridge=gmessages)
- [Initial bridge config](https://docs.mau.fi/bridges/general/initial-config.html#mautrix-gmessages)
- [Registering appservices](https://docs.mau.fi/bridges/general/registering-appservices.html)
- [mautrix-gmessages repository](https://github.com/mautrix/gmessages)
