resource "aws_glue_catalog_database" "customers_database" {
  name = "customers_database"
}

resource "aws_glue_catalog_table" "customers_table" {
  name          = var.aws_glue_catalog_table
  database_name = aws_glue_catalog_database.customers_database.name

  table_type = "EXTERNAL_TABLE" # indicates that data is stored outside of AWS Glue

  storage_descriptor {
    location = "s3://${var.data_lake_name}/${var.data_lake_folder}"

    # Hadoops classes, standard for processing text files like CSV in big data environments
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    # Defines how Glue should read and write data
    ser_de_info {
      name                  = var.aws_glue_catalog_table
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        # Fields are separated by comments
        "field.delim" = ","
      }
    }
  }
}
