variable "vpc_id" {
  description = "VPC id for new agents"
  default     = ""
}

variable "subnet_id" {
  type = "list"
  description = "Subnet for new agent"
}

variable "admin_ips" {
  type = "list"
  description = "List of admin IP adresses"
}

variable "num_winagent" {
  description = "Number of windows agents"
  default = "0"
}

variable "cluster_name" {
  description = "Name of cluster where we will connecting new agnets"
  default = ""
}

variable "expiration" {
  description = "Time to live the agents"
  default = "24h"
}

variable "owner" {
  description = "Who owned the agents"
  default = ""
}

variable "aws_key_name" {
  description = "ssh key for access to EC2 servers"
  default = ""
}

variable "security_group_admin" {
  description = "List of security groups"
  default = ""
}

variable "security_group_internal" {
  description = "List of security groups"
  default = ""
}

variable "bootstrap_public_ip" {
  description = "Parameters of bootstrap node"
}

variable "bootstrap_private_ip" {
  description = "Parameters of bootstrap node"
}

variable "bootstrap_os_user" {
  description = "Parameters of bootstrap node"
}

variable "ssh_private_key_file" {
  description = "Private ssh key"
  default = ""
}

variable "masters_private_ips" {
  type = "list"
  description = ""
}