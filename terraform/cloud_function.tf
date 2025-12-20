resource "google_storage_bucket" "bucket" {
  name                        = "${google_project.toof_infra.name}-monitoring-notification-channel-discord-functions"
  location                    = "US"
  uniform_bucket_level_access = true
}
