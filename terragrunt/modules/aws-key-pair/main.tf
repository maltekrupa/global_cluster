resource "aws_key_pair" "login" {
  key_name   = "login"
  public_key = var.key_pair
}
