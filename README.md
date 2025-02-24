# **Task: Implement Terraform Modules for Networking, IAM, and EKS with GitHub Actions Deployment**

## _Objective_

- Develop three Terraform modules (networking, iam, and eks) and automate their deployment using GitHub Actions.

# Deliverables

- Terraform modules (networking, iam, eks) in a repository.
- GitHub Actions workflow (.github/workflows/deploy.yml) for automated deployment.
- Documentation (README.md) with usage instructions.

# **IMPLEMENTATION STEPS**

## 1. Initialize the Terraform Project

Create a working directory and navigate into it:

```sh
mkdir PracTest && cd PracTest
```

## 2. Set Up the Directory Structure and Developing the Modules

````sh
mkdir modules
mkdir modules/Networking modules/IAM modules/EKS


---

## Step 1: Create the Networking Module

### `modules/networking/main.tf`
```hcl
# Create a VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr  # Provided in variables.tf
  tags = {
    Name = var.vpc_name  # # Add your VPC name details when calling the module
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-${count.index}"  # # This will use your VPC name
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-igw"  # # Name detail is derived from var.vpc_name
  }
}

# Create a public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Create a default route to the internet gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Associate the route table with each public subnet
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
````

# 1.2 IAM Module

## modules/iam/main.tf

```sh
# Create an IAM Role for the EKS cluster
resource "aws_iam_role" "eks_cluster" {
  name = var.eks_cluster_role_name  # Name provided by caller
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# Create an IAM Policy for EKS cluster operations
resource "aws_iam_policy" "eks_cluster_policy" {
  name        = var.eks_cluster_policy_name  # Policy name provided by caller
  description = "Policy for EKS Cluster operations"
  policy      = file(var.eks_policy_file)      # Reads policy JSON from file
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_attach" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = aws_iam_policy.eks_cluster_policy.arn
}
```

## modules/iam/variables.tf

```sh
variable "eks_cluster_role_name" {
  description = "Name for the IAM role for EKS"
  type        = string
}

variable "eks_cluster_policy_name" {
  description = "Name for the IAM policy for EKS"
  type        = string
}

variable "eks_policy_file" {
  description = "Path to the JSON file with the IAM policy definition"
  type        = string
}
```
