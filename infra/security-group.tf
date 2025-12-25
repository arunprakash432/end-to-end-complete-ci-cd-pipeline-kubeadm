resource "aws_security_group" "ec2_sg" {
  name        = "ec2-basic-sg"
  description = "Basic security group for EC2 instances"

  ingress {
    description = "All Traffic" # This rule allows all inbound traffic, only for testing purposes
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-basic-sg"
  }
}
