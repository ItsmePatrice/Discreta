variable "ecr_repository_arn" {
  description = "ARN of the ECR repository GitHub Actions is allowed to push to"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo"
  type        = string
}
