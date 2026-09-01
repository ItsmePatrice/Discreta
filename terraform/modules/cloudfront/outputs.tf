output "distribution_domain_name" {
  value = aws_cloudfront_distribution.website.domain_name
}

output "distribution_arn" {
  value = aws_cloudfront_distribution.website.arn
}

output "distribution_id" {
  value = aws_cloudfront_distribution.website.id
}
