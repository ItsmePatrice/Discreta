output "ecr_repo_arn" {
  value = module.discreta_ecr.repository_arn
}

output "website_certificate_arn" {
  value = aws_acm_certificate.website.arn
}

output "website_cloudfront_domain" {
  value = module.website_cloudfront.distribution_domain_name
}

output "s3_bucket_arn" {
  value = module.website_s3.bucket_arn
}
