variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the EKS cluster is deployed"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID used by the EKS cluster"
  type        = string
}

variable "alb_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller service account"
  type        = string
}

variable "ebs_csi_role_arn" {
  description = "IAM role ARN for the EBS CSI driver service account"
  type        = string
}

variable "external_dns_role_arn" {
  description = "IAM role ARN for the ExternalDNS service account"
  type        = string
}

variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog app key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "datadog_site" {
  description = "Datadog site"
  type        = string
  default     = "datadoghq.com"
}

variable "image_pull_secret_name" {
  description = "Name of the optional Kubernetes image pull secret"
  type        = string
  default     = "registry-creds"
}

variable "image_pull_secret_namespace" {
  description = "Namespace for the optional Kubernetes image pull secret"
  type        = string
  default     = "default"
}

variable "image_pull_secret_server" {
  description = "Registry server for the optional Kubernetes image pull secret"
  type        = string
  default     = ""
}

variable "image_pull_secret_username" {
  description = "Registry username for the optional Kubernetes image pull secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "image_pull_secret_password" {
  description = "Registry password for the optional Kubernetes image pull secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "image_pull_secret_email" {
  description = "Registry email for the optional Kubernetes image pull secret"
  type        = string
  default     = ""
}

variable "external_dns_domain_filters" {
  description = "Optional domain filters for ExternalDNS"
  type        = list(string)
  default     = []
}

variable "external_dns_txt_owner_id" {
  description = "TXT owner ID used by ExternalDNS"
  type        = string
}

variable "route53_zone_name" {
  description = "Public Route53 hosted zone name used by ExternalDNS and ingress hostnames"
  type        = string
}

variable "create_route53_zone" {
  description = "Whether Terraform should create the public Route53 hosted zone"
  type        = bool
  default     = true
}

variable "argocd_hostname" {
  description = "Public hostname for the Argo CD server"
  type        = string
}

variable "argocd_admin_password" {
  description = "Optional Argo CD admin password. Leave empty to generate one"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_acm_certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS termination on the Argo CD ALB ingress"
  type        = string
  default     = ""
}

variable "grafana_hostname" {
  description = "Public hostname for Grafana"
  type        = string
}

variable "grafana_acm_certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS termination on the Grafana ALB ingress"
  type        = string
  default     = ""
}
