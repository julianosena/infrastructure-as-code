provider "aws" {
  region = var.cloud.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

locals {
  name      = var.project.name
  region    = var.cloud.region
  namespace = var.project.namespace

  tags = var.required_tags
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.9"

  cluster_name                   = var.project.name
  cluster_version                = "1.25"
  cluster_endpoint_public_access = true

  # EKS Addons
  cluster_addons = {
    coredns             = {
      most_recent = true
    }

    kube-proxy          = {
      most_recent = true
    }

    vpc-cni             = {
      most_recent = true
    }

    aws-ebs-csi-driver  = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 5
      desired_size = 2
    }
  }

  tags = local.tags
}