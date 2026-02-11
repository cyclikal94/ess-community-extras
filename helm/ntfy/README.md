# ntfy Helm Chart

## Overview

This chart deploys ntfy with a ConfigMap, Service, StatefulSet, and Ingress.

## Prerequisites

- Kubernetes cluster
- Helm 3.x
- Ingress controller (defaults assume `traefik`)
- Default StorageClass (or set `persistence.storageClassName`)

## Quick Start

Create a minimal values file:

```yaml
host: ntfy.example.com
```

Install:

```bash
helm upgrade --install ntfy ./helm/ntfy -f ntfy-values.yaml
```

## Naming

- By default, resource names are release-scoped.
- Example: release `prod` renders names like `prod-ntfy` and `prod-ntfy-ingress`.
- Set `nameOverride` or `fullnameOverride` only when you need fixed/custom names.

## Required Values

- `host` is required.
- Validation is enforced by `values.schema.json`; Helm will fail fast if `host` is missing or empty.
- If deploying to Matrix, you should replace `visitor-request-limit-exempt-hosts` with your Synapse domain.

## Example Values Files

- `values.example.yaml`: absolute minimal chart input (`host` only).
- `values.matrix.example.yaml`: recommended Matrix/Element-focused ntfy config example.
- `values.selfsigned.example.yaml`: self-signed/custom TLS secret example; typically layered with the Matrix example.

## Defaults

- All optional values and defaults are in `values.yaml`.
- View defaults directly with:

```bash
helm show values ./helm/ntfy
```

## TLS Options

### cert-manager (default)

By default, the chart adds this ingress annotation:

`cert-manager.io/cluster-issuer: letsencrypt-prod`

You can change issuer:

```yaml
host: ntfy.example.com
ingress:
  clusterIssuer: letsencrypt-staging
```

### Self-signed or custom certificate secret

Create a TLS secret in the target namespace:

```bash
kubectl -n <namespace> create secret tls ntfy-tls --cert=ntfy.crt --key=ntfy.key
```

Then disable issuer annotation and use your secret:

```yaml
host: ntfy.example.com
ingress:
  clusterIssuer: ""
  tls:
    enabled: true
    secretName: ntfy-tls
```

Ready-to-use file: `values.selfsigned.example.yaml`

You can supply multiple `values.yaml` files so you could also deploy with the `values.matrix.example.yaml `:

```bash
helm upgrade --install ntfy ./helm/ntfy \
  -f values.matrix.example.yaml \
  -f values.selfsigned.example.yaml
```

**Note:** Both examples define `host` so you should ensure both are correct (or the last provided will apply).

## Matrix/Element Example

For Matrix/Element deployments, use custom ntfy server config for UnifiedPush-style access control (for example `auth-access` entries).

Ready-to-use file: `values.matrix.example.yaml`

## Verify

```bash
kubectl get pods,svc -l app.kubernetes.io/instance=ntfy
kubectl get ingress -l app.kubernetes.io/instance=ntfy
```
