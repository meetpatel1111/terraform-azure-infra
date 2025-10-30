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
  description = "All VM names from the vm module(s)"
  value       = flatten([for m in module.vm : m.names])
}

output "vm_public_ips" {
  description = "All VM public IPs from the vm module(s)"
  value       = flatten([for m in module.vm : m.public_ip_addresses])
}

output "databricks_workspace_url" {
  value = try(module.databricks[0].workspace_url, null)
}

output "data_factory_name" {
  value = try(module.datafactory[0].name, null)
}

output "storage_account_name" {
  value = try(module.storage_account[0].name, null)
}

output "key_vault_name" {
  value = try(module.key_vault[0].name, null)
}

output "log_analytics_workspace_id" {
  value = try(module.log_analytics[0].id, null)
}

output "application_insights_connection_string" {
  value = try(module.app_insights[0].connection_string, null)
  sensitive   = true
}


output "acr_login_server" {
  value = try(module.acr[0].login_server, null)
}

output "sql_server_fqdn" {
  value = try(module.sql[0].server_fqdn, null)
}

output "sql_database_id" {
  value = try(module.sql[0].database_id, null)
}

output "bastion_name" {
  value = try(module.bastion[0].name, null)
}

output "vm_ssh_private_key_secret_id" {
  value = try(azurerm_key_vault_secret.vm_private_key[0].id, null)
}

output "vm_ssh_public_key_secret_id" {
  value = try(azurerm_key_vault_secret.vm_public_key[0].id, null)
}
