locals {
  aws_region = "eu-central-1"

  cidr = "10.0.10.0/24"
  name = "mnesia-test"

  ami_id        = "ami-00bc833b4c0a8194e"
  instance_type = "t4g.nano"
  key_pair      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8/OFMet9Xbvx1fKbsoBTP5O9cWM+BGn93gqVGb+hCa maltekrupa"
}
