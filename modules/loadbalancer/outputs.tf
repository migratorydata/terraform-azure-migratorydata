
output "azurerm_lb_public_ip_address" {
  description = "the ip address for the azurerm_lb_public_ip resource"
  value       = azurerm_public_ip.azlb.ip_address
}

