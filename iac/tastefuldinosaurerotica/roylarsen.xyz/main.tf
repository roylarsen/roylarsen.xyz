terraform {
  backend "s3" {
    bucket = "tastefuldinosaurerotica.com.tf-backend"
    key    = "states/tastefuldinosaurerotica.com.tfstate"
    region = "us-east-1"
    endpoint = "nyc3.digitaloceanspaces.com"
    skip_credentials_validation = true
  }
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.42"
    }
  }
}

resource "digitalocean_project" "tastefuldinosaurerotica_com" {
  name        = "tasteful"
  description = "Project for Holding *.roylarsen.xyz resources"
  purpose     = "roylarsen.xyz"
  environment = "Development"
}

data "digitalocean_domain" "tastefuldinosaurerotica_com" {
  name = "tastefuldinosaurerotica.com"
}

resource "digitalocean_droplet" "tasteful" {
  image    = "ubuntu-20-04-x64"
  name     = "tasteful"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  ssh_keys = ["48:32:db:cc:08:db:35:8a:bf:dd:d8:ed:23:ec:a2:54"]
}

resource "digitalocean_record" "root" {
  domain = data.digitalocean_domain.tastefuldinosaurerotica_com.id
  type   = "A"
  name   = "@"
  ttl    = 30
  value  = resource.digitalocean_droplet.tasteful.ipv4_address
}

resource "digitalocean_record" "star" {
  domain = data.digitalocean_domain.tastefuldinosaurerotica_com.id
  type   = "A"
  name   = "*"
  ttl    = 30
  value  = resource.digitalocean_droplet.tasteful.ipv4_address
}
