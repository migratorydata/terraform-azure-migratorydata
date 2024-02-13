variable "namespace" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "additional_tags" {
  type = map(string)
}

variable "max_num_instances" {
  type = number
}

variable "cidr_block" {
  type = string
}

variable "nsg_id" {
  type = string
}