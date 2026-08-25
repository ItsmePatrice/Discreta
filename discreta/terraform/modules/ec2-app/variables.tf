
variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Type of instance to launch"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to launch the EC2 instance"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group ids"
  type        = list(string)
}

variable "ssh_key_name" {
  description = "Name of SSH key"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the EC2 instance"
  type        = string
}

