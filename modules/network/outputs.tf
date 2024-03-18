output "nic_cluster" {
  description = "the id of the network interface"
  value       = [for nic in azurerm_network_interface.nic_cluster : nic.id]
}

output "nic_monitor" {
  description = "the id of the network interface for monitoring"
  value       = azurerm_network_interface.nic_monitor[0].id
}

output "subnet_ids" {
  description = "the ids of all subnet"
  value       = azurerm_subnet.sn.id
}

output "vnet_id" {
  description = "the id of virtual network"
  value       = resource.azurerm_virtual_network.vnet.id

}