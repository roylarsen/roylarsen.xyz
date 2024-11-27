terraform {
  backend "s3" {
    bucket = "roylarsen.xyz.tf-backend"
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
  purpose     = "tastefuldinosaurerotica.com"
  environment = "production"
}

resource "digitalocean_domain" "tastefuldinosaurerotica_com" {
  name = "tastefuldinosaurerotica.com"
}

resource "digitalocean_droplet" "tasteful" {
  image     = "ubuntu-20-04-x64"
  name      = "tasteful"
  region    = "nyc3"
  size      = "s-1vcpu-1gb"
  ssh_keys  = ["48:32:db:cc:08:db:35:8a:bf:dd:d8:ed:23:ec:a2:54"]
  user_data = file("blsky.yaml")
}

resource "digitalocean_record" "root" {
  domain = digitalocean_domain.tastefuldinosaurerotica_com.id
  type   = "A"
  name   = "@"
  ttl    = 30
  value  = digitalocean_droplet.tasteful.ipv4_address
}

resource "digitalocean_record" "star" {
  domain = digitalocean_domain.tastefuldinosaurerotica_com.id
  type   = "A"
  name   = "*"
  ttl    = 30
  value  = digitalocean_droplet.tasteful.ipv4_address
}

locals {
  resend_records = {
    "mx": {
      "type": "MX",
      "host": "send.bluesky",
      "value": "feedback-smtp.us-east-1.amazonses.com."
    },
    "txt1": {
      "type": "TXT",
      "host": "send.bluesky",
      "value": "v=spf1 include:amazonses.com ~all"
    },
    "txt2": {
      "type": "TXT",
      "host": "resend_domainkey.bluesky",
      "value":var.resend
    },
    "dmarc": {
      "type": "TXT",
      "host": "_dmarc",
      "value": "v=DMARC1; p=none;"
    }
  }
}

resource "digitalocean_record" "mx_records" {
  for_each = local.resend_records
  domain   = digitalocean_domain.tastefuldinosaurerotica_com.id
  type     = each.value["type"]
  name     = each.value["host"]
  ttl      = 30
  value    = each.value["value"]
  priority = 10
}

resource "digitalocean_project_resources" "tastefuldinosaurerotica_resources" {
  project = digitalocean_project.tastefuldinosaurerotica_com.id
  resources = [
    digitalocean_domain.tastefuldinosaurerotica_com.urn,
    digitalocean_droplet.tasteful.urn
  ]
}

