
resource "random_id" "name" {
  byte_length = 8
}

resource "azurerm_resource_group" "rg" {
  location = var.region
  name     = "${var.namespace}_${random_id.name.hex}_resource_group"
}

module "migratorydata_network_security_group" {
  source = "../modules/network_security_group"

  namespace           = var.namespace
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rules      = var.migratorydata_ingress_security_rules
  additional_tags     = var.additional_tags
}

module "migratorydata_network" {
  source = "../modules/network"

  max_num_instances   = var.max_num_instances
  namespace           = var.namespace
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
  nsg_id              = module.migratorydata_network_security_group.nsg_id
  additional_tags     = var.additional_tags
  enable_monitoring   = var.enable_monitoring
}

module "migratorydata_cluster" {
  source = "../modules/migratorydata"

  namespace           = var.namespace
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  nic_cluster         = module.migratorydata_network.nic_cluster
  nic_monitor         = module.migratorydata_network.nic_monitor
  num_instances       = var.num_instances
  instance_type       = var.instance_type
  additional_tags     = var.additional_tags
  max_num_instances   = var.max_num_instances
  address_space       = var.address_space
  ssh_private_key     = var.ssh_private_key
  ssh_user            = var.ssh_user
  enable_monitoring   = var.enable_monitoring
}

module "migratorydata_lb" {
  source              = "../modules/loadbalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  frontend_name       = "lb-ip"
  vnet_id             = module.migratorydata_network.vnet_id
  cluster_private_ips = module.migratorydata_cluster.cluster_private_ips
  lb_sku              = "Standard"
  pip_sku             = "Standard"
  name                = "migratorydata-lb"
  pip_name            = "migratorydata-public-ip"


  lb_port  = var.lb_port
  lb_probe = var.lb_probe

  additional_tags = var.additional_tags
}
