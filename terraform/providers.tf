terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
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
  }

  backend "s3" {
    bucket = "terraform-remote-state"
    key    = "terraform.tfstate"
    region = "auto"

    # R2 endpoint is supplied via -backend-config (endpoints.s3) at init time; see Makefile.
    use_path_style              = false
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "google" {
  project = "toof-infra"
}

provider "discord" {
  token = var.discord_token
}
