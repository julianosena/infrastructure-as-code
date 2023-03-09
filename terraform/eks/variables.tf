variable "aws" {
    type    = map(string)
    default = {
        region = "eu-west-1"
    }
}

variable "project" {
    type    = map(string)
    default = {
        name        = "ccb-report-online"
    }
}