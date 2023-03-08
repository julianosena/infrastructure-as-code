data "aws_availability_zones" "available" {}

provider "aws" {
  region  = var.aws.region
}

locals {
  cluster_name = "eks-${random_string.default.result}"
}

module "vpc" {
  source = "./networking/vpc"

  vpc_cidr  = "10.0.0.0/16"
  azs       = slice(data.aws_availability_zones.available.names, 0, 3)
  cluster   = {
    name = local.cluster_name
  }

  tags  = {
    project = var.project.name
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                    = local.cluster_name
  cluster_version                 = "1.24"

  cluster_endpoint_public_access  = true

  cluster_addons = {

    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }

    aws_eks_addon = {
      most_recent = true
    }
  }

  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  control_plane_subnet_ids  = module.vpc.intra_subnets

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}

resource "random_string" "default" {
  length = 16
}