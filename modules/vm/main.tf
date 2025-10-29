locals {
  vm_indexes = toset([for i in range(var.vm_count) : i])
}

resource "azurerm_public_ip" "this" {
  for_each            = var.public_ip ? local.vm_indexes : toset([])
  name                = "${var.name_prefix}-${each.key}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "this" {
  for_each            = local.vm_indexes
  name                = "${var.name_prefix}-${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip ? azurerm_public_ip.this[each.key].id : null
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each              = local.vm_indexes
  name                  = "${var.name_prefix}-${each.key}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.this[each.key].id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    name                 = "${var.name_prefix}-${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  dynamic "data_disk" {
    for_each = var.data_disk_sizes_gb

    content {
      caching              = "ReadWrite"
      disk_size_gb         = data_disk.value
      lun                  = index(var.data_disk_sizes_gb, data_disk.value)
      storage_account_type = "Standard_LRS"
    }
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = var.tags
}

output "names" {
  value = [for k in local.vm_indexes : azurerm_linux_virtual_machine.this[k].name]
}

output "public_ip_addresses" {
  value = var.public_ip ? [for k in local.vm_indexes : azurerm_public_ip.this[k].ip_address] : []
}
