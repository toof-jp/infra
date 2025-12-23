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

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "discord_webhook_url" {
  secret      = google_secret_manager_secret.discord_webhook_url.id
  secret_data = discord_webhook.webhook.url
}

resource "google_service_account" "monitoring_function_runtime" {
  account_id   = "monitoring-function-runtime"
  display_name = "Runtime for monitoring notification function"
  depends_on   = [google_project_service.iam]
}

resource "google_project_iam_member" "monitoring_function_runtime_secret_accessor" {
  project = google_project.toof_infra.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.monitoring_function_runtime.email}"
}
