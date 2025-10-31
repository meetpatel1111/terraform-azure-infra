// backend.tf
terraform {
  required_version = ">= 1.6.0"

  // Do NOT hardcode backend details here.
  // The CI pipeline supplies them via `terraform init -reconfigure -backend-config=...`
  backend "azurerm" {}
}
