data "aws_ssm_parameter" "vpc_id" {
  name = "/network/services/vpc"
}

data "aws_ssm_parameter" "private_subnets" {
  name = "/network/services/private_subnets"
}

data "aws_ssm_parameter" "public_subnets" {
  name = "/network/services/public_subnets"
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_name      = module.eks.cluster_name
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_karpenter = true
  enable_argocd    = true
}


module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "20.24.0"
  vpc_id                                   = data.aws_ssm_parameter.vpc_id.value
  cluster_name                             = "realworld"
  cluster_version                          = "1.30"
  subnet_ids                               = split(",", data.aws_ssm_parameter.private_subnets.value)
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    critical = {
      instance_types = ["t2.medium"]
      min_size     = 3
      max_size     = 3
      desired_size = 3
    }
  }
}