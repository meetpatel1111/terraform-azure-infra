# =============
# Resource Group
# =============
module "resource_group" {
  source   = "./modules/resource_group"
  name     = local.names.rg
  location = var.location
  tags     = merge(var.tags, { env = var.environment_name })
}

# =====
# VNet
# =====
module "vnet" {
  source              = "./modules/vnet"
  name                = local.names.vnet
  resource_group_name = module.resource_group.name
  location            = var.location
  address_space       = var.vnet.address_space
  tags                = var.tags
}

# ====================
# Subnets (+ inline NSG)
# Names: snet-<key>-<envtype>-<loc>-<env>
# ====================
module "subnets" {
  source              = "./modules/subnet"
  for_each            = var.subnets
  vnet_name           = module.vnet.name
  resource_group_name = module.resource_group.name
  location            = var.location
  name                = "${local.svc.snet}-${each.key}-${var.environment_type}-${var.location_code}-${var.environment_name}"
  address_prefixes    = each.value.address_prefixes
  nsg_rules           = each.value.nsg_rules
  tags                = var.tags
}

# ------------
# Linux VMs
# Name prefix: vm[-<role_suffix>]-<envtype>-<loc>-<env>
# ------------
locals {
  vm_subnet_id = module.subnets[var.vm.subnet_key].id

  vm_prefix = join(
    "-",
    compact([
      local.svc.vm,
      var.vm.role_suffix != "" ? var.vm.role_suffix : null,
      var.environment_type,
      var.location_code,
      var.environment_name
    ])
  )
}

# Auto-generated SSH keypair for VMs
resource "tls_private_key" "vm" {
  algorithm = "ED25519"
}

module "vm" {
  source         = "./modules/vm"
  count          = var.vm.count > 0 ? 1 : 0
  name_prefix    = local.vm_prefix
  vm_count       = var.vm.count
  size           = var.vm.size
  admin_username = var.vm.admin_username
  # Use generated OpenSSH public key
  ssh_public_key      = tls_private_key.vm.public_key_openssh
  subnet_id           = local.vm_subnet_id
  public_ip           = try(var.vm.public_ip, true)
  data_disk_sizes_gb  = try(var.vm.data_disk_sizes_gb, [])
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
}

# -------------------
# Databricks Workspace
# -------------------
module "databricks" {
  source                        = "./modules/databricks"
  count                         = var.databricks.enabled ? 1 : 0
  name                          = local.names.adb
  resource_group_name           = module.resource_group.name
  location                      = var.location
  sku                           = try(var.databricks.sku, "standard")
  public_network_access_enabled = try(var.databricks.public_network_access_enabled, true)
  tags                          = var.tags
}

# ----------------
# Azure Data Factory
# ----------------
module "datafactory" {
  source                          = "./modules/datafactory"
  count                           = var.datafactory.enabled ? 1 : 0
  name                            = local.names.adf
  resource_group_name             = module.resource_group.name
  location                        = var.location
  managed_virtual_network_enabled = true
  public_network_enabled          = false
  key_vault_id                    = module.key_vault[0].id
  storage_account_id              = module.storage_account[0].id
  sql_server_id                   = module.sql[0].server_id
  tags                            = var.tags
}

# ------------------
# Storage Account (st-...)
# ------------------
module "storage_account" {
  source                   = "./modules/storage_account"
  count                    = var.storage_account.enabled ? 1 : 0
  name                     = local.names.sa
  resource_group_name      = module.resource_group.name
  location                 = var.location
  account_tier             = try(var.storage_account.account_tier, "Standard")
  account_replication_type = try(var.storage_account.account_replication_type, "LRS")
  allow_blob_public_access = try(var.storage_account.allow_blob_public_access, false)
  tags                     = var.tags
}

# -------------
# Key Vault (kv-...) — module without inline access_policies
# -------------
module "key_vault" {
  source                        = "./modules/key_vault"
  count                         = var.key_vault.enabled ? 1 : 0
  name                          = local.names.kv
  resource_group_name           = module.resource_group.name
  location                      = var.location
  sku_name                      = try(var.key_vault.sku_name, "standard")
  public_network_access_enabled = try(var.key_vault.public_network_access_enabled, true)
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  tags                          = var.tags
}

# Grant current principal secret permissions on the vault (if using access policies)
resource "azurerm_key_vault_access_policy" "current" {
  count        = var.key_vault.enabled ? 1 : 0
  key_vault_id = module.key_vault[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"
  ]
}

# Store generated keys in Key Vault (only when KV + VM are enabled)
resource "azurerm_key_vault_secret" "vm_private_key" {
  count        = var.key_vault.enabled && var.vm.count > 0 ? 1 : 0
  name         = "vm-ssh-private-key"
  value        = tls_private_key.vm.private_key_pem
  content_type = "application/x-pem-file"
  key_vault_id = module.key_vault[0].id
  depends_on   = [azurerm_key_vault_access_policy.current]
}

resource "azurerm_key_vault_secret" "vm_public_key" {
  count        = var.key_vault.enabled && var.vm.count > 0 ? 1 : 0
  name         = "vm-ssh-public-key"
  value        = tls_private_key.vm.public_key_openssh
  content_type = "text/plain"
  key_vault_id = module.key_vault[0].id
  depends_on   = [azurerm_key_vault_access_policy.current]
}

# ----------------------
# Log Analytics + AppInsights
# ----------------------
module "log_analytics" {
  source              = "./modules/log_analytics"
  count               = var.log_analytics.enabled ? 1 : 0
  name                = local.names.law
  resource_group_name = module.resource_group.name
  location            = var.location
  sku                 = try(var.log_analytics.sku, "PerGB2018")
  tags                = var.tags
}

module "app_insights" {
  source                = "./modules/app_insights"
  count                 = var.app_insights.enabled ? 1 : 0
  name                  = local.names.appi
  resource_group_name   = module.resource_group.name
  location              = var.location
  application_type      = try(var.app_insights.application_type, "web")
  workspace_resource_id = try(module.log_analytics[0].id, null)
  tags                  = var.tags
}

# ----------------------
# Container Registry (ACR)
# ----------------------
module "acr" {
  source              = "./modules/acr"
  count               = var.container_registry.enabled ? 1 : 0
  name                = local.names.acr
  resource_group_name = module.resource_group.name
  location            = var.location
  sku                 = try(var.container_registry.sku, "Basic")
  tags                = var.tags
}

# ----------------------
# Azure SQL (Server + DB)
# ----------------------
module "sql" {
  source              = "./modules/sql"
  count               = var.sql.enabled ? 1 : 0
  name                = local.names.sql
  resource_group_name = module.resource_group.name
  location            = var.location
  server_version      = try(var.sql.server_version, "12.0")
  admin_login         = try(var.sql.admin_login, "sqladminuser")
  admin_password      = try(var.sql.admin_password, "")
  db_name             = try(var.sql.db_name, "appdb")
  db_sku_name         = try(var.sql.db_sku_name, "Basic")
  tags                = var.tags
}

# ----------------------
# Bastion (creates AzureBastionSubnet internally)
# ----------------------
module "bastion" {
  source                = "./modules/bastion"
  count                 = var.bastion.enabled ? 1 : 0
  name                  = local.names.bast
  resource_group_name   = module.resource_group.name
  location              = var.location
  vnet_name             = module.vnet.name
  subnet_address_prefix = try(var.bastion.subnet_address_prefix, "10.10.250.0/27")
  sku                   = try(var.bastion.sku, "Basic")
  scale_units           = try(var.bastion.scale_units, 2)
  tags                  = var.tags
}
