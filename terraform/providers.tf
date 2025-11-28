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
