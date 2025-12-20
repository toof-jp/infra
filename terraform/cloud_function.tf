resource "google_storage_bucket" "bucket" {
  project  = var.project
  name     = "${var.project}-google-monitoring-notification-channel-discord-functions"
  location = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "object" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "function-source.zip"
}
