# HCP Terraform Bootstrap

HCP Terraform workspace variables were initially configured by running Terraform locally with the required values supplied via `TF_VAR_` environment variables (for example `TF_VAR_google_billing_account`, `TF_VAR_cloudflare_account_id`, etc.). Export the necessary `TF_VAR_` variables in your shell before running any bootstrap commands so Terraform can push those values into HCP Terraform.
