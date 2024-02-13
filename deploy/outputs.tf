output "loadbalancer_ip" {
  description = "The ip address for loadbalancer resource"
  value       =  module.migratorydata_lb.azurerm_lb_public_ip_address
}