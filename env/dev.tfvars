# Region metadata
location      = "UK South"
location_code = "uks"

# Environment metadata
environment_type = "np" # non-production
environment_name = "dev"

project = "acme"

tags = {
  project = "acme"
  env     = "dev"
  owner   = "platform-team"
}

# Network
vnet = {
  address_space = ["10.10.0.0/16"]
}

subnets = {
  app = {
    address_prefixes = ["10.10.1.0/24"]
    nsg_rules = [
      {
        name                       = "allow-ssh"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
  data = {
    address_prefixes = ["10.10.2.0/24"]
    nsg_rules        = []
  }
}

# Compute
vm = {
  count              = 2
  size               = "Standard_B2s"
  admin_username     = "azureuser"
  ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexampleReplaceWithYourKey"
  subnet_key         = "app"
  public_ip          = true
  data_disk_sizes_gb = [32]
  role_suffix        = "app"
}

# Services (toggle enabled=true to deploy)
databricks = {
  enabled                       = true
  sku                           = "standard"
  public_network_access_enabled = true
}

datafactory = {
  enabled                = true
  public_network_enabled = true
}

storage_account = {
  enabled                  = true
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
}

key_vault = {
  enabled                       = true
  sku_name                      = "standard"
  public_network_access_enabled = true
}

log_analytics = {
  enabled = true
  sku     = "PerGB2018"
}

app_insights = {
  enabled          = true
  application_type = "web"
}

container_registry = {
  enabled = true
  sku     = "Basic"
}

sql = {
  enabled        = true
  server_version = "12.0" # was 'version'
  admin_login    = "sqladminuser"
  admin_password = "ChangeM3Now!" # replace securely
  db_name        = "appdb"
  db_sku_name    = "Basic"
}

bastion = {
  enabled               = true
  subnet_address_prefix = "10.10.250.0/27"
  sku                   = "Basic"
  scale_units           = 2
}
