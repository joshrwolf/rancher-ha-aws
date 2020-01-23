resource "local_file" "rke-config" {
  filename = "${path.root}/outputs/rke-config.yml"
  content = templatefile("${path.module}/files/rancher-cluster.template.yaml", {
    private_instance_addresses = aws_instance.rancher-master.*.private_ip
    public_instance_addresses = aws_instance.rancher-master.*.public_ip
  })
}

//resource "null_resource" "wait_for_docker" {
//}

provider "rke" {}

resource "rke_cluster" "rancher_server" {
  cluster_name = "rancher-management"

  dynamic nodes {
    for_each = aws_instance.rancher-master
    content {
//      Private IP and Public IP are the same to force rancher to connect over private IP
      address = nodes.value.private_ip
      internal_address = nodes.value.private_ip
      user = "ubuntu"
      role = ["controlplane", "etcd", "worker"]
      ssh_key = module.ssh-key.private_key
    }
  }

  dynamic bastion_host {
    for_each = local.bastion
    content {
      address = bastion_host.value["address"]
      user = bastion_host.value["user"]
      ssh_key = bastion_host.value["ssh_key"]
    }
  }

  authentication {
    strategy = "x509"

    sans = [
      local.api_server_hostname,
      aws_lb.rancher.dns_name,
    ]
  }

  authorization {
    mode = "rbac"
  }

  addon_job_timeout = 60

  network {
    plugin = "canal"
  }

  ingress {
    provider = "nginx"
  }

//  services_etcd {
//    backup_config {
//      interval_hours = 12
//      reten
//    }
//  }

  addons = <<EOL
---
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx
  namespace: default
spec:
  containers:
  - name: my-nginx
    image: nginx
    ports:
    - containerPort: 80
EOL
}

// Get the resulting kubeconfig
resource "local_file" "kube_cluster_yaml" {
  filename = "${path.root}/outputs/kube_config_cluster.yaml"
  content = rke_cluster.rancher_server.kube_config_yaml
}

//resource "local_file" "kube_cluster_yaml" {
//  filename = "${path.root}/outputs/kube_config_cluster.yml"
//  content = templatefile("${path.module}/files/kube_config_cluster.yml", {
//    api_server_url = local.api_server_url
//    rancher_cluster
//  }
//}