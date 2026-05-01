output "argocd_url" {
  description = "Public URL configured for Argo CD"
  value       = try(module.gitops[0].argocd_url, null)
}

output "argocd_admin_password" {
  description = "Argo CD admin password managed by Terraform"
  value       = try(module.gitops[0].argocd_admin_password, null)
  sensitive   = true
}

output "grafana_url" {
  description = "Public URL configured for Grafana"
  value       = try(module.gitops[0].grafana_url, null)
}

output "grafana_admin_password" {
  description = "Grafana admin password managed by Terraform"
  value       = try(module.gitops[0].grafana_admin_password, null)
  sensitive   = true
}

output "grafana_acm_certificate_arn" {
  description = "ACM certificate ARN used by the Grafana ALB ingress"
  value       = try(module.gitops[0].grafana_acm_certificate_arn, null)
}

output "argo_rollouts_namespace" {
  description = "Namespace where Argo Rollouts is deployed"
  value       = try(module.gitops[0].argo_rollouts_namespace, null)
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID used by ExternalDNS"
  value       = try(module.gitops[0].route53_zone_id, null)
}

output "route53_zone_name_servers" {
  description = "Name servers for the managed Route53 hosted zone"
  value       = try(module.gitops[0].route53_zone_name_servers, null)
}

output "ecr_repository_urls" {
  description = "ECR repository URLs keyed by repository name"
  value       = module.ecr.repository_urls
}

output "backend_ecr_repository_url" {
  description = "ECR repository URL for the backend image"
  value       = module.ecr.backend_repository_url
}

output "frontend_ecr_repository_url" {
  description = "ECR repository URL for the frontend image"
  value       = module.ecr.frontend_repository_url
}

output "backend_ecr_repository_name" {
  description = "ECR repository name for the backend image"
  value       = module.ecr.backend_repository_name
}

output "frontend_ecr_repository_name" {
  description = "ECR repository name for the frontend image"
  value       = module.ecr.frontend_repository_name
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC CI/CD access"
  value       = module.iam.github_actions_role_arn
}