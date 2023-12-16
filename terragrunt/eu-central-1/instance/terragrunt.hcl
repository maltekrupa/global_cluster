terraform {
  source = "${get_parent_terragrunt_dir()}/modules/instance"
}

dependencies {
  paths = ["../aws-data", "../vpc", "../aws-key-pair"]
}

dependency "aws-data" {
  config_path = "../aws-data"
}

dependency "vpc" {
  config_path = "../vpc"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  key_pair      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8/OFMet9Xbvx1fKbsoBTP5O9cWM+BGn93gqVGb+hCa maltekrupa"
  ami_id        = "ami-0d31b5b837be9f5fe"
  instance_type = "t4g.nano"
  subnet_ids    = dependency.vpc.outputs.public_subnets
  vpc_id        = dependency.vpc.outputs.vpc_id
}
