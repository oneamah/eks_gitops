variable "backend_repository_name" {
  description = "ECR repository name for the backend image."
  type        = string
  default     = "backend"
}

variable "frontend_repository_name" {
  description = "ECR repository name for the frontend image."
  type        = string
  default     = "frontend"
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting for the ECR repositories."
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Whether to enable image scanning on push."
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Whether Terraform may delete repositories even if they still contain images."
  type        = bool
  default     = false
}

variable "image_retention_count" {
  description = "Maximum number of images to retain per repository before expiring older ones."
  type        = number
  default     = 10
}
