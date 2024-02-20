locals {
  ssh_user = "azureuser"
  cloud_provider = "Azure"
  public_ips  = azurerm_linux_virtual_machine.vm[*].public_ip_address
  
  count_range               = range(0, var.max_num_instances)
  migratorydata_cluster_ips = join(",", [for index in local.count_range : format("%s:8801", cidrhost(var.address_space, index + 5))])
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
  network_interface_ids = [var.nic_ids[count.index]]

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
  admin_username                  = local.ssh_user
  disable_password_authentication = true

  admin_ssh_key {
    username   = local.ssh_user
    public_key = data.tls_public_key.private_key_openssh.public_key_openssh
  }

  tags = merge(var.additional_tags, {
    source = "terraform"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "migratorydata_provissioner" {
  depends_on = [azurerm_linux_virtual_machine.vm]

  count = var.num_instances
  connection {
    type        = "ssh"
    host        = local.public_ips[count.index]
    user        = local.ssh_user
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install.sh"
    destination = "/home/${local.ssh_user}/install.sh"
  }

  provisioner "file" {
    source      = "${path.root}/configs/migratorydata.conf"
    destination = "/home/${local.ssh_user}/migratorydata.conf"
  }

  provisioner "file" {
    source      = "${path.root}/configs/migratorydata"
    destination = "/home/${local.ssh_user}/migratorydata"
  }

  provisioner "file" {
    source      = "${path.root}/configs/addons/kafka/consumer.properties"
    destination = "/home/${local.ssh_user}/kafka-consumer.properties"
  }

  provisioner "file" {
    source      = "${path.root}/configs/addons/kafka/producer.properties"
    destination = "/home/${local.ssh_user}/kafka-producer.properties"
  }

  provisioner "file" {
    source      = "${path.root}/configs/addons/authorization-jwt/configuration.properties"
    destination = "/home/${local.ssh_user}/authorization-jwt-configuration.properties"
  }

  provisioner "file" {
    source      = "${path.root}/configs/addons/audit-log4j/log4j2.xml"
    destination = "/home/${local.ssh_user}/audit-log4j-log4j2.xml"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /home/${local.ssh_user}/extensions/",
    ]
  }

  provisioner "file" {
    source      = "${path.root}/extensions/"
    destination = "/home/${local.ssh_user}/extensions/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${local.ssh_user}/install.sh",
      "sudo sh install.sh '${var.migratorydata_download_url}' '${local.migratorydata_cluster_ips}' '${local.cloud_provider}' '${local.ssh_user}'",
    ]
  }
}