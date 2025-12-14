# infra
## GitOps

- Kubernetes manifests are synced by Argo CD to keep clusters declarative.
- Terraform state is applied through GitHub Actions after changes merge into `main`.
