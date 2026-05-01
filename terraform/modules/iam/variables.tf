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
