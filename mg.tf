data "azurerm_subscription" "current" {
}

resource "azurerm_management_group" "prod" {
  display_name = "Prod"

  subscription_ids = []
}

resource "azurerm_management_group" "non-prod" {
  display_name = "Non-Prod"
}

resource "azurerm_management_group" "dev" {
  display_name               = "Dev"
  parent_management_group_id = "${azurerm_management_group.non-prod.id}"

  subscription_ids = [
    "2d31be49-d959-4415-bb65-8aec2c90ba62"
  ]
}

resource "azurerm_management_group" "uat" {
  display_name               = "UAT"
  parent_management_group_id = "${azurerm_management_group.non-prod.id}"

  subscription_ids = [
    // "ac13214c-b929-4677-9e90-279966b93b54"
  ]
}

resource "azurerm_management_group" "test" {
  display_name               = "Test"
  parent_management_group_id = "${azurerm_management_group.non-prod.id}"

  subscription_ids = [
    // "${data.azurerm_subscription.current.subscription_id}"
  ]
}
