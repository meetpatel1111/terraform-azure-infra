variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "public_network_enabled" {
  type    = bool
  default = true
}
variable "tags" {
  type = map(string)
  default = {
  }
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
}

variable "storage_account_id" {
  type    = string
  default = ""
}

variable "sql_server_id" {
  type    = string
  default = ""
}
