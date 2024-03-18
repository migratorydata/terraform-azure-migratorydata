output "loadbalancer_ip" {
  description = "The ip address for loadbalancer resource"
  value       =  "http://${module.migratorydata_lb.azurerm_lb_public_ip_address}"
}

output "cluster_ips" {
  description = "The public ip address for the cluster"
  value       = module.migratorydata_cluster.cluster_public_ips
}

output "monitor-public-ip-grafana-access" {
  sensitive = false
  value     = var.enable_monitoring ? "http://${module.migratorydata_cluster.monitor_public_ip}:3000" : ""
}

resource "local_file" "hosts_ini" {
  content = templatefile("${path.module}/templates/hosts_ini.tpl",
    {
      migratorydata_public_ips = module.migratorydata_cluster.cluster_public_ips
      migratorydata_private_ips = module.migratorydata_cluster.cluster_private_ips
      ssh_user                 = "${var.ssh_user}"
      ssh_private_key          = "${var.ssh_private_key}"

      enable_monitoring  = "${var.enable_monitoring}"
      monitor_public_ip  = var.enable_monitoring ? "${module.migratorydata_cluster.monitor_public_ip}" : ""
      monitor_private_ip = var.enable_monitoring ? "${module.migratorydata_cluster.monitor_private_ip}" : ""
    }
  )
  filename = "${path.module}/artifacts/hosts.ini"
}

resource "local_file" "cluster_members" {
  content = templatefile("${path.module}/templates/cluster_members.tpl",
    {
      cluster_members = module.migratorydata_cluster.migratorydata_cluster_members
    }
  )
  filename = "${path.module}/artifacts/clustermembers"
}