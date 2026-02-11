# Grafana

## Overview

Grafana is a metrics and dashboard UI. This component provides an Ingress resource to expose an existing Grafana service in your cluster.

## Prerequisites

- A running Kubernetes cluster.
- An Ingress controller (this manifest uses `traefik`).
- cert-manager with a ClusterIssuer named `letsencrypt-prod` if you want TLS.
- A Grafana service named `monitoring-grafana` (see install steps below).

## Install Grafana (Helm)

If you don't already have Grafana deployed, install the kube-prometheus-stack chart, which includes Grafana:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack
```

If you already have a Grafana install, ensure the Service name matches the Ingress config in `k8s/grafana/grafana.yaml`.

## Files

- `k8s/grafana/grafana.yaml`: Ingress definition for Grafana.

## Configure

- Update the hostname in `k8s/grafana/grafana.yaml`: `grafana.example.com` -> your actual hostname.
- If your Grafana Service name or port differs, update `service.name` and `service.port`.
- If you use a different Ingress class or TLS issuer, update `ingressClassName` and the annotations.

## Install Ingress

```bash
kubectl apply -f k8s/grafana/grafana.yaml
```

## Verify

```bash
kubectl get ingress grafana-ingress
```

Open the Grafana URL in your browser.

## Docs

- [kube-prometheus-stack chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Grafana docs](https://grafana.com/docs/grafana/latest/)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [cert-manager docs](https://cert-manager.io/docs/)

## Notes

- This component only creates the Ingress. It does not install Grafana itself.
- By default the username is `admin`, you can retrieve your Grafana password using:

    ```bash
    kubectl get secret monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
    ```
