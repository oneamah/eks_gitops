variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "app_port" {
  description = "Application port exposed behind the ALB"
  type        = number
  default     = 80
}
