output "rancher_nodes_ssh_key_id" {
  value = aws_key_pair.ssh.id
}

output "masters_security_group_id" {
  value = aws_security_group.rancher.id
}