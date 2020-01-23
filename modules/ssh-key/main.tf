locals {
  name = var.name
  output_folder = var.output_folder

  file_path = "${local.output_folder}/${local.name}-id_rsa"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "private_key" {
  sensitive_content = tls_private_key.ssh.private_key_pem
  filename = local.file_path

  provisioner "local-exec" {
    command = "chmod 0600 ${local.file_path}"
  }
}

resource "local_file" "public_key" {
  content = tls_private_key.ssh.public_key_openssh
  filename = "${local.file_path}.pub"
}

resource "aws_key_pair" "ssh" {
  key_name_prefix = "${local.name}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}