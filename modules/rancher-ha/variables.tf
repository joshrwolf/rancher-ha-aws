variable "vpc_id" {
  type = string
  description = "VPC to use for deploying, required"
}

variable "rancher2_master_subnet_ids" {
  type = list(string)
  description = "Subnets to deploy master nodes into"
  default = []
}

variable "rancher2_master_ami_id" {
  type = string
  description = "Override ami-id for master nodes"
  default = ""
}

variable "creds_output_path" {
  type = string
  description = "Where to put ssh keys and other sensitive data created on run"
  default = "./outputs/"
}

