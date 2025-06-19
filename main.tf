terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "ap-southeast-1"
  access_key = ""
  secret_key = ""
}

resource "aws_instance" "stupid-server" {
  ami           = "ami-0435fcf800fb5418d"
  instance_type = "t2.micro"
  tags = {
    Name = "My stupid server"
  }
}