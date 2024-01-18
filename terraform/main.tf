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
  source            = "./modules/aws-s3"
  s3_data_lake_name = var.s3_data_lake_name
}

module "aws_permissions" {
  source = "./modules/aws-permissions"

  data_lake_s3_arn = module.s3.data_lake_s3_arn
}

module "glue-database" {
  source                 = "./modules/aws-glue-database"
  aws_glue_database_name = var.aws_glue_database_name
}

module "glue-crawler" {
  source                           = "./modules/aws-glue-crawler"
  glue_service_role_arn            = module.aws_permissions.glue_service_role_arn
  s3_data_lake_name                = var.s3_data_lake_name
  s3_data_lake_customers_file_name = var.s3_data_lake_customers_file_name
  aws_glue_database_name           = var.aws_glue_database_name
  s3_raw_data_folder               = var.s3_raw_data_folder
}
