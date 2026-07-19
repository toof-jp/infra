locals {
  zero_trust_apps = [
    "warrior",
    "argocd",
    "headlamp",
    "opentelemetry-demo",
    "longhorn",
    "grafana",
    "obsidian-gui",
    "beancount",
  ]
}

resource "cloudflare_zero_trust_access_identity_provider" "github" {
  account_id = var.cloudflare_account_id
  name       = "GitHub only for toof-jp"
  type       = "github"

  config = {
    client_id     = var.github_client_id
    client_secret = var.github_client_secret
  }
}

resource "cloudflare_zero_trust_access_policy" "allow_github_toof" {
  account_id       = var.cloudflare_account_id
  name             = "allow-github-toof"
  decision         = "allow"
  session_duration = "12h"

  include = [
    {
      email = {
        email = "toof@toof.jp"
      }
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "app" {
  for_each = toset(local.zero_trust_apps)

  account_id       = var.cloudflare_account_id
  name             = each.key
  domain           = "${each.key}.${var.domain}"
  type             = "self_hosted"
  session_duration = "24h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.github.id
  ]

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.allow_github_toof.id
      precedence = 1
    }
  ]
}
