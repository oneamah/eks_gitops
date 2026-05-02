output "image_pull_secret_name" {
  description = "Name of the optional Kubernetes image pull secret"
  value       = try(kubernetes_secret_v1.image_pull_secret[0].metadata[0].name, null)
}

output "argocd_namespace" {
  description = "Namespace where Argo CD is deployed"
  value       = helm_release.argocd.namespace
}

output "argocd_server_service_name" {
  description = "Argo CD API server Kubernetes service name"
  value       = "argocd-server"
}

output "argocd_url" {
  description = "Public URL configured for Argo CD"
  value       = local.argocd_url
}

output "argocd_admin_password" {
  description = "Argo CD admin password managed by Terraform"
  value       = local.argocd_admin_password
  sensitive   = true
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID used by ExternalDNS"
  value       = var.create_route53_zone ? aws_route53_zone.primary[0].zone_id : data.aws_route53_zone.primary[0].zone_id
}

output "route53_zone_name_servers" {
  description = "Name servers for the managed Route53 hosted zone"
  value       = var.create_route53_zone ? aws_route53_zone.primary[0].name_servers : []
}

output "argocd_acm_certificate_arn" {
  description = "ACM certificate ARN used by the Argo CD ALB ingress"
  value       = local.argocd_effective_certificate_arn
}

output "argo_rollouts_namespace" {
  description = "Namespace where Argo Rollouts is deployed"
  value       = helm_release.argo_rollouts.namespace
}

output "argo_rollouts_url" {
  description = "Public URL configured for the Argo Rollouts dashboard"
  value       = local.argo_rollouts_url
}

output "argo_rollouts_acm_certificate_arn" {
  description = "ACM certificate ARN used by the Argo Rollouts ALB ingress"
  value       = local.argo_rollouts_effective_certificate_arn
}

output "monitoring_namespace" {
  description = "Namespace where Prometheus, Loki, and Grafana are deployed"
  value       = local.monitoring_namespace
}

output "grafana_admin_password" {
  description = "Grafana admin password managed by Terraform"
  value       = local.grafana_admin_password
  sensitive   = true
}

output "grafana_url" {
  description = "Public URL configured for Grafana"
  value       = local.grafana_url
}

output "grafana_acm_certificate_arn" {
  description = "ACM certificate ARN used by the Grafana ALB ingress"
  value       = local.grafana_effective_certificate_arn
}

output "grafana_service_name" {
  description = "Grafana service name"
  value       = "grafana"
}

output "prometheus_server_service_name" {
  description = "Prometheus server service name"
  value       = "prometheus-server"
}

output "loki_service_name" {
  description = "Loki service name"
  value       = "loki"
}

output "metrics_server_namespace" {
  description = "Namespace where metrics-server is deployed"
  value       = helm_release.metrics_server.namespace
}

