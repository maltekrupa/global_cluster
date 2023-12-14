data "aws_availability_zones" "available" {}

data "aws_ami" "freebsd_14_arm_zfs" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FreeBSD 14.0-RELEASE-arm64 UEFI-PREFERRED base ZFS*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}
