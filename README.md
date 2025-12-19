# infra

## GitOps

- Kubernetes manifests are synced by [Argo CD](https://argo-cd.readthedocs.io/en/stable/) to keep clusters declarative.
- Terraform automation runs via [Burrito](https://docs.burrito.tf/overview/) (an "Argo CD for Terraform"); Burrito continuously plans/applies the layers defined under `kubernetes/applications/burrito-project/`.
