resource "aws_glue_crawler" "customers_db_crawler" {
  name          = "customers_db_crawler"
  role          = aws_iam_role.glue_role.arn
  database_name = var.aws_glue_database_name

  s3_target {
    path = "s3://${var.s3_data_lake_name}/${var.s3_raw_data_folder}/${var.s3_data_lake_customers_file_name}"
  }
}

resource "aws_iam_policy" "glue_policy" {
  name        = "NewGluePolicy"
  description = "A policy for AWS Glue to access S3 data"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${var.data_lake_s3_arn}",
          "${var.data_lake_s3_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "glue:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "glue_role" {
  name = "NewAWSGlueServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}
