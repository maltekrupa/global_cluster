output "available_aws_availability_zones_names" {
  description = "A list of the Availability Zone names available to the account"
  value       = data.aws_availability_zones.available.names
}

output "available_aws_availability_zones_zone_ids" {
  description = "A list of the Availability Zone IDs available to the account"
  value       = data.aws_availability_zones.available.zone_ids
}

output "freebsd_14_arm_aws_ami_id" {
  description = "AMI ID of FreeBSD 14/arm64 with ZFS"
  value       = data.aws_ami.freebsd_14_arm_zfs.id
}
