locals {
  aws_region = "eu-central-1"

  cidr = "10.0.10.0/24"
  name = "mnesia-test"

  ami_id        = "ami-01883106be644655a"
  instance_type = "t3.nano"
  key_pair      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8/OFMet9Xbvx1fKbsoBTP5O9cWM+BGn93gqVGb+hCa"
}
