variable "cloud" {
  type = map(string)
  default = {
    region = "eu-west-1"
  }
}

variable "project" {
  type = map(string)
  default = {
    name      = "ccb-report-online"
    namespace = "ccb-report-online"
  }
}

variable "required_tags" {
  type = map(string)
  default = {
    Project     = "ccb-report-online"
    Environment = "production"
  }
}