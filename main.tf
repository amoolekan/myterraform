terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
 
}

provider "aws" {
  region     = "eu-north-1"
  access_key = "AKIAQOOWLHZGIX7B2AUC"
  secret_key = "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"
}



# 1. Create Security Group to allow port 22,80,443
  resource "aws_security_group" "allow_port" {
   name        = "allow_port_traffic"
   description = "Allow port inbound traffic"
   vpc_id      = "vpc-05921d3a5deccbf68"

   ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"] 
   }

   ingress {
     description = "SSH"
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

# 2. Create a network interface with NSG for app 1
resource "aws_network_interface" "my-app1-nic" {
    subnet_id       = "subnet-03488bd03dc43b94d"
    private_ips     = [""]
    security_groups = [aws_security_group.allow_port.id]
    }

# 3. Create a network interface with NSG for app 2
resource "aws_network_interface" "my-app2-nic" {
    subnet_id       = "subnet-03488bd03dc43b94d"
    private_ips     = [""]
    security_groups = [aws_security_group.allow_port.id]
    }

# 4. Create EC2 instance my-app-1 with NSG settings of Ethernet
resource "aws_instance" "my-app-1" {
  ami               = "ami-08766f81ab52792ce"
  instance_type     = "t3.micro"

    tags = {
    Name = "my-app-1"
    }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.my-app1-nic.id

  }
}

# 5. Create EC2 intsance my-app-2 with NSG settings of Ethernet
resource "aws_instance" "my-app-2" {
  ami               = "ami-08766f81ab52792ce"
  instance_type     = "t3.micro"

  tags = {
    Name = "my-app-2"
    }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.my-app2-nic.id


  }
}

