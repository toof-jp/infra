resource "tfe_organization" "infra" {
  name  = "toof-infra"
  email = var.tfe_email
}

resource "tfe_workspace" "infra" {
  name              = "toof-infra"
  organization      = tfe_organization.infra.name
  working_directory = "terraform"
  queue_all_runs    = true
  auto_apply        = true

  vcs_repo {
    identifier     = "toof-jp/infra"
    branch         = "main"
    oauth_token_id = var.tfe_oauth_token_id
  }
}

resource "tfe_workspace_settings" "infra" {
  workspace_id   = tfe_workspace.infra.id
  execution_mode = "remote"
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
    tfe_email = {
      value     = var.tfe_email
      sensitive = false
    }
    tfe_token = {
      value     = var.tfe_token
      sensitive = true
    }
    tfe_oauth_token_id = {
      value     = var.tfe_oauth_token_id
      sensitive = true
    }
    auth0_domain = {
      value     = var.auth0_domain
      sensitive = false
    }
    auth0_client_id = {
      value     = var.auth0_client_id
      sensitive = false
    }
    auth0_client_secret = {
      value     = var.auth0_client_secret
      sensitive = true
    }
    domain = {
      value     = var.domain
      sensitive = false
    }
    vultr_api_key = {
      value     = var.vultr_api_key
      sensitive = true
      # Hand-seeded in the workspace with hcl=false; TFE refuses to flip
      # the hcl flag on a sensitive variable, so keep managing it as-is.
      hcl = false
    }
    oci_tenancy_ocid = {
      value     = var.oci_tenancy_ocid
      sensitive = false
    }
    oci_user_ocid = {
      value     = var.oci_user_ocid
      sensitive = false
    }
    oci_fingerprint = {
      value     = var.oci_fingerprint
      sensitive = false
    }
    oci_private_key = {
      value     = var.oci_private_key
      sensitive = true
      # Seeded via the TFE API with hcl=false; same constraint as
      # vultr_api_key above.
      hcl = false
    }
    TFC_GCP_PROVIDER_AUTH = {
      value     = "true"
      sensitive = false
      category  = "env"
    }
    TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL = {
      value     = google_service_account.terraform_sa.email
      sensitive = false
      category  = "env"
    }
    TFC_GCP_WORKLOAD_PROVIDER_NAME = {
      value     = google_iam_workload_identity_pool_provider.hcp_terraform.name
      sensitive = false
      category  = "env"
    }
    TFC_AWS_PROVIDER_AUTH = {
      value     = "true"
      sensitive = false
      category  = "env"
    }
    TFC_AWS_RUN_ROLE_ARN = {
      value     = aws_iam_role.hcp_terraform.arn
      sensitive = false
      category  = "env"
    }
  }
}

resource "tfe_variable" "infra_variables" {
  for_each = local.hcp_terraform_variables

  key          = each.key
  category     = lookup(each.value, "category", "terraform")
  value        = lookup(each.value, "hcl", lookup(each.value, "category", "terraform") == "terraform") ? provider::terraform::encode_expr(each.value.value) : tostring(each.value.value)
  workspace_id = tfe_workspace.infra.id
  hcl          = lookup(each.value, "hcl", lookup(each.value, "category", "terraform") == "terraform")
  sensitive    = each.value.sensitive
}
