variable "github_repo" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}

variable "aws_iam_openid_connect_provider_arn" {
  description = "iam open id connect provider"
  type        = string
}
