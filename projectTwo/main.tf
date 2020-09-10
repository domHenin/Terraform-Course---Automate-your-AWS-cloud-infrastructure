# AWS Provider
provider "aws" {
    version = ">= 2.46.0"
    region = var.aws_region
}

# s3 Bucket
terraform {
    backend "s3" {
        bucket = "cloudlogixtrtfstate"
        key = "projectTwo/terraform.tfstate"
        region = "us-east-2"
    }
}

# AWS Key Pair
resource "aws_key_pair" "deployer" {
    key_name = "provision-key"
    public_key = file("~/.ssh/id_rsa.pub")
}

# AWS Instance
resource "aws_instance" "ubuntu_container" {
    ami = "ami-085925f297f89fce1"
    instance_type = "t2.micro"

    connection {
        type = "ssh"
        uers = "admin"
        private_key = file("~/.ssh/id_rsa")
        host = self.publics_ip
    }

    user_data = file("files/install_apachev2.sh")

    tags = {
        Name = "ubuntu_container"
    }
}

# AWS VPC
resource "aws_vpc" "prod_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "prod_vpc"
    }
}

# AWS Internet Gateway
resource "aws_internet_gateway" "prod_gw" {
    vpc_id = aws_vpc.prod_vpc.id

    tags = {
        Name = "prod_gw_main"
    }
}

#AWS Route Table
resource "aws_route_table" "prod_rt" {
    vpc_id = aws_vpc.prod_vpc.id

    route {
        cidr_block = "10.0.1.0/24"
        gateway_id = aws_internet_gateway.prod_gw.id
    }

    tags = {
        Name = "prod_rt_main"
    }
}

# AWS Route Table Association
resource "aws_route_table" "sub_association" {
    vpc_id = aws_vpc.prod_vpc.id
    // subnet_id = aws_subnet.prod_subnet.id
    // route_table_id = aws_route_table.prod_rt.id
}

#AWS Subnet
resource "aws_subnet" "prod_subnet" {
    vpc_id = aws_vpc.prod_vpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "prod_subnet"
    }
}

#AWS Security Group
resource "aws_security_group" "allow_connection" {
    name = "allow_connection"
    description = "Allow connection inbound traffic"
    vpc_id = aws_vpc.prod_vpc.id

    ingress {
        description = "TLS from VPC"
        from_port = var.tls_port
        to_port = var.tls_port
        protocol = "tcp"
        cidr_blocks = [aws_vpc.prod_vpc.cidr_block]
    }

    ingress {
        description = "SSH Port"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = [aws_vpc.prod_vpc.cidr_block]
    }

    ingress {
        description = "HTTP Port"
        from_port = var.http_port
        to_port = var.http_port
        protocol = "tcp"
        cidr_blocks = [aws_vpc.prod_vpc.cidr_block]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# AWS Network Interface
resource "aws_network_interface" "elastic_ip" {
    subnet_id = aws_subnet.prod_subnet.id
    private_ips = ["10.0.0.50"]
    security_groups = [aws_security_group.allow_connection.id]

    attachment {
        instance = aws_instance.ubuntu_container.id
        device_index = 1
    }
}

# TODO:
# 1 create VPC
# 2 create internet gateway
# 3 create custom route table
# 4 creat a subnet
# 5 associate subnet with route table create security group to allow port 22,80,443
# 6 create security group to allow 22,80,443
# 7 create a network interface with an ip in the subnet that was create in step 4
# 8 assign an elastic IP to the network interface created in step 7
# 9 create Ubuntu server and install/enable apache2