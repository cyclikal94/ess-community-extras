# mautrix-whatsapp

A Matrix-WhatsApp puppeting bridge. See [mautrix/whatsapp](https://github.com/mautrix/whatsapp) for details.

## Overview

This chart deploys `mautrix-whatsapp` with:

- Singleton bridge `StatefulSet` (replicas fixed at 1)
- Bridge `Service` with `publishNotReadyAddresses: true`
- Runtime config `Secret` (`config.yaml`)
- Registration ConfigMap in release namespace and optional duplicate in Synapse namespace
- Optional bundled Postgres `StatefulSet`

Default image/app version tracks upstream image/git tag `v0.2602.0` (release `v26.02`).

## Kubernetes behavior

This chart follows mautrix Kubernetes guidance:

- No startup script usage
- Bridge runs with direct command and `--no-update`
- No registration file mounted in bridge pod
- `/data` mounted read-only
- Singleton runtime (`StatefulSet`, 1 replica)
- `publishNotReadyAddresses: true`
- Probe endpoints are available, but probes are disabled by default

## Quick Start

Create a minimal values file:

```yaml
homeserver:
  domain: matrix.example.com
```

Install:

```bash
helm dependency build ./charts/mautrix-whatsapp
helm upgrade --install mautrix-whatsapp ./charts/mautrix-whatsapp -f mautrix-whatsapp-values.yaml
```

Install from published OCI registry (preferred):

```bash
helm upgrade --install mautrix-whatsapp oci://ghcr.io/cyclikal94/matrix-helm-charts/mautrix-whatsapp -n mautrix-whatsapp --create-namespace --values mautrix-whatsapp-values.yaml
```

Install from published Helm repository (legacy-compatible):

```bash
helm repo add matrix-helm-charts https://cyclikal94.github.io/matrix-helm-charts
helm repo update
helm upgrade --install mautrix-whatsapp matrix-helm-charts/mautrix-whatsapp -n mautrix-whatsapp --create-namespace --values mautrix-whatsapp-values.yaml
```

## Required values

- `homeserver.domain`

Validation is enforced by `values.schema.json`.

## Registration ConfigMap model

The chart renders registration in release namespace as:

- ConfigMap: `<release>-mautrix-whatsapp-registration`
- Key: `appservice-registration-whatsapp.yaml`

Set `registration.synapseNamespace` if Synapse runs in a different namespace (for example `ess`).
An additional registration ConfigMap copy is created only when `registration.synapseNamespace` is non-empty and different from the release namespace.

For ESS, add the appservice ConfigMap in Synapse values:

```yaml
synapse:
  appservices:
    - configMap: <release>-mautrix-whatsapp-registration
      configMapKey: appservice-registration-whatsapp.yaml
```

## Runtime secret generation

If unset, the chart resolves these in this order:

- from `registration.existingSecret` (keys `asToken`, `hsToken`) when set
- from chart-managed Secret (default `<release>-mautrix-whatsapp-runtime-secrets`) when it already exists
- auto-generated 64-hex-char values when `registration.autoGenerate=true` and `registration.managedSecret.enabled=true` (default behavior)

The resolved values are used for:

- `registration.asToken`
- `registration.hsToken`

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
- `appservice.id`
- `appservice.bot.username`
- `appservice.as_token`
- `appservice.hs_token`
- `appservice.database`

If `config.extra` overlaps any managed path, template rendering fails.

## Postgres

Bundled Postgres is enabled by default.

Disable bundled Postgres and use external DB:

```yaml
postgres:
  enabled: false

database:
  postgres:
    host: postgres.example.com
    port: 5432
    user: mautrix_whatsapp
    password:
      value: replace_me
    database: mautrix_whatsapp
    sslMode: prefer
```

See: `values.external.example.yaml`

## Example Values Files

- `values.example.yaml`: absolute minimal chart input.
- `values.matrix.example.yaml`: recommended Matrix/ESS-focused mautrix-whatsapp config example.
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
helm dependency build ./charts/mautrix-whatsapp
helm lint ./charts/mautrix-whatsapp -f ./charts/mautrix-whatsapp/values.example.yaml
```

## Verify

```bash
kubectl get pods,svc -l app.kubernetes.io/instance=mautrix-whatsapp -n whatsapp
kubectl get configmap <release>-mautrix-whatsapp-registration -n whatsapp
kubectl get configmap <release>-mautrix-whatsapp-registration -n <synapse-namespace>
```

## Docs

- [Bridge setup with Docker](https://docs.mau.fi/bridges/general/docker-setup.html?bridge=whatsapp)
- [Initial bridge config](https://docs.mau.fi/bridges/general/initial-config.html#mautrix-whatsapp)
- [Registering appservices](https://docs.mau.fi/bridges/general/registering-appservices.html)
- [mautrix-whatsapp repository](https://github.com/mautrix/whatsapp)
