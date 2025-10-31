location      = "UK South"
location_code = "uks"

environment_type = "np"
environment_name = "uat"

project = "acme"

tags = {
  project = "acme"
  env     = "uat"
  owner   = "platform-team"
}

vnet = {
  address_space = ["10.20.0.0/16"]
}

subnets = {
  app = {
    address_prefixes = ["10.20.1.0/24"]
    nsg_rules        = []
  }
  data = {
    address_prefixes = ["10.20.2.0/24"]
    nsg_rules        = []
  }
}

vm = {
  count              = 1
  size               = "Standard_B1s"
  admin_username     = "azureuser"
  ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexampleReplaceWithYourKey"
  subnet_key         = "app"
  public_ip          = false
  data_disk_sizes_gb = [16]
  role_suffix        = "app"
}

databricks = {
  enabled = true
}

datafactory = {
  enabled = true
}

storage_account = {
  enabled = true
}

key_vault = {
  enabled = true
}

log_analytics = {
  enabled = true
}

app_insights = {
  enabled = true
}

container_registry = {
  enabled = true
}

sql = {
  enabled = false
}

bastion = {
  enabled = false
}
