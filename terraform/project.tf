resource "google_project" "toof_infra" {
  name            = "toof-infra"
  project_id      = "toof-infra"
  billing_account = var.google_billing_account
}
