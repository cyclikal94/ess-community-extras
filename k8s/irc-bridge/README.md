# matrix-appservice-irc

## Overview

This directory uses a single all-in-one Kubernetes manifest:

- `k8s/irc-bridge/irc-bridge.yaml`

It includes:

- bridge config + appservice registration in one `ConfigMap`
- duplicate registration `ConfigMap` in Synapse namespace (`ess`) for Synapse mounting
- bridge `Service` + `Deployment`
- bundled Postgres (`Secret` + `Service` + `StatefulSet`)
- bundled Redis (`Service` + `StatefulSet`)
- pool worker `Deployment` (connection pooling enabled by default)

## Upstream docs

- [Bridge setup](https://matrix-org.github.io/matrix-appservice-irc/latest/bridge_setup.html)
- [Config sample](https://github.com/matrix-org/matrix-appservice-irc/blob/develop/config.sample.yaml)
- [Usage](https://matrix-org.github.io/matrix-appservice-irc/latest/usage.html)
- [Connection pooling](https://matrix-org.github.io/matrix-appservice-irc/latest/connection_pooling.html)

## 1) Edit the ConfigMap in `irc-bridge.yaml`

In `k8s/irc-bridge/irc-bridge.yaml`, edit `ConfigMap` values:

- `data.config.yaml`:
  - `homeserver.url`
  - `homeserver.domain`
  - `ircService.servers` entry
  - `database.connectionString`
  - `ircClients.mode` and `connectionPool.redisUrl` (if pooling)
- `data.appservice-registration-irc.yaml`:
  - `url`
  - `as_token`
  - `hs_token`
  - `namespaces.*.regex` domain
- second `ConfigMap` (`matrix-irc-bridge-registration`) `metadata.namespace` for Synapse
- keep both `appservice-registration-irc.yaml` copies identical

Generate secure tokens, for example:

```bash
openssl rand -hex 32
openssl rand -hex 32
```

## 2) Apply

```bash
kubectl -n <namespace> apply -f k8s/irc-bridge/irc-bridge.yaml
```

## 3) Synapse changes (required)

Synapse must load the same `appservice-registration-irc.yaml` content.

1. Mount the registration file from `ConfigMap/matrix-irc-bridge-registration` in the Synapse namespace.
2. Add its path to `app_service_config_files` in Synapse config.
3. Restart Synapse.

If Synapse does not load the registration file, no bridge traffic will be routed.

## External Postgres / Redis

The manifest defaults to bundled Postgres + bundled Redis.

- External Postgres:
  - update `database.connectionString` in `data.config.yaml`
  - remove postgres `Secret` + `Service` + `StatefulSet`
- Disable pooling:
  - set `ircClients.mode: "bot"`
  - remove `connectionPool` section in `data.config.yaml`
  - remove redis `Service` + `StatefulSet` and pool `Deployment`
- External Redis with pooling:
  - update `connectionPool.redisUrl`
  - update pool `REDIS_URL`
  - remove bundled redis `Service` + `StatefulSet`

## Verify

```bash
kubectl -n <namespace> get pods,svc | grep matrix-irc-bridge
kubectl -n <namespace> logs deploy/matrix-irc-bridge
kubectl -n <namespace> logs deploy/matrix-irc-bridge-pool
```
