output "alb_security_group_id" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb.id
}

output "private_security_group_id" {
  description = "Security group ID for private workloads"
  value       = aws_security_group.private.id
}