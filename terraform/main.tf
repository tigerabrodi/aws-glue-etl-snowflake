terraform {

  cloud {
    organization = "{your-organization}"
    workspaces {
      name = "{your-workspace}"
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

module "glue-database" {
  source                 = "./modules/aws-glue-database"
  aws_glue_database_name = var.aws_glue_database_name
}

module "glue-crawler" {
  source                           = "./modules/aws-glue-crawler"
  s3_data_lake_name                = var.s3_data_lake_name
  s3_data_lake_customers_file_name = var.s3_data_lake_customers_file_name
  aws_glue_database_name           = var.aws_glue_database_name
  s3_raw_data_folder               = var.s3_raw_data_folder
  data_lake_s3_arn                 = module.s3.data_lake_s3_arn

  depends_on = [module.s3]
}

module "snowflake-iam-user" {
  source                     = "./modules/aws-snowflake-iam-user"
  s3_transformed_data_folder = var.s3_transformed_data_folder
  s3_data_lake_arn           = module.s3.data_lake_s3_arn
}

module "snowflake" {
  source = "./modules/snowflake"

  s3_data_lake_name             = var.s3_data_lake_name
  s3_transformed_data_folder    = var.s3_transformed_data_folder
  snowflake_iam_user_key_id     = module.snowflake-iam-user.snowflake_iam_access_key_id
  snowflake_iam_user_key_secret = module.snowflake-iam-user.snowflake_iam_access_key_secret
}
