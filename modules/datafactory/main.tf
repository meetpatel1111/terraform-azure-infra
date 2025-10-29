resource "azurerm_data_factory" "this" {
  identity { type = "SystemAssigned" }
  managed_virtual_network_enabled = var.managed_virtual_network_enabled
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  public_network_enabled          = false
  tags                            = var.tags
}


# Managed Azure IR within ADF managed VNet
resource "azurerm_data_factory_integration_runtime_azure" "managed_ir" {
  name                    = "AutoResolveIntegrationRuntime"
  data_factory_id         = azurerm_data_factory.this.id
  location                = var.location
  virtual_network_enabled = true
}

# Managed Private Endpoints (inside ADF module)

# Key Vault
resource "azurerm_data_factory_managed_private_endpoint" "kv" {
  count              = var.enable_private_endpoints && var.key_vault_id != "" ? 1 : 0
  name               = "kv-pe"
  data_factory_id    = azurerm_data_factory.this.id
  target_resource_id = var.key_vault_id
  subresource_name   = "vault"
}

# Storage (Blob)
resource "azurerm_data_factory_managed_private_endpoint" "storage_blob" {
  count              = var.enable_private_endpoints && var.storage_account_id != "" ? 1 : 0
  name               = "sa-blob-pe"
  data_factory_id    = azurerm_data_factory.this.id
  target_resource_id = var.storage_account_id
  subresource_name   = "blob"
}

# SQL Server
resource "azurerm_data_factory_managed_private_endpoint" "sql_server" {
  count              = var.enable_private_endpoints && var.sql_server_id != "" ? 1 : 0
  name               = "sql-pe"
  data_factory_id    = azurerm_data_factory.this.id
  target_resource_id = var.sql_server_id
  subresource_name   = "sqlServer"
}
