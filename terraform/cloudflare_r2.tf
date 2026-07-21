resource "cloudflare_r2_bucket" "longhorn_backup" {
  account_id = var.cloudflare_account_id
  name       = "toof-longhorn-backup"
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
