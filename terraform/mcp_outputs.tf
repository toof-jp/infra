output "auth0_obsidian_mcp_client_id" {
  value       = auth0_client.obsidian_mcp.client_id
  description = "OAuth client ID for the Claude Obsidian MCP connector."
}

output "auth0_obsidian_mcp_client_secret" {
  value       = auth0_client_credentials.obsidian_mcp.client_secret
  description = "OAuth client secret for the Claude Obsidian MCP connector."
  sensitive   = true
}

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

output "obsidian_mcp_resource_uri" {
  value       = local.obsidian_mcp_url
  description = "Public URL/resource URI for the Obsidian MCP gateway."
}

output "obsidian_mcp_audience" {
  value       = auth0_resource_server.obsidian_mcp.identifier
  description = "Expected audience configured for mcp-gate. Requires the tenant's Resource Parameter Compatibility Profile so RFC 8707 resource requests map to this API."
}

output "auth0_immich_mcp_client_id" {
  value       = auth0_client.immich_mcp.client_id
  description = "OAuth client ID for the Claude Immich MCP connector."
}

output "auth0_immich_mcp_client_secret" {
  value       = auth0_client_credentials.immich_mcp.client_secret
  description = "OAuth client secret for the Claude Immich MCP connector."
  sensitive   = true
}

output "immich_mcp_resource_uri" {
  value       = local.immich_mcp_url
  description = "Public URL/resource URI for the Immich MCP gateway."
}

output "immich_mcp_audience" {
  value       = auth0_resource_server.immich_mcp.identifier
  description = "Expected audience configured for mcp-gate. Requires the tenant's Resource Parameter Compatibility Profile so RFC 8707 resource requests map to this API."
}
