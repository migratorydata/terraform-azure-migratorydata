locals {
  public_ips = azurerm_linux_virtual_machine.vm[*].public_ip_address

  count_range               = range(0, var.max_num_instances)
  migratorydata_cluster_ips = join(",", [for index in local.count_range : format("%s:8801", cidrhost(var.address_space, index + 5))])
  monitor_private_ip        = cidrhost(var.address_space, var.max_num_instances + 10)
}

data "tls_public_key" "private_key_openssh" {
  private_key_openssh = file(var.ssh_private_key)
}

resource "azurerm_availability_set" "az_set" {
  name                = "${var.namespace}_availability-set"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  count = var.num_instances

  name                  = "${var.namespace}_vm_${count.index}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.instance_type
  network_interface_ids = [var.nic_cluster[count.index]]

  availability_set_id = azurerm_availability_set.az_set.id

  os_disk {
    name                 = "${var.namespace}_disk_${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = "30"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12-daily"
    sku       = "12-backports-gen2"
    version   = "latest"
  }

  computer_name                   = "migratorydata"
  admin_username                  = var.ssh_user
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.ssh_user
    public_key = data.tls_public_key.private_key_openssh.public_key_openssh
  }

  tags = merge(var.additional_tags, {
    source = "terraform"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "monitor" {
  count = var.enable_monitoring ? 1 : 0

  name                  = "${var.namespace}_vm_monitor"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.instance_type
  network_interface_ids = [var.nic_monitor]

  availability_set_id = azurerm_availability_set.az_set.id

  os_disk {
    name                 = "${var.namespace}_disk_monitor"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = "30"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12-daily"
    sku       = "12-backports-gen2"
    version   = "latest"
  }

  computer_name                   = "migratorydata"
  admin_username                  = var.ssh_user
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.ssh_user
    public_key = data.tls_public_key.private_key_openssh.public_key_openssh
  }

  tags = merge(var.additional_tags, {
    source = "terraform"
  })

}
