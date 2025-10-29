variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "sku_name" {
  type    = string
  default = "standard"
}
variable "public_network_access_enabled" {
  type    = bool
  default = true
}
variable "tenant_id" {
  type = string
}
variable "tags" {
  type = map(string)
  default = {
  }
}

variable "access_policies" {
  description = "List of access policies to assign to Key Vault"
  type = list(object({
    object_id               = string
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
    storage_permissions     = optional(list(string), [])
  }))
  default = []
}
