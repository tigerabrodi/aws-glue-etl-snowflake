variable "s3_data_lake_name" {
  type = string
}

variable "s3_transformed_data_folder" {
  type = string
}

variable "snowflake_iam_user_key_id" {
  type      = string
  sensitive = true
}

variable "snowflake_iam_user_key_secret" {
  type      = string
  sensitive = true
}
