terraform {
     backend "s3" {
    bucket         = "kube-ec2-backend-bucket-123"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-eks-state-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "example" {
  count         = 4
  ami           = "ami-02b8269d5e85954ef" # Ubuntu (ap-south-1)
  instance_type = "m7i-flex.large"
  key_name = "master-machine-key"

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  tags = {
    Name = "kube-ec2-${count.index + 1}"
  }
}
