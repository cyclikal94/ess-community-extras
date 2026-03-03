# Matrix Helm Charts

This is the branch for GitHub pages. It is primarily used to serve the `index.yaml` of helm charts for use when using the legacy-compatiable HTTP Registry:

```bash
helm repo add matrix-helm-charts https://cyclikal94.github.io/matrix-helm-charts
helm repo update
helm upgrade --install <release-name> matrix-helm-charts/<chart-name> --namespace <namespace> --create-namespace --values <values-file>
```
