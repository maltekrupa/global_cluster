locals {
  aws_region = "ap-northeast-1"

  cidr = "10.0.12.0/24"
  name = "mnesia-test"

  ami_id        = "ap-northeast-1"
  instance_type = "t4g.nano"
  key_pair      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8/OFMet9Xbvx1fKbsoBTP5O9cWM+BGn93gqVGb+hCa maltekrupa"
}
