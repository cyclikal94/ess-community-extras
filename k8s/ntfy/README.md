# ntfy

## Overview

ntfy is a simple pub/sub notification service. This directory contains the raw Kubernetes manifest deployment (ConfigMap, Service, StatefulSet, and Ingress).

## Prerequisites

- A running Kubernetes cluster.
- An Ingress controller (this manifest uses `traefik`).
- cert-manager with a ClusterIssuer named `letsencrypt-prod` if you want TLS.
- A default StorageClass, or edit the PVC spec in `k8s/ntfy/ntfy.yaml` to match your environment.

## Files

- `k8s/ntfy/ntfy.yaml`: ConfigMap, Service, StatefulSet, and Ingress for ntfy.

## Configure

- Update `base-url` in `k8s/ntfy/ntfy.yaml`: `https://ntfy.example.com` -> your actual URL.
- Update the Ingress hostname and TLS secret name if needed.
- Adjust storage size or class in `volumeClaimTemplates` if your cluster requires it.

## Install

```bash
kubectl apply -f k8s/ntfy/ntfy.yaml
```

## Verify

```bash
kubectl get pods,svc -l app=ntfy
```

```bash
kubectl get ingress ntfy-ingress
```

Open the ntfy URL and publish a test message.

## Docs

- [ntfy docs](https://docs.ntfy.sh/)
- [ntfy server config](https://docs.ntfy.sh/config/)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [cert-manager docs](https://cert-manager.io/docs/)

## Notes

- The container image is `binwiederhier/ntfy`. Pin a version tag if you want deterministic upgrades.
