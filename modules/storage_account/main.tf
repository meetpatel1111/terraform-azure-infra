# Azure imposes naming rules; ensure lower case and <=24 chars. Caller should pass valid name.
resource "azurerm_storage_account" "this" {
  name                          = replace(lower(var.name), "-", "")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = var.account_tier
  account_replication_type      = var.account_replication_type
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = true
  tags                          = var.tags
}
