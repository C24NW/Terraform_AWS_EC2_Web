#Configure AWS provider with region
provider "aws" {
  region = "us-east-1"
}

#Create default VPC if one does not exist
resource "aws_default_vpc" "default_vpc" {

  tags = {
    Name = "default vpc"
  }
}

#Use data source to get all AZ's in region
data "aws_availability_zones" "available_zones" {}

#Create default subnet if one does not already exist
resource "aws_default_subnet" "default_az1" {
  #Get first AZ with index 0
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet"
  }
}

#Create security group for EC2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 80 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  #Rule in security group that allows incoming traffic
  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    #All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.102/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2 security group"
  }
}

#Launch the EC2 instance and install website
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-05e411cf591b5c9f6"
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "main-key"
  user_data              = file("website.sh")

  tags = {
    Name = "server"
  }
}

#Print the EC2's public IPv4 address
output "public_ipv4_address" {
  value = aws_instance.ec2_instance.public_ip
}