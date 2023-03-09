provider "aws" {
  region  = var.aws.region
}

locals {
    # Cluster
    cluster_name  = "eks-${var.project.name}"

    tags = {
      environment   = "production"
    }
}


## EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name      = local.cluster_name
  role_arn  = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids          = aws_subnet.private.*.id
    security_group_ids  = [aws_security_group.eks_cluster.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster]

  tags = local.tags
}

# Define the IAM role for the EKS cluster
resource "aws_iam_role" "eks_cluster" {
  name = "iam-role-${local.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks_cluster.name
}

# Define the VPC and subnets
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = local.tags
}

resource "aws_subnet" "private" {
  count = 2
  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id = aws_vpc.vpc.id

  tags = local.tags
}

# Define the security group for the EKS cluster
resource "aws_security_group" "eks_cluster" {
  name_prefix = "eks-cluster-"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}