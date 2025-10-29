resource "azurerm_data_factory" "this" {
  identity { 
    type = "SystemAssigned" 
  }
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

# -------------------------------
# Managed Private Endpoints (MPEs)
# -------------------------------

# Key Vault
resource "azurerm_data_factory_managed_private_endpoint" "kv" {
  count              = var.enable_private_endpoints ? 1 : 0
  name               = "kv-pe"
  data_factory_id    = azurerm_data_factory.this.id
  target_resource_id = var.key_vault_id
  subresource_name   = "vault"

  lifecycle {
    precondition {
      condition     = var.enable_private_endpoints ? (try(var.key_vault_id, "") != "") : true
      error_message = "kv: var.key_vault_id must be provided when enable_private_endpoints = true."
    }
  }
}

# Storage (Blob)
resource "azurerm_data_factory_managed_private_endpoint" "storage_blob" {
  count              = var.enable_private_endpoints ? 1 : 0
  name               = "sa-blob-pe"
  data_factory_id    = azurerm_data_factory.this.id
  target_resource_id = var.storage_account_id
  subresource_name   = "blob"

  lifecycle {
    precondition {
      condition     = var.enable_private_endpoints ? (try(var.storage_account_id, "") != "") : true
      error_message = "storage_blob: var.storage_account_id must be provided when enable_private_endpoints = true."
    }
  }
}

# SQL Server
resource "azurerm_data_factory_managed_private_endpoint" "sql_server" {
  count              = var.enable_private_endpoints ? 1 : 0
  name               = "sql-pe"
  data_factory_id    = azurerm_data_factory.this.id
  target_resource_id = var.sql_server_id
  subresource_name   = "sqlServer"

  lifecycle {
    precondition {
      condition     = var.enable_private_endpoints ? (try(var.sql_server_id, "") != "") : true
      error_message = "sql_server: var.sql_server_id must be provided when enable_private_endpoints = true."
    }
  }
}
