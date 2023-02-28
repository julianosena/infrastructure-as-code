terraform {

  required_version = ">= 1.0"

  cloud {
    organization = "julianossc"
    workspaces {
      name = "platform"
    }
  }

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.56"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
}