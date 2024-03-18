

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
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.address_space]
}

resource "azurerm_subnet_network_security_group_association" "sn_nsg_asso" {
  subnet_id                 = azurerm_subnet.sn.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_public_ip" "cluster_public_ips" {
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

resource "azurerm_public_ip" "monitor_ip" {
  count = var.enable_monitoring ? 1 : 0

  name                = "${var.namespace}_public_ip_monitor"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.additional_tags, {
    source = "terraform"
  })
}


resource "azurerm_network_interface" "nic_cluster" {
  count = var.max_num_instances

  name                = "${var.namespace}_nic_${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.namespace}_ip_configuration_${count.index}"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.address_space, count.index + 5)
    public_ip_address_id          = azurerm_public_ip.cluster_public_ips[count.index].id
  }

  tags = merge(var.additional_tags, {
    source = "terraform"
  })
}

resource "azurerm_network_interface" "nic_monitor" {
  count = var.enable_monitoring ? 1 : 0

  name                = "${var.namespace}_nic_monitor"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.namespace}_ip_configuration_monitor"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.address_space, var.max_num_instances + 10)
    public_ip_address_id          = azurerm_public_ip.monitor_ip[0].id
  }

  tags = merge(var.additional_tags, {
    source = "terraform"
  })
}
