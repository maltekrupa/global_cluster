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
  subnet_ids    = dependency.vpc.outputs.public_subnets
  vpc_id        = dependency.vpc.outputs.vpc_id
}
