resource "aws_glue_crawler" "customers_db_crawler" {
  name          = "customers_db_crawler"
  role          = var.glue_service_role_arn
  database_name = var.aws_glue_database_name

  s3_target {
    path = "s3://${var.s3_data_lake_name}/${var.s3_raw_data_folder}/${var.s3_data_lake_customers_file_name}"
  }
}
