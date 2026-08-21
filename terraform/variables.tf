variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS deployment region"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment identifier (dev, staging, prod)"
}

variable "cluster_name" {
  type        = string
  default     = "aegismind-eks-cluster"
  description = "Name of the AWS EKS Cluster"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the AWS VPC"
}

variable "node_instance_types" {
  type        = list(string)
  default     = ["t3.medium", "t3.large"]
  description = "EC2 Instance types for EKS Worker Node Groups"
}

variable "min_node_count" {
  type        = number
  default     = 2
  description = "Minimum worker nodes in EKS auto-scaling group"
}

variable "max_node_count" {
  type        = number
  default     = 6
  description = "Maximum worker nodes in EKS auto-scaling group"
}
