# Generate a random SSH key pair locally
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Upload the public key to AWS
resource "aws_key_pair" "ec2_key" {
  key_name   = "terraform-managed-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# Optionally save the private key to a local file
resource "local_file" "private_key" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = "${path.module}/IAM.pem"
  file_permission = "0400"
}