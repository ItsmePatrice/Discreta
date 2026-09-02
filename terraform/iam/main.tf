
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



data "terraform_remote_state" "prod" {
  backend = "local"
  config = {
    path = "../environments/prod/terraform.tfstate"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_node_role.name
}

resource "aws_iam_role" "ec2_node_role" {
  name               = "ec2_node_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "send_to_cloudwatch_policy" {
  name = "send_to_cloudwatch_policy"
  role = aws_iam_role.ec2_node_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:ca-central-1:*:log-group:/discreta/prod/app:*",
          "arn:aws:logs:ca-central-1:*:log-group:/discreta/staging/app:*"
        ]
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "discreta_app" {
  for_each          = toset(["prod", "staging"])
  name              = "/discreta/${each.key}/app"
  retention_in_days = each.key == "prod" ? 30 : 7
  log_group_class   = "INFREQUENT_ACCESS"
}

resource "aws_iam_role_policy" "ecr_read_only_policy" {
  name = "ecr_read_only_policy"
  role = aws_iam_role.ec2_node_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings"
        ]
        Resource = data.terraform_remote_state.prod.outputs.ecr_repo_arn
      },
    ]
  })
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

// Create an IAM role for GitHub Actions to push to ECR
module "github_oidc" {
  source                              = "../modules/github-oidc"
  ecr_repository_arn                  = data.terraform_remote_state.prod.outputs.ecr_repo_arn
  github_repo                         = "ItsmePatrice/Discreta"
  aws_iam_openid_connect_provider_arn = aws_iam_openid_connect_provider.github.arn
}

// Create an IAM role for Github Actions to update website in S3
module "github_oidc_web" {
  source                              = "../modules/github-oidc-web"
  s3_bucket_arn                       = data.terraform_remote_state.prod.outputs.s3_bucket_arn
  github_repo                         = "ItsmePatrice/panic-necklace"
  aws_iam_openid_connect_provider_arn = aws_iam_openid_connect_provider.github.arn
}
