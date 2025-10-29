variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

# Deprecated: kept for backward compatibility. The module forces public_network_enabled = false.
variable "public_network_enabled" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "managed_virtual_network_enabled" {
  type    = bool
  default = true
}

variable "enable_private_endpoints" {
  type    = bool
  default = true
}

variable "key_vault_id" {
  type    = string
  default = ""
  validation {
    condition     = var.enable_private_endpoints ? length(trim(var.key_vault_id)) > 0 : true
    error_message = "When enable_private_endpoints=true, key_vault_id must be provided."
  }
}

variable "storage_account_id" {
  type    = string
  default = ""
  validation {
    condition     = var.enable_private_endpoints ? length(trim(var.storage_account_id)) > 0 : true
    error_message = "When enable_private_endpoints=true, storage_account_id must be provided."
  }
}

variable "sql_server_id" {
  type    = string
  default = ""
  validation {
    condition     = var.enable_private_endpoints ? length(trim(var.sql_server_id)) > 0 : true
    error_message = "When enable_private_endpoints=true, sql_server_id must be provided."
  }
}
