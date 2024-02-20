output "loadbalancer_ip" {
  description = "The ip address for loadbalancer resource"
  value       =  module.migratorydata_lb.azurerm_lb_public_ip_address
}

output "cluster_ips" {
  description = "The public ip address for the cluster"
  value       = module.migratorydata_cluster.cluster_public_ips
}