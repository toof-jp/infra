locals {
  obsidian_mcp_hostname = "obsidian-mcp.${var.domain}"
  obsidian_mcp_url      = "https://${local.obsidian_mcp_hostname}"
  immich_mcp_hostname   = "immich-mcp.${var.domain}"
  immich_mcp_url        = "https://${local.immich_mcp_hostname}"
}

resource "auth0_client" "obsidian_mcp" {
  name        = "obsidian-mcp"
  app_type    = "regular_web"
  description = "Claude Mobile remote MCP connector for the Obsidian vault."

  callbacks = [
    "https://claude.ai/api/mcp/auth_callback",
    "https://claude.com/api/mcp/auth_callback",
  ]

  allowed_logout_urls = []

  grant_types = [
    "authorization_code",
    "refresh_token",
  ]

  oidc_conformant = true
}

resource "auth0_client_credentials" "obsidian_mcp" {
  client_id             = auth0_client.obsidian_mcp.id
  authentication_method = "client_secret_post"
}

# Claude sends the RFC 8707 resource parameter as the canonical origin URI
# with a trailing slash; Auth0 matches API identifiers by exact string, so
# the identifier must carry the slash too.
resource "auth0_resource_server" "obsidian_mcp" {
  name                 = "obsidian-mcp-api"
  identifier           = "${local.obsidian_mcp_url}/"
  signing_alg          = "RS256"
  allow_offline_access = true
}

resource "auth0_resource_server_scopes" "obsidian_mcp" {
  resource_server_identifier = auth0_resource_server.obsidian_mcp.identifier
  scopes {
    name        = "mcp:tools"
    description = "MCP tools access"
  }
}

resource "auth0_client" "immich_mcp" {
  name        = "immich-mcp"
  app_type    = "regular_web"
  description = "Claude remote MCP connector for the Immich photo library."

  callbacks = [
    "https://claude.ai/api/mcp/auth_callback",
    "https://claude.com/api/mcp/auth_callback",
  ]

  allowed_logout_urls = []

  grant_types = [
    "authorization_code",
    "refresh_token",
  ]

  oidc_conformant = true
}

resource "auth0_client_credentials" "immich_mcp" {
  client_id             = auth0_client.immich_mcp.id
  authentication_method = "client_secret_post"
}

resource "auth0_resource_server" "immich_mcp" {
  name                 = "immich-mcp-api"
  identifier           = "${local.immich_mcp_url}/"
  signing_alg          = "RS256"
  allow_offline_access = true
}

resource "auth0_resource_server_scopes" "immich_mcp" {
  resource_server_identifier = auth0_resource_server.immich_mcp.identifier
  scopes {
    name        = "mcp:tools"
    description = "MCP tools access"
  }
}
