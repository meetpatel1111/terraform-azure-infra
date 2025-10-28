resource "random_password" "sql" {
  length  = 20
  special = true
}

locals {
  admin_password = var.admin_password != "" ? var.admin_password : random_password.sql.result
}

resource "azurerm_mssql_server" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.version
  administrator_login          = var.admin_login
  administrator_login_password = local.admin_password
  minimum_tls_version          = "1.2"
  tags                         = var.tags
}

resource "azurerm_mssql_database" "this" {
  name      = var.db_name
  server_id = azurerm_mssql_server.this.id
  sku_name  = var.db_sku_name
  tags      = var.tags
}

output "server_fqdn" {
  value = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "database_id" {
  value = azurerm_mssql_database.this.id
}
