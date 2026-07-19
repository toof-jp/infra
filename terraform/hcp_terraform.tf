data "google_secret_manager_secret_version" "aws_access_key_id" {
  project    = google_project.toof_infra.project_id
  secret     = "aws_access_key_id"
  version    = "latest"
  depends_on = [google_project_service.enabled["secretmanager.googleapis.com"]]
}

data "google_secret_manager_secret_version" "aws_secret_access_key" {
  project    = google_project.toof_infra.project_id
  secret     = "aws_secret_access_key"
  version    = "latest"
  depends_on = [google_project_service.enabled["secretmanager.googleapis.com"]]
}

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
  aws_access_key_id_value     = data.google_secret_manager_secret_version.aws_access_key_id.secret_data
  aws_secret_access_key_value = data.google_secret_manager_secret_version.aws_secret_access_key.secret_data
  google_credentials_value    = replace(replace(base64decode(google_service_account_key.terraform_sa_key.private_key), "\r", ""), "\n", "")

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
    AWS_ACCESS_KEY_ID = {
      value     = local.aws_access_key_id_value
      sensitive = true
      category  = "env"
    }
    AWS_SECRET_ACCESS_KEY = {
      value     = local.aws_secret_access_key_value
      sensitive = true
      category  = "env"
    }
    GOOGLE_CREDENTIALS = {
      value     = local.google_credentials_value
      sensitive = true
      category  = "env"
    }
  }
}

resource "terraform_data" "validate_hcp_env_secrets" {
  lifecycle {
    precondition {
      condition = alltrue([
        local.aws_access_key_id_value != "",
        local.aws_secret_access_key_value != "",
        local.google_credentials_value != "",
      ])
      error_message = "Missing required secrets: ensure aws_access_key_id, aws_secret_access_key (GSM) and terraform_sa key (GOOGLE_CREDENTIALS) are populated."
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
