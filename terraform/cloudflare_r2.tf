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
