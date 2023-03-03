data "aws_availability_zones" "available" {}

provider "aws" {
  region  = var.aws.region
}

module "vpc" {
  source = "./networking/vpc"

  vpc_cidr  = "10.0.0.0/16"
  azs       = slice(data.aws_availability_zones.available.names, 0, 3)

  tags  = {
    project = var.project.name
  }
}