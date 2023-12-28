packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "freebsd" {
  ami_name    = "freebsd-template-${formatdate("YYYY-MM-DD-hhmmss", timestamp())}"
  ami_regions = [
    "af-south-1",
    "ap-northeast-1",
    "sa-east-1"
  ]

  instance_type               = "t3.large"
  profile                     = "test"
  region                      = "eu-central-1"

  ssh_username = "ec2-user"
  ssh_timeout  = "15m"

  source_ami_filter {
    filters = {
      name                = "FreeBSD 14.0-RELEASE-amd64 UEFI-PREFERRED base ZFS*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["679593333241"]
  }
}

build {
  sources = ["source.amazon-ebs.freebsd"]

  provisioner "shell" {
    inline = [
      "echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8/OFMet9Xbvx1fKbsoBTP5O9cWM+BGn93gqVGb+hCa > .ssh/authorized_keys"
    ]
  }
}
