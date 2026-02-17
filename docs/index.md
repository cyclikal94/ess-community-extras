---
layout: page
title: ESS Community Extras
---

A collection of charts and configs to deploy services alongside ESS Community. See `k8s` for deployment.yml files to apply with `kubectl apply -f` or `helm` for helm charts.

## Components

- `grafana`: Ingress for exposing Grafana (following helm chart install).
- `ntfy`: ntfy notification service.
- `irc-bridge`: IRC bridge using `matrix-appservice-irc`.