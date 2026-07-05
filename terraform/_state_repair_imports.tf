# Temporary: re-import Cloudflare resources whose state got stuck at
# schema_version 0 (pre-dating a provider schema change) and stopped
# reading/saving correctly. Safe to remove once these have landed in state.

import {
  to = cloudflare_zone.toof_jp
  id = "620d8481087eb35d9bf0619b337e26ed"
}

import {
  to = cloudflare_dns_record.portfolio_cname
  id = "620d8481087eb35d9bf0619b337e26ed/5bd1165162b388afc9c39ef1a6680821"
}

import {
  to = cloudflare_dns_record.root_a_1
  id = "620d8481087eb35d9bf0619b337e26ed/ec7c1a2da1def3887056a4f846529168"
}

import {
  to = cloudflare_dns_record.root_a_2
  id = "620d8481087eb35d9bf0619b337e26ed/e880d9f23fd8720a14ffd931fccc16b6"
}

import {
  to = cloudflare_dns_record.root_a_3
  id = "620d8481087eb35d9bf0619b337e26ed/eb23cb7f8f2b66c1d0cc7cc7f16ce021"
}

import {
  to = cloudflare_dns_record.root_a_4
  id = "620d8481087eb35d9bf0619b337e26ed/2950ab1bfcd1bb2940202d32c405dde9"
}

import {
  to = cloudflare_dns_record.root_aaaa_1
  id = "620d8481087eb35d9bf0619b337e26ed/6cbf62e78c994e9f648269d9a671aa00"
}

import {
  to = cloudflare_dns_record.root_aaaa_2
  id = "620d8481087eb35d9bf0619b337e26ed/f207fd9b2377d783bb6c1d42a919be40"
}

import {
  to = cloudflare_dns_record.root_aaaa_3
  id = "620d8481087eb35d9bf0619b337e26ed/1a09dbe02b96782f6f7edca4161c0140"
}

import {
  to = cloudflare_dns_record.root_aaaa_4
  id = "620d8481087eb35d9bf0619b337e26ed/0d50cafa1bfca58aba65600d9fbcb816"
}

import {
  to = cloudflare_dns_record.root_mx_1
  id = "620d8481087eb35d9bf0619b337e26ed/5dcff4b4094f41dee320db4ce49c59a4"
}

import {
  to = cloudflare_dns_record.root_mx_2
  id = "620d8481087eb35d9bf0619b337e26ed/cf3c720df0de67f33e03b72ac4186b87"
}

import {
  to = cloudflare_dns_record.root_txt_atproto
  id = "620d8481087eb35d9bf0619b337e26ed/c32f21e50108dbc39736bf177e5d9afe"
}

import {
  to = cloudflare_dns_record.root_txt_dkim
  id = "620d8481087eb35d9bf0619b337e26ed/b5a1a3c3e7b811d5250cfa1315e72211"
}

import {
  to = cloudflare_dns_record.root_txt_dmarc
  id = "620d8481087eb35d9bf0619b337e26ed/d2212e018c288ee28252c107f6dd8e2e"
}

import {
  to = cloudflare_dns_record.root_txt_spf
  id = "620d8481087eb35d9bf0619b337e26ed/198b44cdd13441bed9c1acab233d3380"
}

import {
  to = cloudflare_dns_record.s_cname
  id = "620d8481087eb35d9bf0619b337e26ed/cafb1f61fcb246aa769d615e249e49fb"
}

import {
  to = cloudflare_zero_trust_access_application.argocd
  id = "8c528be8bf366ff2bd6c9bde11077120/c892de1f-1539-4075-b31d-514f73fa9860"
}

import {
  to = cloudflare_zero_trust_access_application.kubernetes_dashboard
  id = "8c528be8bf366ff2bd6c9bde11077120/a6db300c-2004-4c0e-ba59-7157e25beadc"
}

import {
  to = cloudflare_zero_trust_access_application.longhorn
  id = "8c528be8bf366ff2bd6c9bde11077120/9aa64c21-0fa7-45af-98ee-e8e50f1d1938"
}

import {
  to = cloudflare_zero_trust_access_application.opentelemetry_demo
  id = "8c528be8bf366ff2bd6c9bde11077120/46378c16-02a3-4844-823c-151f6a5fb7ea"
}

import {
  to = cloudflare_zero_trust_access_application.warrior
  id = "8c528be8bf366ff2bd6c9bde11077120/db2bb569-bbdc-4427-82cf-7fe5d5350662"
}

import {
  to = cloudflare_zero_trust_access_identity_provider.github
  id = "8c528be8bf366ff2bd6c9bde11077120/af84c7bc-781d-4ed8-85ae-16a9fe711a03"
}

import {
  to = cloudflare_zero_trust_access_policy.allow_github_toof
  id = "8c528be8bf366ff2bd6c9bde11077120/ee122c8f-fea0-40fb-8201-830ba24bae0f"
}
