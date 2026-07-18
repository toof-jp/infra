# Obsidian MCP Gateway

This exposes the Obsidian MCP endpoint through `mcp-gate` at:

```text
https://obsidian-mcp.toof.jp/mcp
```

Auth0 is only used as the SaaS identity provider and JWKS issuer. Nothing for Auth0 runs in the cluster. The hostname is published through the Cloudflare Tunnel ingress; authentication is enforced at the origin by `mcp-gate` validating Auth0-issued JWTs.

## Why Not Cloudflare Access

Cloudflare Access (Managed OAuth for MCP) cannot front this hostname: the claude.ai web and mobile connectors fail during the OAuth handshake against Access-protected MCP servers because Access omits the `WWW-Authenticate` header on 401 responses (only Claude Code tolerates this). The issue was closed as not planned on both sides. Putting an identity-requiring Access application on `obsidian-mcp.toof.jp` would therefore break the connector; OAuth via Auth0 + JWT validation in `mcp-gate` provides the equivalent protection instead.

## Auth0 Manual Settings

- Tenant Settings -> Advanced -> enable **Resource Parameter Compatibility Profile**. The MCP spec (RFC 8707) makes Claude send a `resource` parameter, and without this profile Auth0 ignores it and issues an opaque access token that `mcp-gate` cannot validate. With it enabled, the token is a JWT with `aud` = `https://obsidian-mcp.toof.jp/` (the `obsidian-mcp-api` resource server identifier — the trailing slash matters, because Claude canonicalizes the resource URI to the origin with a trailing slash and Auth0 matches identifiers by exact string).
- Enable the Social Connection you want to use, such as Google or GitHub.
- In the `obsidian-mcp` Auth0 Application, add `https://claude.ai` to Allowed Web Origins.

## Secret Values

Populate the `mcp-gate/obsidian/*` 1Password items from Terraform outputs:

```sh
cd terraform
terraform output -raw auth0_obsidian_mcp_issuer
terraform output -raw auth0_obsidian_mcp_jwks_uri
terraform output -raw obsidian_mcp_audience
```

Expected mappings:

- `mcp-gate/obsidian/authorization-server`: `terraform output -raw auth0_obsidian_mcp_issuer`
- `mcp-gate/obsidian/jwks-uri`: `terraform output -raw auth0_obsidian_mcp_jwks_uri`
- `mcp-gate/obsidian/expected-issuer`: `terraform output -raw auth0_obsidian_mcp_issuer`
- `mcp-gate/obsidian/expected-audience`: `terraform output -raw obsidian_mcp_audience`

## Claude Connector

In Claude:

1. Settings -> Connectors -> Add Custom Connector
2. Remote MCP server URL: `https://obsidian-mcp.toof.jp/mcp`
3. Advanced settings -> OAuth Client ID: `terraform output -raw auth0_obsidian_mcp_client_id`
4. Advanced settings -> OAuth Client Secret: `terraform output -raw auth0_obsidian_mcp_client_secret`
5. Add, sign in on the Auth0 screen, and finish the connector setup.

## Adding Another MCP Server

- Copy the `mcp-gate` Deployment/Service/Ingress and change `UPSTREAM_URL` and `RESOURCE_URI`.
- Add the new hostname as a Cloudflare Tunnel Ingress by creating a Kubernetes Ingress with `ingressClassName: cloudflare-tunnel`.
- Add the callback URL to the Auth0 Application if the client requires a new callback.

## Current Obsidian Upstream

The gateway points to `http://obsidian-msp.obsidian-msp.svc.cluster.local:3001`.

`@bitbonsai/mcpvault` is a stdio-only MCP server, so the `obsidian-msp` Deployment wraps it with `mcp-proxy`, which serves Streamable HTTP at `/mcp` (and SSE at `/sse`) on port 3001.

## Immich MCP Gateway

`immich.yaml` exposes the Immich MCP endpoint at:

```text
https://immich-mcp.toof.jp/mcp
```

The upstream is [barryw/ImmichMCP](https://github.com/barryw/ImmichMCP) running in the `immich-mcp` namespace (`kubernetes/applications/immich-mcp/`), serving Streamable HTTP at `/mcp` on port 5000. ImmichMCP 3.x targets Immich v3 APIs, so the image is pinned to `v0.4.0` until the Immich chart is upgraded past v2.

### Secret Values

Populate the `mcp-gate/immich/*` 1Password items from Terraform outputs:

- `mcp-gate/immich/authorization-server`: `terraform output -raw auth0_obsidian_mcp_issuer`
- `mcp-gate/immich/jwks-uri`: `terraform output -raw auth0_obsidian_mcp_jwks_uri`
- `mcp-gate/immich/expected-issuer`: `terraform output -raw auth0_obsidian_mcp_issuer`
- `mcp-gate/immich/expected-audience`: `terraform output -raw immich_mcp_audience`

The Immich API key comes from GCP Secret Manager (`immich-mcp-api-key`). Create it in Immich (Account Settings -> API Keys) with read-only permissions only; ImmichMCP has no read-only mode, so the key permissions are what enforce it.

### Auth0 Manual Settings

In the `immich-mcp` Auth0 Application, add `https://claude.ai` to Allowed Web Origins. The tenant-wide Resource Parameter Compatibility Profile is already enabled for obsidian-mcp.

### Claude Connector

1. Settings -> Connectors -> Add Custom Connector
2. Remote MCP server URL: `https://immich-mcp.toof.jp/mcp`
3. Advanced settings -> OAuth Client ID: `terraform output -raw auth0_immich_mcp_client_id`
4. Advanced settings -> OAuth Client Secret: `terraform output -raw auth0_immich_mcp_client_secret`
5. Add, sign in on the Auth0 screen, and finish the connector setup.
