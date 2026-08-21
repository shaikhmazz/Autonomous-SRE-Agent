# AegisMind Root Infrastructure Assembly Module

module "vpc" {
  source      = "./modules/vpc"
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "ecr" {
  source      = "./modules/ecr"
  environment = var.environment
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = "${var.cluster_name}-${var.environment}"
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_instance_types = var.node_instance_types
  min_node_count      = var.min_node_count
  max_node_count      = var.max_node_count
}

module "iam" {
  source           = "./modules/iam"
  environment      = var.environment
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}
