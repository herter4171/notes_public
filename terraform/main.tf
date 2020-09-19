provider "aws" {
  region = "us-west-1"
}

resource "aws_eip" "wp_ip" {
  instance = aws_instance.wp_ec2.id
  vpc      = true
}

resource "aws_instance" "wp_ec2" {
  ami = "ami-0d90795fef20300c4"
  instance_type = "t2.micro"

  vpc_security_group_ids = ["${aws_security_group.wp_sg.id}"]

  key_name = "wp"

  tags = {
    Name = "wp"
  }
}