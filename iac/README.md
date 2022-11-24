# IaC Organization and structure

## Infrastructure Organization

### Digital Ocean

#### PROJECT: CORE

This project will be for some of the core infrastructure for my DO account. The main resource will be a S3 Compatible object store.

These pieces will be created via the `doctl` CLI tool to bootstrap my DO account

Currently, the `doctl` tool and the Python DO Module don't support building Spaces for ReAsOnS

#### PROJECT: roylarsen.xyz

This project will be the core of my new web presence.

In this we will have the DO App Service, and other support infrastructure for that. These resources will be created via Terraform.

### Namecheap

## Code Organization