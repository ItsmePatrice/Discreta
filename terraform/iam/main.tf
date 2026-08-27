
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
  role = aws_iam_role.ecr_read.name
}

resource "aws_iam_role" "ecr_read" {
  name               = "ecr_read"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_iam_role_policy" "ecr_read_only_policy" {
  name = "ecr_read_only_policy"
  role = aws_iam_role.ecr_read.id

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

// Create an IAM role for GitHub Actions to push to ECR
module "github_oidc" {
  source             = "../modules/github-oidc"
  ecr_repository_arn = data.terraform_remote_state.prod.outputs.ecr_repo_arn
  github_repo        = "ItsmePatrice/Discreta"
}
