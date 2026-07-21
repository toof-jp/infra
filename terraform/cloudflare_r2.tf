resource "cloudflare_r2_bucket" "longhorn_backup" {
  account_id = var.cloudflare_account_id
  name       = "toof-longhorn-backup"
  location   = "apac"
}

# Terraform remote state bucket for toof-jp/github-repository-terraform.
# That repo runs Terraform outside HCP TFC (it manages GitHub repos on its
# own) and stores its state here via the S3-compatible R2 API.
resource "cloudflare_r2_bucket" "github_repository_terraform_state" {
  account_id = var.cloudflare_account_id
  name       = "toof-github-repository-terraform-state"
  location   = "apac"
}

resource "google_secret_manager_secret" "longhorn_backup_r2_endpoints" {
  secret_id = "longhorn-backup-r2-endpoints"
  replication {
    auto {}
  }
  depends_on = [google_project_service.enabled["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "longhorn_backup_r2_endpoints" {
  secret      = google_secret_manager_secret.longhorn_backup_r2_endpoints.id
  secret_data = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
}

# S3-compatible credentials for the state bucket above. R2 exposes tokens
# as `id` (Access Key ID) + `sha256(value)` (Secret Access Key). We stash
# both in Google Secret Manager so the github-repository-terraform repo
# can pull them with `gcloud secrets versions access` at `terraform init`
# time, instead of anyone clicking through the Cloudflare dashboard.
data "cloudflare_api_token_permission_groups_list" "r2_bucket_item_write" {
  # URL-encoded "Workers R2 Storage Bucket Item Write" — this permission
  # group grants both read and write on bucket-scoped objects.
  name = "Workers%20R2%20Storage%20Bucket%20Item%20Write"
}

resource "cloudflare_api_token" "github_repository_terraform_state" {
  name = "github-repository-terraform state R/W"

  policies = [{
    effect = "allow"
    permission_groups = [{
      id = data.cloudflare_api_token_permission_groups_list.r2_bucket_item_write.result[0].id
    }]
    resources = jsonencode({
      "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_default_${cloudflare_r2_bucket.github_repository_terraform_state.name}" = "*"
    })
  }]
}

resource "google_secret_manager_secret" "github_repository_terraform_state_r2_access_key_id" {
  secret_id = "github-repository-terraform-r2-access-key-id"
  replication {
    auto {}
  }
  depends_on = [google_project_service.enabled["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "github_repository_terraform_state_r2_access_key_id" {
  secret      = google_secret_manager_secret.github_repository_terraform_state_r2_access_key_id.id
  secret_data = cloudflare_api_token.github_repository_terraform_state.id
}

resource "google_secret_manager_secret" "github_repository_terraform_state_r2_secret_access_key" {
  secret_id = "github-repository-terraform-r2-secret-access-key"
  replication {
    auto {}
  }
  depends_on = [google_project_service.enabled["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "github_repository_terraform_state_r2_secret_access_key" {
  secret      = google_secret_manager_secret.github_repository_terraform_state_r2_secret_access_key.id
  secret_data = sha256(cloudflare_api_token.github_repository_terraform_state.value)
}
