provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name   = "${local.backend_resource_group_name}"
    storage_account_name  = "${local.backend_storage_account_name}"
    container_name        = "${local.backend_storage_container_name}"
    key                   = "terraform.tfstate"
  }
}