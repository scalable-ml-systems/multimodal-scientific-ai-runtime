terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # /16 -> split into public/private per AZ
  public_subnets  = [for i, az in local.azs : cidrsubnet(var.cidr, 8, i)]
  private_subnets = [for i, az in local.azs : cidrsubnet(var.cidr, 8, i + 10)]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.5.0"

  name = var.name
  cidr = var.cidr

  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = var.one_nat_gateway
  one_nat_gateway_per_az = !var.one_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true
}
