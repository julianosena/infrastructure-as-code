provider "aws" {
  region = var.cloud.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

locals {
  name          = var.project.name
  cluster_name  = var.eks.cluster_name
  tags          = var.required_tags
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.14"

  cluster_name                   = local.cluster_name
  cluster_version                = "1.27"
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

module "secrets-store-csi" {
  source  = "SPHTech-Platform/secrets-store-csi/aws"
  version = "1.0.1"

  cluster_name      = var.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
}

resource "aws_iam_role" "ccb_report_service_account_iam_role" {
  name = "ccb-report-service-account-iam-role"

  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Principal: {
          Federated: "${module.eks.oidc_provider_arn}"
        },
        Action: "sts:AssumeRoleWithWebIdentity"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ccb_report_service_account_iam_role_policy" {
  name        = "ccb-report-service-account-iam-policy"
  role        = aws_iam_role.ccb_report_service_account_iam_role.name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "*"
    }]
  })
}

resource "kubernetes_service_account" "ccb_report_service_account" {
  metadata {
    name      = "ccb-report-service-account"
    namespace = "default"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ccb_report_service_account_iam_role.arn
    }
  }
}
