terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ✅ Configure the AWS Provider
provider "aws" {
  region     = "ap-southeast-1"
  access_key = ""
  secret_key = ""
}

# ✅ Set up the VPC
resource "aws_vpc" "mm_bookstore_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "mm_bookstore_vpc"
  }
}

# ✅ Set up the VPC subnets (Public Subnet)
resource "aws_subnet" "mm_bookstore_subnet_public" {
  vpc_id     = aws_vpc.mm_bookstore_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "mm_bookstore_subnet_public"
  }
}

# ✅ Set up the VPC subnets (Private Subnet)
resource "aws_subnet" "mm_bookstore_subnet_private" {
  vpc_id     = aws_vpc.mm_bookstore_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "mm_bookstore_subnet_private"
  }
}

# ✅ Internet Gateway
resource "aws_internet_gateway" "mm_bookstore_igw" {
  vpc_id = aws_vpc.mm_bookstore_vpc.id

  tags = {
    Name = "mm_bookstore_igw"
  }
}

# ✅ Route Table for Public Subnet
resource "aws_route_table" "mm_bookstore_public_rt" {
  vpc_id = aws_vpc.mm_bookstore_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mm_bookstore_igw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "mm_bookstore_public_rt"
  }
}

# ✅ Route Table for Private Subnet
resource "aws_route_table" "mm_bookstore_private_rt" {
  vpc_id = aws_vpc.mm_bookstore_vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "mm_bookstore_private_rt"
  }
}

# ✅ Associate Route Table with Public Subnet
resource "aws_route_table_association" "mm_bookstore_public_rta" {
  subnet_id      = aws_subnet.mm_bookstore_subnet_public.id
  route_table_id = aws_route_table.mm_bookstore_public_rt.id
}

# ✅ Associate Route Table with Private Subnet
resource "aws_route_table_association" "mm_bookstore_private_rta" {
  subnet_id      = aws_subnet.mm_bookstore_subnet_private.id
  route_table_id = aws_route_table.mm_bookstore_private_rt.id
}

# ✅ Security Group: Allow SSH, HTTP, HTTPS
resource "aws_security_group" "mm_bookstore_secgp" {
  name        = "mm-bookstore-sg"
  description = "Allow SSH, HTTP, and HTTPS"
  vpc_id      = aws_vpc.mm_bookstore_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mm_bookstore security_group"
  }
}

# ✅ Key Pair for SSH Access
resource "aws_key_pair" "mm_bookstore_keypair" {
  key_name   = "mm_bookstore-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxjqj5P9bj/3Uc0yOFIWGbPUt5mOz+Z5oJXoTSarCnnoZAKs2xEy6V6Vttzlv30FNuwTY+to/GLG/6yehgZN9xbVzmoyemh/pyF0p7yn1NhbXeDk0soE4jd3xYe7tl3mtChUpoN5kjJk0RUrs8PhnkT6y498IMrjwhpmexZDjMnlbX/qRdkMDFuxXl0Azr9cxp8OZH0SZVqZPwq7RReU2/OqhWVRO4QfSpwRrhjM9DdIkZ3CFRmoYUVgSDZbTf9SB/RVhX6j6RgWIajjU8cW0T16V70ms6mJcjGD2Og1bjABkjUSt9enVH5TAloIZicwPK/SlpfGgD8pfAiO9xZvNmwsQDMkAkVY0WABkVYs2OzMx/4VbiNqoCRDQTlebJjk8O0f9LmynE6xvSpa2PV+GkreY5ksjyA1Y+06aG7AR62yhxY0G53u4L2Y4Wiyo0JupYU14/Oj0Sn4VyyFc4vsmDUx5GLgcsBYn4hl14FtSO6PmbVnU3ILX+o5+jSwKr+A8ZZaq2oTFMdCRe85zuO/LSi6YCuazp1yrolXcwzmNV034s9J0Fddw0v7I9rwDVnBY/3zeIiQPTUP/Gnz+u3m8Qf3gjkquvVJMvLh7pa8CgJwPmaEZKqf1AcYBr4qgTquhwKYhCuefhCUiH0Gkub9b2vAh6DPP0evJ8HuQ2NAdrrw== kghte@BCMM172"
  tags = {
    Name = "MM Book Store Key Pair"
  }
}

resource "aws_instance" "mm-book-store" {

  # Change to t2.micro for free tier eligibility
  instance_type = "t2.micro"

  # Enable public IP for the instance
  associate_public_ip_address = true

  # Ubuntu 24.04 LTS (HVM), SSD Volume Type
  ami = "ami-02c7683e4ca3ebf58"

  # Use the public subnet created earlier
  subnet_id = aws_subnet.mm_bookstore_subnet_public.id

  # Use the security group created earlier
  key_name = aws_key_pair.mm_bookstore_keypair.key_name

  # Use the security group created earlier
  vpc_security_group_ids = [aws_security_group.mm_bookstore_secgp.id]

  tags = {
    Name = "MM Book Store"
  }
}