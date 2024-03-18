output "cluster_private_ips" {
  value = azurerm_linux_virtual_machine.vm[*].private_ip_address
}

output "cluster_public_ips" {
  value = azurerm_linux_virtual_machine.vm[*].public_ip_address
}

output "monitor_public_ip" {
  value     = var.enable_monitoring ? azurerm_linux_virtual_machine.monitor[0].public_ip_address : ""
}

output "monitor_private_ip" {
  value     = var.enable_monitoring ? azurerm_linux_virtual_machine.monitor[0].private_ip_address : ""
}

output "migratorydata_cluster_members" {
  sensitive = false
  value     = local.migratorydata_cluster_ips
}
