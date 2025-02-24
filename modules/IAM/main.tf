resource "aws_iam_role" "eks_cluster" {
  name = var.eks_cluster_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "eks_cluster_policy" {
  name        = var.eks_cluster_policy_name
  description = "Policy for EKS Cluster operations"
  policy      = file(var.eks_policy_file)
}

resource "aws_iam_role_policy_attachment" "eks_cluster_attach" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = aws_iam_policy.eks_cluster_policy.arn
}
