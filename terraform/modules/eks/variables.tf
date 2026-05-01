variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "main-eks"
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS resources"
  type        = list(string)
}

variable "private_security_group_id" {
  description = "Security group ID intended for private workloads behind the ALB"
  type        = string
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for the EKS managed node group"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.33"
}

variable "node_instance_types" {
  description = "Instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of nodes in the managed node group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of nodes in the managed node group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes in the managed node group"
  type        = number
  default     = 3
}
