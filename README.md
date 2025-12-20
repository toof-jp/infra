# infra

## GitOps

- Kubernetes manifests are synced by Argo CD to keep clusters declarative.
- Terraform automation runs via HCP Terraform; it continuously plans/applies the configurations under `terraform/`.
