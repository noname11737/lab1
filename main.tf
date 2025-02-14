terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  region  = "us-east-2"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_security_group" "sg_terraform" {
  name        = "security group using Terraform"
  description = "security group using Terraform"
  vpc_id      = "vpc-0a36a1b86c45b2343"

  ingress {
    description = "Allow Inbound HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Inbound HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_terraform"
  }
}

resource "aws_instance" "demo_instance" {
  ami                    = "ami-05803413c51f242b7"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_terraform.id]
  key_name               = "lab_keypair"
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y docker.io
    sudo docker run -d --name watchto -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower -i 10
    sudo docker run -d -p 80:80 nonan002/lab1
  EOF
}