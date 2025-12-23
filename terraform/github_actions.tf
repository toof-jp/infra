locals {
  monitoring_function_repo = "toof-jp/google-monitoring-notification-channel-discord-functions"
}

resource "google_service_account" "monitoring_function_deployer" {
  account_id   = "monitoring-function-deployer"
  display_name = "Uploads monitoring notification function artifacts"
  depends_on   = [google_project_service.iam]
}

resource "google_iam_workload_identity_pool" "github_actions" {
  project                   = google_project.toof_infra.project_id
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"
  description               = "OIDC pool for GitHub Actions workflows"
  depends_on                = [google_project_service.iam]
}

resource "google_iam_workload_identity_pool_provider" "monitoring_function_repo" {
  project                            = google_project.toof_infra.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "monitoring-function-repo"
  display_name                       = "Workflow identity for Cloud Run functions Repo"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository == \"${local.monitoring_function_repo}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "monitoring_function_wiuser" {
  service_account_id = google_service_account.monitoring_function_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.repository/${local.monitoring_function_repo}"
}

resource "google_storage_bucket_iam_member" "monitoring_function_deployer_object_admin" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.monitoring_function_deployer.email}"
}

resource "google_project_iam_member" "monitoring_function_deployer_cf_developer" {
  project = google_project.toof_infra.project_id
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${google_service_account.monitoring_function_deployer.email}"
}

resource "google_project_iam_member" "monitoring_function_deployer_run_developer" {
  project = google_project.toof_infra.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.monitoring_function_deployer.email}"
}
