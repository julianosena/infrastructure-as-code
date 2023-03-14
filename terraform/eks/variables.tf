variable "cloud" {
  type = map(string)
  default = {
    region = "eu-west-1"
  }
}

variable "project" {
  type = map(string)
  default = {
    name      = "ccb_report_online"
    namespace = "ccb_report_online"
  }
}