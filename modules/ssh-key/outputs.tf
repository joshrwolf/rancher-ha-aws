output "aws_key_id" {
  value = aws_key_pair.ssh.id
}

output "private_key" {
  value = tls_private_key.ssh.private_key_pem
}

output "private_key_path" {
  value = local.file_path
}

output "public_key_path" {
  value = "${local.file_path}.pub"
}