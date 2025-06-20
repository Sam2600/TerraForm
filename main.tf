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

# ✅ Get the default VPC
data "aws_vpc" "mm_bookstore_vpc" {
  default = true
}

# ✅ Security Group: Allow SSH, HTTP, HTTPS
resource "aws_security_group" "mm_bookstore_secgp" {
  name        = "mm-bookstore-sg"
  description = "Allow SSH, HTTP, and HTTPS"
  vpc_id      = data.aws_vpc.mm_bookstore_vpc.id

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
}

resource "aws_key_pair" "mm_bookstore_keypair" {
  key_name   = "mm_bookstore-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxjqj5P9bj/3Uc0yOFIWGbPUt5mOz+Z5oJXoTSarCnnoZAKs2xEy6V6Vttzlv30FNuwTY+to/GLG/6yehgZN9xbVzmoyemh/pyF0p7yn1NhbXeDk0soE4jd3xYe7tl3mtChUpoN5kjJk0RUrs8PhnkT6y498IMrjwhpmexZDjMnlbX/qRdkMDFuxXl0Azr9cxp8OZH0SZVqZPwq7RReU2/OqhWVRO4QfSpwRrhjM9DdIkZ3CFRmoYUVgSDZbTf9SB/RVhX6j6RgWIajjU8cW0T16V70ms6mJcjGD2Og1bjABkjUSt9enVH5TAloIZicwPK/SlpfGgD8pfAiO9xZvNmwsQDMkAkVY0WABkVYs2OzMx/4VbiNqoCRDQTlebJjk8O0f9LmynE6xvSpa2PV+GkreY5ksjyA1Y+06aG7AR62yhxY0G53u4L2Y4Wiyo0JupYU14/Oj0Sn4VyyFc4vsmDUx5GLgcsBYn4hl14FtSO6PmbVnU3ILX+o5+jSwKr+A8ZZaq2oTFMdCRe85zuO/LSi6YCuazp1yrolXcwzmNV034s9J0Fddw0v7I9rwDVnBY/3zeIiQPTUP/Gnz+u3m8Qf3gjkquvVJMvLh7pa8CgJwPmaEZKqf1AcYBr4qgTquhwKYhCuefhCUiH0Gkub9b2vAh6DPP0evJ8HuQ2NAdrrw== kghte@BCMM172"
  tags = {
    Name = "MM Book Store Key Pair"
  }
}

resource "aws_instance" "mm-book-store" {
  ami           = "ami-0435fcf800fb5418d"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name      = aws_key_pair.mm_bookstore_keypair.key_name
  vpc_security_group_ids  = [aws_security_group.mm_bookstore_secgp.id]
  tags = {
    Name = "MM Book Store"
  }
}