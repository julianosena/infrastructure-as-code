provider "aws" {
  region = var.cloud.region
}

locals {
  name                  = var.project.name
  region                = var.cloud.region
  namespace             = var.project.namespace

  cluster               = {
    name                  = "cluster_ccb_report_online"
    service_account_name  = "ccb-report-online.com"

    tags                  = {
      Project     = "ccb_report_online"
      Environment = "production"
    }
  }
}