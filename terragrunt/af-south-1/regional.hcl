locals {
  aws_region = "af-south-1"

  cidr = "10.0.11.0/24"
  name = "mnesia-test"

  ami_id        = "ami-028e57764b0ddc64d"
  instance_type = "t4g.nano"
  key_pair      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8/OFMet9Xbvx1fKbsoBTP5O9cWM+BGn93gqVGb+hCa maltekrupa"
}
