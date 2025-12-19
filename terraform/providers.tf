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

    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }

  backend "s3" {
    bucket  = "toof-infra-terraform-remote-state"
    key     = "terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
    assume_role = {
      role_arn     = "arn:aws:iam::571600847070:role/terraform-management"
      session_name = "terraform"
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
