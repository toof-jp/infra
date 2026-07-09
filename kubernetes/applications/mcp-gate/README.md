# Obsidian MCP Gateway

This exposes the Obsidian MCP endpoint through `mcp-gate` at:

```text
https://obsidian-mcp.toof.jp/mcp
```

Auth0 is only used as the SaaS identity provider and JWKS issuer. Nothing for Auth0 runs in the cluster. The hostname is published through the Cloudflare Tunnel ingress; authentication is enforced at the origin by `mcp-gate` validating Auth0-issued JWTs.

## Why Not Cloudflare Access

Cloudflare Access (Managed OAuth for MCP) cannot front this hostname: the claude.ai web and mobile connectors fail during the OAuth handshake against Access-protected MCP servers because Access omits the `WWW-Authenticate` header on 401 responses (only Claude Code tolerates this). The issue was closed as not planned on both sides. Putting an identity-requiring Access application on `obsidian-mcp.toof.jp` would therefore break the connector; OAuth via Auth0 + JWT validation in `mcp-gate` provides the equivalent protection instead.

## Auth0 Manual Settings

- Tenant Settings -> Advanced -> enable **Resource Parameter Compatibility Profile**. The MCP spec (RFC 8707) makes Claude send a `resource` parameter, and without this profile Auth0 ignores it and issues an opaque access token that `mcp-gate` cannot validate. With it enabled, the token is a JWT with `aud` = `https://obsidian-mcp.toof.jp` (the `obsidian-mcp-api` resource server identifier).
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
