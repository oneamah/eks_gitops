output "argocd_url" {
  description = "Public URL configured for Argo CD"
  value       = module.gitops.argocd_url
}

output "argocd_admin_password" {
  description = "Argo CD admin password managed by Terraform"
  value       = module.gitops.argocd_admin_password
  sensitive   = true
}

output "grafana_url" {
  description = "Public URL configured for Grafana"
  value       = module.gitops.grafana_url
}

output "grafana_admin_password" {
  description = "Grafana admin password managed by Terraform"
  value       = module.gitops.grafana_admin_password
  sensitive   = true
}

output "grafana_acm_certificate_arn" {
  description = "ACM certificate ARN used by the Grafana ALB ingress"
  value       = module.gitops.grafana_acm_certificate_arn
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID used by ExternalDNS"
  value       = module.gitops.route53_zone_id
}

output "route53_zone_name_servers" {
  description = "Name servers for the managed Route53 hosted zone"
  value       = module.gitops.route53_zone_name_servers
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