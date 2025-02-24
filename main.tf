module "eks" {
  source = "./modules/eks"

  # EKS module variables
  cluster_name = "my-eks-cluster"              # # Replace with your EKS cluster name

  # Networking variables
  vpc_cidr            = "10.0.0.0/16"            # # Replace with your VPC CIDR
  vpc_name            = "my-vpc"                 # # Replace with your VPC name
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]  # # Replace with your public subnet CIDRs
  availability_zones  = ["us-east-1a", "us-east-1b"]      # # Replace with your desired AZs

  # IAM variables
  eks_cluster_role_name   = "my-eks-role"          # # Replace with your IAM role name
  eks_cluster_policy_name = "my-eks-policy"        # # Replace with your IAM policy name
  eks_policy_file         = "path/to/eks-policy.json"  # # Replace with the actual path to your policy JSON file
}
