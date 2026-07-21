output "auth0_domain" {
  value       = var.auth0_domain
  description = "Auth0 tenant domain."
}

output "auth0_obsidian_mcp_issuer" {
  value       = "https://${var.auth0_domain}/"
  description = "Expected JWT issuer for mcp-gate."
}

output "auth0_obsidian_mcp_jwks_uri" {
  value       = "https://${var.auth0_domain}/.well-known/jwks.json"
  description = "JWKS URI for mcp-gate."
}

output "auth0_obsidian_mcp_client_id" {
  value       = auth0_client.mcp["obsidian-mcp"].client_id
  description = "OAuth client ID for the Claude Obsidian MCP connector."
}

output "auth0_obsidian_mcp_client_secret" {
  value       = auth0_client_credentials.mcp["obsidian-mcp"].client_secret
  description = "OAuth client secret for the Claude Obsidian MCP connector."
  sensitive   = true
}

output "obsidian_mcp_resource_uri" {
  value       = local.mcp_urls["obsidian-mcp"]
  description = "Public URL/resource URI for the Obsidian MCP gateway."
}

output "obsidian_mcp_audience" {
  value       = auth0_resource_server.mcp["obsidian-mcp"].identifier
  description = "Expected audience configured for mcp-gate. Requires the tenant's Resource Parameter Compatibility Profile so RFC 8707 resource requests map to this API."
}

output "auth0_immich_mcp_client_id" {
  value       = auth0_client.mcp["immich-mcp"].client_id
  description = "OAuth client ID for the Claude Immich MCP connector."
}

output "auth0_immich_mcp_client_secret" {
  value       = auth0_client_credentials.mcp["immich-mcp"].client_secret
  description = "OAuth client secret for the Claude Immich MCP connector."
  sensitive   = true
}

output "immich_mcp_resource_uri" {
  value       = local.mcp_urls["immich-mcp"]
  description = "Public URL/resource URI for the Immich MCP gateway."
}

output "immich_mcp_audience" {
  value       = auth0_resource_server.mcp["immich-mcp"].identifier
  description = "Expected audience configured for mcp-gate. Requires the tenant's Resource Parameter Compatibility Profile so RFC 8707 resource requests map to this API."
}

output "auth0_apple_health_mcp_client_id" {
  value       = auth0_client.mcp["apple-health-mcp"].client_id
  description = "OAuth client ID for the Claude Apple Health MCP connector."
}

output "auth0_apple_health_mcp_client_secret" {
  value       = auth0_client_credentials.mcp["apple-health-mcp"].client_secret
  description = "OAuth client secret for the Claude Apple Health MCP connector."
  sensitive   = true
}

output "apple_health_mcp_resource_uri" {
  value       = local.mcp_urls["apple-health-mcp"]
  description = "Public URL/resource URI for the Apple Health MCP gateway."
}

output "apple_health_mcp_audience" {
  value       = auth0_resource_server.mcp["apple-health-mcp"].identifier
  description = "Expected audience configured for mcp-gate. Requires the tenant's Resource Parameter Compatibility Profile so RFC 8707 resource requests map to this API."
}

output "auth0_beancount_mcp_client_id" {
  value       = auth0_client.mcp["beancount-mcp"].client_id
  description = "OAuth client ID for the Claude Beancount MCP connector."
}

output "auth0_beancount_mcp_client_secret" {
  value       = auth0_client_credentials.mcp["beancount-mcp"].client_secret
  description = "OAuth client secret for the Claude Beancount MCP connector."
  sensitive   = true
}

output "beancount_mcp_resource_uri" {
  value       = local.mcp_urls["beancount-mcp"]
  description = "Public URL/resource URI for the Beancount MCP gateway."
}

output "beancount_mcp_audience" {
  value       = auth0_resource_server.mcp["beancount-mcp"].identifier
  description = "Expected audience configured for mcp-gate. Requires the tenant's Resource Parameter Compatibility Profile so RFC 8707 resource requests map to this API."
}

output "auth0_dawarich_mcp_client_id" {
  value       = auth0_client.mcp["dawarich-mcp"].client_id
  description = "OAuth client ID for the Claude Dawarich MCP connector."
}

output "auth0_dawarich_mcp_client_secret" {
  value       = auth0_client_credentials.mcp["dawarich-mcp"].client_secret
  description = "OAuth client secret for the Claude Dawarich MCP connector."
  sensitive   = true
}

output "dawarich_mcp_resource_uri" {
  value       = local.mcp_urls["dawarich-mcp"]
  description = "Public URL/resource URI for the Dawarich MCP gateway."
}

output "dawarich_mcp_audience" {
  value       = auth0_resource_server.mcp["dawarich-mcp"].identifier
  description = "Expected audience configured for mcp-gate. Requires the tenant's Resource Parameter Compatibility Profile so RFC 8707 resource requests map to this API."
}
