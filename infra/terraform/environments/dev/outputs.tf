output "vpc_id" { value = module.network_vpc.vpc_id }
output "cluster_name" { value = module.cluster_eks.cluster_name }
output "cluster_endpoint" { value = module.cluster_eks.cluster_endpoint }

output "postgres_endpoint" { value = module.rds_postgres.endpoint }

output "s3_bucket_names" { value = module.s3.bucket_names }
output "ecr_repo_urls" { value = module.ecr.repo_urls }
