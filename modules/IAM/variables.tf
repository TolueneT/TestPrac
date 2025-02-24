variable "eks_cluster_role_name" {
  description = "IAM role name for EKS cluster"
  type        = string
}

variable "eks_cluster_policy_name" {
  description = "IAM policy name for EKS cluster"
  type        = string
}

variable "eks_policy_file" {
  description = "Path to the JSON file containing the EKS policy"
  type        = string
}
