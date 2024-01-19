

output "snowflake_iam_access_key_id" {
  value     = module.snowflake-iam-user.snowflake_iam_access_key_id
  sensitive = true
}

output "snowflake_iam_access_key_secret" {
  value     = module.snowflake-iam-user.snowflake_iam_access_key_secret
  sensitive = true
}
