

output "iam_ec2_instance_profile" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}

output "github_actions_s3_role_arn" {
  value = module.github_oidc_web.github_actions_s3_role_arn
}

output "grafana_reader_access_key_id" {
  value     = aws_iam_access_key.grafana_reader_key.id
  sensitive = true
}

output "grafana_reader_secret_access_key" {
  value     = aws_iam_access_key.grafana_reader_key.secret
  sensitive = true
}
