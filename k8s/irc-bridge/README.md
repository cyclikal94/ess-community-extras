# matrix-appservice-irc

## Overview

matrix-appservice-irc bridges Matrix and IRC. This directory provides a single all-in-one manifest with bridge config, appservice registration, bridge runtime, bundled Postgres, bundled Redis, and pool worker deployment.

## Prerequisites

- A running Kubernetes cluster.
- Synapse running in your cluster (this repo currently assumes namespace `ess`).
- Namespaces `ircbridge` and `ess`.
- DNS/network connectivity from bridge to Synapse.
- An Ingress controller (this manifest uses `traefik`).
- cert-manager with a ClusterIssuer named `letsencrypt-prod` if you want TLS automation.

## Files

- `k8s/irc-bridge/irc-bridge.yaml`: all resources for IRC bridge deployment and registration ConfigMaps.

## Configure

- Edit `data.config.yaml` in `k8s/irc-bridge/irc-bridge.yaml`:
  - `homeserver.url` and `homeserver.domain`
  - `ircService.mediaProxy.publicUrl`
  - `ircService.servers`
  - `database.connectionString`
  - `ircClients.mode` and `connectionPool.redisUrl`
- Edit media proxy ingress values in `k8s/irc-bridge/irc-bridge.yaml`:
  - `Ingress.spec.rules[0].host`
  - `Ingress.spec.tls[0].hosts[0]`
  - `Ingress.spec.tls[0].secretName` (if needed)
- Keep `ircService.mediaProxy.publicUrl` and the Ingress hostname aligned.
- Edit both `appservice-registration-irc.yaml` blocks in `k8s/irc-bridge/irc-bridge.yaml` and keep them identical:
  - `url`
  - `as_token`
  - `hs_token`
  - `namespaces.*.regex`
- Generate secure tokens for `as_token` and `hs_token`:

```bash
openssl rand -hex 32
openssl rand -hex 32
```

- If Synapse is not in namespace `ess`, update `metadata.namespace` for `matrix-irc-bridge-registration`.
- For additional bridge options, see upstream config sample.

## Install

```bash
kubectl create namespace ircbridge || true
kubectl create namespace ess || true
kubectl apply -f k8s/irc-bridge/irc-bridge.yaml
```

## Verify

```bash
kubectl -n ircbridge get pods,svc | grep matrix-irc-bridge
```

```bash
kubectl -n ircbridge logs deploy/matrix-irc-bridge
kubectl -n ircbridge logs deploy/matrix-irc-bridge-pool
```

```bash
kubectl -n ircbridge get ingress matrix-irc-bridge-media-proxy
```

## Docs

- [Bridge setup](https://matrix-org.github.io/matrix-appservice-irc/latest/bridge_setup.html)
- [Usage](https://matrix-org.github.io/matrix-appservice-irc/latest/usage.html)
- [Connection pooling](https://matrix-org.github.io/matrix-appservice-irc/latest/connection_pooling.html)
- [Config sample](https://github.com/matrix-org/matrix-appservice-irc/blob/develop/config.sample.yaml)

## Notes

- Synapse must mount and load `appservice-registration-irc.yaml` via `app_service_config_files`, then be restarted.
- The bridge defaults to bundled Postgres and bundled Redis.
- To use external Postgres/Redis, update config values and remove the bundled resource sections from `k8s/irc-bridge/irc-bridge.yaml`.
