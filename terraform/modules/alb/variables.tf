variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}
variable "subnet_ids" {
  description = "Subnet IDs for the ALB"
  type        = list(string)
}
