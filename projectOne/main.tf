# AWS Provider
provider "aws" {
  version = ">= 2.46.0"
  region  = var.aws_region
}

# AWS Instance
resource "aws_instance" "foo_web" {
  ami           = "ami-085925f297f89fce1"
  instance_type = "t2.micro"

  tags = {
    Name = "ubuntu_server1"
  }
}

# AWS VPC
resource "aws_vpc" "foo_vpc" {
  cidr_block = "10.0.0.0/16"



  tags = {
    Name = "prod-vpc"
  }
}

# AWS Subnet
resource "aws_subnet" "foo_subnet" {
  vpc_id     = aws_vpc.foo_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "prod-subnet"
  }
}