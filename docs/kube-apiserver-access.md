# kube-apiserver Public Access

`k8s.toof.jp` exposes the in-cluster `kubernetes.default.svc` (kube-apiserver) as a TCP endpoint through a dedicated Cloudflare Tunnel. Cloudflare Zero Trust Access (GitHub SSO, `toof@toof.jp`) sits in front of the tunnel; the apiserver's own TLS + client certificate authentication is preserved end-to-end (Cloudflare does not terminate the apiserver TLS).

## Components

- `terraform/kube_apiserver.tf` — named tunnel `kube-apiserver`, its remote ingress config (`k8s.toof.jp` → `tcp://kubernetes.default.svc.cluster.local:443`), the CNAME `k8s.toof.jp` → `<tunnel-id>.cfargotunnel.com`, the Zero Trust Access application, and the Secret Manager entry `cloudflared-kube-apiserver-tunnel-token`.
- `kubernetes/applications/cloudflared-kube-apiserver/` — cloudflared Deployment (2 replicas) and the ExternalSecret that syncs the token from Secret Manager.

## Client setup

1. Install `cloudflared` locally.
2. Log in once so the browser SSO cookie is cached: `cloudflared access login https://k8s.toof.jp`.
3. Start the local TCP proxy in a long-running terminal / systemd user unit:

   ```
   cloudflared access tcp --hostname k8s.toof.jp --url localhost:16443
   ```

4. Add a kubeconfig context that points at the local proxy. Client cert / CA data stays whatever `kubeadm` issued; only `server` and `tls-server-name` change:

   ```yaml
   clusters:
     - name: toof-public
       cluster:
         server: https://localhost:16443
         tls-server-name: kubernetes
         certificate-authority-data: <same as the existing in-cluster context>
   contexts:
     - name: toof-public
       context:
         cluster: toof-public
         user: <existing kubeadm client cert user>
   ```

   `tls-server-name: kubernetes` is required because `localhost` is not in the apiserver's cert SANs; `kubernetes` is (kubeadm always adds it).

## Notes

- The tunnel is fronted by Cloudflare Access, so `cloudflared access tcp` will prompt for the GitHub SSO flow the first time (or after the 24 h session expires).
- Client-cert mTLS still runs between kubectl and the apiserver — Cloudflare only sees an opaque TCP stream. Revoking access requires updating the Cloudflare Access policy _and_ (for a compromised client cert) rotating the kubeadm CA / issuing a new client cert.
- The cloudflared Deployment runs inside the cluster and dials `kubernetes.default.svc.cluster.local:443`, so if the apiserver is completely down the tunnel is also unreachable — this is not a recovery path for a broken cluster. Use direct Tailscale + `kubectl --server=https://100.83.127.53:6443` from zen2 for that.
