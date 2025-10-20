resource "cloudflare_zone" "toof_jp" {
  account = {
    id = var.account_id
  }
  name = "toof.jp"
  type = "full"
}

resource "cloudflare_dns_record" "root_a_1" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "toof.jp"
  type    = "A"
  ttl     = 60
  content = "185.199.108.153"
}

resource "cloudflare_dns_record" "root_a_2" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "toof.jp"
  type    = "A"
  ttl     = 60
  content = "185.199.109.153"
}

resource "cloudflare_dns_record" "root_a_3" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "toof.jp"
  type    = "A"
  ttl     = 60
  content = "185.199.110.153"
}

resource "cloudflare_dns_record" "root_a_4" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "toof.jp"
  type    = "A"
  ttl     = 60
  content = "185.199.111.153"
}

resource "cloudflare_dns_record" "root_aaaa_1" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "toof.jp"
  type    = "AAAA"
  ttl     = 60
  content = "2606:50c0:8000::153"
}

resource "cloudflare_dns_record" "root_aaaa_2" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "toof.jp"
  type    = "AAAA"
  ttl     = 60
  content = "2606:50c0:8001::153"
}

resource "cloudflare_dns_record" "root_aaaa_3" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "toof.jp"
  type    = "AAAA"
  ttl     = 60
  content = "2606:50c0:8002::153"
}

resource "cloudflare_dns_record" "root_aaaa_4" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "toof.jp"
  type    = "AAAA"
  ttl     = 60
  content = "2606:50c0:8003::153"
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

resource "cloudflare_dns_record" "blog_cname" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "blog.toof.jp"
  type    = "CNAME"
  ttl     = 60
  content = "blog-hugo-89n.pages.dev"
}

resource "cloudflare_dns_record" "shisha_cname" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "shisha.toof.jp"
  type    = "CNAME"
  ttl     = 60
  content = "ddnkqwv6246p7.cloudfront.net."
}

resource "cloudflare_dns_record" "shisha_a" {
  zone_id = cloudflare_zone.toof_jp.id
  name    = "api.shisha.toof.jp"
  type    = "A"
  ttl     = 60
  content = "18.179.70.217"
}

resource "cloudflare_dns_record" "root_mx_1" {
  zone_id  = cloudflare_zone.toof_jp.id
  name     = "toof.jp"
  type     = "MX"
  ttl      = 86400
  priority = 10
  content  = "mx1.titan.email"
}

resource "cloudflare_dns_record" "root_mx_2" {
  zone_id  = cloudflare_zone.toof_jp.id
  name     = "toof.jp"
  type     = "MX"
  ttl      = 86400
  priority = 20
  content  = "mx2.titan.email"
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
