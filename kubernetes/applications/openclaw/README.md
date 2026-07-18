# OpenClaw

[OpenClaw](https://openclaw.ai) gateway running in-cluster as a monitoring agent. It watches the Kubernetes cluster and Prometheus, and reports to Discord.

- Control UI: `https://openclaw.toof.jp` (token auth)
- Discord: bot connection via `DISCORD_BOT_TOKEN`
- Cluster access: read-only RBAC (`view` + cluster-scoped read) with `kubectl` installed by an init container
- Prometheus: `http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090`
- Model: Claude on Vertex AI (`anthropic-vertex/claude-sonnet-4-6`) via the `openclaw-vertex-sa` service account

## Vertex AI Provider

The agent talks to Claude through Google Vertex AI instead of the Anthropic API. Terraform (`terraform/service_account.tf`, `terraform/api.tf`) provisions everything: enables `aiplatform.googleapis.com`, creates the `openclaw-vertex-sa` service account with `roles/aiplatform.user`, and stores its key in GCP Secret Manager as `openclaw-vertex-sa-key`. The Deployment mounts the key and sets `GOOGLE_APPLICATION_CREDENTIALS`, `GOOGLE_CLOUD_PROJECT`, and `GOOGLE_CLOUD_LOCATION` for ADC.

The official Docker image does not bundle the Vertex provider's dependencies, so install the plugin once after the first deploy (it persists on the state PVC):

```sh
kubectl -n openclaw exec deploy/openclaw -- \
  node /app/openclaw.mjs plugin add @openclaw/anthropic-vertex-provider
kubectl -n openclaw rollout restart deploy/openclaw
```

## Secret Values

Create this secret in GCP Secret Manager (project `toof-infra`):

- `openclaw-discord-bot-token`: Discord bot token (see below)

The gateway auth token (`OPENCLAW_GATEWAY_TOKEN`) is generated in-cluster by the `password` ClusterGenerator. Read it with:

```sh
kubectl -n openclaw get secret openclaw-gateway-token-secret \
  -o jsonpath='{.data.OPENCLAW_GATEWAY_TOKEN}' | base64 -d
```

Paste it into the Control UI at `https://openclaw.toof.jp` (Settings -> Token).

## Discord Bot

1. Create an application at <https://discord.com/developers/applications> and add a Bot.
2. Enable the **Message Content Intent** under Privileged Gateway Intents.
3. Copy the bot token into the `openclaw-discord-bot-token` GCP secret.
4. Invite the bot to the server via OAuth2 URL Generator (`bot` scope; Send Messages, Read Message History, Create Public Threads permissions).
5. DM the bot once and approve the pairing code:

   ```sh
   kubectl -n openclaw exec deploy/openclaw -- \
     node /app/openclaw.mjs pairing approve discord <CODE>
   ```

## Monitoring Cron Jobs

Cron jobs are stored in the gateway state (SQLite on the `openclaw-state` PVC), so they are created once via the CLI rather than declared in manifests:

```sh
kubectl -n openclaw exec deploy/openclaw -- \
  node /app/openclaw.mjs cron create "*/30 * * * *" \
  "Check cluster health. Use kubectl to look for NotReady nodes, pods that are not Running/Succeeded, and recent Warning events. Query Prometheus at http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090 for firing alerts and for node CPU, memory, and disk usage above 90%. Only send a report if something needs attention; stay silent otherwise." \
  --name "cluster-health" \
  --session isolated \
  --announce \
  --channel discord \
  --to "channel:<DISCORD_CHANNEL_ID>"
```

A daily summary variant:

```sh
kubectl -n openclaw exec deploy/openclaw -- \
  node /app/openclaw.mjs cron create "0 9 * * *" \
  "Post a short daily cluster summary: node status, workload health by namespace, Longhorn volume state, Argo CD application sync status, and any Prometheus alerts that fired in the last 24h." \
  --name "daily-summary" \
  --session isolated \
  --announce \
  --channel discord \
  --to "channel:<DISCORD_CHANNEL_ID>"
```

List and remove jobs with `cron list` / `cron delete <id>`.

## Notes

- The pod runs with a read-only ServiceAccount; the agent can inspect but not mutate the cluster.
- `openclaw.json` is copied from the `openclaw-config` ConfigMap to the state PVC by an init container on every pod start (OpenClaw needs the config directory writable); edit it via Git, then `kubectl -n openclaw rollout restart deploy/openclaw` to apply.
- Everything else (sessions, cron store, workspace, auth profiles) persists on the `openclaw-state` PVC.
