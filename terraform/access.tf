resource "cloudflare_zero_trust_access_identity_provider" "github" {
  account_id = var.cloudflare_account_id
  name       = "GitHub"
  type       = "github"

  config = {
    client_id     = var.github_client_id client_secret = var.github_client_secret } }
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

resource "cloudflare_zero_trust_access_application" "warrior" {
  account_id       = var.cloudflare_account_id
  name             = "warrior"
  domain           = "warrior.toof.jp"
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

resource "cloudflare_zero_trust_access_application" "argocd" {
  account_id       = var.cloudflare_account_id
  name             = "argocd"
  domain           = "argocd.toof.jp"
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

resource "cloudflare_zero_trust_access_application" "kubernetes_dashboard" {
  account_id       = var.cloudflare_account_id
  name             = "kubernetes-dashboard"
  domain           = "kubernetes-dashboard.toof.jp"
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

resource "cloudflare_zero_trust_access_application" "opentelemetry_demo" {
  account_id       = var.cloudflare_account_id
  name             = "opentelemetry-demo"
  domain           = "opentelemetry-demo.toof.jp"
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

resource "cloudflare_zero_trust_access_application" "burrito" {
  account_id       = var.cloudflare_account_id
  name             = "burrito"
  domain           = "burrito.toof.jp"
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

resource "cloudflare_zero_trust_access_application" "hoge" {
  account_id       = var.cloudflare_account_id
  name             = "hoge"
  domain           = "hoge.toof.jp"
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
