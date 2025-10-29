provider "azurerm" {
  features {}
}

# Generate SSH keypair in Terraform
provider "tls" {}

# Current principal/context (used for Key Vault tenant/object IDs)
data "azurerm_client_config" "current" {}
