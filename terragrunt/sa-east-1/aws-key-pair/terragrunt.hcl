terraform {
  source = "${get_parent_terragrunt_dir()}/modules/aws-key-pair"
}

include {
  path = find_in_parent_folders()
}

inputs = {}
