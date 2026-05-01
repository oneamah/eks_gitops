variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "git" {
  description = "Git repository information for the application."
  type = object({
    repo_url   = string
    branch     = string
    auth_token = string
  })
}