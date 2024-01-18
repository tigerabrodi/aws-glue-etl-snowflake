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
  source         = "./modules/aws-s3"
  data_lake_name = var.data_lake_name
}

module "aws_permissions" {
  source = "./modules/aws-permissions"

  data_lake_s3_arn = module.s3.data_lake_s3_arn
}

module "glue-database" {
  source                 = "./modules/aws-glue-database"
  data_lake_name         = var.data_lake_name
  data_lake_folder       = var.data_lake_folder
  aws_glue_catalog_table = var.aws_glue_catalog_table
}
