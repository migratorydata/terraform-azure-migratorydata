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

variable "nic_ids" {
  type = list(any)
}

variable "num_instances" {
  type = number
}

variable "instance_type" {
  type = string
}

variable "migratorydata_download_url" {
  type = string
}

variable "max_num_instances" {
  type = number
}

variable "cidr_block" {
  type = string
}