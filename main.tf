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
  intra_subnets = ["172.25.201.0/24", "172.25.202.0/24", "172.25.203.0/24"]

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

  ssh_security_group_ids = aws_instance.common-svc-bastion.vpc_security_group_ids

//  Bastion config
  bastion = true
  bastion_address = aws_instance.common-svc-bastion.public_ip
  bastion_user = "ubuntu"
  bastion_ssh_key_path = module.bastion-ssh-key.private_key_path
}

module "bastion-ssh-key" {
  source = "./modules/ssh-key"
  name = "bastion"
  output_folder = "./outputs"
}

resource "aws_security_group" "bastion-sg" {
  name = "bastion-sg"
  vpc_id = module.common-svc-vpc.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "common-svc-bastion" {
  ami = "ami-99f6aaf8"
  instance_type = "t3.small"
  key_name = module.bastion-ssh-key.aws_key_id

  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
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
