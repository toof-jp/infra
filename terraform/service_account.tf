locals {
  otel_sa_roles = [
    "roles/monitoring.metricWriter",
    "roles/cloudtrace.agent",
    "roles/logging.logWriter",
  ]
  terraform_sa_roles = [
    "roles/editor",
    "roles/secretmanager.secretAccessor",
    "roles/resourcemanager.projectIamAdmin",
  ]
}

resource "google_service_account" "otel_sa" {
  account_id   = "otel-collector-sa"
  display_name = "Service account for OTel Collector"
  depends_on   = [google_project_service.enabled["iam.googleapis.com"]]
}

resource "google_service_account" "terraform_sa" {
  account_id   = "terraform"
  display_name = "Terraform service account"
  depends_on   = [google_project_service.enabled["iam.googleapis.com"]]
}

resource "google_project_iam_member" "otel_sa" {
  for_each = toset(local.otel_sa_roles)

  project = google_project.toof_infra.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.otel_sa.email}"
}

resource "google_project_iam_member" "terraform_sa" {
  for_each = toset(local.terraform_sa_roles)

  project = google_project.toof_infra.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

resource "google_service_account_key" "otel_sa_key" {
  service_account_id = google_service_account.otel_sa.name
}

resource "google_service_account_key" "terraform_sa_key" {
  service_account_id = google_service_account.terraform_sa.name
}

resource "google_secret_manager_secret" "otel_sa_secret" {
  secret_id = "otel-collector-sa-key"
  replication {
    auto {}
  }
  depends_on = [google_project_service.enabled["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "otel_sa_secret_ver" {
  secret      = google_secret_manager_secret.otel_sa_secret.id
  secret_data = google_service_account_key.otel_sa_key.private_key
}

resource "google_secret_manager_secret" "terraform_sa_secret" {
  secret_id = "terraform-service-account-key"
  replication {
    auto {}
  }
  depends_on = [google_project_service.enabled["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "terraform_sa_secret_ver" {
  secret      = google_secret_manager_secret.terraform_sa_secret.id
  secret_data = google_service_account_key.terraform_sa_key.private_key
}

moved {
  from = google_project_iam_member.sa_monitoring_writer
  to   = google_project_iam_member.otel_sa["roles/monitoring.metricWriter"]
}

moved {
  from = google_project_iam_member.sa_trace_agent
  to   = google_project_iam_member.otel_sa["roles/cloudtrace.agent"]
}

moved {
  from = google_project_iam_member.sa_logging_writer
  to   = google_project_iam_member.otel_sa["roles/logging.logWriter"]
}

moved {
  from = google_project_iam_member.terraform_sa_editor
  to   = google_project_iam_member.terraform_sa["roles/editor"]
}

moved {
  from = google_project_iam_member.terraform_sa_secret_accessor
  to   = google_project_iam_member.terraform_sa["roles/secretmanager.secretAccessor"]
}

moved {
  from = google_project_iam_member.terraform_sa_project_iam_admin
  to   = google_project_iam_member.terraform_sa["roles/resourcemanager.projectIamAdmin"]
}
