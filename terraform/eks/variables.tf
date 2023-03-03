variable "project" {
    type    = map(string)
    default = {
        name = "name-project"
    }
}

variable "aws" {
    type    = map(string)
    default = {
        region = "eu-west-1"
    }
}