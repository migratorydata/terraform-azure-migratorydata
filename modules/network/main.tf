locals {
  vnet_name     = azurerm_virtual_network.vnet.name
  public_ip_ids = [for ip in azurerm_public_ip.ip : ip.id]
  subnet_ids    = azurerm_subnet.sn.id
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.namespace}_vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]

  tags = merge(var.additional_tags, {
    source = "terraform"
  })
}

resource "azurerm_subnet" "sn" {
  name                 = "${var.namespace}_sn"
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [var.address_space]
}

resource "azurerm_subnet_network_security_group_association" "sn_nsg_asso" {
  subnet_id                 = local.subnet_ids
  network_security_group_id = var.nsg_id
}

resource "azurerm_public_ip" "ip" {
  count = var.max_num_instances

  name                = "${var.namespace}_public_ip_${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.additional_tags, {
    source = "terraform"
  })
}

resource "azurerm_network_interface" "nic" {
  count = var.max_num_instances

  name                = "${var.namespace}_nic_${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.namespace}_ip_configuration_${count.index}"
    subnet_id                     = local.subnet_ids
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.address_space, count.index + 5)
    public_ip_address_id          = local.public_ip_ids[count.index]
  }

  tags = merge(var.additional_tags, {
    source = "terraform"
  })
}