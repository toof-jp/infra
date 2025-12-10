resource "google_service_account" "otel_sa" {
  account_id   = "otel-collector-sa"
  display_name = "Service account for OTel Collector"
  depends_on   = [google_project_service.iam]
}

resource "google_project_iam_member" "sa_monitoring_writer" {
  project = google_project.toof_infra.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.otel_sa.email}"
}

resource "google_project_iam_member" "sa_trace_agent" {
  project = google_project.toof_infra.project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.otel_sa.email}"
}

resource "google_project_iam_member" "sa_logging_writer" {
  project = google_project.toof_infra.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.otel_sa.email}"
}

resource "google_service_account_key" "otel_sa_key" {
  service_account_id = google_service_account.otel_sa.name
}

resource "google_secret_manager_secret" "otel_sa_secret" {
  secret_id = "otel-collector-sa-key"
  replication {
    auto {}
  }
  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "otel_sa_secret_ver" {
  secret      = google_secret_manager_secret.otel_sa_secret.id
  secret_data = google_service_account_key.otel_sa_key.private_key
}
