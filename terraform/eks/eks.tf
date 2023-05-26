provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.9"

  cluster_name                    = local.cluster.name
  cluster_version                 = "1.25"
  cluster_endpoint_public_access  = true

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
      enable_amazon_eks_aws_ebs_csi_driver = true
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

  tags = local.cluster.tags
}

# Create AWS Secrets Manager secret
resource "aws_secretsmanager_secret" "aws_secret_manager" {
  name = "aws_secret_manager_${local.project_name}"
}

resource "kubernetes_secret" "secrets" {
  metadata {
    name = local.cluster.service_account_name
  }
}

resource "kubernetes_service_account" "service_account" {
  metadata {
    name = local.cluster.service_account_name
  }

  secret {
    name = "${kubernetes_secret.secrets.metadata.0.name}"
  }
}

resource "aws_iam_role" "role_services" {
  name = "RoleServices"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "policy_services_reading_secrets" {
  name        = "ServicesReadingSecrets"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment_services_reading_secrets" {
  policy_arn  = aws_iam_policy.policy_services_reading_secrets.arn
  role        = aws_iam_role.role_services.name
}