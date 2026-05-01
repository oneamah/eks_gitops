terraform {
  required_version = "~> 1.14"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
    github = {
        source = "integrations/github"
        version = "~> 6.0"
    }
    random = {
        source = "hashicorp/random"
        version = "~> 3.0"
    }
    null = {
        source = "hashicorp/null"
        version = "~> 3.0"
    }
    local = {
        source = "hashicorp/local"
        version = "~> 2.0"
    }
    kubernetes = {
        source = "hashicorp/kubernetes"
        version = "~> 2.0"
    }
    helm = {
        source = "hashicorp/helm"
      version = "~> 3.0"
    }
    time = {
        source = "hashicorp/time"
        version = "~> 0.10"
    }
    tls = {
        source = "hashicorp/tls"
        version = "~> 4.0"
    }
    http = {
        source = "hashicorp/http"
        version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
}

provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  }
}

provider "github" {
  token = var.git.auth_token
  owner = var.git.repo_url
  base_url = "https://api.github.com/"
}
provider "random" {}
provider "null" {}
provider "time" {}
provider "tls" {}
provider "http" {}