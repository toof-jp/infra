locals {
  otel_sa_roles = [
    "roles/monitoring.metricWriter",
    "roles/cloudtrace.agent",
    "roles/logging.logWriter",
  ]
  terraform_sa_roles = [
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/monitoring.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/secretmanager.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin",
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

resource "google_service_account" "openclaw_vertex_sa" {
  account_id   = "openclaw-vertex-sa"
  display_name = "Service account for OpenClaw Vertex AI"
  depends_on   = [google_project_service.enabled["iam.googleapis.com"]]
}

resource "google_project_iam_member" "openclaw_vertex_sa" {
  project = google_project.toof_infra.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.openclaw_vertex_sa.email}"
}

resource "google_service_account_key" "openclaw_vertex_sa_key" {
  service_account_id = google_service_account.openclaw_vertex_sa.name
}

resource "google_secret_manager_secret" "openclaw_vertex_sa_secret" {
  secret_id = "openclaw-vertex-sa-key"
  replication {
    auto {}
  }
  depends_on = [google_project_service.enabled["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "openclaw_vertex_sa_secret_ver" {
  secret      = google_secret_manager_secret.openclaw_vertex_sa_secret.id
  secret_data = google_service_account_key.openclaw_vertex_sa_key.private_key
}
