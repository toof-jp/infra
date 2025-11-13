resource "cloudflare_zero_trust_access_policy" "warrior_allow_toof" {
  account_id = var.account_id
  name       = "allow-toof"
  decision   = "allow"

  include = [
    {
      email = {
        email = "toof@toof.jp"
      }
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "warrior" {
  account_id       = var.account_id
  name             = "warrior"
  domain           = "warrior.toof.jp"
  type             = "self_hosted"
  session_duration = "24h"

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.warrior_allow_toof.id
      precedence = 1
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "argocd" {
  account_id       = var.account_id
  name             = "argocd"
  domain           = "argocd.toof.jp"
  type             = "self_hosted"
  session_duration = "24h"

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.warrior_allow_toof.id
      precedence = 1
    }
  ]
}
