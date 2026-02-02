locals {
  name = "${var.project_name}-${var.env}"
}

# 1) VPC + NAT
module "network_vpc" {
  source          = "../../modules/network-vpc"
  name            = local.name
  cidr            = var.vpc_cidr
  az_count        = var.az_count
  one_nat_gateway = var.one_nat_gateway
}

# 2) EKS + nodegroups
module "cluster_eks" {
  source             = "../../modules/cluster-eks"
  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id          = module.network_vpc.vpc_id
  private_subnets = module.network_vpc.private_subnet_ids

  system_instance_type = var.system_instance_type
  system_min           = var.system_min
  system_max           = var.system_max
  system_desired       = var.system_desired

  enable_gpu_nodegroup = var.enable_gpu_nodegroup

  gpu_instance_type = var.gpu_instance_type
  gpu_min           = var.gpu_min
  gpu_max           = var.gpu_max
  gpu_desired       = var.gpu_desired
}

# 3) IRSA roles (create the OIDC provider + IRSA roles for future controllers/apps)
module "iam_irsa" {
  source            = "../../modules/iam-irsa"
  cluster_name      = module.cluster_eks.cluster_name
  oidc_provider_arn = module.cluster_eks.oidc_provider_arn
  oidc_provider_url = module.cluster_eks.oidc_provider_url
}

# 4) RDS Postgres
module "rds_postgres" {
  source                = "../../modules/data-rds-postgres"
  name                  = local.name
  vpc_id                = module.network_vpc.vpc_id
  private_subnet_ids    = module.network_vpc.private_subnet_ids
  eks_security_group_id = module.cluster_eks.node_security_group_id

  instance_class    = var.postgres_instance_class
  allocated_storage = var.postgres_allocated_storage
  multi_az          = var.postgres_multi_az
}

# 5) S3 buckets
module "s3" {
  source  = "../../modules/storage-s3"
  name    = local.name
  buckets = var.s3_buckets
}

# 6) ECR repositories
module "ecr" {
  source = "../../modules/registry-ecr"
  repos  = var.ecr_repos
}

# 7) Route53 + ACM (optional in dev)
module "dns" {
  source           = "../../modules/dns-route53"
  count            = var.enable_dns_tls ? 1 : 0
  hosted_zone_name = var.hosted_zone_name
}

module "acm" {
  source         = "../../modules/tls-acm"
  count          = var.enable_dns_tls ? 1 : 0
  domain_name    = var.acm_domain_name
  hosted_zone_id = module.dns[0].hosted_zone_id
}

