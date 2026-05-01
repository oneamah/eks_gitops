variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "main-eks"
}

variable "create_eks_base_roles" {
  description = "Whether to create the IAM roles required by the EKS control plane and node groups"
  type        = bool
  default     = true
}

variable "create_irsa_roles" {
  description = "Whether to create IAM Roles for Service Accounts used by EKS add-ons"
  type        = bool
  default     = false
}

variable "oidc_provider_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster"
  type        = string
  default     = null
}

variable "create_github_actions_role" {
  description = "Whether to create a GitHub Actions OIDC role for CI/CD access"
  type        = bool
  default     = false
}

variable "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  type        = string
  default     = "terraform"
}

variable "github_repository" {
  description = "GitHub repository in owner/repo format allowed to assume the CI/CD role"
  type        = string
  default     = null
}

variable "github_actions_oidc_subjects" {
  description = "Optional OIDC subject patterns allowed to assume the GitHub Actions role"
  type        = list(string)
  default     = []
}

variable "github_actions_ecr_repository_arns" {
  description = "ECR repository ARNs the GitHub Actions role may push to"
  type        = list(string)
  default     = []
}
