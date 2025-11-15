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
  }
}

provider "cloudflare" {
  api_token = var.api_token
}

provider "google" {
  project = "toof-infra"
}
