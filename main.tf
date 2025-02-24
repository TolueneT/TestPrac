module "eks" {
  source = "./modules/eks"
  
  cluster_name            = var.cluster_name
  vpc_cidr                = var.vpc_cidr
  vpc_name                = var.vpc_name
  public_subnet_cidrs     = var.public_subnet_cidrs
  availability_zones      = var.availability_zones
  eks_cluster_role_name   = var.eks_cluster_role_name
  eks_cluster_policy_name = var.eks_cluster_policy_name
  eks_policy_file         = var.eks_policy_file
}
