locals {
  regional_vars = read_terragrunt_config(find_in_parent_folders("regional.hcl"))

  aws_region = local.regional_vars.locals.aws_region
}

inputs = merge(local.regional_vars.locals)

# Provider to use for all regions
# Uses region from <region>/region.tfvars file
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  assume_role {
    role_arn = "arn:aws:iam::220385822420:role/OrganizationAccountAccessRole"
  }
}
EOF
}

# Remote state to use for all regions
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "mnesia-test"

    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "mnesia-test-lock-table"
  }
}
