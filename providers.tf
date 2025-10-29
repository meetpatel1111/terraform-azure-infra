provider "azurerm" {
  features {}
}

provider "tls" {}

data "azurerm_client_config" "current" {}
