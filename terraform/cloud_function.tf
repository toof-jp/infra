resource "google_storage_bucket" "bucket" {
  name                        = "${google_project.toof_infra.name}-monitoring-notification-channel-discord-functions"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_secret_manager_secret" "discord_webhook_url" {
  secret_id = "discord-webhhok-url"
  replication {
    auto {}
  }
  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "discord_webhook_url" {
  secret      = google_secret_manager_secret.discord_webhook_url.id
  secret_data = discord_webhook.webhook.url
}
