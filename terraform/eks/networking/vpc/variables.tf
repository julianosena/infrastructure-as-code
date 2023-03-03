variable "azs" {
    type = list(string)
}

variable "vpc_cidr" {
    description = "CIDR notation for vpc."
    type        = string
}

variable "enable_nat_gateway" {
    type    = bool
    default = true
}

variable "single_nat_gateway" {
    type    = bool
    default = false
}

variable "reuse_nat_ips" {
    type    = bool
    default = true
}

variable "enable_vpn_gateway" {
    type    = bool
    default = true
}

variable "enable_flow_log" {
    type    = bool
    default = true
}

variable "create_flow_log_cloudwatch_iam_role" {
    type    = bool
    default = true
}

variable "create_flow_log_cloudwatch_log_group" {
    type    = bool
    default = true
}

variable "tags" {
    type = map(string)
}