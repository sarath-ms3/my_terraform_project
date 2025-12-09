provider "aws" {
  region = "ap-south-1"
}

# Create VPC
resource "aws_vpc" "my_vpc07" {
  cidr_block = "10.0.0.0/18"
  tags = {
    Name = "my_vpc07"
  }
}
#create subnet
resource "aws_subnet" "my_subnet07" {
  vpc_id                  = aws_vpc.my_vpc07.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "my_subnet07"
  }
}
#create Gateway
resource "aws_internet_gateway" "my_igw07" {
  vpc_id = aws_vpc.my_vpc07.id
  tags = {
    name = "my_igw07"
  }
}

# Create Route Table
resource "aws_route_table" "my_rt07" {
  vpc_id = aws_vpc.my_vpc07.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw07.id
  }
  tags = {
    Name = "my_rt07"
  }
}

# Create Route Table Association
resource "aws_route_table_association" "my_rt_association7" {
  subnet_id      = aws_subnet.my_subnet07.id
  route_table_id = aws_route_table.my_rt07.id
}

# Create Security Group for EC2 instance
resource "aws_security_group" "my_sg07" {
  name        = "my_sg07"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.my_vpc07.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 Instance to generate an AMI
resource "aws_instance" "my_ec07" {
  ami                         = "ami-022ab161c81d74cc6"  # Initial AMI ID
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.my_subnet07.id  # Subnet in the same VPC
  associate_public_ip_address = true
  key_name                    = "lock1"  # Existing key pair in AWS
  
  vpc_security_group_ids = [aws_security_group.my_sg07.id]
  
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd
  EOF

  tags = {
    Name = "my_ec07"
  }
}
 
