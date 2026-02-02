variable "project_name" {
  type    = string
  default = "ecr-platform"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "owner" {
  type    = string
  default = "your-name"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "one_nat_gateway" {
  type    = bool
  default = true
}

variable "cluster_name" {
  type    = string
  default = "ecr-platform-dev"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

# Nodegroups (ECR V1 is CPU-first; GPU is gated)
variable "system_instance_type" {
  type    = string
  default = "m6i.large"
}

variable "system_desired" {
  type    = number
  default = 2
}

variable "system_min" {
  type    = number
  default = 1
}

variable "system_max" {
  type    = number
  default = 3
}

variable "enable_gpu_nodegroup" {
  type    = bool
  default = false
}

variable "gpu_instance_type" {
  type    = string
  default = "g4dn.xlarge"
}

variable "gpu_desired" {
  type    = number
  default = 0
}

variable "gpu_min" {
  type    = number
  default = 0
}

variable "gpu_max" {
  type    = number
  default = 0
}

# Data services
variable "postgres_instance_class" {
  type    = string
  default = "db.t4g.medium"
}

variable "postgres_allocated_storage" {
  type    = number
  default = 50
}

variable "postgres_multi_az" {
  type    = bool
  default = false
}

# Buckets (ECR V1)
variable "s3_buckets" {
  type = map(object({
    versioning     = bool
    lifecycle_days = number
  }))
  default = {
    snapshots = { versioning = true, lifecycle_days = 30 }
    artifacts = { versioning = true, lifecycle_days = 30 }
  }
}

# ECR repositories (ECR V1 services)
variable "ecr_repos" {
  type = list(string)
  default = [
    "fraud-scorer",
    "lead-investigator",
    "history-actor",
    "policy-actor",
    "evaluator-summarizer",
    "outbox-relay",
    "observability"
  ]
}

# DNS/TLS (optional in dev)
variable "enable_dns_tls" {
  type    = bool
  default = false
}

variable "hosted_zone_name" {
  type    = string
  default = "example.com"
}

variable "acm_domain_name" {
  type    = string
  default = "*.example.com"
}
