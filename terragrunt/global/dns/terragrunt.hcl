terraform {
  source = "${get_parent_terragrunt_dir()}/modules/dns"
}

dependencies {
  paths = [
    "../../eu-central-1/instance",
    "../../af-south-1/instance",
    "../../ap-northeast-1/instance",
    "../../sa-east-1/instance"
  ]
}

dependency "eu_central_1" {
  config_path = "../../eu-central-1/instance"
}

dependency "af_south_1" {
  config_path = "../../af-south-1/instance"
}

dependency "ap_northeast_1" {
  config_path = "../../ap-northeast-1/instance"
}

dependency "sa_east_1" {
  config_path = "../../sa-east-1/instance"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  base_domain    = "nafn.de"

  eu_central_1_v4   = dependency.eu_central_1.outputs.instance_public_ipv4
  eu_central_1_v6   = dependency.eu_central_1.outputs.instance_public_ipv6
  af_south_1_v4     = dependency.af_south_1.outputs.instance_public_ipv4
  af_south_1_v6     = dependency.af_south_1.outputs.instance_public_ipv6
  ap_northeast_1_v4 = dependency.ap_northeast_1.outputs.instance_public_ipv4
  ap_northeast_1_v6 = dependency.ap_northeast_1.outputs.instance_public_ipv6
  sa_east_1_v4      = dependency.sa_east_1.outputs.instance_public_ipv4
  sa_east_1_v6      = dependency.sa_east_1.outputs.instance_public_ipv6
}
