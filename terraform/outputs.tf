output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the AWS VPC"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "The endpoint URL for the AWS EKS API Server"
}

output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the provisioned EKS cluster"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "The URL of the ECR repository for AegisMind Engine"
}

output "aegismind_irsa_role_arn" {
  value       = module.iam.aegismind_role_arn
  description = "IAM Role ARN associated with AegisMind Kubernetes ServiceAccount (IRSA)"
}
