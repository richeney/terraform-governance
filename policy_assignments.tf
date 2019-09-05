resource "azurerm_policy_assignment" "deny" {
  name                 = "non-prod_deny"
  scope                = "${azurerm_management_group.non-prod.id}"
  policy_definition_id = "${azurerm_policy_set_definition.deny.id}"
  description          = "Deny policy initiative assignment for UAT subscriptions(s) - location and SKUs."
  display_name         = "Default deny initiative for Non-Prod"

  parameters = <<PARAMETERS
{
  "regions": {
    "value": [ "UK South", "UK West" ]
  }
}
PARAMETERS
}

resource "azurerm_policy_assignment" "dev_tags" {
  name                 = "dev_tags"
  scope                = "${azurerm_management_group.dev.id}"
  policy_definition_id = "${azurerm_policy_set_definition.tags.id}"
  description          = "Policy Initiative Assignment for default tagging"
  display_name         = "Default tagging initiative for Dev"

  parameters = <<PARAMETERS
{
  "Environment": {
    "value": "Dev"
  }
}
PARAMETERS
}

resource "azurerm_policy_assignment" "test_tags" {
  name                 = "test_tags"
  scope                = "${azurerm_management_group.test.id}"
  policy_definition_id = "${azurerm_policy_set_definition.tags.id}"
  description          = "Policy Initiative Assignment for default tagging"
  display_name         = "Default tagging initiative for Test"

  parameters = <<PARAMETERS
{
  "Environment": {
    "value": "Test"
  }
}
PARAMETERS
}

resource "azurerm_policy_assignment" "uat_tags" {
  name                 = "uat_tags"
  scope                = "${azurerm_management_group.uat.id}"
  policy_definition_id = "${azurerm_policy_set_definition.tags.id}"
  description          = "Policy Initiative Assignment for default tagging"
  display_name         = "Default tagging initiative for UAT"

  parameters = <<PARAMETERS
{
  "Environment": {
    "value": "UAT"
  }
}
PARAMETERS
}

resource "azurerm_policy_assignment" "prod_tags" {
  name                 = "prod_tags"
  scope                = "${azurerm_management_group.prod.id}"
  policy_definition_id = "${azurerm_policy_set_definition.tags.id}"
  description          = "Policy Initiative Assignment for default tagging"
  display_name         = "Default tagging initiative for Prod"

  parameters = <<PARAMETERS
{
  "Environment": {
    "value": "Prod"
  }
}
PARAMETERS
}
