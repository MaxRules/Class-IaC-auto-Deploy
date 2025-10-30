variable "aws_region" {
  description = "AWS region for resource deployment"
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name prefix for resources"
  default     = "iac-demo"
}

variable "ec2_ami" {
  description = "Ubuntu AMI ID for EC2 instance"
  default     = "ami-0c5ddb3560e768732" # Ubuntu Server 22.04 LTS (us-east-2)
}

variable "ec2_type" {
  description = "Instance type for EC2"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the existing EC2 key pair"
  default     = "1PU_key"
}
