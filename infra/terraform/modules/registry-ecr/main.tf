terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

resource "aws_ecr_repository" "this" {
  for_each = toset(var.repos)
  name     = each.value

  image_scanning_configuration { scan_on_push = true }
}
