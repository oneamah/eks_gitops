output "repository_urls" {
  description = "Repository URLs keyed by repository name."
  value       = { for name, repository in aws_ecr_repository.repositories : name => repository.repository_url }
}

output "repository_arns" {
  description = "Repository ARNs keyed by repository name."
  value       = { for name, repository in aws_ecr_repository.repositories : name => repository.arn }
}

output "backend_repository_url" {
  description = "Repository URL for the backend image."
  value       = aws_ecr_repository.repositories[var.backend_repository_name].repository_url
}

output "backend_repository_arn" {
  description = "Repository ARN for the backend image."
  value       = aws_ecr_repository.repositories[var.backend_repository_name].arn
}

output "frontend_repository_url" {
  description = "Repository URL for the frontend image."
  value       = aws_ecr_repository.repositories[var.frontend_repository_name].repository_url
}

output "frontend_repository_arn" {
  description = "Repository ARN for the frontend image."
  value       = aws_ecr_repository.repositories[var.frontend_repository_name].arn
}

output "backend_repository_name" {
  description = "Repository name for the backend image."
  value       = var.backend_repository_name
}

output "frontend_repository_name" {
  description = "Repository name for the frontend image."
  value       = var.frontend_repository_name
}
