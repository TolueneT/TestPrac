variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

# Networking module variables
variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

# IAM module variables
variable "eks_cluster_role_name" {
  type = string
}

variable "eks_cluster_policy_name" {
  type = string
}

variable "eks_policy_file" {
  type = string
}
