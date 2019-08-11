variable "aws" {
  default = {
    region  = ""
    account = ""
    profile = ""
  }
}

variable "master_vpc_cidr" {
  description = "Master VPC CIDR"
}

variable "az_a" {
  description = "Availibility Zone A"
}

variable "az_b" {
  description = "Availibility Zone B"
}

variable "master_pub_cidr_a" {
  description = "CIDR for Public Subnet A"
}

variable "master_pub_cidr_b" {
  description = "CIDR for Public Subnet B"
}

variable "master_prv_cidr_a" {
  description = "CIDR for Private Subnet A"
}

variable "master_prv_cidr_b" {
  description = "CIDR for Private Subnet B"
}

variable "utility_vpc_cidr" {
  description = "Master VPC CIDR"
}

variable "utility_pub_cidr_a" {
  description = "CIDR for Public Subnet A"
}

variable "utility_pub_cidr_b" {
  description = "CIDR for Public Subnet B"
}

variable "utility_prv_cidr_a" {
  description = "CIDR for Private Subnet A"
}

variable "utility_prv_cidr_b" {
  description = "CIDR for Private Subnet B"
}

variable "cluster_name" {
  description = "Name of the EKS Cluster"
}

variable "environment" {
  description = "Deployment Environment"
}

variable "stack_name" {
  description = "Name of Build Stack"
}

variable "key_pair" {
  description = "Name for SSH Key Pair to use for worker nodes"
}

variable "instance_size" {
  description = "AWS Instance size for worker nodes"
}

