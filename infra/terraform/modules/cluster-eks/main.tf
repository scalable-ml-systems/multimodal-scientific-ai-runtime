terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 20.0.0"

  cluster_name    = var.name
  cluster_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_irsa = true

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  eks_managed_node_groups = merge(
    {
      system = {
        instance_types = [var.system_instance_type]
        min_size       = var.system_min
        max_size       = var.system_max
        desired_size   = var.system_desired

        labels = { "nodegroup" = "system" }
      }
    },
    var.enable_gpu_nodegroup ? {
      gpu = {
        instance_types = [var.gpu_instance_type]
        min_size       = var.gpu_min
        max_size       = var.gpu_max
        desired_size   = var.gpu_desired

        labels = { "nodegroup" = "gpu" }
        taints = {
          gpu = {
            key    = "nvidia.com/gpu"
            value  = "present"
            effect = "NO_SCHEDULE"
          }
        }
      }
    } : {}
  )
}
