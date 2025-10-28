output "resource_group_name" {
  value = module.resource_group.name
}

output "vnet_name" {
  value = module.vnet.name
}

output "subnet_names" {
  value = { for k, s in module.subnets : k => s.name
  }
}

output "vm_names" {
  value = module.vm.names
}

output "vm_public_ips" {
  value = module.vm.public_ip_addresses
}

output "databricks_workspace_url" {
  value = try(module.databricks.workspace_url, null)
}

output "data_factory_name" {
  value = try(module.datafactory.name, null)
}

output "storage_account_name" {
  value = try(module.storage_account.name, null)
}

output "key_vault_name" {
  value = try(module.key_vault.name, null)
}

output "log_analytics_workspace_id" {
  value = try(module.log_analytics.id, null)
}

output "application_insights_connection_string" {
  value = try(module.app_insights.connection_string, null)
}

output "acr_login_server" {
  value = try(module.acr.login_server, null)
}

output "sql_server_fqdn" {
  value = try(module.sql.server_fqdn, null)
}

output "sql_database_id" {
  value = try(module.sql.database_id, null)
}

output "bastion_name" {
  value = try(module.bastion.name, null)
}
