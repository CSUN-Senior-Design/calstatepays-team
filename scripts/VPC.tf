variable "my_region" {
  description = "Region being used"
  default     = "us-west-2"
}
variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default     = "10.0.1.0/24"
}
variable "public_subnet_cidr_two" {
  description = "CIDR for the public subnet"
  default = "10.0.2.0/24"
}
variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  default     = "10.0.3.0/24"
}
variable "my_ami" {
  description = "Amazon Linux AMI"
  default     = "ami-0d6621c01e8c2de2c"
}
variable "key_path" {
  description = "SSH Public Key path"
  default     = "/home/sam/terra1/.ssh/id_rsa.pub"
}
# AWS provider
provider "aws" {
  region = var.my_region
}
# VPC settings
resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "terra-vpc"
  }
}
# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "us-west-2a"
  tags = {
    Name = "Terra Public Subnet"
  }
}
# Define the public subnet_2
resource "aws_subnet" "public-subnet_two"{
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr_two}"
  availability_zone = "us-west-2b"
  tags= {
    Name = "Terra Public Subnet"
  }
}
# Define the private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "us-west-2c"
  tags = {
    Name = "Terra Private Subnet"
  }
}
# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "Terra VPC IGW"
  }
}
# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = " Terra Public Subnet Route Table"
  }
}
# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.web-public-rt.id
}
resource "aws_route_table_association" "web-public-rt2" {
  subnet_id      = aws_subnet.public-subnet_two.id
  route_table_id = aws_route_table.web-public-rt.id
}
# Define the security group for public subnet
resource "aws_security_group" "sgweb" {
  name        = "sgweb"
  description = "This will allow incoming HTTP connections & SSH access"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "Terra_VPC"
  }
}
# Define the security group for private Subnet
resource "aws_security_group" "sgweb2" {
  name        = "sgweb2"
  description = "This will allow incoming HTTP connections & SSH access"
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }
  
  
  
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "Bastion_SHH"
  }
}
# bastion security group
resource "aws_security_group" "sgweb3" {
  name        = "sgweb3"
  description = "This will allow incoming HTTP connections & SSH access"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "Spot-SG"
  }
}
# Define SSH key pair for our instances
#resource "aws_key_pair" "default" {
#  key_name = "micro"
#  public_key = "${file("${var.key_path}")}"
#}

# testing bastion
resource "aws_instance" "wb4" {
  ami                         = var.my_ami
  instance_type               = "t1.micro"
  key_name = "calstatepays"
  subnet_id                   = aws_subnet.public-subnet.id
  vpc_security_group_ids      = [aws_security_group.sgweb2.id]
  associate_public_ip_address = true
  source_dest_check           = false
  
  tags = {
    Name = "Terra_Bastion"
  }
}

