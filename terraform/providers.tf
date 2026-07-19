terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 7"
    }

    discord = {
      source  = "Lucky3028/discord"
      version = "~> 2"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = "0.79.0"
    }

    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1"
    }

    vultr = {
      source  = "vultr/vultr"
      version = "~> 2"
    }

    oci = {
      source  = "oracle/oci"
      version = "~> 8"
    }

    terraform = {
      source = "terraform.io/builtin/terraform"
    }
  }

  cloud {
    organization = "toof-infra"
    workspaces {
      name = "toof-infra"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "aws" {
  region = "ap-northeast-1"

  assume_role {
    role_arn     = "arn:aws:iam::571600847070:role/terraform-management"
    session_name = "terraform"
  }
}

provider "google" {
  project = "toof-infra"
}

provider "discord" {
  token = var.discord_token
}

provider "tfe" {
  token = var.tfe_token
}

provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}
provider "vultr" {
  api_key = var.vultr_api_key
}

provider "oci" {
  tenancy_ocid = var.oci_tenancy_ocid
  user_ocid    = var.oci_user_ocid
  fingerprint  = var.oci_fingerprint
  private_key  = var.oci_private_key
  region       = "ap-osaka-1"
}
