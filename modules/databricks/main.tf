resource "azurerm_databricks_workspace" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  custom_parameters {
    no_public_ip = !var.public_network_access_enabled
  }

  tags = var.tags
}
