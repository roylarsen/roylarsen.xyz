terraform {
  backend "s3" {
    bucket = "roylarsen.xyz.tf-backend"
    key    = "states/core.tfstate"
    region = "us-east-1"
    endpoint = "nyc3.digitaloceanspaces.com"
    skip_credentials_validation = true
  }
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_project" "core" {
  name        = "core"
  description = "core project"
  purpose     = "core"
  environment = "Development"
}