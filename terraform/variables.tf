variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "main-eks"
}

variable "git" {
  description = "Git repository information for the application."
  type = object({
    repo_url   = string
    branch     = string
    auth_token = string
  })
}
variable "datadog_api_key" {
  description = "Datadog API key for monitoring."
  type        = string
  default     = ""
}
variable "datadog_app_key" {
  description = "Datadog application key for monitoring."
  type        = string
  default     = ""
}

variable "datadog_site" {
  description = "Datadog site to use for the Helm chart."
  type        = string
  default     = "datadoghq.com"
}

variable "image_pull_secret_name" {
  description = "Name of the optional Kubernetes image pull secret."
  type        = string
  default     = "registry-creds"
}

variable "image_pull_secret_namespace" {
  description = "Namespace of the optional Kubernetes image pull secret."
  type        = string
  default     = "default"
}

variable "image_pull_secret_server" {
  description = "Registry server of the optional Kubernetes image pull secret."
  type        = string
  default     = ""
}

variable "image_pull_secret_username" {
  description = "Registry username of the optional Kubernetes image pull secret."
  type        = string
  default     = ""
}

variable "image_pull_secret_password" {
  description = "Registry password of the optional Kubernetes image pull secret."
  type        = string
  default     = ""
}

variable "image_pull_secret_email" {
  description = "Registry email of the optional Kubernetes image pull secret."
  type        = string
  default     = ""
}

variable "external_dns_domain_filters" {
  description = "Optional domain filters for ExternalDNS."
  type        = list(string)
  default     = []
}

variable "external_dns_txt_owner_id" {
  description = "TXT owner ID used by ExternalDNS."
  type        = string
  default     = "main-eks"
}

variable "route53_zone_name" {
  description = "Public Route53 hosted zone name used by ExternalDNS and ingress hostnames."
  type        = string
  default     = "marmil.co"
}

variable "create_route53_zone" {
  description = "Whether Terraform should create the public Route53 hosted zone instead of looking up an existing one."
  type        = bool
  default     = true
}

variable "argocd_hostname" {
  description = "Public hostname for the Argo CD server."
  type        = string
  default     = "argocd.marmil.co"
}

variable "argocd_admin_password" {
  description = "Optional Argo CD admin password. Leave empty to let Terraform generate one."
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_acm_certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS termination on the Argo CD ALB ingress."
  type        = string
  default     = ""
}

variable "grafana_hostname" {
  description = "Public hostname for Grafana."
  type        = string
  default     = "grafana.marmil.co"
}

variable "grafana_acm_certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS termination on the Grafana ALB ingress."
  type        = string
  default     = ""
}

variable "backend_ecr_repository_name" {
  description = "ECR repository name for the backend image."
  type        = string
  default     = "backend"
}

variable "frontend_ecr_repository_name" {
  description = "ECR repository name for the frontend image."
  type        = string
  default     = "frontend"
}

variable "ecr_image_retention_count" {
  description = "Maximum number of images to retain per ECR repository before lifecycle cleanup expires older images."
  type        = number
  default     = 10
}

variable "github_repository" {
  description = "GitHub repository in owner/repo format allowed to assume the GitHub Actions role."
  type        = string
  default     = "oneamah/eks_gitops"
}

variable "github_actions_role_name" {
  description = "IAM role name for GitHub Actions OIDC CI/CD access."
  type        = string
  default     = "terraform"
}
