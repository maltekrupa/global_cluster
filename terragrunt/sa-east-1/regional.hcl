locals {
  aws_region = "sa-east-1"

  cidr = "10.0.13.0/24"
  name = "mnesia-test"

  ami_id        = "ami-0233490806253f385"
  instance_type = "t3.nano"
  key_pair      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8/OFMet9Xbvx1fKbsoBTP5O9cWM+BGn93gqVGb+hCa"
}
