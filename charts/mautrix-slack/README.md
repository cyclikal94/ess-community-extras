# mautrix-slack

A Matrix-Slack puppeting bridge. See [mautrix/slack](https://github.com/mautrix/slack) for details.

## Overview

This chart deploys `mautrix-slack` with:

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
helm upgrade --install mautrix-slack ./charts/mautrix-slack -f mautrix-slack-values.yaml
```

Install from published Helm repository:

```bash
helm repo add matrix-helm-charts https://cyclikal94.github.io/matrix-helm-charts
helm repo update
helm upgrade --install mautrix-slack matrix-helm-charts/mautrix-slack -n mautrix-slack --create-namespace --values mautrix-slack-values.yaml
```

## Required values

- `homeserver.domain`

Validation is enforced by `values.schema.json`.

## Registration ConfigMap model

The chart renders registration in release namespace as:

- ConfigMap: `<release>-mautrix-slack-registration`
- Key: `appservice-registration-slack.yaml`

Set `registration.synapseNamespace` if Synapse runs in a different namespace (for example `ess`).
An additional registration ConfigMap copy is created only when `registration.synapseNamespace` is non-empty and different from the release namespace.

For ESS, add the appservice ConfigMap in Synapse values:

```yaml
synapse:
  appservices:
    - configMap: <release>-mautrix-slack-registration
      configMapKey: appservice-registration-slack.yaml
```

## Runtime secret generation

If unset, the chart resolves these in this order:

- from `registration.existingSecret` (keys `asToken`, `hsToken`, `provisioningSharedSecret`) when set
- from chart-managed Secret (default `<release>-mautrix-slack-runtime-secrets`) when it already exists
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
  connectionString: postgres://mautrix_slack:replace_me@postgres.example.com:5432/mautrix_slack
```

See: `values.external.example.yaml`

## Example Values Files

- `values.example.yaml`: absolute minimal chart input.
- `values.matrix.example.yaml`: recommended Matrix/ESS-focused mautrix-slack config example.
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
helm lint ./charts/mautrix-slack -f ./charts/mautrix-slack/values.example.yaml
```

## Verify

```bash
kubectl get pods,svc -l app.kubernetes.io/instance=mautrix-slack -n slack
kubectl get configmap <release>-mautrix-slack-registration -n slack
kubectl get configmap <release>-mautrix-slack-registration -n <synapse-namespace>
```

## Docs

- [Bridge setup with Docker](https://docs.mau.fi/bridges/general/docker-setup.html?bridge=slack)
- [Initial bridge config](https://docs.mau.fi/bridges/general/initial-config.html#mautrix-slack)
- [Registering appservices](https://docs.mau.fi/bridges/general/registering-appservices.html)
- [mautrix-slack repository](https://github.com/mautrix/slack)
