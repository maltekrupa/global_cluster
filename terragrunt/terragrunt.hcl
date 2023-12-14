terraform {
  extra_arguments "regional_vars" {
    commands = get_terraform_commands_that_need_vars()

    optional_var_files = [
      find_in_parent_folders("regional.tfvars"),
    ]

  }
}

# Provider to use for all regions
# Uses region from <region>/regional.tfvars file
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::220385822420:role/OrganizationAccountAccessRole"
  }

}

variable "aws_region" {
  description = "AWS region to create infrastructure in"
  type        = string
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

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "mnesia-test-lock-table"
  }
}
