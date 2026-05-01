output "vpc_id" {
  description = "VPC ID created by the networking module"
  value       = aws_vpc.main.id
}
output "public_subnet_ids" {
  description = "Public subnet IDs created by the networking module"
  value       = aws_subnet.public[*].id
}
output "private_subnet_ids" {
  description = "Private subnet IDs created by the networking module"
  value       = aws_subnet.private[*].id
}

output "subnet_id" {
  description = "First public subnet ID created by the networking module"
  value       = aws_subnet.public[0].id
}

output "private_subnet_id" {
  description = "First private subnet ID created by the networking module"
  value       = aws_subnet.private[0].id
}

