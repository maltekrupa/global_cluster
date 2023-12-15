output "instance_public_ipv4" {
  value = aws_instance.freebsd.public_ip
}

output "instance_public_ipv6" {
  value = aws_instance.freebsd.ipv6_addresses
}
