terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.18"
    }
  }

  backend "s3" {
    bucket = "iac-tlf-state"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}