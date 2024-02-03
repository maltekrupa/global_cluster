terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.5.1"
}

dependencies {
  paths = ["../aws-data"]
}

dependency "aws-data" {
  config_path = "../aws-data"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "region" {
  path   = find_in_parent_folders("regional.hcl")
  expose = true
}

inputs = {
  azs  = [for v in dependency.aws-data.outputs.available_aws_availability_zones_names : v]
  cidr = include.region.locals.cidr
  name = include.region.locals.name

  private_subnets = [for k, v in dependency.aws-data.outputs.available_aws_availability_zones_names : cidrsubnet(include.region.locals.cidr, 3, k + 4)]

  public_subnets = [for k, v in dependency.aws-data.outputs.available_aws_availability_zones_names : cidrsubnet(include.region.locals.cidr, 3, k)]

  enable_nat_gateway = false
  single_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_ipv6                                   = true
  public_subnet_assign_ipv6_address_on_creation = true

  public_subnet_ipv6_prefixes  = [0, 1, 2]
  private_subnet_ipv6_prefixes = [3, 4, 5]

  tags = {
    terraform = true
  }
}
