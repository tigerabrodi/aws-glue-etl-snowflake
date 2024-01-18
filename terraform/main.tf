terraform {

  cloud {
    organization = "tiger_projects"
    workspaces {
      name = "aws-etl-snowflake"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

module "s3" {
  source         = "./modules/s3"
  data_lake_name = var.data_lake_name
}
