variable "vpc_id" {
  type = string
  description = "VPC to use for deploying, required"
}

variable "ssh_security_group_ids" {
  type = list(string)
  default = []
  description = "List of security groups to allows ssh FROM"
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

variable "bastion" {
  type = bool
  description = "whether or not to use a bastion for sshing"
  default = false
}

variable "bastion_address" {
  type = string
  description = "Bastion address"
  default = ""
}

variable "bastion_user" {
  type = string
  description = "Bastion ssh user"
  default = ""
}

variable "bastion_ssh_key_path" {
  type = string
  description = "Relative path to ssh keyfile for bastion (not the contents)"
  default = ""
}

variable "bastion_ssh_key" {
  type = string
  description = "SSH key for bastion host"
  default = ""
}