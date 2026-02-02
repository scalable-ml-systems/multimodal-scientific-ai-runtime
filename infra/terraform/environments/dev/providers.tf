provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project = var.project_name
      env     = var.env
      owner   = var.owner
    }
  }
}

# Kubernetes/Helm providers configured after EKS creation via data sources
data "aws_eks_cluster" "this" {
  name       = module.cluster_eks.cluster_name
  depends_on = [module.cluster_eks]
}

data "aws_eks_cluster_auth" "this" {
  name       = module.cluster_eks.cluster_name
  depends_on = [module.cluster_eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
