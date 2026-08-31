

output "iam_ec2_instance_profile" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}

output "github_actions_s3_role_arn" {
  value = module.github_oidc_web.github_actions_s3_role_arn
}
