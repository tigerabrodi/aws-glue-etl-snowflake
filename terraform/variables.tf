variable "s3_data_lake_name" {
  type = string
}

variable "s3_data_lake_customers_file_name" {
  type = string
}

variable "aws_glue_catalog_table" {
  type = string
}

variable "aws_glue_database_name" {
  type = string
}

variable "s3_raw_data_folder" {
  type = string
}

variable "s3_transformed_data_folder" {
  type = string
}
