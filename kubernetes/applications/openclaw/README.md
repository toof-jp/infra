# OpenClaw

[OpenClaw](https://openclaw.ai) gateway running in-cluster as a monitoring agent. It watches the Kubernetes cluster and Prometheus, and reports to Discord.

- Control UI: `https://openclaw.toof.jp` (token auth)
- Discord: bot connection via `DISCORD_BOT_TOKEN`
- Cluster access: read-only RBAC (`view` + cluster-scoped read) with `kubectl` installed by an init container
- Prometheus: `http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090`
- Model: MiMo V2.5 on [opencode Go](https://opencode.ai/docs/go/) (`opencode-go/mimo-v2.5`)

## Model Provider

The agent talks to the model through the opencode Go subscription, declared in `openclaw.json` as the custom `opencode-go` provider: OpenAI-compatible API at `https://opencode.ai/zen/go/v1`, authenticated with the `OPENCODE_API_KEY` environment variable that comes from the `openclaw-secret` ExternalSecret.

DeepSeek V4 Flash was the first choice but opencode Go rejects it with `403 The latest version of this model is only available hosted in China and requires explicit opt in`, so it needs an opt-in in the opencode workspace before it can be used.

Only the Discord plugin is declared in `plugins.entries`; the gateway's startup doctor auto-installs `@openclaw/discord` from npm onto the state PVC on first start. A custom OpenAI-compatible provider needs no plugin.

## Secret Values

Create these secrets in GCP Secret Manager (project `toof-infra`):

- `openclaw-discord-bot-token`: Discord bot token (see below)
- `openclaw-gateway-token`: any random string used to authenticate to the Control UI
- `openclaw-opencode-api-key`: opencode Zen/Go API key from <https://opencode.ai/auth>

Read the current value of the gateway token (mirrored into the cluster as `openclaw-gateway-token-secret`) with:

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
