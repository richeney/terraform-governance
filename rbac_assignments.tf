/*
$ az ad group list --output table --query "[?securityEnabled].{name:displayName, description:description, objectId:objectId}"
Name                    Description                                      ObjectId
----------------------  -----------------------------------------------  ------------------------------------
Databricks Admins       Enable Databricks workspace via portal as admin  3ba57833-991b-40a8-8ce8-825a34164ebf
RBAC Admins             Allowed to create and assign roles               3defc448-c5f8-4dd0-addd-c94ea52341d3
Network Admins          Admins for the shared services                   4a1451a1-de76-45e5-ac80-e4276591c96b
Key Vault Secrets       Those with access to update Key Vault secrets    74fa1c03-aeeb-422e-bab3-7d6575407e9c
Virtual Machine Admins  Admins for the Virtual Machines                  88515d1f-e386-4a23-afcc-78b012f805f9
*/

data "azuread_group" "network_admins" {
  name = "Network Admins"
}

data "azuread_group" "virtual_machine_admins" {
  name = "Virtual Machine Admins"
}

resource "azurerm_role_assignment" "prod_network_admins" {
  principal_id         = "${data.azuread_group.network_admins.id}"
  role_definition_name = "Network Contributor"
  scope                = "${azurerm_management_group.prod.id}"
}

resource "azurerm_role_assignment" "prod_virtual_machine_admins" {
  principal_id         = "${data.azuread_group.virtual_machine_admins.id}"
  role_definition_name = "Virtual Machine Contributor"
  scope                = "${azurerm_management_group.prod.id}"
}

// Reuse the same AD groups for both prod and non-prod.  Allows for future split.

resource "azurerm_role_assignment" "non-prod_network_admins" {
  principal_id         = "${data.azuread_group.network_admins.id}"
  role_definition_name = "Network Contributor"
  scope                = "${azurerm_management_group.non-prod.id}"
}

resource "azurerm_role_assignment" "non-prod_virtual_machine_admins" {
  principal_id         = "${data.azuread_group.virtual_machine_admins.id}"
  role_definition_name = "Virtual Machine Contributor"
  scope                = "${azurerm_management_group.non-prod.id}"
}
