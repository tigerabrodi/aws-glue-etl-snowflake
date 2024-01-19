# A full data pipeline: S3, AWS Glue and Snowflake

# Debugging stories I still remember lmfao

- AWS Glue Studio putting script in s3 bucket different from the role i gave it to have permission

- Terraform account wtf, ah, snowcomputing link, the part before, not account identifier, so confusing lol

- snowflake stage not properly configured, tried snowflake storage integration: https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/storage_integration, didn't work out, looking at snowflake stage docs, seems like we don't need integration, got confused lol https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/stage, still getting the error, let's examine what is happening, where we are, and what is going wrong, LOL github issue suggested different syntax for file format, workaround
