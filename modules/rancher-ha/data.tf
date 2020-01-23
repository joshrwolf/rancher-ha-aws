data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_subnet_ids" "available" {
  vpc_id = data.aws_vpc.this.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["513442679011"]

  filter {
    name = "name"
//    values = ["ubuntu/images/*/ubuntu-bionic-18.04-*"]
    values = ["ubuntu/images/*/ubuntu-bionic-18.04-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}
