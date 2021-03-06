data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {}

resource "azurerm_management_group" "prod" {
  display_name = "Prod"

  subscription_ids = []
}

resource "azurerm_management_group" "non-prod" {
  display_name = "Non-Prod"
}

resource "azurerm_management_group" "dev" {
  display_name               = "Dev"
  parent_management_group_id = azurerm_management_group.non-prod.id

  lifecycle {
    ignore_changes = [
      subscription_ids
    ]
  }

  subscription_ids = [
    // "2d31be49-d959-4415-bb65-8aec2c90ba62"
  ]
}

resource "azurerm_management_group" "uat" {
  display_name               = "UAT"
  parent_management_group_id = azurerm_management_group.non-prod.id

  lifecycle {
    ignore_changes = [
      subscription_ids
    ]
  }

  subscription_ids = []
}

resource "azurerm_management_group" "test" {
  display_name               = "Test"
  parent_management_group_id = azurerm_management_group.non-prod.id

  lifecycle {
    ignore_changes = [
      subscription_ids
    ]
  }

  subscription_ids = [
    // "${data.azurerm_subscription.current.subscription_id}"
  ]
}
