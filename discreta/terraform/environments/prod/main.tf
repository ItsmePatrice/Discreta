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
}

module "discreta_ecr" {
  source = "../../modules/ecr"
}

module "github_oidc" {
  source         = "../../modules/github-oidc"
  repository_arn = module.discreta_ecr.repository_arn
  github_repo    = "ItsmePatrice/Discreta"
}
