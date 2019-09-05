terraform {
  required_version = ">= 0.12"
}

provider "azuread" {
  version = "~> 0.3.1"
}

provider "azurerm" {
  version = "~> 1.29.0"
}
