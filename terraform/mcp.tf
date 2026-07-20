locals {
  obsidian_mcp_hostname = "obsidian-mcp.${var.domain}"
  obsidian_mcp_url      = "https://${local.obsidian_mcp_hostname}"
  immich_mcp_hostname   = "immich-mcp.${var.domain}"
  immich_mcp_url        = "https://${local.immich_mcp_hostname}"

  apple_health_mcp_hostname = "apple-health-mcp.${var.domain}"
  apple_health_mcp_url      = "https://${local.apple_health_mcp_hostname}"

  beancount_mcp_hostname = "beancount-mcp.${var.domain}"
  beancount_mcp_url      = "https://${local.beancount_mcp_hostname}"

  dawarich_mcp_hostname = "dawarich-mcp.${var.domain}"
  dawarich_mcp_url      = "https://${local.dawarich_mcp_hostname}"
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

resource "auth0_client" "apple_health_mcp" {
  name        = "apple-health-mcp"
  app_type    = "regular_web"
  description = "Claude remote MCP connector for the Apple Health InfluxDB data."

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

resource "auth0_client_credentials" "apple_health_mcp" {
  client_id             = auth0_client.apple_health_mcp.id
  authentication_method = "client_secret_post"
}

resource "auth0_resource_server" "apple_health_mcp" {
  name                 = "apple-health-mcp-api"
  identifier           = "${local.apple_health_mcp_url}/"
  signing_alg          = "RS256"
  allow_offline_access = true
}

resource "auth0_resource_server_scopes" "apple_health_mcp" {
  resource_server_identifier = auth0_resource_server.apple_health_mcp.identifier
  scopes {
    name        = "mcp:tools"
    description = "MCP tools access"
  }
}

resource "auth0_client" "beancount_mcp" {
  name        = "beancount-mcp"
  app_type    = "regular_web"
  description = "Claude remote MCP connector for the Beancount ledger."

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

resource "auth0_client_credentials" "beancount_mcp" {
  client_id             = auth0_client.beancount_mcp.id
  authentication_method = "client_secret_post"
}

resource "auth0_resource_server" "beancount_mcp" {
  name                 = "beancount-mcp-api"
  identifier           = "${local.beancount_mcp_url}/"
  signing_alg          = "RS256"
  allow_offline_access = true
}

resource "auth0_resource_server_scopes" "beancount_mcp" {
  resource_server_identifier = auth0_resource_server.beancount_mcp.identifier
  scopes {
    name        = "mcp:tools"
    description = "MCP tools access"
  }
}

resource "auth0_client" "dawarich_mcp" {
  name        = "dawarich-mcp"
  app_type    = "regular_web"
  description = "Claude remote MCP connector for the Dawarich location history."

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

resource "auth0_client_credentials" "dawarich_mcp" {
  client_id             = auth0_client.dawarich_mcp.id
  authentication_method = "client_secret_post"
}

resource "auth0_resource_server" "dawarich_mcp" {
  name                 = "dawarich-mcp-api"
  identifier           = "${local.dawarich_mcp_url}/"
  signing_alg          = "RS256"
  allow_offline_access = true
}

resource "auth0_resource_server_scopes" "dawarich_mcp" {
  resource_server_identifier = auth0_resource_server.dawarich_mcp.identifier
  scopes {
    name        = "mcp:tools"
    description = "MCP tools access"
  }
}
