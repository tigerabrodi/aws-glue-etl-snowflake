

output "snowflake_iam_access_key_id" {
  value     = aws_iam_access_key.snowflake_user_key.id
  sensitive = true
}

output "snowflake_iam_access_key_secret" {
  value     = aws_iam_access_key.snowflake_user_key.secret
  sensitive = true
}
