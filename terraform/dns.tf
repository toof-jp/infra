# Some DNS records are managed externally by the cloudflare-tunnel-ingress-controller and Cloudflare Workers.
# For details, refer to the Cloudflare DNS Records dashboard.

locals {
  github_pages_ipv4 = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
  github_pages_ipv6 = [
    "2606:50c0:8000::153",
    "2606:50c0:8001::153",
    "2606:50c0:8002::153",
    "2606:50c0:8003::153",
  ]
  titan_mx = {
    "mx1.titan.email" = 10
    "mx2.titan.email" = 20
  }
}

resource "cloudflare_zone" "toof_jp" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "toof.jp"
  type = "full"
}

resource "cloudflare_dns_record" "root_a" {
  for_each = toset(local.github_pages_ipv4)

  zone_id = cloudflare_zone.toof_jp.id
  name    = "toof.jp"
  type    = "A"
  ttl     = 60
  content = each.key
}

resource "cloudflare_dns_record" "root_aaaa" {
  for_each = toset(local.github_pages_ipv6)

  zone_id = cloudflare_zone.toof_jp.id
  name    = "toof.jp"
  type    = "AAAA"
  ttl     = 60
  content = each.key
}

resource "cloudflare_dns_record" "s_cname" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "s.toof.jp"
  type    = "CNAME"
  ttl     = 60
  content = "s-toof-jp.pages.dev"
}

resource "cloudflare_dns_record" "portfolio_cname" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "portfolio.toof.jp"
  type    = "CNAME"
  ttl     = 60
  content = "portfolio-c1v.pages.dev"
}

resource "cloudflare_dns_record" "root_mx" {
  for_each = local.titan_mx

  zone_id  = cloudflare_zone.toof_jp.id
  name     = "toof.jp"
  type     = "MX"
  ttl      = 86400
  priority = each.value
  content  = each.key
}

resource "cloudflare_dns_record" "root_txt_spf" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "toof.jp"
  type    = "TXT"
  ttl     = 86400
  content = "v=spf1 include:spf.titan.email ~all"
}

resource "cloudflare_dns_record" "root_txt_dkim" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "titan1._domainkey.toof.jp"
  type    = "TXT"
  ttl     = 86400
  content = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCmaAY0hGACDm16ayq8wWpo9jDOwbdieDCQvOW32KWm0/SFeNFKaxosxTn//4ffnPE9/x00Cxun8sBsQj4eXVNRtwm0oykLgMcm38JJ8SggYn/XL5G10J7knGCFwgjlhWGvebSzZQ8gUH2gOPW47BCvoqo5zcQ2X97V8muJFm1YLwIDAQAB"
}

resource "cloudflare_dns_record" "root_txt_dmarc" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "_dmarc.toof.jp"
  type    = "TXT"
  ttl     = 86400
  content = "v=DMARC1; p=reject; rua=mailto:dmarc-reports@toof.jp; aspf=s; adkim=s"
}

resource "cloudflare_dns_record" "root_txt_atproto" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "_atproto.toof.jp"
  type    = "TXT"
  ttl     = 86400
  content = "did=did:plc:fzeed6j234rni24nk2gr6u53"
}

# hana admin panel, behind IAP on a Google Cloud external HTTPS load balancer.
# Must stay DNS-only (not proxied): the LB IP needs a Google-managed SSL cert
# and IAP's own auth, so Cloudflare's proxy would break both.
resource "cloudflare_dns_record" "hana_admin_a" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "hana-admin.toof.jp"
  type    = "A"
  ttl     = 60
  content = "136.68.11.50"
  proxied = false
}

# hana user-facing site, same IAP-on-Google-LB setup as hana-admin above.
resource "cloudflare_dns_record" "hana_user_a" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "hana.toof.jp"
  type    = "A"
  ttl     = 60
  content = "8.233.52.20"
  proxied = false
}

moved {
  from = cloudflare_dns_record.root_a_1
  to   = cloudflare_dns_record.root_a["185.199.108.153"]
}

moved {
  from = cloudflare_dns_record.root_a_2
  to   = cloudflare_dns_record.root_a["185.199.109.153"]
}

moved {
  from = cloudflare_dns_record.root_a_3
  to   = cloudflare_dns_record.root_a["185.199.110.153"]
}

moved {
  from = cloudflare_dns_record.root_a_4
  to   = cloudflare_dns_record.root_a["185.199.111.153"]
}

moved {
  from = cloudflare_dns_record.root_aaaa_1
  to   = cloudflare_dns_record.root_aaaa["2606:50c0:8000::153"]
}

moved {
  from = cloudflare_dns_record.root_aaaa_2
  to   = cloudflare_dns_record.root_aaaa["2606:50c0:8001::153"]
}

moved {
  from = cloudflare_dns_record.root_aaaa_3
  to   = cloudflare_dns_record.root_aaaa["2606:50c0:8002::153"]
}

moved {
  from = cloudflare_dns_record.root_aaaa_4
  to   = cloudflare_dns_record.root_aaaa["2606:50c0:8003::153"]
}

moved {
  from = cloudflare_dns_record.root_mx_1
  to   = cloudflare_dns_record.root_mx["mx1.titan.email"]
}

moved {
  from = cloudflare_dns_record.root_mx_2
  to   = cloudflare_dns_record.root_mx["mx2.titan.email"]
}
