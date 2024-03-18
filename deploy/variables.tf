variable "region" {
  description = "(Required) The Azure Region where the Resource Group should exist"
  type        = string
  default     = "eastus"
}

variable "namespace" {
  description = "(Required) The prefix of these resources"
  type        = string
  default     = "migratorydata"
}

variable "additional_tags" {
  description = "(Optional) Additional resource tags"
  type        = map(string)
  default     = {}
}

variable "address_space" {
  description = "(Required) The address space that is used by the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "migratorydata_ingress_security_rules" {
  description = "(Required) Allow ingress port communication for MigratoryData cluster with cidr blocks"
  type        = list(any)
  default = [
    {
      name                       = "ssh"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "clients"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8800"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "inter-cluster1"
      priority                   = 102
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8801"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "inter-cluster2"
      priority                   = 103
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8802"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "inter-cluster3"
      priority                   = 104
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8083"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "inter-cluster4"
      priority                   = 105
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8804"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "prometheus"
      priority                   = 106
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "9900"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "grafana"
      priority                   = 107
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3000"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "loki"
      priority                   = 108
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3100"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "promtail"
      priority                   = 109
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "9080"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "outgoing"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

variable "num_instances" {
  description = "(Required) The count of MigratoryData nodes"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "(Required) The SKU which should be used for this Virtual Machine"
  type        = string
  default     = "Standard_F2s_v2"
}

variable "ssh_private_key" {
  description = "The private key to use when connecting to the instances."
  type        = string
}

variable "lb_port" {
  description = "(Required) Protocols to be used for lb rules. Format as [frontend_port, protocol, backend_port]"
  type        = map(any)
  default = {
    clients     = ["80", "Tcp", "8800"]
  }
}

variable "lb_probe" {
  description = "(Required) Protocols to be used for lb health probes. Format as [protocol, port, request_path]"
  type        = map(any)
  default = {
    clients = ["Tcp", "8800", ""]
  }
}

variable "max_num_instances" {
  description = "(Required) The max number of nodes in the MigratoryData cluster"
  type        = number
  default     = 5
}

variable "enable_monitoring" {
  description = "Enable monitoring for the MigratoryData cluster."
  type        = bool
  default     = false
}

variable "ssh_user" {
  description = "The user name to use when connecting to the instances."
  type        = string
  default     = "azureuser"
}
