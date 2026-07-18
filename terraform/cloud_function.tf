resource "google_storage_bucket" "bucket" {
  name                        = "${google_project.toof_infra.name}-monitoring-notification-channel-discord-functions"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_secret_manager_secret" "discord_webhook_url" {
  secret_id = "discord-webhook-url"

  replication {
    auto {}
  }

  depends_on = [google_project_service.enabled["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "discord_webhook_url" {
  secret      = google_secret_manager_secret.discord_webhook_url.id
  secret_data = discord_webhook.webhook.url
}

resource "google_service_account" "monitoring_function_runtime" {
  account_id   = "monitoring-function-runtime"
  display_name = "Runtime for monitoring notification function"
  depends_on   = [google_project_service.enabled["iam.googleapis.com"]]
}

resource "google_secret_manager_secret_iam_member" "monitoring_function_runtime_secret_accessor" {
  secret_id = google_secret_manager_secret.discord_webhook_url.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.monitoring_function_runtime.email}"
}
