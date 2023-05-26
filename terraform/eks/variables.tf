variable "cloud" {
  type = map(string)
  default = {
    region = "eu-west-1"
  }
}

variable "project" {
  type = map(string)
  default = {
    name      = "ccb-report"
    namespace = "ccb-report"
  }
}

variable "eks" {
  type = map(string)
  default = {
    cluster_name = "ccb-report"
  }
}

variable "required_tags" {
  type = map(string)
  default = {
    Project     = "ccb-report"
    Environment = "production"
  }
}