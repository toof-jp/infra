# infra

Personal infrastructure monorepo: Kubernetes manifests synced by Argo CD and Terraform configurations for cloud resources.

## GitOps

- Kubernetes manifests are synced by Argo CD to keep clusters declarative.
- Terraform automation runs via HCP Terraform; it continuously plans/applies the configurations under `terraform/`.

## Repository layout

```
.
├── kubernetes/
│   ├── app-of-apps.yaml      # Argo CD root Application
│   └── applications/         # ApplicationSet + per-app manifests
├── terraform/                # Cloudflare / GCP / AWS / Vultr / Auth0 / Discord resources
└── docs/                     # Operational notes
```

## Architecture

```mermaid
flowchart TB
    subgraph repo["GitHub: toof-jp/infra"]
        k8sdir["kubernetes/"]
        tfdir["terraform/"]
    end

    subgraph cluster["Kubernetes cluster"]
        argocd["Argo CD"]
        appofapps["app-of-apps"]
        appset["ApplicationSet"]
        apps["Applications<br/>archiveteam-warrior, argocd, bbs, blues,<br/>dev-vm, healthcheck, kubevirt, mcp-gate,<br/>milktea, monitoring, npm-stats, obsidian,<br/>obsidian-msp, shisha-log, ..."]
        platform["Platform (Helm)<br/>longhorn, external-secrets,<br/>cloudflare-tunnel-ingress-controller,<br/>kube-prometheus-stack, metrics-server,<br/>headlamp, immich"]
    end

    subgraph providers["Cloud providers"]
        cloudflare["Cloudflare<br/>DNS / Tunnel / Zero Trust Access"]
        gcp["Google Cloud<br/>Secret Manager / Monitoring /<br/>Cloud Functions"]
        aws["AWS<br/>S3 (Terraform remote state)"]
        vultr["Vultr<br/>vultr-vps instance"]
        auth0["Auth0<br/>MCP OAuth clients"]
        discord["Discord<br/>alert webhook"]
    end

    hcp["HCP Terraform"]

    k8sdir -->|sync| argocd
    argocd --> appofapps
    appofapps --> appset
    appofapps --> platform
    appset --> apps

    tfdir --> hcp
    hcp --> providers

    platform -->|ExternalSecret| gcp
    platform -->|Ingress| cloudflare
```

## Kubernetes nodes

All nodes run Kubernetes v1.36 on containerd. Cluster traffic (apiserver, etcd, kubelet) flows over the Tailscale mesh. `zen2` is untainted and runs the workloads; the VPS nodes carry the `control-plane` taint.

```mermaid
flowchart LR
    subgraph k8s["Kubernetes cluster (v1.36)"]
        subgraph home["Home"]
            zen2["zen2<br/>Arch Linux<br/>16 CPU / 64 GiB<br/>control-plane + worker"]
        end
        subgraph sakura["Sakura VPS"]
            sakuravps["sakura-vps<br/>NixOS<br/>4 CPU / 4 GiB<br/>control-plane (tainted)"]
        end
        subgraph vultrcloud["Vultr"]
            vultrvps["vultr-vps<br/>NixOS<br/>1 CPU / 2 GiB<br/>control-plane (tainted)"]
        end
    end

    zen2 <-->|Tailscale| sakuravps
    zen2 <-->|Tailscale| vultrvps
    sakuravps <-->|Tailscale| vultrvps
```
