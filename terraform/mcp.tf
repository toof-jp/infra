locals {
  mcp_clients = {
    "obsidian-mcp" = {
      description = "Claude Mobile remote MCP connector for the Obsidian vault."
    }
    "immich-mcp" = {
      description = "Claude remote MCP connector for the Immich photo library."
    }
    "apple-health-mcp" = {
      description = "Claude remote MCP connector for the Apple Health InfluxDB data."
    }
    "beancount-mcp" = {
      description = "Claude remote MCP connector for the Beancount ledger."
    }
    "dawarich-mcp" = {
      description = "Claude remote MCP connector for the Dawarich location history."
    }
  }

  mcp_hostnames = { for k, _ in local.mcp_clients : k => "${k}.${var.domain}" }
  mcp_urls      = { for k, h in local.mcp_hostnames : k => "https://${h}" }
}

resource "auth0_client" "mcp" {
  for_each = local.mcp_clients

  name        = each.key
  app_type    = "regular_web"
  description = each.value.description

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

resource "auth0_client_credentials" "mcp" {
  for_each = local.mcp_clients

  client_id             = auth0_client.mcp[each.key].id
  authentication_method = "client_secret_post"
}

# Claude sends the RFC 8707 resource parameter as the canonical origin URI
# with a trailing slash; Auth0 matches API identifiers by exact string, so
# the identifier must carry the slash too.
resource "auth0_resource_server" "mcp" {
  for_each = local.mcp_clients

  name                 = "${each.key}-api"
  identifier           = "${local.mcp_urls[each.key]}/"
  signing_alg          = "RS256"
  allow_offline_access = true
}

resource "auth0_resource_server_scopes" "mcp" {
  for_each = local.mcp_clients

  resource_server_identifier = auth0_resource_server.mcp[each.key].identifier
  scopes {
    name        = "mcp:tools"
    description = "MCP tools access"
  }
}

# Preserve terraform state across the flat-resource → for_each migration so
# apply doesn't destroy and recreate these clients (which would rotate their
# client_ids and break connected Claude instances).
moved {
  from = auth0_client.obsidian_mcp
  to   = auth0_client.mcp["obsidian-mcp"]
}
moved {
  from = auth0_client_credentials.obsidian_mcp
  to   = auth0_client_credentials.mcp["obsidian-mcp"]
}
moved {
  from = auth0_resource_server.obsidian_mcp
  to   = auth0_resource_server.mcp["obsidian-mcp"]
}
moved {
  from = auth0_resource_server_scopes.obsidian_mcp
  to   = auth0_resource_server_scopes.mcp["obsidian-mcp"]
}

moved {
  from = auth0_client.immich_mcp
  to   = auth0_client.mcp["immich-mcp"]
}
moved {
  from = auth0_client_credentials.immich_mcp
  to   = auth0_client_credentials.mcp["immich-mcp"]
}
moved {
  from = auth0_resource_server.immich_mcp
  to   = auth0_resource_server.mcp["immich-mcp"]
}
moved {
  from = auth0_resource_server_scopes.immich_mcp
  to   = auth0_resource_server_scopes.mcp["immich-mcp"]
}

moved {
  from = auth0_client.apple_health_mcp
  to   = auth0_client.mcp["apple-health-mcp"]
}
moved {
  from = auth0_client_credentials.apple_health_mcp
  to   = auth0_client_credentials.mcp["apple-health-mcp"]
}
moved {
  from = auth0_resource_server.apple_health_mcp
  to   = auth0_resource_server.mcp["apple-health-mcp"]
}
moved {
  from = auth0_resource_server_scopes.apple_health_mcp
  to   = auth0_resource_server_scopes.mcp["apple-health-mcp"]
}

moved {
  from = auth0_client.beancount_mcp
  to   = auth0_client.mcp["beancount-mcp"]
}
moved {
  from = auth0_client_credentials.beancount_mcp
  to   = auth0_client_credentials.mcp["beancount-mcp"]
}
moved {
  from = auth0_resource_server.beancount_mcp
  to   = auth0_resource_server.mcp["beancount-mcp"]
}
moved {
  from = auth0_resource_server_scopes.beancount_mcp
  to   = auth0_resource_server_scopes.mcp["beancount-mcp"]
}

moved {
  from = auth0_client.dawarich_mcp
  to   = auth0_client.mcp["dawarich-mcp"]
}
moved {
  from = auth0_client_credentials.dawarich_mcp
  to   = auth0_client_credentials.mcp["dawarich-mcp"]
}
moved {
  from = auth0_resource_server.dawarich_mcp
  to   = auth0_resource_server.mcp["dawarich-mcp"]
}
moved {
  from = auth0_resource_server_scopes.dawarich_mcp
  to   = auth0_resource_server_scopes.mcp["dawarich-mcp"]
}
