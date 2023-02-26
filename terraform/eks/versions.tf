terraform {

  cloud {
    organization = "julianossc"
    workspaces {
      name = "infrastructure"
    }
  }

  required_version = ">= 1.0"

  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
}