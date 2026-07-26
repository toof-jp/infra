resource "random_id" "kube_apiserver_tunnel_secret" {
  byte_length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "kube_apiserver" {
  account_id    = var.cloudflare_account_id
  name          = "kube-apiserver"
  config_src    = "cloudflare"
  tunnel_secret = random_id.kube_apiserver_tunnel_secret.b64_std
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "kube_apiserver" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.kube_apiserver.id

  config = {
    ingress = [
      {
        hostname = "k8s.${var.domain}"
        service  = "tcp://kubernetes.default.svc.cluster.local:443"
      },
      {
        service = "http_status:404"
      },
    ]
  }
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "kube_apiserver" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.kube_apiserver.id
}

resource "cloudflare_dns_record" "k8s" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "k8s.${var.domain}"
  type    = "CNAME"
  ttl     = 1
  proxied = true
  content = "${cloudflare_zero_trust_tunnel_cloudflared.kube_apiserver.id}.cfargotunnel.com"
}

resource "cloudflare_zero_trust_access_application" "kube_apiserver" {
  account_id           = var.cloudflare_account_id
  name                 = "kube-apiserver"
  domain               = "k8s.${var.domain}"
  type                 = "self_hosted"
  session_duration     = "24h"
  app_launcher_visible = false

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

resource "google_secret_manager_secret" "cloudflared_kube_apiserver_tunnel_token" {
  secret_id = "cloudflared-kube-apiserver-tunnel-token"
  replication {
    auto {}
  }
  depends_on = [google_project_service.enabled["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "cloudflared_kube_apiserver_tunnel_token" {
  secret      = google_secret_manager_secret.cloudflared_kube_apiserver_tunnel_token.id
  secret_data = data.cloudflare_zero_trust_tunnel_cloudflared_token.kube_apiserver.token
}
