resource "aws_default_vpc" "default" {
}


resource "aws_security_group" "wp_sg" {
  name        = "wp_sg"
  description = "Security group for WordPress"
  vpc_id      = aws_default_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}/32"]
  }

  ingress {
    description = "HTTP from home"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}/32"]
  }

  tags = {
    Name = "wp_sg"
  }
}
