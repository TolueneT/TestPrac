variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "eks_cluster_role_name" {
  description = "Name for the IAM role for EKS"
  type        = string
}

variable "eks_cluster_policy_name" {
  description = "Name for the IAM policy for EKS"
  type        = string
}

variable "eks_policy_file" {
  description = "Path to the IAM policy JSON file"
  type        = string
}
