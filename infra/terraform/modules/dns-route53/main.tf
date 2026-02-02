terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

resource "aws_route53_zone" "this" {
  name = var.hosted_zone_name
}
