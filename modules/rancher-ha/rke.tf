resource "local_file" "rke-config" {
  filename = "${path.root}/outputs/rke-config.yml"
  content = templatefile("${path.module}/files/rancher-cluster.template.yaml", {
    private_instance_addresses = aws_instance.rancher-master.*.private_ip
    public_instance_addresses = aws_instance.rancher-master.*.public_ip
  })
}