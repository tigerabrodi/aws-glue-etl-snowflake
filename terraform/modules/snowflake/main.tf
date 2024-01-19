terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.83.1"
    }
  }
}

provider "snowflake" {
  role = "ACCOUNTADMIN"
}

# Create a Snowflake warehouse
resource "snowflake_warehouse" "customers_warehouse" {
  name           = "customers_wh"
  warehouse_size = "X-SMALL"
  auto_suspend   = 120
  auto_resume    = true
}

# Create a Snowflake database
resource "snowflake_database" "customers_database" {
  name = "customers_db"
}

# Create a Snowflake schema
resource "snowflake_schema" "customers_schema" {
  name     = "customers_schema"
  database = snowflake_database.customers_database.name
}

# Create a Snowflake table
resource "snowflake_table" "customers_table" {
  database = snowflake_database.customers_database.name
  schema   = snowflake_schema.customers_schema.name
  name     = "customers"

  column {
    name = "CustomerID"
    type = "STRING"
  }
  column {
    name = "Title"
    type = "STRING"
  }
  column {
    name = "FirstName"
    type = "STRING"
  }
  column {
    name = "LastName"
    type = "STRING"
  }
  column {
    name = "EmailAddress"
    type = "STRING"
  }
  column {
    name = "Phone"
    type = "STRING"
  }
}

# Create a Snowflake stage for the S3 bucket
resource "snowflake_stage" "s3_stage" {
  name     = "s3_stage"
  database = snowflake_database.customers_database.name
  schema   = snowflake_schema.customers_schema.name
  url      = "s3://${var.s3_data_lake_name}/${var.s3_transformed_data_folder}/"

  file_format = "TYPE = JSON"

  credentials = "AWS_KEY_ID='${var.snowflake_iam_user_key_id}' AWS_SECRET_KEY='${var.snowflake_iam_user_key_secret}'"

}
