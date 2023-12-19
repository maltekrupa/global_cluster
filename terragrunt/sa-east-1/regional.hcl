locals {
  aws_region = "sa-east-1"

  cidr = "10.0.13.0/24"
  name = "mnesia-test"

  ami_id        = "ami-080bae56a56a7e169"
  instance_type = "t4g.nano"
  key_pair      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8/OFMet9Xbvx1fKbsoBTP5O9cWM+BGn93gqVGb+hCa maltekrupa"
}
