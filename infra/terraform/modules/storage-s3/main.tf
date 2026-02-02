terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

resource "aws_s3_bucket" "b" {
  for_each = var.buckets
  bucket   = "${var.name}-${each.key}"
}

resource "aws_s3_bucket_public_access_block" "b" {
  for_each                = var.buckets
  bucket                  = aws_s3_bucket.b[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "b" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.b[each.key].id
  versioning_configuration {
    status = each.value.versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "b" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.b[each.key].id

  rule {
    id     = "expire-objects"
    status = "Enabled"
    expiration { days = each.value.lifecycle_days }
  }
}
