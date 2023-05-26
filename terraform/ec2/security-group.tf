resource "aws_security_group" "instance_security_group" {
  name_prefix = "cloudx_"
  vpc_id      = aws_default_vpc.default.id
  description = "Security group for EC2 instances"
  
  # Allow HTTP/HTTPS access from anywhere
  ingress {
    from_port = 80
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow SSH access from your IP address only
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_default_vpc" "default" {
}