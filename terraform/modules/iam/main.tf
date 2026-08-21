# AWS IRSA (IAM Roles for Service Accounts) Module for AegisMind SRE Engine

resource "aws_iam_role" "aegismind_sa" {
  name = "aegismind-sa-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:default:aegismind-sre-sa"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "aegismind_policy" {
  name        = "aegismind-sre-policy-${var.environment}"
  description = "Permissions for AegisMind to query CloudWatch, EKS, and manage auto-healing resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "logs:FilterLogEvents",
          "eks:DescribeCluster",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.aegismind_sa.name
  policy_arn = aws_iam_policy.aegismind_policy.arn
}
