resource "aws_iam_user" "snowflake_user" {
  name = "snowflake_user"
}

resource "aws_iam_policy" "s3_policy" {
  name        = "s3_policy"
  description = "Policy for accessing S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ],
        Resource = [
          "${var.s3_data_lake_arn}/${var.s3_transformed_data_folder}/*",
          "${var.s3_data_lake_arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.snowflake_user.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_access_key" "snowflake_user_key" {
  user = aws_iam_user.snowflake_user.name
}
