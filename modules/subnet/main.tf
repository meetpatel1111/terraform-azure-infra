locals {
  create_nsg = length(var.nsg_rules) > 0
  nsg_name   = replace("${var.name}-nsg", "snet-", "nsg-")
}

resource "azurerm_network_security_group" "this" {
  count               = local.create_nsg ? 1 : 0
  name                = local.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "rules" {
  for_each = local.create_nsg ? { for r in var.nsg_rules : r.name => r } : {}

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[0].name
}

resource "azurerm_subnet" "this" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.address_prefixes
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  count                     = local.create_nsg ? 1 : 0
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this[0].id
}
