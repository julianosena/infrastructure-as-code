module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "~> 3.0"

    name    = "vpc-${random_string.default.result}"
    cidr    = var.vpc_cidr

    azs             = var.azs
    private_subnets = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 4, k)]
    public_subnets  = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
    intra_subnets   = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]

    enable_nat_gateway  = var.enable_nat_gateway
    single_nat_gateway  = var.single_nat_gateway
    reuse_nat_ips       = var.reuse_nat_ips
    enable_vpn_gateway  = var.enable_vpn_gateway

    external_nat_ip_ids = "${aws_eip.nat.*.id}"

    enable_flow_log                      = var.enable_flow_log
    create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role
    create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group

    tags = var.tags
}

/*
By default this module will provision new Elastic IPs for the VPC's 
NAT Gateways. This means that when creating a new VPC, new IPs are 
allocated, and when that VPC is destroyed those IPs are released. 
Sometimes it is handy to keep the same IPs even after the VPC is 
destroyed and re-created. To that end, it is possible to assign existing 
IPs to the NAT Gateways. This prevents the destruction of the VPC from 
releasing those IPs, while making it possible that a re-created VPC 
uses the same IPs.
*/

# Elastic IP for public NAT gateway
resource "aws_eip" "nat" {
    count   = 3
    vpc     = true
}

resource "random_string" "default" {
  length = 16
}