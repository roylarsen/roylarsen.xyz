# IaC Organization and structure

## Infrastructure Organization

### Digital Ocean

Each Project/Site will be hosted within it's own DO Project. Biggest issue currently is creating DO Space.

#### PROJECT: CORE

This project will be for some of the core infrastructure for my DO account. The main resource will be a S3 Compatible object store.

These pieces will be created via the `doctl` CLI tool to bootstrap my DO account

Currently, the `doctl` tool and the Python DO Module don't support building Spaces for ReAsOnS

##### Notes

* I think DO might have completely implemented the S3 API
  * I might be able to use BOTO3 to create the Bucket/Space
* Create a quick Python tool to create the Central Project and Space for TF State Storage
  * PYDO to check for the existence of the Central/MGMT Project - Create if it doesn't exist
  * BOTO3 to check if the bucket exists and create it if it doesn't

#### PROJECT: roylarsen.xyz

This project will be the core of my new web presence.

In this we will have the DO App Service, and other support infrastructure for that. These resources will be created via Terraform.

### Namecheap

## Code Organization
