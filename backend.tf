terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"  # # Replace with your S3 bucket name for state storage
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"                    # # Replace with your AWS region
    dynamodb_table = "terraform-lock-table"         # # Replace with your DynamoDB table name for state locking
    encrypt        = true
  }
}
