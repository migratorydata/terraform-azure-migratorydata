output "cluster_private_ips" {
  value = azurerm_linux_virtual_machine.vm[*].private_ip_address
}

output "cluster_public_ips" {
  value = azurerm_linux_virtual_machine.vm[*].public_ip_address
}
