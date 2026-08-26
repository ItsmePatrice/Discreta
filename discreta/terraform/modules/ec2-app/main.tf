

data "terraform_remote_state" "iam" {
  backend = "local"
  config = {
    path = "../../iam/terraform.tfstate"
  }
}

resource "aws_instance" "ec2_instance" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  iam_instance_profile = data.terraform_remote_state.iam.outputs.iam_ec2_instance_profile

  vpc_security_group_ids = var.vpc_security_group_ids
  key_name               = var.ssh_key_name

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    domain_name = var.domain_name
  })

  tags = {
    Name = var.instance_name
  }
}

resource "aws_eip" "ec2_ip" {
  instance = aws_instance.ec2_instance.id
  domain   = "vpc"
}
