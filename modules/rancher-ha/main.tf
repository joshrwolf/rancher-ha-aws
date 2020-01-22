provider "aws" {
  region = "us-west-1"
}

locals {
  name = "joshwolf"
  vpc_id = var.vpc_id
  ami_id = var.rancher2_master_ami_id == "" ? data.aws_ami.ubuntu.image_id : var.rancher2_master_ami_id
  instance_type = "m5.large"

  rancher2_master_tags = {}
  master_node_count = 3
  master_worker_count = 3
  rancher2_master_subnet_ids = length(var.rancher2_master_subnet_ids) > 0 ? var.rancher2_master_subnet_ids : data.aws_subnet_ids.available.ids

//  Just use the rancher master existing subnet ids for lb
  aws_elb_subnet_ids = local.rancher2_master_subnet_ids
//  aws_elb_subnet_ids = length(var.aws_elb_subnet_ids) > 0 ? var.aws_elb_subnet_ids : data.aws_subnet_ids.available.ids
}