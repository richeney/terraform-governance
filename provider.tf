terraform {
  required_version = ">= 0.12"
}

provider "azuread" {
  version = "~> 0.3.1"
}

provider "azurerm" {
  version = "~> 2.7.0"
  features {}
}
