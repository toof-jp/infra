resource "cloudflare_r2_bucket" "remote_state" {
  account_id = var.cloudflare_account_id
  name       = "terraform-remote-state"
}
