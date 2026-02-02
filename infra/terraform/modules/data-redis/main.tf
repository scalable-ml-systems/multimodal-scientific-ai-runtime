terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-redis-subnets"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "redis" {
  name   = "${var.name}-redis-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "from_eks" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = var.eks_security_group_id
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = "${var.name}-redis"
  description                   = "Redis for ${var.name}"
  engine                        = "redis"
  node_type                     = var.node_type
  num_cache_clusters            = 1

  subnet_group_name             = aws_elasticache_subnet_group.this.name
  security_group_ids            = [aws_security_group.redis.id]

  automatic_failover_enabled    = false
  multi_az_enabled              = false
}
