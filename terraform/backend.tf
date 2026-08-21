# Remote Backend Configuration using AWS S3 & DynamoDB State Locking
terraform {
  backend "s3" {
    bucket         = "aegismind-tf-state-bucket"
    key            = "aegismind/sre-control-plane/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aegismind-tf-locks"
    encrypt        = true
  }
}
