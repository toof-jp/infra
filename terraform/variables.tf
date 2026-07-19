variable "google_billing_account" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "discord_token" {
  type      = string
  sensitive = true
}

variable "github_client_id" {
  type = string
}

variable "github_client_secret" {
  type      = string
  sensitive = true
}

variable "tfe_token" {
  type      = string
  sensitive = true
}

variable "tfe_email" {
  type = string
}

variable "tfe_oauth_token_id" {
  type      = string
  sensitive = true
}

variable "auth0_domain" {
  type        = string
  description = "Auth0 tenant domain, e.g. xxx.auth0.com."
}

variable "auth0_client_id" {
  type        = string
  description = "Auth0 Management API client ID for Terraform."
}

variable "auth0_client_secret" {
  type        = string
  sensitive   = true
  description = "Auth0 Management API client secret for Terraform."
}
variable "domain" {
  type        = string
  description = "Base public domain."
  default     = "toof.jp"
}

variable "vultr_api_key" {
  type      = string
  sensitive = true
}

variable "vultr_region" {
  type        = string
  description = "Vultr region for the k8s node (nrt = Tokyo, itm = Osaka)."
  default     = "nrt"
}

variable "vultr_plan" {
  type        = string
  description = "Vultr plan ID. vhp-2c-4gb-amd = High Performance AMD 2vCPU/4GB."
  default     = "vhp-2c-4gb-amd"
}

variable "vultr_iso_url" {
  type        = string
  description = "Public URL of the NixOS installer ISO (built with `make vultr-iso` in toof-jp/nix-sandbox). Vultr downloads it into My ISOs."
  default     = ""
}

variable "vultr_attach_iso" {
  type        = bool
  description = "Boot the instance from the installer ISO. Set to false after `vultr-install` so the node boots NixOS from disk."
  default     = false
}

variable "oci_tenancy_ocid" {
  type = string
}

variable "oci_user_ocid" {
  type = string
}

variable "oci_fingerprint" {
  type        = string
  description = "Fingerprint of the OCI API signing key."
}

variable "oci_private_key" {
  type        = string
  sensitive   = true
  description = "PEM private key for OCI API signing."
}
