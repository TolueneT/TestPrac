module "networking" {
  source = "../networking"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  public_subnet_cidrs  = var.public_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "iam" {
  source                  = "../iam"
  eks_cluster_role_name   = var.eks_cluster_role_name
  eks_cluster_policy_name = var.eks_cluster_policy_name
  eks_policy_file         = var.eks_policy_file
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = module.iam.eks_cluster_role_arn

  vpc_config {
    subnet_ids = module.networking.public_subnet_ids
  }

  depends_on = [module.iam, module.networking]
}
