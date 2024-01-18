resource "aws_s3_bucket" "data_lake" {
  bucket = var.data_lake_name

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name    = "Data Lake Bucket"
    Project = "Data Lake"
  }
}

resource "aws_s3_bucket_ownership_controls" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "data_lake" {
  depends_on = [aws_s3_bucket_ownership_controls.data_lake]

  bucket = aws_s3_bucket.data_lake.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "lake_versioning" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}
