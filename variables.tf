variable "location" {
  description = "Azure region display name, e.g., 'UK South'"
  type        = string
}

variable "location_code" {
  description = "Short code for location used in names, e.g., 'uks' for UK South"
  type        = string
}

variable "project" {
  description = "Short project name prefix (optional tag)"
  type        = string
  default     = ""
}

variable "environment_type" {
  description = "Environment type short code (np, p, etc.)"
  type        = string
}

variable "environment_name" {
  description = "Environment name (dev, uat, prod, etc.)"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

# ---- Network + compute/data services ----

variable "vnet" {
  description = "VNet settings (address space only; name is derived)"
  type = object({
    address_space = list(string)
  })
}

variable "subnets" {
  description = "Map of subnets with address prefixes and optional NSG rules (names derived)"
  type = map(object({
    address_prefixes = list(string)
    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    })), [])
  }))
}

variable "vm" {
  description = "Linux VM configuration"
  type = object({
    count              = number
    size               = string
    admin_username     = string
    ssh_public_key     = string
    subnet_key         = string
    public_ip          = optional(bool, true)
    data_disk_sizes_gb = optional(list(number), [])
    role_suffix        = optional(string, "")
  })
}

variable "databricks" {
  description = "Azure Databricks workspace config"
  type = object({
    enabled                       = optional(bool, true)
    sku                           = optional(string, "standard")
    public_network_access_enabled = optional(bool, true)
  })
  default = {
    enabled = false
  }
}

variable "datafactory" {
  description = "Azure Data Factory config"
  type = object({
    enabled                = optional(bool, true)
    public_network_enabled = optional(bool, true)
  })
  default = {
    enabled = false
  }
}

variable "storage_account" {
  description = "Azure Storage Account config"
  type = object({
    enabled                  = optional(bool, true)
    account_tier             = optional(string, "Standard")
    account_replication_type = optional(string, "LRS")
    allow_blob_public_access = optional(bool, false)
  })
  default = {
    enabled = false
  }
}

variable "key_vault" {
  description = "Azure Key Vault config"
  type = object({
    enabled                       = optional(bool, true)
    sku_name                      = optional(string, "standard")
    public_network_access_enabled = optional(bool, true)
  })
  default = {
    enabled = false
  }
}

variable "log_analytics" {
  description = "Log Analytics Workspace"
  type = object({
    enabled = optional(bool, true)
    sku     = optional(string, "PerGB2018")
  })
  default = {
    enabled = false
  }
}

variable "app_insights" {
  description = "Application Insights (Classic)"
  type = object({
    enabled          = optional(bool, true)
    application_type = optional(string, "web")
  })
  default = {
    enabled = false
  }
}

variable "container_registry" {
  description = "Azure Container Registry"
  type = object({
    enabled = optional(bool, true)
    sku     = optional(string, "Basic")
  })
  default = {
    enabled = false
  }
}

variable "sql" {
  description = "Azure SQL Server and one DB"
  type = object({
    enabled        = optional(bool, true)
    version        = optional(string, "12.0")
    admin_login    = optional(string, "sqladminuser")
    admin_password = optional(string, "")
    db_name        = optional(string, "appdb")
    db_sku_name    = optional(string, "Basic")
  })
  default = {
    enabled = false
  }
}

variable "bastion" {
  description = "Azure Bastion (deployed into AzureBastionSubnet)"
  type = object({
    enabled               = optional(bool, true)
    subnet_address_prefix = optional(string, "10.10.250.0/27")
    sku                   = optional(string, "Basic")
    scale_units           = optional(number, 2)
  })
  default = {
    enabled = false
  }
}
