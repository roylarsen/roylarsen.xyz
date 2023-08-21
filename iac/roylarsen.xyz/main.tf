terraform {
  backend "s3" {
    bucket = "roylarsen.xyz.tf-backend"
    key    = "states/roylarsen.xyz.tfstate"
    region = "us-east-1"
    endpoint = "nyc3.digitaloceanspaces.com"
    skip_credentials_validation = true
  }
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.25"
    }
  }
}

resource "digitalocean_project" "roylarsen_xyz" {
  name        = "roylarsen.xyz"
  description = "Project for Holding *.roylarsen.xyz resources"
  purpose     = "roylarsen.xyz"
  environment = "Development"
}

data "digitalocean_domain" "roylarsen_xyz" {
  name = "roylarsen.xyz"
}

resource "digitalocean_app" "blag" {
    spec {
      name   = "blag"
      region = "nyc3"
      domain = {
        name = data.digitalocean_domain.roylarsen_xyz.id
      }

      static_site {
        name          = "blog-content"
        source_dir    = "/blag/output"

        github {
          repo           = "roylarsen/roylarsen.xyz"
          branch         = "main"
          deploy_on_push = false
        }

        routes {
          path = "/"
        }
      }
    }
}
