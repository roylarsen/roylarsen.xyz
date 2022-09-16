# Web Presence on *.roylarsen.xyz

The goal of this is to eventually have this be automated and deployed to DigitalOcean via Github Actions

## Roadmap

* Setup Digital Ocean infrastructure for static site
  * Setup Access Key(s) for IaC
    * ~~Digital Ocean Key~~
    * Namecheap Key
  * Migrate from Namecheap to DigitalOcean?
* IaC for roylarsen.xyz and tastefuldinosaurerotica.com
  * Terraform is the obvious answer, maybe eval Pulumi eventually?
  * Testing in PRs for Terraform
* Github Actions to Build and deploy blag to roylarsen.xyz
* Staging/Prod for blag?
* Gitea to replace Github?
* Drone to replace Github Actions?

## Organization of Repo and Technologies in use

* .github/workflows
  * Github Actions for various tasks
* blag
  * Content for [www.roylarsen.xyz](www.roylarsen.xyz)
  * Uses Python and [Pelican](https://getpelican.com/) for site generation
* iac
  * Code for deploying Infrastructure
  * [Docs Here](iac/README.md)
