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

# modules/iam/outputs.tf

```sh
output "eks_cluster_role_arn" {
  description = "ARN of the created IAM role for EKS"
  value       = aws_iam_role.eks_cluster.arn
}
```

# modules/eks/main.tf

```sh
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
```

# modules/eks/variables.tf

```sh
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

# Variables for the Networking module
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
}

# Variables for the IAM module
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
```

# modules/eks/outputs.tf

```sh
output "eks_cluster_id" {
  description = "ID of the created EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL of the created EKS cluster"
  value       = aws_eks_cluster.this.endpoint
}
```

# **Root Module Configuration**

## main.tf

```sh
module "eks" {
  source = "./modules/eks"

  # EKS module variables
  cluster_name = "my-eks-cluster"

  # Networking variables
  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "my-vpc"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones  = ["us-east-1a", "us-east-1b"]      #

  # IAM variables
  eks_cluster_role_name   = "my-eks-role"
  eks_cluster_policy_name = "my-eks-policy"
  eks_policy_file         = "path/to/eks-policy.json"  # # Replace with the actual path to your policy JSON file
}
```

## outputs.tf

```sh
output "eks_cluster_endpoint" {
  description = "The endpoint of the deployed EKS cluster"
  value       = module.eks.eks_cluster_endpoint
}
```

## backend.tf

```sh
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
```

# GitHub Actions Workflow

## .github/workflows/deploy.yml

```yaml
name: Terraform Deployment

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  terraform:
    runs-on: ubuntu-latest
    env:
      AWS_REGION: us-east-1
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.4.0

      - name: Terraform Format
        run: terraform fmt -check

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        id: plan
        run: terraform plan -out=tfplan

      - name: Terraform Apply
        if: github.event_name == 'push'
        run: |
          echo "Manual approval should be incorporated here if needed"
          # # You can integrate a manual approval step using GitHub Environments or an approval job
          terraform apply -auto-approve tfplan
```
