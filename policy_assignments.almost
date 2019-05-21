resource "azurerm_policy_assignment" "deny" {
  name                 = "uat_deny"
  scope                = azurerm_management_group.uat.id
  policy_definition_id = azurerm_policy_set_definition.deny.id
  description          = "Deny policy initiative assignment for UAT subscriptions(s) - location and SKUs."
  display_name         = "Default deny initiative for UAT"

  parameters = <<PARAMETERS
{
  "regions": {
    "value": [ "West Europe", "North Europe" ]
  }
}
PARAMETERS
}

resource "azurerm_policy_assignment" "tags" {
  name                 = "uat_tags"
  scope                = azurerm_management_group.uat.id
  policy_definition_id = azurerm_policy_set_definition.tags.id
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
