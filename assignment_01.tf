# Initialize
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# AWS provider
provider "aws" {
  region = var.region
}

variable "region" {
 default = "us-west-1"
 description = "AWS Region"
}

# EC2 instance
resource "aws_instance" "test_instance" {
  ami           = var.ami
  instance_type = var.type
  security_groups = [aws_security_group.test_security_group.name]
  subnet_id     = aws_subnet.test_public_subnet.id

  root_block_device {
    volume_size = 5
    volume_type = "gp2"
  }

  tags = {
    purpose = "Assignment"
  }
}

variable "ami" {
 default = "ami-04e914639d0cca79a"
 description = "Amazon Machine Image ID"
}
 
variable "type" {
 default = "t2.micro"
}

# Create VPC, private subnet, and public subnet
resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "test_public_subnet" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
}

resource "aws_subnet" "test_private_subnet" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
}

# Create security group for the EC2 instance
resource "aws_security_group" "test_security_group" {
  name        = "test-security-group"
  description = "Test security group"
  vpc_id = aws_vpc.test_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}