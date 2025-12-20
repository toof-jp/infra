resource "tfe_workspace" "infra" {
  name = "toof-infra"
}

locals {
  hcp_terraform_variables = {
    google_billing_account = {
      value     = var.google_billing_account
      sensitive = true
    }
    cloudflare_account_id = {
      value     = var.cloudflare_account_id
      sensitive = false
    }
    cloudflare_api_token = {
      value     = var.cloudflare_api_token
      sensitive = true
    }
    discord_token = {
      value     = var.discord_token
      sensitive = true
    }
    github_client_id = {
      value     = var.github_client_id
      sensitive = false
    }
    github_client_secret = {
      value     = var.github_client_secret
      sensitive = true
    }
  }
}

resource "tfe_variable" "infra_variables" {
  for_each = local.hcp_terraform_variables

  key          = each.key
  value        = provider::terraform::encode_expr(each.value.value)
  category     = "terraform"
  workspace_id = tfe_workspace.infra.id
  hcl          = true
  sensitive    = each.value.sensitive
}
