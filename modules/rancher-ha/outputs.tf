output "masters_security_group_id" {
  value = aws_security_group.rancher.id
}

output "rancher_key_id" {
  value = module.ssh-key.aws_key_id
}

output "rancher_key" {
  value = module.ssh-key.private_key
}