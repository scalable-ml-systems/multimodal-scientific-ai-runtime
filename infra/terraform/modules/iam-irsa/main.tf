terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

# Example: a generic role you can reuse for apps writing to S3 (least privilege in policy)
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_s3_writer" {
  name               = "${var.cluster_name}-app-s3-writer"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach policies later (or extend with variables for specific bucket ARNs)
resource "aws_iam_policy" "app_s3_writer" {
  name = "${var.cluster_name}-app-s3-writer-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:AbortMultipartUpload", "s3:ListBucket"]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_s3_writer" {
  role       = aws_iam_role.app_s3_writer.name
  policy_arn = aws_iam_policy.app_s3_writer.arn
}
