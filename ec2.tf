provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "web-vpc"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id     = aws_vpc.my_vpc.id
  tags = {
    Name = "web-igw"
  }
}

resource "aws_subnet" "my_subnet_a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "web-subnet-a"
  }
}

resource "aws_subnet" "my_subnet_b" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  
  tags = {
    Name = "web-subnet-b"
  }
}

resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "web-rt"
  }
}

resource "aws_route_table_association" "my_rta" {
  subnet_id = aws_subnet.my_subnet_a.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_route_table_association" "my_rta_1" {
  subnet_id = aws_subnet.my_subnet_b.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg"
  vpc_id = aws_vpc.my_vpc.id
  
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

resource "aws_instance" "my_instance_1" {
  ami           = "ami-006e00d6ac75d2ebb"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.my_subnet_b.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name = "web-key"
  associate_public_ip_address = true
  
  tags = {
    Name = "web-instance-1"
  }
}