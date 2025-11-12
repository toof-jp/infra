locals {
  warrior_domain = "warrior.toof.jp"
}

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
  domain           = local.warrior_domain
  type             = "self_hosted"
  session_duration = "24h"

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.warrior_allow_toof.id
      precedence = 1
    }
  ]
}
