resource "aws_key_pair" "login" {
  key_name   = "login"
  public_key = var.key_pair
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "ICMP"
    from_port        = 0
    to_port          = 0
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "freebsd" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.login.key_name
  subnet_id     = element(var.subnet_ids, 0)

  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
}
