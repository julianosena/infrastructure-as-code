terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.9.0"
    }
  }

  backend "s3" {
    bucket = "iac-tlf-state"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}