output "eks_cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane"
  value       = try(aws_iam_role.eks_cluster[0].arn, null)
}

output "eks_node_role_arn" {
  description = "IAM role ARN for the EKS managed node group"
  value       = try(aws_iam_role.eks_node_group[0].arn, null)
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller service account"
  value       = try(aws_iam_role.aws_load_balancer_controller[0].arn, null)
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN for the EBS CSI driver service account"
  value       = try(aws_iam_role.ebs_csi[0].arn, null)
}

output "external_dns_role_arn" {
  description = "IAM role ARN for the ExternalDNS service account"
  value       = try(aws_iam_role.external_dns[0].arn, null)
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for the EKS cluster"
  value       = try(aws_iam_openid_connect_provider.eks[0].arn, null)
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC CI/CD access"
  value       = try(aws_iam_role.github_actions[0].arn, null)
}
