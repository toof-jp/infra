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

resource "cloudflare_api_token" "longhorn_backup_r2" {
  name = "longhorn-backup-r2"
  policies = [{
    effect = "allow"
    resources = jsonencode({
      "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_default_${cloudflare_r2_bucket.longhorn_backup.name}" = "*"
    })
    permission_groups = [
      { id = "6a018a9f2fc74eb6b293b0c548f38b39" }, # Workers R2 Storage Bucket Item Read
      { id = "2efd5506f9c8494dacb1fa10a3e7d5b6" }, # Workers R2 Storage Bucket Item Write
    ]
  }]
}

resource "google_secret_manager_secret" "longhorn_backup_r2_access_key_id" {
  secret_id = "longhorn-backup-r2-access-key-id"
  replication {
    auto {}
  }
  depends_on = [google_project_service.enabled["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "longhorn_backup_r2_access_key_id" {
  secret      = google_secret_manager_secret.longhorn_backup_r2_access_key_id.id
  secret_data = cloudflare_api_token.longhorn_backup_r2.id
}

resource "google_secret_manager_secret" "longhorn_backup_r2_secret_access_key" {
  secret_id = "longhorn-backup-r2-secret-access-key"
  replication {
    auto {}
  }
  depends_on = [google_project_service.enabled["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "longhorn_backup_r2_secret_access_key" {
  secret      = google_secret_manager_secret.longhorn_backup_r2_secret_access_key.id
  secret_data = sha256(cloudflare_api_token.longhorn_backup_r2.value)
}
