terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.58.0"
    }
  }

  required_version = ">=1.2"
}

provider "aws" {
  region = "ca-central-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../../network/terraform.tfstate"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.ssh_key_name
  public_key = file("C:/Users/patri/.ssh/${var.ssh_key_name}.pub")
}

module "discreta_server" {
  source = "../../modules/ec2-app"

  instance_name          = var.instance_name
  instance_type          = var.instance_type
  ami_id                 = var.ami_id
  vpc_security_group_ids = [data.terraform_remote_state.network.outputs.sg_id]
  ssh_key_name           = aws_key_pair.deployer.key_name
  domain_name            = var.domain_name
  repository_arn         = module.discreta_ecr.repository_arn
}

module "discreta_ecr" {
  source = "../../modules/ecr"
}

module "github_oidc" {
  source             = "../../modules/github-oidc"
  ecr_repository_arn = module.discreta_ecr.repository_arn
  github_repo        = "ItsmePatrice/Discreta"
}

module "website_s3" {
  source = "../../modules/s3"

  bucket_name = "discreta-website-prod"
}

resource "aws_acm_certificate" "website" {
  provider = aws.us_east_1

  domain_name               = var.website_domain_name
  subject_alternative_names = ["*.${var.website_domain_name}"]

  validation_method = "DNS"

  tags = {
    Name = var.website_domain_name
  }
}

resource "aws_acm_certificate_validation" "website" {
  provider = aws.us_east_1

  certificate_arn = aws_acm_certificate.website.arn

  validation_record_fqdns = [
    for option in aws_acm_certificate.website.domain_validation_options :
    option.resource_record_name
  ]
}

module "website_cloudfront" {
  source                         = "../../modules/cloudfront"
  s3_bucket_regional_domain_name = module.website_s3.bucket_regional_domain_name
  certificate_arn                = aws_acm_certificate.website.arn
  website_domain_name            = var.website_domain_name
}

data "aws_iam_policy_document" "website_bucket" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${module.website_s3.bucket_arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        module.website_cloudfront.distribution_arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = module.website_s3.bucket_name
  policy = data.aws_iam_policy_document.website_bucket.json
}
