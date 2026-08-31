variable "ecr_repository_arn" {
  description = "ARN of the ECR repository GitHub Actions is allowed to push to"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo"
  type        = string
}

variable "aws_iam_openid_connect_provider_arn" {
  description = "iam open id connect provider"
  type        = string
}
