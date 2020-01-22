provider "aws" {
  region = "us-west-1"
}

module "common-svc-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "common-svc-vpc"
  cidr = "172.25.0.0/16"

  azs = ["us-west-1a", "us-west-1b", "us-west-1c"]
  public_subnets = ["172.25.101.0/24", "172.25.102.0/24", "172.25.103.0/24"]
  private_subnets = ["172.25.1.0/24", "172.25.2.0/24", "172.25.3.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  enable_dns_support = true

  tags = {
    Owner = "Josh Wolf"
    Environment = "common services"
    Orchestrator = "Terraform"
  }
}

module "rancher-ha" {
  source = "./modules/rancher-ha"

  vpc_id = module.common-svc-vpc.vpc_id
  rancher2_master_ami_id = "ami-c52e0ea4"
  rancher2_master_subnet_ids = module.common-svc-vpc.private_subnets
}

resource "aws_instance" "common-svc-bastion" {
  ami = "ami-99f6aaf8"
  instance_type = "t3.small"
  key_name = module.rancher-ha.rancher_nodes_ssh_key_id

  vpc_security_group_ids = [module.rancher-ha.masters_security_group_id]
  subnet_id = module.common-svc-vpc.public_subnets[0]
  associate_public_ip_address = true

  root_block_device {
    volume_size = "10"
    volume_type = "gp2"
  }

  tags = {
    Name = "common-svc-bastion"
    Owner = "Josh Wolf"
    Orchestrator = "Terraform"
  }
}