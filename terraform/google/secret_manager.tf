resource "google_service_account" "external_secrets_operator" {
  account_id   = "external-secrets-operator"
  display_name = "External Secrets Operator"
}

resource "google_project_iam_member" "external_secret_operator_accessor" {
  project = google_project.toof_infra.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.external_secrets_operator.email}"
}
