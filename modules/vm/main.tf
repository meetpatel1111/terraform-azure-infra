locals {
  # Index sets for VMs and data disks
  vm_indexes   = toset([for i in range(var.vm_count) : i])
  disk_indexes = toset([for i in range(length(var.data_disk_sizes_gb)) : i])

  # Build a map of vm x disk pairs for creating/attaching data disks
  vm_disk_pairs = {
    for pair in flatten([
      for v in local.vm_indexes : [
        for d in local.disk_indexes : {
          key        = "${v}-${d}"
          vm_index   = v
          disk_index = d
        }
      ]
    ]) : pair.key => pair
  }
}

# Optional public IPs (one per VM)
resource "azurerm_public_ip" "this" {
  for_each            = var.public_ip ? local.vm_indexes : toset([])
  name                = "${var.name_prefix}-${each.key}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# NICs (one per VM)
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

# Linux VMs (one per index)
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

  # Ubuntu 22.04 LTS (Gen2)
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = var.tags
}

# Data disks (managed) — one per vm x disk_index
resource "azurerm_managed_disk" "data" {
  for_each             = local.vm_disk_pairs
  name                 = "${var.name_prefix}-${each.value.vm_index}-d${each.value.disk_index}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_sizes_gb[each.value.disk_index]
  tags                 = var.tags
}

# Attach data disks to VMs
resource "azurerm_virtual_machine_data_disk_attachment" "attach" {
  for_each           = local.vm_disk_pairs
  managed_disk_id    = azurerm_managed_disk.data[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.this[each.value.vm_index].id
  lun                = each.value.disk_index
  caching            = "ReadWrite"
}

# Outputs (module-level)
output "names" {
  value = [for k in local.vm_indexes : azurerm_linux_virtual_machine.this[k].name]
}

output "public_ip_addresses" {
  value = var.public_ip ? [for k in local.vm_indexes : azurerm_public_ip.this[k].ip_address] : []
}
